///////////////////////////////////////////////////////////////////////////
// 0L Module
// Epoch Prologue
///////////////////////////////////////////////////////////////////////////
// The prologue for transitioning to next epoch after every n blocks.
// File Prefix for errors: 1801
///////////////////////////////////////////////////////////////////////////

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
        use 0x0::MinerState;
        use 0x0::Globals;
        use 0x0::Vector;
        use 0x0::Stats;


        // This function is called by block-prologue once after n blocks.
        // Function code: 01. Prefix: 180101
        public fun reconfigure(account: &signer, current_block_height: u64) {
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0, 180101014010);

            // TODO: one more check in reconfigure.move to confirm it's executing in epoch boundary.

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
            prepare_upcoming_validator_set(account, current_block_height);
        }

        // Function code: 02. Prefix: 180102
        fun process_outgoing_validators(vm_sig: &signer, current_block_height: u64) {

            // Get outgoing validator and sum of all validator weights
            let (outgoing_validators, outgoing_validator_weights, sum_of_all_validator_weights)
                 = LibraSystem::get_outgoing_validators_with_weights(Globals::get_epoch_length(), current_block_height);
            // Step 1: End redeem for all validators
            MinerState::epoch_boundary(vm_sig);

            // Step 2: Subsidy payments to the validators
            // Calculate and pay subsidy for the current epoch
            // Calculate start and end block height for the current epoch

            // Get the subsidy units and burn units after deducting transaction fees
            // NOTE: current block height is the end of the epoch.

            //TODO: do we need skip first epoch?
           let subsidy_units = Subsidy::calculate_Subsidy();

            Subsidy::process_subsidy(
                vm_sig,
                &outgoing_validators,
                &outgoing_validator_weights,
                subsidy_units,
                sum_of_all_validator_weights,
                current_block_height
            );
            // Step 3: Distribute transaction fees here before updating validators
            TransactionFee::distribute_transaction_fees<GAS::T>();
            // Step 4: Getting current epoch value. Burning for all epochs except for the first one.
            if (LibraConfig::get_current_epoch() != 0) {
              Subsidy::burn_subsidy(vm_sig);
            };
        }

        // Function code: 03. Prefix: 180103
        fun prepare_upcoming_validator_set(account: &signer, current_block_height: u64) {
            // Step 1: Calls NodeWeights on validatorset to select top N accounts.
            let validator_set = NodeWeight::top_n_accounts(
                account, Globals::get_max_validator_per_epoch(),
                current_block_height);
            let length = Vector::length<address>(&validator_set);
            // If the cardinality of validator_set in the next epoch is less than 4, we skip the epoch tranisition. 
            // Refer Theorem: If we reach an epoch boundary with at least 6 rounds, we would have at least 2/3rd of the validator set with at least 66% liveliness (@sm86)  
            // This is very rare and theoretically impossible for network with at least 6 nodes and 6 rounds. 
            if(length >= 4){
            // Step 2: Call bulkUpdate module
                Stats::reconfig(&validator_set);
                LibraSystem::bulk_update_validators(account, validator_set);
            };

            // Step 3: Mint subsidy units for upcoming epoch
            Subsidy::mint_subsidy(account);
        }
  }
}
