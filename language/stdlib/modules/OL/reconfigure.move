// This module is responsible for reconfiguration - updating validator set after each epoch. 
// Also has test in /language/ir-testsuite/tests/OL

address 0x0 {
    module ReconfigureOL {

        // use 0x0::Redeem;

        // This function is called in block-prologue once after n blocks. 
        // Takes in list of validators, runs stats and node weights.
        // Updates the validator set
        public fun reconfigure(){
            // Get array of validators

            // Calls NodeWeights on validatorset

            // Call bulkUpdate module

            // Redeem::initialize_validator_universe(0xA550C18, 1);

        }

  }
}
