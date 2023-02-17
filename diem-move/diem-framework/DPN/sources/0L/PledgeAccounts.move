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
        // use Std::Errors;
        // use Std::Option;
        use Std::FixedPoint32;
        use DiemFramework::DiemConfig;
        use DiemFramework::Debug::print;
        use DiemFramework::Testnet;
        use DiemFramework::Diem;
        use DiemFramework::GAS::GAS;


        const ENO_BENEFICIARY_POLICY: u64 = 150001;
        const ENON_ZERO_BALANCE: u64 = 150002;
        const ENO_PLEDGE_INIT: u64 = 150003;

        struct MyPledges has key {
          list: vector<PledgeAccount>
        }

        // A Pledge Account is a sub-account on a user's account.
        struct PledgeAccount has key, store {
            // project_id: vector<u8>, // a string that identifies the project
            address_of_beneficiary: address, // the address of the project, also where the BeneficiaryPolicy is stored for reference.
            amount: u64,
            pledge: Diem::Diem<GAS>,
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
          amount_available: u64, // The amount available to withdraw
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
                    amount_available: 0,
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


        public fun save_pledge(
          sig: &signer,
          // project_id: vector<u8>,
          address_of_beneficiary: address,
          pledge: Diem::Diem<GAS>
          ) acquires MyPledges, BeneficiaryPolicy {
            let sender_addr = Signer::address_of(sig);
            let (found, idx) = pledge_at_idx(&sender_addr, &address_of_beneficiary);
            if (found) {
              add_coin_to_pledge_account(sig, idx, Diem::value(&pledge), pledge)
            } else {
              create_pledge_account(sig, address_of_beneficiary, pledge)
            }
        }
        // Create a new pledge account on a user's list of pledges
        fun create_pledge_account(
          sig: &signer,
          // project_id: vector<u8>,
          address_of_beneficiary: address,
          init_pledge: Diem::Diem<GAS>,
        ) acquires MyPledges {
            let account = Signer::address_of(sig);
            maybe_initialize_my_pledges(sig);
            let my_pledges = borrow_global_mut<MyPledges>(account);
            let value = Diem::value(&init_pledge);
            let new_pledge_account = PledgeAccount {
                // project_id: project_id,
                address_of_beneficiary: address_of_beneficiary,
                amount: value,
                pledge: init_pledge,
                epoch_of_last_deposit: DiemConfig::get_current_epoch(),
                lifetime_pledged: value,
                lifetime_withdrawn: 0
            };
            Vector::push_back(&mut my_pledges.list, new_pledge_account);
        }

        // add funds to an existing pledge account
        // Note: only funds that are Unlocked and otherwise unrestricted can be used in pledge account.
        fun add_coin_to_pledge_account(sender: &signer, idx: u64, amount: u64, coin: Diem::Diem<GAS>) acquires MyPledges, BeneficiaryPolicy {
          let sender_addr = Signer::address_of(sender);
          // let (found, _idx) = pledge_at_idx(&sender_addr, &address_of_beneficiary);

          let my_pledges = borrow_global_mut<MyPledges>(sender_addr);
          let pledge_account = Vector::borrow_mut(&mut my_pledges.list, idx);

          pledge_account.amount = pledge_account.amount + amount;
          pledge_account.epoch_of_last_deposit = DiemConfig::get_current_epoch();
          pledge_account.lifetime_pledged = pledge_account.lifetime_pledged + amount;

          // merge the coins in the account
          Diem::deposit(&mut pledge_account.pledge, coin);

          // must add pledger address the ProjectPledgers list on beneficiary account

          let b = borrow_global_mut<BeneficiaryPolicy>(pledge_account.address_of_beneficiary);
          Vector::push_back(&mut b.pledgers, sender_addr);

          b.amount_available = b.amount_available  + amount;
          b.lifetime_pledged = b.lifetime_pledged + amount;

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
                    print(&66);
                    print(&pledge_account.amount);
                    if (
                      pledge_account.amount > 0 &&
                      pledge_account.amount >= amount
                      
                      ) {
                        print(&1101);
                        pledge_account.amount = pledge_account.amount - amount;
                        print(&1102);
                        pledge_account.lifetime_withdrawn = pledge_account.lifetime_withdrawn + amount;
                        print(&1103);
                        // update the beneficiaries state too
                        print(&bp.amount_available);
                        bp.amount_available = bp.amount_available - amount;
                        print(&1104);
                        print(&bp.amount_available);
                        bp.lifetime_withdrawn = bp.lifetime_withdrawn + amount;
                        print(&1105);
                        coin = amount;
                        print(&coin);
                        // return coin
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
            let user_pledge_balance = get_user_pledge_amount(&pledger, &address_of_beneficiary);
            Vector::push_back(&mut bp.table_votes_to_revoke, user_pledge_balance);
            bp.total_revoke_vote = bp.total_revoke_vote + user_pledge_balance;

            // The first voter to cross the threshold  also
            // triggers the dissolution.
            if (tally_vote(address_of_beneficiary)) {
              print(&444);
              dissolve_beneficiary_project(address_of_beneficiary);
            };
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
            let amount_available = bp.amount_available;
            let total_revoke_vote = bp.total_revoke_vote;

            // TODO: use FixedPoint here.
            let ratio = FixedPoint32::create_from_rational(total_revoke_vote, amount_available);
            let pct = FixedPoint32::multiply_u64(100, ratio);
            if (pct > bp.vote_threshold_to_revoke) {
                return true
            };
            false
        }


        // Danger: this function must remain private!
        // private function to dissolve the beneficiary project, and return all funds to the pledgers.
        fun dissolve_beneficiary_project(address_of_beneficiary: address) acquires MyPledges, BeneficiaryPolicy {
            print(&888888888);
            let pledgers = *&borrow_global<BeneficiaryPolicy>(address_of_beneficiary).pledgers;

            // let pledgers = *&bp.pledgers;
            let i = 0;
            while (i < Vector::length(&pledgers)) {
                print(&888);
                let pledge_account = Vector::borrow(&pledgers, i);
                let user_pledge_balance = get_user_pledge_amount(pledge_account, &address_of_beneficiary);
                print(&user_pledge_balance);
                let coin = withdraw_from_one_pledge_account(&address_of_beneficiary, pledge_account, user_pledge_balance);
                print(&coin);
                i = i + 1;
            };

          let bp = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);
          print(&bp.amount_available);
          assert!(bp.amount_available == 0, ENON_ZERO_BALANCE);
          print(&5555555);
          print(&bp.revoked);
          bp.revoked = true;
          print(&bp.revoked);

          // otherwise leave the information as-is for reference purposes
        }

        ////////// GETTERS //////////

        // Danger: If the VM calls this and there is an error there will be a halt.
        // always call pledge_at_idx() first.
        // NOTE: cannot wrap in option witout changing the struct abilities to copy, drop.
        // can't do that because Diem<GAS> cannot be copy, or drop.
        // public fun maybe_find_a_pledge(account: &address, address_of_beneficiary: &address): &mut PledgeAccount acquires MyPledges {
        //   let (found, idx) = pledge_at_idx(account, address_of_beneficiary);
        //   assert!(found, Errors::invalid_state(ENO_PLEDGE_INIT));

        //   let my_pledges = borrow_global_mut<MyPledges>(*account).list;
        //   let p = Vector::borrow_mut(&mut my_pledges, idx);
        //   p
        // }

        fun pledge_at_idx(account: &address, address_of_beneficiary: &address): (bool, u64) acquires MyPledges {
          if (exists<MyPledges>(*account)) {
          let my_pledges = &borrow_global<MyPledges>(*account).list;
            let i = 0;
            while (i < Vector::length(my_pledges)) {
                let p = Vector::borrow(my_pledges, i);
                if (&p.address_of_beneficiary == address_of_beneficiary) {
                    return (true, i)
                };
                i = i + 1;
            };
          };
          (false, 0)
        }

        // public fun maybe_find_a_pledge(account: &address, address_of_beneficiary: &address): Option::Option<PledgeAccount> acquires MyPledges {
        //   if (!exists<MyPledges>(*account)) {
        //     return Option::none<PledgeAccount>()
        //   };

        //   let my_pledges = &borrow_global<MyPledges>(*account).list;
        //     let i = 0;
        //     while (i < Vector::length(my_pledges)) {
        //         let p = Vector::borrow(my_pledges, i);
        //         if (&p.address_of_beneficiary == address_of_beneficiary) {
        //             return Option::some<PledgeAccount>(*p)
        //         };
        //         i = i + 1;
        //     };
        //     return Option::none()
        // }
        // get the pledge amount on a specific pledge account
        public fun get_user_pledge_amount(account: &address, address_of_beneficiary: &address): u64 acquires MyPledges {
            let (found, idx) = pledge_at_idx(account, address_of_beneficiary);
            if (found) {
              let my_pledges = borrow_global<MyPledges>(*account);
              let p = Vector::borrow(&my_pledges.list, idx);
              return p.amount
            };
            return 0
        }

      public fun get_available_to_beneficiary(bene: &address): u64 acquires BeneficiaryPolicy {
        if (exists<BeneficiaryPolicy>(*bene)) {
          let bp = borrow_global<BeneficiaryPolicy>(*bene);
          return bp.amount_available
        };
        0
      }

      public fun get_lifetime_to_beneficiary(bene: &address): (u64, u64)acquires BeneficiaryPolicy {
        if (exists<BeneficiaryPolicy>(*bene)) {
          let bp = borrow_global<BeneficiaryPolicy>(*bene);
          return (bp.lifetime_pledged, bp.lifetime_withdrawn)
        };
        (0, 0)
      }

      public fun get_revoke_vote(bene: &address): (bool, FixedPoint32::FixedPoint32) acquires BeneficiaryPolicy {
        let null = FixedPoint32::create_from_raw_value(0);
        if (exists<BeneficiaryPolicy>(*bene)) {
          let bp = borrow_global<BeneficiaryPolicy>(*bene);
          if (bp.revoked) {
            return (true, null)
          } else if (
            bp.total_revoke_vote > 0 &&
            bp.amount_available > 0
          ) {
            return (
              false,
              FixedPoint32::create_from_rational(bp.total_revoke_vote, bp.amount_available)
            )
          }
        };
        (false, null)
      }



      //////// TEST HELPERS ///////
      // Danger! withdraws from an account.
      public fun test_single_withdrawal(vm: &signer, bene: &address, donor: &address, amount: u64): u64 acquires MyPledges, BeneficiaryPolicy{
        Testnet::assert_testnet(vm);
        withdraw_from_one_pledge_account(bene, donor, amount)
      }
}
}
