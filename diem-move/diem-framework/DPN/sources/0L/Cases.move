/////////////////////////////////////////////////////////////////////////
// 0L Module
// CASES of validation and mining
// Error code for File: 0300
/////////////////////////////////////////////////////////////////////////

address DiemFramework{
    /// # Summary
    /// This module can be used by root to determine whether a validator is compliant 
    /// Validators who are no longer compliant may be kicked out of the validator 
    /// set and/or jailed. To be compliant, validators must be BOTH validating and mining. 
    module Cases{
        // use DiemFramework::TowerState;
        use DiemFramework::Stats;
        use DiemFramework::Roles;

        const VALIDATOR_COMPLIANT: u64 = 1;
        // const VALIDATOR_HALF_COMPLIANT: u64 = 2;
        // const VALIDATOR_NOT_COMPLIANT: u64 = 3;
        const VALIDATOR_DOUBLY_NOT_COMPLIANT: u64 = 4;

        const INVALID_DATA: u64 = 0;

        // Determine the consensus case for the validator.
        // This happens at an epoch prologue, and labels the validator based on 
        // performance in the outgoing epoch.
        // The consensus case determines if the validator receives transaction 
        // fees or subsidy for performance, inclusion in following epoch, and 
        // at what voting power. 
        // Permissions: Public, VM Only
        public fun get_case(
            vm: &signer, node_addr: address, height_start: u64, height_end: u64
        ): u64 {

            // this is a failure mode. Only usually seen in rescue missions,
            // where epoch counters are reconfigured by writeset offline.
            if (height_end < height_start) return INVALID_DATA;

            Roles::assert_diem_root(vm);
            // did the validator sign blocks above threshold?
            let signs = Stats::node_above_thresh(vm, node_addr, height_start, height_end);

            // let mines = TowerState::node_above_thresh(node_addr);

            if (signs) {
                // compliant: in next set, gets paid, weight increments
                VALIDATOR_COMPLIANT
            }
            // V6: Simplify compliance cases by removing mining.

            // } 
            // else if (signs && !mines) {
            //     // half compliant: not in next set, does not get paid, weight 
            //     // does not increment.
            //     VALIDATOR_HALF_COMPLIANT
            // }
            // else if (!signs && mines) {
            //     // not compliant: jailed, not in next set, does not get paid, 
            //     // weight increments.
            //     VALIDATOR_NOT_COMPLIANT
            // }
            else {
                // not compliant: jailed, not in next set, does not get paid, 
                // weight does not increment.
                VALIDATOR_DOUBLY_NOT_COMPLIANT
            }
        }
    }
}