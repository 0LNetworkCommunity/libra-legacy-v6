/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x0{
module Cases{
  use 0x0::Transaction;
  use 0x0::MinerState;
  use 0x0::Stats;

  // Determine the consensus case for the validator.
  // This happens at an epoch prologue, and labels the validator based on performance in the outgoing epoch.
  // The consensus case determines if the validator receives transaction fees or subsidy for performance, inclusion in following epoch, and at what voting power. 
  // Permissions: Public, VM Only
  public fun get_case(node_addr: address): u64 {
      Transaction::assert(Transaction::sender() == 0x0, 220106014010);
      // did the validator sign blocks above threshold?
      let signs = Stats::node_above_thresh(node_addr);
      let mines = MinerState::node_above_thresh(node_addr);
  
      if (signs && mines) return 1; // compliant: in next set, gets paid, weight increments
      if (signs && !mines) return 2; // half compliant: in next set, does not get paid, weight does not increment.
      if (!signs && mines) return 3; // not compliant: jailed, not in next set, does not get paid, weight increments.
      //if !signs && !mines
      return 4 // not compliant: jailed, not in next set, does not get paid, weight does not increment.
  }
}
}
