/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x0{
module Cases{
  use 0x0::Transaction;
  use 0x0::ValidatorUniverse;
  use 0x0::Globals;
  use 0x0::LibraConfig;
  use 0x0::MinerState;

  // TODO: prefer to use get_current_block_height, but it causes dependency cycle.
  // use 0x0::LibraBlock::get_current_block_height;


  // Determine the consensus case for the validator.
  // This happens at an epoch prologue, and labels the validator based on performance in the outgoing epoch.
  // The consensus case determines if the validator receives transaction fees or subsidy for performance, inclusion in following epoch, and at what voting power. 
  // Permissions: Public, VM Only
  public fun get_case(node_addr: address, current_block_height: u64): u64 {
      Transaction::assert(Transaction::sender() == 0x0, 220106014010);
      // did the validator sign blocks above threshold?
      let signs = ValidatorUniverse::check_if_active_validator(node_addr, Globals::get_epoch_length(), current_block_height);
      let mines = (MinerState::get_miner_latest_epoch(node_addr) == LibraConfig::get_current_epoch());

      if (signs) {
          if (mines) return 1 // compliant: in next set, gets paid, weight increments
          else return 2 // half compliant: in next set, does not get paid, weight does not increment.
      } else if (mines) return 3; // not compliant: jailed, not in next set, does not get paid, weight does not increment.

      return 4 // not compliant: jailed, not in next set, does not get paid, weight does not increment.
  }
}
}
