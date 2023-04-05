///////////////////////////////////////////////////////////////////////////
// 0L Module
// FullnodeSubsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies at 
// a given time in the network.
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module FullnodeSubsidy {
    use DiemFramework::CoreAddresses;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Diem;
    use DiemFramework::DiemAccount;
    use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;

    public fun get_proof_price(one_val_subsidy: u64): u64 {

      let global_proofs = TowerState::get_fullnode_proofs_in_epoch_above_thresh();

      // proof price is simple, miners divide the equivalent of one compliant 
      // validator's subsidy.
      // Miners get a subsidy per proof in their tower.

      // Note to rascals: I know what you're thinking, but for the same effort
      // you'll put into that idea, it would be more profitable to just run
      // a validator node.
      if (global_proofs > 0) {
        return one_val_subsidy/global_proofs
      };

      0
    }

    public fun distribute_fullnode_subsidy(
      vm: &signer,
      miner: address,
      subsidy: u64
    ):u64 {
      CoreAddresses::assert_diem_root(vm);
      // Payment is only for fullnodes, ie. not validator candidates
      // TODO: this check is duplicated in reconfigure
      if (DiemSystem::is_validator(miner)) return 0; 
      if (subsidy == 0) return 0;

      let minted_coins = Diem::mint<GAS>(vm, subsidy);
      DiemAccount::vm_deposit_with_metadata<GAS>(
        vm,
        @VMReserved,
        miner,
        minted_coins,
        b"fullnode_subsidy",
        b""
      );

      subsidy
    }
}
}