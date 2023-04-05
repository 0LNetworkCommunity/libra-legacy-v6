///////////////////////////////////////////////////////////////////////////
// 0L Module
// Subsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies 
// at a given time in the network
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module Subsidy {
    use DiemFramework::CoreAddresses;
    use Std::Errors;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Diem;
    use Std::Signer;
    use DiemFramework::DiemAccount;
    use Std::Vector;
    // use DiemFramework::Stats;
    use DiemFramework::ValidatorUniverse;
    use DiemFramework::Globals;
    use DiemFramework::DiemTimestamp;
    use DiemFramework::TransactionFee;
    use DiemFramework::ValidatorConfig;
    use DiemFramework::TowerState;
    use Std::FixedPoint32;

    // estimated gas unit cost for proof verification divided coin scaling factor
    // Cost for verification test/easy difficulty: 1173 / 1000000
    // Cost for verification prod/hard difficulty: 2294 / 1000000
    // Cost for account creation prod/hard: 4336

    const BASELINE_TX_COST: u64 = 4336; // microgas
    
    // Method to calculate subsidy split for an epoch.
    // This method should be used to get the units at the beginning of the epoch.
    // Function code: 01 Prefix: 190101
    public fun process_subsidy(
      vm: &signer,
      subsidy_units: u64,
      outgoing_set: &vector<address>,
    ) {
      CoreAddresses::assert_vm(vm);
      // Get the split of payments from Stats.
      let len = Vector::length<address>(outgoing_set);
      // equal subsidy for all active validators
      let subsidy_granted;
      // TODO: This calculation is duplicated with get_subsidy
      if (subsidy_units > len && subsidy_units > 0 ) { // arithmetic safety check
        subsidy_granted = subsidy_units/len;
      } else { return };

      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(outgoing_set, i));
        // Transfer gas from vm address to validator
        let minted_coins = Diem::mint<GAS>(vm, subsidy_granted);
        DiemAccount::vm_deposit_with_metadata<GAS>(
          vm,
          @VMReserved,
          node_address,
          minted_coins,
          b"validator subsidy",
          b""
        );

        // refund operator tx fees for mining
        refund_operator_tx_fees(vm, node_address);
        i = i + 1;
      };
    }

    // Function code: 02 Prefix: 190102
    public fun calculate_subsidy(vm: &signer, network_density: u64): (u64, u64) {
      CoreAddresses::assert_vm(vm);
      // skip genesis
      assert!(!DiemTimestamp::is_genesis(), Errors::invalid_state(190102));

      // Gets the transaction fees in the epoch
      let txn_fee_amount = TransactionFee::get_amount_to_distribute(vm);
      // Calculate the split for subsidy and burn
      let subsidy_ceiling_gas = Globals::get_subsidy_ceiling_gas();
      // TODO: This metric network density is different than 
      // DiemSystem::get_fee_ratio which actually checks the cases.

      // let network_density = Stats::network_density(vm, height_start, height_end);
      let max_node_count = Globals::get_val_set_at_genesis();
      let guaranteed_minimum = subsidy_curve(
        subsidy_ceiling_gas,
        network_density,
        max_node_count,
      );
      let subsidy = 0;
      let subsidy_per_node = 0;
      // deduct transaction fees from guaranteed minimum.
      if (guaranteed_minimum > txn_fee_amount ){
        subsidy = guaranteed_minimum - txn_fee_amount;

        if (subsidy > subsidy_ceiling_gas) {
          subsidy = subsidy_ceiling_gas
        };
        
        // return global subsidy and subsidy per node.
        // TODO: we are doing this computation twice at reconfigure time.
        if ((subsidy > network_density) && (network_density > 0)) {
          subsidy_per_node = subsidy/network_density;
        };
      };
      (subsidy, subsidy_per_node)
    }

    // Function code: 03 Prefix: 190103
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

      if (network_density >= max_node_count) {
        return 0u64
      };

      let slope = FixedPoint32::divide_u64(
        subsidy_ceiling_gas,
        FixedPoint32::create_from_rational(max_node_count - min_node_count, 1)
      );
      // y-intercept
      let intercept = slope * max_node_count;
      // calculating subsidy and burn units
      // NOTE: confirm order of operations here:
      let guaranteed_minimum = intercept - slope * network_density;
      guaranteed_minimum
    }

    // Todo: Can be private, used only in tests
    // Function code: 04 Prefix: 190104
    public fun genesis(vm_sig: &signer) { // Todo: rename to "genesis_deposit" ?
      // Need to check for association or vm account
      let vm_addr = Signer::address_of(vm_sig);
      assert!(vm_addr == @DiemRoot, Errors::requires_role(190104));

      // Get eligible validators list
      let genesis_validators = ValidatorUniverse::get_eligible_validators();
      let len = Vector::length(&genesis_validators);
      // ten coins for validator, sufficient for first epoch of transactions,
      // and an extra which the validator will send to operator.
      let subsidy = 11000000;
      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(&genesis_validators, i));
        let old_validator_bal = DiemAccount::balance<GAS>(node_address);
        
        let minted_coins = Diem::mint<GAS>(vm_sig, *&subsidy);
        DiemAccount::vm_deposit_with_metadata<GAS>(
          vm_sig,
          @VMReserved,
          node_address,
          minted_coins,
          b"genesis subsidy",
          b""
        );
        
        // Confirm the calculations, and that the ending balance is incremented accordingly.
        assert!(
          DiemAccount::balance<GAS>(node_address) == old_validator_bal + subsidy,
          Errors::invalid_argument(190104)
        );

        i = i + 1;
      };
    }

    // Function code: 05 Prefix: 190105
    public fun process_fees(
      vm: &signer,
      outgoing_set: &vector<address>,
    ) {
      CoreAddresses::assert_vm(vm);

      let len = Vector::length<address>(outgoing_set);
      let bal = TransactionFee::get_amount_to_distribute(vm);
      // leave fees in tx_fee if there isn't at least 1 gas coin per validator.
      if (bal < len) {
        return
      };

      if (bal < 1) {
        return
      };

      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(outgoing_set, i));
        let fees = bal/len;
        
        DiemAccount::vm_deposit_with_metadata<GAS>(
            vm,
            @VMReserved,
            node_address,
            TransactionFee::get_transaction_fees_coins_amount<GAS>(vm, fees),
            b"transaction fees",
            b""
        );
        i = i + 1;
      };
    }

    // Operators may run out of balance to submit txs for the Validator. 
    // This is true for mining, where the operator receives no network subsidy.
    fun refund_operator_tx_fees(vm: &signer, miner_addr: address) {
        // get operator for validator
        let oper_addr = ValidatorConfig::get_operator(miner_addr);
        // count OWNER's proofs submitted
        let proofs_in_epoch = TowerState::get_count_in_epoch(miner_addr);

        let cost = 0;
        // find cost from baseline
        if (proofs_in_epoch > 0) {
          cost = BASELINE_TX_COST * proofs_in_epoch;
        };

        // deduct from subsidy from Validator
        // send payment to operator
        if (cost > 0) {
          let owner_balance = DiemAccount::balance<GAS>(miner_addr);
          if (!(owner_balance > cost)) {
            cost = owner_balance;
          };

          DiemAccount::vm_make_payment_no_limit<GAS>(
            miner_addr,
            oper_addr,
            cost,
            b"tx fee refund",
            b"",
            vm
          );
        };
    }
}
}