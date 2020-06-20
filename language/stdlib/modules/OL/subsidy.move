address 0x0 {
  module Subsidy {
    use 0x0::Transaction;
    use 0x0::GAS;
    use 0x0::Libra;

    resource struct PrivilegedCapability<Privilege> { }

    resource struct SubsidyInfo {
      minted_gas: GAS,
      max_subsidy: u64,
      current_epoch: u64
    }

    struct T { }

    // Permissions: Only the redeem.end_redeem method should be able to \
    //call this contract.
    // Mint the maximum reward coins that could be used in the epoch.
    // The coins exist in this contract's address until the end of consensus.
    // let epoch_subsidy = [minted coins]
    public fun mint_subsidy(account: &signer, _epoch: u64) acquires SubsidyInfo{
      //TODO:Check if account signer is priviledged account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 1002);
      //TODO:Check if minted in the same epoch - Is it neccessary

      //Acquire subsidy info
      let subsidy_info = borrow_global<SubsidyInfo>(subsidy_root_address());

      //Mint gas coin and store it in subsidy info
      let minted_coin = Libra::mint<GAS::T>(account, max_subsidy);
      Transaction::assert(Libra::value<GAS::T>(&minted_coin) == max_subsidy, 1003);
      
    }

    // pub fun calculate_Subsidy(blockheight: u8){
      // Gets the proxy for liveness from Stats
      // Stats.Network_heuristics().signer_density_lookback(blockheight)

      // Gets the fees paid in the block from Stdlib.BlockMetadata
      // let fees_in_epoch = Stdlib.BlockMetadata.[Get fees paid]

      // subsidy_Curve(node_density) {
        // Returns the split bestween subsidy_units, burn_units according to curve.
        // return (subsidy_units, burn_units);
      //}
    //}

    // process_subsidy(node_address, amount) {
      // get the split of payments to subsidy and burn
      // let split = calculate_Subsidy()

      // let subsidy_owed = epoch_subsidy * split.subsidy
      // Issue: Need to transfer the calculate_subsidy but transfers are not enabled.
      // Gas_coin.transfer(consensus_leader, subsidy_owed)

      // process_burn(coins) {
        // let burn = epoch_subsidy * split.burn
        // gas_coin.burn(burn)
      //}
    //}

    /// The address at which the root account will be published.
    public fun subsidy_root_address(): address {
      0x20D1AC
    }

    public fun assert_is_subsidy(addr: address) {
      Transaction::assert(addr == subsidy_root_address(), 1001);
    }
  }
}
