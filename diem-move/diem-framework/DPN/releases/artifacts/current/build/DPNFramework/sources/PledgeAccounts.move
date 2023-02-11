///////////////////////////////////////////////////////////////////////////
// 0L Module
// Pledge Accounts
///////////////////////////////////////////////////////////////////////////
// How does a decentralized project gather funds, without the authority of a foundation? 
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
///////////////////////////////////////////////////////////////////////////

address DiemFramework{
    module PledgeAccounts{
        use Std::Vector;
        use Std::Signer;
        use Std::Errors;
        use DiemFramework::DiemConfig;


        const ENO_BENEFICIARY_POLICY: u64 = 150001;

        struct MyPledges has key {
          list: vector<PledgeAccount>
        }

        // A Pledge Account is a sub-account on a user's account.
        struct PledgeAccount has key, store {
            project_id: vector<u8>, // a string that identifies the project
            address_of_beneficiary: address, // the address of the project, also where the BeneficiaryPolicy is stored for reference.
            amount: u64,
            epoch_of_last_deposit: u64,
            lifetime_deposited: u64,
            lifetime_withdrawn: u64
        }

        // A struct with some rules established by the beneficiary
        // that is agreed on, upon pledge.
        // IMPORTANT: this struct cannot be modified after a pledge is made.

        struct BeneficiaryPolicy has key, store {
          purpose: vector<u8>, // a string that describes the purpose of the pledge
          vote_threshold_to_revoke: u64, // the threshold of votes, weighted by pledged balance, needed to dissolve, and revoke the pledge.
          burn_funds_on_revoke: bool, // neither the beneficiary not the pledger can get the funds back, they are burned. Changes the game theory, may be necessary to in certain cases to prevent attacks in high stakes projects.
          pledgers: vector<address>
        }

        // beneficiary publishes a policy to their account.
        // NOTE: It cannot be modified after a first pledge is made!.
        public fun publish_beneficiary_policy(account: &signer, purpose: vector<u8>, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool) acquires BeneficiaryPolicy {
            if (!exists<BeneficiaryPolicy>(Signer::address_of(account))) {
                let beneficiary_policy = BeneficiaryPolicy {
                    purpose: purpose,
                    vote_threshold_to_revoke: vote_threshold_to_revoke,
                    burn_funds_on_revoke: burn_funds_on_revoke,
                    pledgers: Vector::empty(),
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
        public fun initialize_my_pledges(account: &signer) {
            if (!exists<MyPledges>(Signer::address_of(account))) {
                let my_pledges = MyPledges { list: Vector::empty() };
                move_to(account, my_pledges);
            }
        }

        // Create a new pledge account on a user's list of pledges
        public fun create_pledge_account(account: &signer, project_id: vector<u8>, address_of_beneficiary: address, amount: u64) acquires MyPledges {
            let my_pledges = borrow_global_mut<MyPledges>(Signer::address_of(account));

            // check a beneficiary policy exists
            assert!(exists<BeneficiaryPolicy>(address_of_beneficiary), Errors::invalid_argument(ENO_BENEFICIARY_POLICY));

            let new_pledge_account = PledgeAccount {
                project_id: project_id,
                address_of_beneficiary: address_of_beneficiary,
                amount: amount,
                epoch_of_last_deposit: DiemConfig::get_current_epoch(),
                lifetime_deposited: amount,
                lifetime_withdrawn: 0
            };
            Vector::push_back(&mut my_pledges.list, new_pledge_account);
        }

        // add funds to an existing pledge account
        public fun add_funds_to_pledge_account(account: &signer, address_of_beneficiary: address, amount: u64) acquires MyPledges, BeneficiaryPolicy {
            let my_pledges = borrow_global_mut<MyPledges>(Signer::address_of(account));
            let i = 0;
            while (i < Vector::length(&my_pledges.list)) {
                if (Vector::borrow(&my_pledges.list, i).address_of_beneficiary == address_of_beneficiary) {
                    let pledge_account = Vector::borrow_mut(&mut my_pledges.list, i);
                    pledge_account.amount = pledge_account.amount + amount;
                    pledge_account.epoch_of_last_deposit = DiemConfig::get_current_epoch();
                    pledge_account.lifetime_deposited = pledge_account.lifetime_deposited + amount;

                    // must add pledger address the ProjectPledgers list on beneficiary account
                    
                    let b = borrow_global_mut<BeneficiaryPolicy>(address_of_beneficiary);
                    Vector::push_back(&mut b.pledgers, Signer::address_of(account));

                    break
                };
                i = i + 1;
            };

          // exits silently if nothing is found.
          // this is to prevent halting in the event that a VM route is calling the function and is unable to check the return value.
        }
    }
}
