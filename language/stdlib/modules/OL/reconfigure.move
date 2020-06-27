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
        // This function is called in block-prologue once after n blocks. 
        // Takes in list of validators, runs stats and node weights and updates the validator set
        public fun reconfigure(account: &signer, current_block_height: u64){
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 8001);

            // Process outgoing validators 
            // Step 1: End redeem for all validators
            // Step 2: Subsidy payments
            // Step 3: Distribute transaction fees to all outgoing validators
            // Step 4: Burn subsidy units
            process_outgoing_validators(account, current_block_height);

            // Recommend upcoming validator set
            // Step 1: Get all eligible validators
            // Step 2: Sort Top N validators
            // Step 3: Bulk update validator weights
            // Step 4: Mint subsidy for upcoming epoch
            recommend_upcoming_validator_set(account, current_block_height);
        }

        fun process_outgoing_validators(account: &signer, current_block_height: u64) {
            // Get outgoing validator and sum of all validator weights
            let (outgoing_validators, outgoing_validator_weights, sum_of_all_validator_weights)
                 = LibraSystem::get_outgoing_validators_with_weights();

            // Step 1: End redeem for all validators
            Redeem::end_redeem_outgoing_validators(account, &outgoing_validators);

            // Step 2: Subsidy payments to the validators 
            // Calculate and pay subsidy for the current epoch
            // Calculate start and end block height for the current epoch
            // TODO: OL: Create constant for epoch length
            let epoch_length = 15;
            let end_block_height = current_block_height;
            Transaction::assert(end_block_height >= epoch_length, 8003);
            let start_block_height = end_block_height - epoch_length;
            // Get the subsidy units and burn units after deducting transaction fees
            let subsidy_units = Subsidy::calculate_Subsidy(account, start_block_height, end_block_height);
            Subsidy::process_subsidy(account, &outgoing_validators, &outgoing_validator_weights, 
                                     subsidy_units, sum_of_all_validator_weights);

            // Step 3: Distribute transaction fees here before updating validators
            TransactionFee::distribute_transaction_fees<GAS::T>();

            // Step 4: Getting current epoch value. Burning for all epochs except for the first one.
            if (LibraConfig::get_current_epoch() != 0)
                Subsidy::burn_subsidy(account);
        }

        fun recommend_upcoming_validator_set(account: &signer, current_block_height: u64) {
            // Step 1: Calls NodeWeights on validatorset to select top N accounts.
            // TODO: OL: N should be made constant in Genesis
            let (eligible_validators, _sum_of_all_validator_weights) = NodeWeight::top_n_accounts(account, 10);

            // Step 2: Call bulkUpdate module
            LibraSystem::bulk_update_validators(account, eligible_validators, current_block_height); 

            // Step 3: Mint subsidy units for upcoming epoch
            Subsidy::mint_subsidy(account);
        }

  }
}
