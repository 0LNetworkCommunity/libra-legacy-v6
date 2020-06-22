// This module is responsible for reconfiguration - updating validator set after each epoch. 
// Also has test in /language/ir-testsuite/tests/OL

address 0x0 {
    module ReconfigureOL {

        use 0x0::Redeem;
        use 0x0::NodeWeight;
        use 0x0::LibraSystem;

        // This function is called in block-prologue once after n blocks. 
        // Takes in list of validators, runs stats and node weights and updates the validator set
        public fun reconfigure(account: &signer){
            // Get the eligible validators vector
            let eligible_validators = Redeem::query_eligible_validators(account);

            // Calls NodeWeights on validatorset to select top N accounts.
            // TODO: 'N' variable is a global constant. To be set in genesis block. 
            let selected_validators = NodeWeight::top_n_accounts(eligible_validators, 10);

            // Call bulkUpdate module
            LibraSystem::bulk_update_validators(account, selected_validators); 

            Redeem::new_epoch_validator_universe_update(account);

        }

  }
}
