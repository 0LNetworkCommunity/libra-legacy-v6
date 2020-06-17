address 0x0 {
  module Subsidy {
    use 0x0::Transaction;

    resource struct PrivilegedCapability<Privilege> { }

    struct T { }

    // pub fun mint_subsidy() {
      // Permissions: Only the redeem.end_redeem method should be able to call this contract.

      // Mint the maximum reward coins that could be used in the epoch.
      // The coins exist in this contract's address until the end of consensus.
      // let epoch_subsidy = [minted coins]
    //}

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

    public fun mint_gas() {
      
    }

    public fun assert_is_subsidy(addr: address) {
      Transaction::assert(addr_is_subsidy(addr), 1001);
    }

    public fun addr_is_subsidy(addr: address): bool {
        //TODO:Do we initialize subsidy to a particular address like association
        exists<PrivilegedCapability<T>>(addr)
    }
  }
}
