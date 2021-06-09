/////////////////////////////////////////////////////////////////////////
// 0L Module
// CASES of validation and mining
/////////////////////////////////////////////////////////////////////////

address 0x1{
    module Cases{
        use 0x1::CoreAddresses;
        use 0x1::MinerState;
        use 0x1::Signer;
        use 0x1::Stats;

        // Determine the consensus case for the validator.
        // This happens at an epoch prologue, and labels the validator based on performance in the outgoing epoch.
        // The consensus case determines if the validator receives transaction fees or subsidy for performance, inclusion in following epoch, and at what voting power. 
        // Permissions: Public, VM Only
        public fun get_case(vm: &signer, node_addr: address, height_start: u64, height_end: u64): u64 {
            let sender = Signer::address_of(vm);
            assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 030101014010);
            // did the validator sign blocks above threshold?
            let signs = Stats::node_above_thresh(vm, node_addr, height_start, height_end);
            let mines = MinerState::node_above_thresh(vm, node_addr);

            if (signs && mines) return 1; // compliant: in next set, gets paid, weight increments
            if (signs && !mines) return 2; // half compliant: in next set, does not get paid, weight does not increment.
            if (!signs && mines) return 3; // not compliant: jailed, not in next set, does not get paid, weight increments.
            //if !signs && !mines
            return 4 // not compliant: jailed, not in next set, does not get paid, weight does not increment.
        }
    }
}