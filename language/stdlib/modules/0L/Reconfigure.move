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
        use 0x0::Subsidy;
        use 0x0::NodeWeight;
        use 0x0::LibraSystem;
        use 0x0::GAS;
        use 0x0::TransactionFee;
        use 0x0::MinerState;
        use 0x0::Globals;
        use 0x0::Vector;
        use 0x0::AltStats;

        // This function is called by block-prologue once after n blocks.
        // Function code: 01. Prefix: 180101
        public fun reconfigure(account: &signer) {
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0, 180101014010);

            // Process outgoing validators
            // Step 1: Update MinerState for all validators
            // Step 2: Distribute Subsidy payments
            // Step 3: Distribute transaction fees to all outgoing validators
            process_outgoing_validators(account);

            // Recommend upcoming validator set
            // Step 1: Sort Top N Elegible validators
            // Step 2: Bulk update validator set (reconfig)
            // Step 3: Update Stats counter
            prepare_upcoming_validator_set(account);
        }

        // Function code: 02. Prefix: 180102
        fun process_outgoing_validators(vm_sig: &signer) {
            // Get outgoing validator and sum of all validator weights

            // Step 1: End redeem for all validators
            MinerState::epoch_boundary(vm_sig);

            //TODO: do we need skip first epoch?
            let subsidy_units = Subsidy::calculate_Subsidy();
            
            Subsidy::process_subsidy(vm_sig, subsidy_units);
            // Step 3: Distribute transaction fees here before updating validators
            TransactionFee::distribute_transaction_fees<GAS::T>();
            // Step 4: Getting current epoch value. Burning for all epochs except for the first one.
        }

        // Function code: 03. Prefix: 180103
        fun prepare_upcoming_validator_set(account: &signer) {
            // Step 1: Calls NodeWeights on validatorset to select top N accounts.
            let validator_set = NodeWeight::top_n_accounts(
                account, Globals::get_max_validator_per_epoch());
            let length = Vector::length<address>(&validator_set);

            if(length >= 4){
            // If the cardinality of validator_set in the next epoch is less than 4, we skip the epoch tranisition. 
            // Refer Theorem: If we reach an epoch boundary with at least 6 rounds, we would have at least 2/3rd of the validator set with at least 66% liveliness (@sm86)  
            // This is very rare and theoretically impossible for network with at least 6 nodes and 6 rounds. 
            
            // Step 2: Call bulkUpdate module
                AltStats::reconfig(&validator_set);
                LibraSystem::bulk_update_validators(account, validator_set);
            };

        }
  }
}
