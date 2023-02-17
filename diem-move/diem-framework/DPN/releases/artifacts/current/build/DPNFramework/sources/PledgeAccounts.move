///////////////////////////////////////////////////////////////////////////
// 0L Module
// Pledge Accounts
///////////////////////////////////////////////////////////////////////////
// How does a decentralized project gather funds, without the authority of a foundation? 
// 0L presents two options to builders: PledgeAccounts and DonorDirectedAccounts. Pledge accounts are coins which are the user's property 
// but use strong coordination of smart contracts to guarantee funding.
// DonorDirectedAccounts are coins which are the beneficiary's property, but have strong coordination to refund, and veto account transactions.
// Regarding DonorDirectedAccounts, there is a subtype called CommunityWallets which have special properties: they can (permissionlessly) receive matching funds from the Burn Match of user/validator rewards. These have voluntary restrictions such as funds can only be transferred to slow wallet (to prevent gaming of the matching funds ), and have a purpose designed multisig n-of-m authorization for transactions.

// each of these accounts have a unique purpose, and are designed to be used in a specific way. DonorDirected accounts will be best suited to programs that have a lot of human management involved: evaluating the merit of proposals for spending. The donors need agility to spend the funds, hence they are in the user's proprty.

// PledgeAccounts are best suited for automated contributions. For charing fees algorithmically. It's also important for cases where pooled funding may not be practical or regulatorily advisable.

// The hard problem of coordination is how to get a group of people to
// fund common interest, when each person in the group
// can only pledge a small amount, and has no guarantee that the remainder 
// will be filled. And once pledged there is always the risk that the
// user will renege on the pledge, this is a classic prisoner's dilemma.
// As such not even the first funds of most committed members will arrive
// because it's known that the project is doomed. This is the tragedy of
// the commons. 

// Smart contracts may help, if they can be trusted. Thus the service needs
// to be provided with the highest level of shared security (no one can hold
// the key to the funds.
// Pledge Accounts are a service that the chain provides.
// The funds never leave the user's possession. They are placed in Pledged Accounts, a segregated sub-account on the user's account. 
// The pledged accounts are project-specific.
// Projects which raise through pledges, can lose the pledge though a vote 
// of the pledgers. There are no funds to return, instead the earmarked funds are no longer authorized for withdrawal, i.e. they return to user accounts.

// For voting we can only use the value pledged at the time of the vote,
// same for the purposes of revoking. 
// Note that there's a known policy issue here, which is not addresses for
// now. A "chip bully" can add funds to the pledge, and then vote to revoke, knowing that they can get over the threshold. The current
// mitigation is to only allow Unlocked coins, which levels the playing field.
///////////////////////////////////////////////////////////////////////////

