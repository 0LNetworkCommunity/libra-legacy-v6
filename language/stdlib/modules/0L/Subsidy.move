///////////////////////////////////////////////////////////////////////////
// 0L Module
// Subsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies at a given time in the network
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

address 0x1 {
  module Subsidy {
    use 0x1::CoreAddresses;
    use 0x1::GAS::GAS;
    use 0x1::Libra;
    use 0x1::Signer;
    use 0x1::LibraAccount;
    use 0x1::Vector;
    use 0x1::FixedPoint32::{Self, FixedPoint32};    
    use 0x1::Stats;
    use 0x1::ValidatorUniverse;
    use 0x1::Globals;
    use 0x1::LibraTimestamp;
    use 0x1::LibraSystem;
    use 0x1::TransactionFee;

    // Method to calculate subsidy split for an epoch.
    // This method should be used to get the units at the beginning of the epoch.
    // Function code: 07 Prefix: 190107
    public fun calculate_Subsidy(vm: &signer):u64 {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190101014010);

      // skip genesis
      assert(!LibraTimestamp::is_genesis(), 190101021000);

      // Gets the transaction fees in the epoch
      let txn_fee_amount = TransactionFee::get_amount_to_distribute(vm);
      // Calculate the split for subsidy and burn

      let subsidy_ceiling_gas = Globals::get_subsidy_ceiling_gas();
      let network_density = Stats::network_density(vm);
      let max_node_count = Globals::get_max_node_density();
      let subsidy_units = subsidy_curve(
        subsidy_ceiling_gas,
        network_density,
        max_node_count,
        );

      // deduct transaction fees from minimum guarantee.
      subsidy_units = subsidy_units - txn_fee_amount;
      subsidy_units
    }
    // Function code: 03 Prefix: 190103
    public fun process_subsidy(vm_sig: &signer, subsidy_units: u64) {
      let sender = Signer::address_of(vm_sig);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190101034010);

      // Get the split of payments from Stats.
      let (outgoing_set, fee_ratio) = LibraSystem::get_fee_ratio(vm_sig);
      let length = Vector::length<address>(&outgoing_set);

      //TODO: assert the lengths of vectors are the same.
      let i = 0;
      while (i < length) {

        let node_address = *(Vector::borrow<address>(&outgoing_set, i));
        let node_ratio = *(Vector::borrow<FixedPoint32>(&fee_ratio, i));
        let subsidy_granted = FixedPoint32::multiply_u64(subsidy_units, node_ratio);
        // Transfer gas from vm address to validator
        let minted_coins = Libra::mint<GAS>(vm_sig, subsidy_granted);
        LibraAccount::vm_deposit_with_metadata<GAS>(
          vm_sig,
          node_address,
          minted_coins,
          x"", x""
        );
        i = i + 1;
      };
    }

    // Function code: 04 Prefix: 190104
    public fun subsidy_curve(
      subsidy_ceiling_gas: u64,
      network_density: u64,
      max_node_count: u64
      ): u64 {
      
      let min_node_count = 4u64;

      // Return early if we know the value is below 4.
      // This applies only to test environments where there is network of 1.
      if (network_density <= min_node_count) {
        return subsidy_ceiling_gas
      };

      let slope = FixedPoint32::divide_u64(
        subsidy_ceiling_gas,
        FixedPoint32::create_from_rational(max_node_count - min_node_count, 1)
        );
      //y-intercept
      let intercept = slope * max_node_count;
      //calculating subsidy and burn units
      // NOTE: confirm order of operations here:
      let subsidy_units = intercept - slope * network_density;
      subsidy_units
    }

    use 0x1::Debug::print;
    // Function code: 06 Prefix: 190106
    public fun genesis(vm_sig: &signer) {
      //Need to check for association or vm account
      let vm_addr = Signer::address_of(vm_sig);
      assert(vm_addr == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190101044010);

      // Get eligible validators list
      let genesis_validators = ValidatorUniverse::get_eligible_validators(vm_sig);
      let len = Vector::length(&genesis_validators);
      // Calculate subsidy equally for all the validators based on subsidy curve
      // Calculate the split for subsidy and burn
      // let subsidy_info = borrow_global_mut<SubsidyInfo>(0x0);
      let subsidy_ceiling_gas = Globals::get_subsidy_ceiling_gas();
      let network_density = Stats::network_density(vm_sig);
      let max_node_count = Globals::get_max_node_density();
      let subsidy_units = subsidy_curve(
        subsidy_ceiling_gas,
        network_density,
        max_node_count,
      );
      // Distribute gas coins to initial validators
      let subsidy_granted = subsidy_units / len;
      print(&subsidy_granted);

      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(&genesis_validators, i));
        let old_validator_bal = LibraAccount::balance<GAS>(node_address);
        print(&node_address);
        //Transfer gas from association to validator
        let minted_coins = Libra::mint<GAS>(vm_sig, subsidy_granted);
        print(&minted_coins);
        LibraAccount::vm_deposit_with_metadata<GAS>(
          vm_sig,
          node_address,
          minted_coins,
          x"", x""
        );

        //Confirm the calculations, and that the ending balance is incremented accordingly.
        assert(LibraAccount::balance<GAS>(node_address) == old_validator_bal + subsidy_granted, 19010105100);
        i = i + 1;
      };

      // assert(LibraAccount::balance<GAS>(vm_addr) == 0, 19010105100);

    }
    
    public fun process_fees(vm: &signer) {
      assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190103014010);
      let capability_token = LibraAccount::extract_withdraw_capability(vm);

      let (outgoing_set, fee_ratio) = LibraSystem::get_fee_ratio(vm);
      let len = Vector::length<address>(&outgoing_set);

      let bal = TransactionFee::get_amount_to_distribute(vm);
    // leave fees in tx_fee if there isn't at least 1 gas coin per validator.
      if (bal < len) {
        LibraAccount::restore_withdraw_capability(capability_token);
        return
      };

      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(&outgoing_set, i));
        let node_ratio = *(Vector::borrow<FixedPoint32::FixedPoint32>(&fee_ratio, i));
        let fees = FixedPoint32::multiply_u64(bal, node_ratio);
        
        LibraAccount::vm_deposit_with_metadata<GAS>(
            vm,
            node_address,
            TransactionFee::get_transaction_fees_coins_amount<GAS>(vm, fees),
            x"",
            x""
        );
        i = i + 1;
      };
      LibraAccount::restore_withdraw_capability(capability_token);
    }

}
}