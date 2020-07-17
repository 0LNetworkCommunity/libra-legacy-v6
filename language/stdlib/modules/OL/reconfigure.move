// Epoch Prologue
// This module is responsible for reconfiguration - updating validator set after each epoch.
// Also has test in /language/ir-testsuite/tests/OL

address 0x0 {
    module ReconfigureOL {
        use 0x0::Signer;
        use 0x0::Transaction;
        use 0x0::LibraConfig;
        use 0x0::Subsidy;
        use 0x0::NodeWeight;
        use 0x0::LibraSystem;
        use 0x0::GAS;
        use 0x0::TransactionFee;
        use 0x0::Redeem;
        use 0x0::Debug;
        use 0x0::Vector;
        use 0x0::Globals;


        // resource struct EpochInfo {
        //     epoch_length: u64,
        //     validator_count_epoch: u64
        // }
        // function to initialize ValidatorUniverse in genesis.
        // This is triggered in new epoch by Configuration in Genesis.move
        public fun initialize(account: &signer){
            // Check for transactions sender is association
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0, 8001);

            // move_to<EpochInfo>(account, EpochInfo {
            //     epoch_length: epoch_length,
            //     validator_count_epoch: validator_count_epoch
            // });
        }

        // This function is called in block-prologue once after n blocks.
        // Takes in list of validators, runs stats and node weights and updates the validator set
        public fun reconfigure(account: &signer, current_block_height: u64) {
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0, 8001);

            // TODO: one more check in reconfigure.move to confirm it's executing in epoch boundary.

            // Process outgoing validators
            // Step 1: End redeem for all validators
            // Step 2: Subsidy payments
            // Step 3: Distribute transaction fees to all outgoing validators
            // Step 4: Burn subsidy units

            // Skip this step on the first epoch, which is exceptional.
            // TODO: Are the buffer blocks causing this problem?
            if (current_block_height > Globals::get_epoch_length() + 3) {
              process_outgoing_validators(account, current_block_height);
              Debug::print(&0x12EC011F160000000000000000000001);

            };
            // Recommend upcoming validator set
            // Step 1: Get all eligible validators
            // Step 2: Sort Top N validators
            // Step 3: Bulk update validator weights
            // Step 4: Mint subsidy for upcoming epoch
            prepare_upcoming_validator_set(account, current_block_height);
            Debug::print(&0x12EC011F160000000000000000000002);

        }

        fun process_outgoing_validators(account: &signer, current_block_height: u64) {
            Debug::print(&0x12EC011F160000000000000000001001);

            // Get outgoing validator and sum of all validator weights
            let (outgoing_validators, outgoing_validator_weights, sum_of_all_validator_weights)
                 = LibraSystem::get_outgoing_validators_with_weights(Globals::get_epoch_length(), current_block_height);
            // Step 1: End redeem for all validators
            Debug::print(&0x12EC011F160000000000000000001002);
            Redeem::end_redeem_outgoing_validators(account, &outgoing_validators);
            Debug::print(&0x12EC011F160000000000000000001003);

            // Step 2: Subsidy payments to the validators
            // Calculate and pay subsidy for the current epoch
            // Calculate start and end block height for the current epoch
            Debug::print(&0x12EC011F160000000000000000001004);
            let start_block_height = current_block_height - Globals::get_epoch_length();
            // Get the subsidy units and burn units after deducting transaction fees
            // NOTE: current block height is the end of the epoch.
            let subsidy_units = Subsidy::calculate_Subsidy(account, start_block_height, current_block_height);
            Debug::print(&0x12EC011F160000000000000000001005);

            Subsidy::process_subsidy(account, &outgoing_validators, &outgoing_validator_weights,
                                     subsidy_units, sum_of_all_validator_weights);
            Debug::print(&0x12EC011F160000000000000000001006);
            // Step 3: Distribute transaction fees here before updating validators
            TransactionFee::distribute_transaction_fees<GAS::T>();
            Debug::print(&0x12EC011F160000000000000000001007);
            // Step 4: Getting current epoch value. Burning for all epochs except for the first one.
            if (LibraConfig::get_current_epoch() != 0) {
              Subsidy::burn_subsidy(account);
              Debug::print(&0x12EC011F160000000000000000001008);
            }


        }

        fun prepare_upcoming_validator_set(account: &signer, current_block_height: u64) {
            // Step 1: Calls NodeWeights on validatorset to select top N accounts.
            // TODO: OL: N should be made constant in Genesis
            Debug::print(&0x12EC011F160000000000000000002001);
            let eligible_validators = NodeWeight::top_n_accounts(account, Globals::get_max_validator_per_epoch());
            Debug::print(&0x12EC011F160000000000000000002002);
            let n = Vector::length<address>(&eligible_validators);
            Debug::print(&n);


            // Step 2: Call bulkUpdate module
            LibraSystem::bulk_update_validators(account, eligible_validators, Globals::get_epoch_length(), current_block_height);
            Debug::print(&0x12EC011F160000000000000000002003);

            // Step 3: Mint subsidy units for upcoming epoch
            Subsidy::mint_subsidy(account);
            Debug::print(&0x12EC011F160000000000000000002004);
        }

        // //TODO: Reconfig::get_epoch_length is being called on every block, should not be.
        // public fun get_epoch_length(): u64 acquires EpochInfo {
        //   Debug::print(&0x12EC011F160000000000000000003001);
        //
        //     // Get epoch info from association
        //     let epochInfo = borrow_global<EpochInfo>(0x0);
        //     epochInfo.epoch_length
        // }
        //
        // public fun Globals::get_max_validator_per_epoch(): u64 acquires EpochInfo {
        //   Debug::print(&0x12EC011F160000000000000000004001);
        //     // Get epoch info from association
        //     let epochInfo = borrow_global<EpochInfo>(0x0);
        //     epochInfo.validator_count_epoch
        // }
  }
}