address DiemFramework{
    module PledgeAccounts{
        use Std::Vector;
        use Std::Signer;
        use Std::Errors;
        use Std::Option;
        use DiemFramework::DiemConfig;
        use DiemFramework::Debug::print;
        use DiemFramework::Testnet;


        const ENO_BENEFICIARY_POLICY: u64 = 150001;
        const ENON_ZERO_BALANCE: u64 = 150002;
        const ENO_PLEDGE_INIT: u64 = 150003;

        struct MyPledges has key {
          list: vector<PledgeAccount>
        }

        // A Pledge Account is a sub-account on a user's account.
        struct PledgeAccount has key, store, copy, drop {
            // project_id: vector<u8>, // a string that identifies the project
            address_of_beneficiary: address, // the address of the project, also where the BeneficiaryPolicy is stored for reference.
            amount: u64,
            epoch_of_last_deposit: u64,
            lifetime_pledged: u64,
            lifetime_withdrawn: u64
        }

        // A struct with some rules established by the beneficiary
        // that is agreed on, upon pledge.
        // IMPORTANT: this struct cannot be modified after a pledge is made.

        struct BeneficiaryPolicy has key, store, copy {
          purpose: vector<u8>, // a string that describes the purpose of the pledge
          vote_threshold_to_revoke: u64, // Percent in two digits, no decimals: the threshold of votes, weighted by pledged balance, needed to dissolve, and revoke the pledge. 
          burn_funds_on_revoke: bool, // neither the beneficiary not the pledger can get the funds back, they are burned. Changes the game theory, may be necessary to in certain cases to prevent attacks in high stakes projects.
          total_pledged: u64, // The amount available to withdraw
          lifetime_pledged: u64, // Of all users
          lifetime_withdrawn: u64, // Of all users
          pledgers: vector<address>,
          // TODO: use proper table data structure. This is oldschool Libra pattern.
          table_votes_to_revoke: vector<u64>, // recalculate on each vote to revoke.
          table_revoking_electors: vector<address>, // the list of electors who have voted to revoke. They can also cancel their vote.
          total_revoke_vote: u64, // for informational purposes,
          revoked: bool, // for historical record keeping.
        }

        // beneficiary publishes a policy to their account.
        // NOTE: It cannot be modified after a first pledge is made!.
        public fun publish_beneficiary_policy(
          account: &signer, 
          purpose: vector<u8>, 
          vote_threshold_to_revoke: u64, 
          burn_funds_on_revoke: bool
        ) acquires BeneficiaryPolicy {
            if (!exists<BeneficiaryPolicy>(Signer::address_of(account))) {
                let beneficiary_policy = BeneficiaryPolicy {
                    purpose: purpose,
                    vote_threshold_to_revoke: vote_threshold_to_revoke,
                    burn_funds_on_revoke: burn_funds_on_revoke,
                    total_pledged: 0,
                    lifetime_pledged: 0,
                    lifetime_withdrawn: 0,
                    pledgers: Vector::empty(),
                    table_votes_to_revoke: Vector::empty(),
                    table_revoking_electors: Vector::empty(),
                    total_revoke_vote: 0,
                    revoked: false
                    
                };
                move_to(account, beneficiary_policy);
            } else {
              // allow the beneficiary to write drafts, and modify the policy, as long as no pledge has been made.
              let b = borrow_global_mut<BeneficiaryPolicy>(Signer::address_of(account));
              if (Vector::length(&b.pledgers) == 0) {
                b.purpose = purpose;
                b.vote_threshold_to_revoke = vote_threshold_to_revoke;
                b.burn_funds_on_revoke = burn_funds_on_revoke;
              } 
            }
            // no changes can be made if a pledge has been made.
        }

        // Initialize a list of pledges on a user's account
        public fun maybe_initialize_my_pledges(account: &signer) {
            if (!exists<MyPledges>(Signer::address_of(account))) {
                let my_pledges = MyPledges { list: Vector::empty() };
                move_to(account, my_pledges);
            }
        }

        // Create a new pledge account on a user's list of pledges
        public fun create_pledge_account(
          sig: &signer,
          // project_id: vector<u8>,
          address_of_beneficiary: address,
        ) acquires MyPledges {
            let account = Signer::address_of(sig);
            maybe_initialize_my_pledges(sig);
            let my_pledges = borrow_global_mut<MyPledges>(account);

            // check a beneficiary policy exists
            assert!(exists<BeneficiaryPolicy>(address_of_beneficiary), Errors::invalid_argument(ENO_BENEFICIARY_POLICY));

            // check if there isn't already a pledge initialized.
            // let len = Vector::length(&my_pledges.list);

            let new_pledge_account = PledgeAccount {
                // project_id: project_id,
                address_of_beneficiary: address_of_beneficiary,
                amount: 0,
                epoch_of_last_deposit: DiemConfig::get_current_epoch(),
                lifetime_pledged: 0,
                lifetime_withdrawn: 0
            };
            Vector::push_back(&mut my_pledges.list, new_pledge_account);
        }

        // add funds to an existing pledge account
        // Note: only funds that are Unlocked and otherwise unrestricted can be used in pledge account.
        public fun add_funds_to_pledge_account(sender: &signer, address_of_beneficiary: address, amount: u64) acquires MyPledges, BeneficiaryPolicy {
            let sender_addr = Signer::address_of(sender);
            if (Option::is_none(&maybe_find_a_pledge(&sender_addr, &address_of_beneficiary))) {
              create_pledge_account(sender, address_of_beneficiary);
            };

            assert!(exists<MyPledges>(sender_addr), Errors::invalid_state(ENO_PLEDGE_INIT));

            let my_pledges = borrow_global_mut<MyPledges>(sender_addr);
            let i = 0;
            while (i < Vector::length(&my_pledges.list)) {
                if (Vector::borrow(&my_pledges.list, i).address_of_beneficiary == address_of_beneficiary) {
                    let pledge_account = Vector::borrow_mut(&mut my_pledges.list, i);
                    pledge_account.amount = pledge_account.amount + amount;
                    pledge_account.epoch_of_last_deposit = DiemConfig::get_current_epoch();
                    pledge_account.lifetime_pledged = pledge_account.lifetime_pledged + amount;

                    // must add pledger address the ProjectPledgers list on beneficiary account
                    
                    let b = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);
                    Vector::push_back(&mut b.pledgers, sender_addr);

                    b.total_pledged = b.total_pledged  + amount;
                    b.lifetime_pledged = b.lifetime_pledged + amount;

                    break
                };
                i = i + 1;
            };

          // exits silently if nothing is found.
          // this is to prevent halting in the event that a VM route is calling the function and is unable to check the return value.
        }

        // withdraw an amount from all pledge accounts. Check first that there are remaining funds before attempting to withdraw.
        public fun withdraw_from_all_pledge_accounts(sig_beneficiary: &signer, amount: u64) acquires MyPledges, BeneficiaryPolicy {
            let pledgers = *&borrow_global<BeneficiaryPolicy>(Signer::address_of(sig_beneficiary)).pledgers;

            let address_of_beneficiary = Signer::address_of(sig_beneficiary);
            let i = 0;

            while (i < Vector::length(&pledgers)) {
                let pledge_account = *Vector::borrow(&pledgers, i);

                // DANGER: this is a private function that changes balances.
                withdraw_from_one_pledge_account(&address_of_beneficiary, &pledge_account, amount);
                i = i + 1;
            };
        }

        
        // DANGER: private function that changes balances.
        // withdraw funds from one pledge account
        // this is to be used for funding,
        // but also for revoking a pledge
        fun withdraw_from_one_pledge_account(address_of_beneficiary: &address, payer: &address, amount: u64): u64 acquires MyPledges, BeneficiaryPolicy {
            let pledge_state = borrow_global_mut<MyPledges>(*payer);
            let bp = borrow_global_mut<BeneficiaryPolicy>(*address_of_beneficiary);

            // TODO: this will be replaced with an actual coin.
            let coin = 0;

            let i = 0;
            while (i < Vector::length(&pledge_state.list)) {
                if (&Vector::borrow(&pledge_state.list, i).address_of_beneficiary == address_of_beneficiary) {
                    let pledge_account = Vector::borrow_mut(&mut pledge_state.list, i);
                    print(&pledge_account.amount);
                    if (
                      pledge_account.amount > 0 &&
                      pledge_account.amount > amount
                      
                      ) {
                        print(&1101);
                        pledge_account.amount = pledge_account.amount - amount;
                        print(&1102);
                        pledge_account.lifetime_withdrawn = pledge_account.lifetime_withdrawn + amount;
                        print(&1103);
                        // update the beneficiaries state too
                        print(&bp.total_pledged);
                        bp.total_pledged = bp.total_pledged - amount;
                        print(&1104);
                        bp.lifetime_withdrawn = bp.lifetime_withdrawn - amount;
                        print(&1104);
                        coin = amount;
                        return coin
                      }
                };
                i = i + 1;
            };

          // exits silently if nothing is found.
          // this is to prevent halting in the event that a VM route is calling the function and is unable to check the return value.
          coin
        }

        // vote to revoke a beneficiary's policy
        // this is just a vote, it requires a tally, and consensus to
        // revert the fund OR burn them, depending on policy
        public fun vote_to_revoke_beneficiary_policy(account: &signer, address_of_beneficiary: address) acquires MyPledges, BeneficiaryPolicy {
            

            // first check if they have already voted
            // and if so, cancel in one step
            try_cancel_vote(account, address_of_beneficiary);

            let pledger = Signer::address_of(account);
            let bp = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);

            Vector::push_back(&mut bp.table_revoking_electors, pledger);
            let user_pledge_balance = get_pledge_amount(&pledger, &address_of_beneficiary);
            Vector::push_back(&mut bp.table_votes_to_revoke, user_pledge_balance);
            bp.total_revoke_vote = bp.total_revoke_vote + user_pledge_balance;
        }

        // The user changes their mind.
        // They are retracting/cancelling their vote.
        public fun try_cancel_vote(account: &signer, address_of_beneficiary: address) acquires BeneficiaryPolicy {
            let pledger = Signer::address_of(account);
            let bp = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);

            let idx = find_index_of_vote(&bp.table_revoking_electors, &pledger);

            if (idx == 0) {
                return
            };
            //adjust the running totals
            let prior_vote = Vector::borrow(&bp.table_votes_to_revoke, idx);
            bp.total_revoke_vote = bp.total_revoke_vote - *prior_vote;

            // update the vote
            Vector::remove(&mut bp.table_revoking_electors, idx);
            Vector::remove(&mut bp.table_votes_to_revoke, idx);
        }

        // helper to find the index of a vote the user has already cast
        fun find_index_of_vote(table_revoking_electors: &vector<address>, pledger: &address): u64 {
            if (Vector::contains(table_revoking_electors, pledger)) {
                return 0
            };

            let i = 0;
            while (i < Vector::length(table_revoking_electors)) {
                if (Vector::borrow(table_revoking_electors, i) == pledger) {
                    return i
                };
                i = i + 1;
            };
            0 // TODO: return an option type
        }

        // count the votes.
        // does not change any state.
        fun tally_vote(address_of_beneficiary: address): bool acquires BeneficiaryPolicy {
            let bp = borrow_global<BeneficiaryPolicy>(address_of_beneficiary);
            let total_pledged = bp.total_pledged;
            let total_revoke_vote = bp.total_revoke_vote;

            // TODO: use FixedPoint here.
            if ((total_revoke_vote / total_pledged) > bp.vote_threshold_to_revoke) {
                return true
            };
            false
        }


        // Danger: this function must remain private!
        // private function to dissolve the beneficiary project, and return all funds to the pledgers.
        fun dissolve_beneficiary_project(address_of_beneficiary: address) acquires MyPledges, BeneficiaryPolicy {
            let pledgers = *&borrow_global<BeneficiaryPolicy>(address_of_beneficiary).pledgers;

            // let pledgers = *&bp.pledgers;
            let i = 0;
            while (i < Vector::length(&pledgers)) {
                let pledge_account = Vector::borrow(&pledgers, i);
                let user_pledge_balance = get_pledge_amount(pledge_account, &address_of_beneficiary);

                let _coin = withdraw_from_one_pledge_account(&address_of_beneficiary, pledge_account, user_pledge_balance);

                i = i + 1;
            };

          let bp = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);
          assert!(bp.total_pledged == 0, ENON_ZERO_BALANCE);

          bp.revoked = true;

          // otherwise leave the information as-is for reference purposes
        }

        ////////// GETTERS //////////

        public fun maybe_find_a_pledge(account: &address, address_of_beneficiary: &address): Option::Option<PledgeAccount> acquires MyPledges {
          if (!exists<MyPledges>(*account)) {
            return Option::none<PledgeAccount>()
          };

          let my_pledges = &borrow_global<MyPledges>(*account).list;
            let i = 0;
            while (i < Vector::length(my_pledges)) {
                let p = Vector::borrow(my_pledges, i);
                if (&p.address_of_beneficiary == address_of_beneficiary) {
                    return Option::some<PledgeAccount>(*p)
                };
                i = i + 1;
            };
            return Option::none()
        }
        // get the pledge amount on a specific pledge account
        public fun get_pledge_amount(account: &address, address_of_beneficiary: &address): u64 acquires MyPledges {
            let found_pledge = maybe_find_a_pledge(account, address_of_beneficiary);
            
            if (Option::is_some(&found_pledge)) {
              return Option::borrow(&found_pledge).amount
            };
            return 0
        }

      public fun get_total_pledged_to_beneficiary(bene: address): u64 acquires BeneficiaryPolicy {
        if (exists<BeneficiaryPolicy>(bene)) {
          let bp = borrow_global<BeneficiaryPolicy>(bene);
          return bp.total_pledged
        };
        0
      }


      //////// TEST HELPERS ///////
      // Danger! withdraws from an account.
      public fun test_single_withdrawal(vm: &signer, bene: address, donor: address, amount: u64): u64 acquires MyPledges, BeneficiaryPolicy{
        Testnet::assert_testnet(vm);
        withdraw_from_one_pledge_account(&bene, &donor, amount)
      }
}
}
