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
        // This function is called in block-prologue once after n blocks. 
        // Takes in list of validators, runs stats and node weights and updates the validator set
        public fun reconfigure(account: &signer, current_block_height: u64){
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);
            //Calls NodeWeights on validatorset to select top N accounts.
            let (selected_validators, total_voting_power) = NodeWeight::top_n_accounts(account, 10);

            // Getting current epoch value. Burning for all epochs except for the first one.
            if (LibraConfig::get_current_epoch() != 0)
                Subsidy::burn_subsidy(account);
            
            // TODO: OL: Confirm the current epoch length assuming it as 15 because of round check
            // Calculate start and end block height for the current epoch
            // What about empty blocks that get created after every epoch? 
            let epoch_length = 15;
            let end_block_height = current_block_height;
            let start_block_height = end_block_height - epoch_length;

            // Calculate and pay subsidy for the current epoch
            // Get the subsidy units and burn units after deducting transaction fees
            let subsidy_units = Subsidy::calculate_Subsidy(account, start_block_height, end_block_height);

            // Mint subsidy units for upcoming epoch
            Subsidy::mint_subsidy(account);

            // Subsidy payments to the validators 
            Subsidy::process_subsidy(account, &selected_validators, subsidy_units, total_voting_power);

            // Distribute transaction fees here before updating validators

            // Call bulkUpdate module
            LibraSystem::bulk_update_validators(account, selected_validators, current_block_height); 
        }

  }
}
