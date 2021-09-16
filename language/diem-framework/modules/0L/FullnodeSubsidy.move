///////////////////////////////////////////////////////////////////////////
// 0L Module
// Subsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies at a given time in the network
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

address 0x1 {
  module FullnodeSubsidy {
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::GAS::GAS;
    use 0x1::Diem;
    use 0x1::Signer;
    use 0x1::DiemAccount;
    use 0x1::DiemSystem;
    use 0x1::Vector;
    use 0x1::TransactionFee;
    use 0x1::Roles;
    use 0x1::Testnet::is_testnet;

    // estimated gas unit cost for proof verification divided coin scaling factor
    // Cost for verification test/easy difficulty: 1173 / 1000000
    // Cost for verification prod/hard difficulty: 2294 / 1000000
    // Cost for account creation prod/hard: 4336

    const BASELINE_TX_COST: u64 = 4336; // microgas


    //////// FULLNODE /////////

    struct FullnodeSubsidy has key {
        previous_epoch_proofs: u64,
        current_proof_price: u64,
        current_cap: u64,
        current_subsidy_distributed: u64,
        current_proofs_verified: u64,
    }

    // Function code: 06 Prefix: 190106
    public fun init_fullnode_sub(vm: &signer) {
      let genesis_validators = DiemSystem::get_val_set_addr();
      let validator_count = Vector::length(&genesis_validators);
      if (validator_count < 10) validator_count = 10;

      // baseline_cap: baseline units per epoch times the mininmum as used in tx, times minimum gas per unit.

      let ceiling = baseline_auction_units() * BASELINE_TX_COST * validator_count;

      Roles::assert_diem_root(vm);
      assert(!exists<FullnodeSubsidy>(Signer::address_of(vm)), Errors::not_published(190106));
      move_to<FullnodeSubsidy>(vm, FullnodeSubsidy{
        previous_epoch_proofs: 0u64,
        current_proof_price: BASELINE_TX_COST * 24 * 8 * 3, // number of proof submisisons in 3 initial epochs.
        current_cap: ceiling,
        current_subsidy_distributed: 0u64,
        current_proofs_verified: 0u64,
      });
    }

    // // TODO: Deprecate in v4.2.9+ since the onboarding gas transfer resolves this issue.
    // public fun distribute_onboarding_subsidy(
    //   vm: &signer,
    //   miner: address
    // ):u64 acquires FullnodeSubsidy {
    //   // Bootstrap gas if it's the first payment to a prospective validator. Check no fullnode payments have been made, and is in validator universe. 
    //   CoreAddresses::assert_diem_root(vm);

    //   FullnodeState::is_onboarding(miner);
      
    //   let state = borrow_global<FullnodeSubsidy>(CoreAddresses::DIEM_ROOT_ADDRESS());

    //   let subsidy = bootstrap_validator_balance();
    //   // give max possible subisidy, if auction is higher
    //   if (state.current_proof_price > subsidy) subsidy = state.current_proof_price;
      
    //   let minted_coins = Diem::mint<GAS>(vm, subsidy);
    //   DiemAccount::vm_deposit_with_metadata<GAS>(
    //     vm,
    //     miner,
    //     minted_coins,
    //     b"onboarding_subsidy",
    //     b""
    //   );

    //   subsidy
    // }


    public fun distribute_fullnode_subsidy(vm: &signer, miner: address, count: u64):u64 acquires FullnodeSubsidy{
      CoreAddresses::assert_diem_root(vm);
      // Payment is only for fullnodes, ie. not in current validator set.
      if (DiemSystem::is_validator(miner)) return 0;

      let state = borrow_global_mut<FullnodeSubsidy>(Signer::address_of(vm));
      let subsidy;

      // fail fast, abort if ceiling was met
      if (state.current_subsidy_distributed > state.current_cap) return 0;

      let proposed_subsidy = state.current_proof_price * count;

      if (proposed_subsidy == 0) return 0;
      // check if payments will exceed ceiling.
      if (state.current_subsidy_distributed + proposed_subsidy > state.current_cap) {
        // pay the remainder only
        // TODO: This creates a race. Check ordering of list.
        subsidy = state.current_cap - state.current_subsidy_distributed;
      } else {
        // happy case, the ceiling is not met.
        subsidy = proposed_subsidy;
      };

      if (subsidy == 0) return 0;
      let minted_coins = Diem::mint<GAS>(vm, subsidy);
      DiemAccount::vm_deposit_with_metadata<GAS>(
        vm,
        miner,
        minted_coins,
        b"fullnode_subsidy",
        b""
      );

      state.current_subsidy_distributed = state.current_subsidy_distributed + subsidy;

      subsidy
    }

    public fun fullnode_reconfig(vm: &signer) acquires FullnodeSubsidy {
      Roles::assert_diem_root(vm);

      // update values for the proof auction.
      auctioneer(vm);
      let state = borrow_global_mut<FullnodeSubsidy>(Signer::address_of(vm));
       // save 
      state.previous_epoch_proofs = state.current_proofs_verified;
      // reset counters
      state.current_subsidy_distributed = 0u64;
      state.current_proofs_verified = 0u64;
    }

    public fun set_global_count(vm: &signer, count: u64) acquires FullnodeSubsidy{
      let state = borrow_global_mut<FullnodeSubsidy>(Signer::address_of(vm));
      state.current_proofs_verified = count;
    }

    fun baseline_auction_units():u64 {
      let epoch_length_mins = 24 * 60;
      let steady_state_nodes = 1000;
      let target_delay_mins = 10;
      steady_state_nodes * (epoch_length_mins/target_delay_mins)
    }

    fun auctioneer(vm: &signer) acquires FullnodeSubsidy {

      Roles::assert_diem_root(vm);

      let state = borrow_global_mut<FullnodeSubsidy>(Signer::address_of(vm));

      // The targeted amount of proofs to be submitted network-wide per epoch.
      let baseline_auction_units = baseline_auction_units(); 
      // The max subsidy that can be paid out in the next epoch.
      let ceiling = fullnode_subsidy_ceiling(vm);


      // Failure case
      if (ceiling < 1) ceiling = 1;

      state.current_proof_price = calc_auction(
        ceiling,
        baseline_auction_units,
        state.current_proofs_verified
      );
      // Set new ceiling
      state.current_cap = ceiling;
    }

    
    public fun calc_auction(
      ceiling: u64,
      baseline_auction_units: u64,
      current_proofs_verified: u64,
    ): u64 {
      // Calculate price per proof
      // Find the baseline price of a proof, which will be altered based on performance.
      // let baseline_proof_price = FixedPoint32::divide_u64(
      //   ceiling,
      //   FixedPoint32::create_from_raw_value(baseline_auction_units)
      // );
      let baseline_proof_price = ceiling/baseline_auction_units;

      // print(&FixedPoint32::get_raw_value(copy baseline_proof_price));
      // Calculate the appropriate multiplier.
      let proofs = current_proofs_verified;
      if (proofs < 1) proofs = 1;

      let multiplier = baseline_auction_units/proofs;
      
      // let multiplier = FixedPoint32::create_from_rational(
      //   baseline_auction_units,
      //   proofs
      // );
      // print(&multiplier);

      // Set the proof price using multiplier.
      // New unit price cannot be more than the ceiling
      // let proposed_price = FixedPoint32::multiply_u64(
      //   baseline_proof_price,
      //   multiplier
      // );

      let proposed_price = baseline_proof_price * multiplier;

      // print(&proposed_price);

      if (proposed_price < ceiling) {
        return proposed_price
      };
      //Note: in failure case, the next miner gets the full ceiling
      return ceiling
    }

    fun fullnode_subsidy_ceiling(vm: &signer):u64 {
      //get TX fees from previous epoch.
      let fees = TransactionFee::get_amount_to_distribute(vm);
      // Recover from failure case where there are no fees
      if (fees < baseline_auction_units()) return baseline_auction_units();
      fees
    }

    // fun bootstrap_validator_balance():u64 {
    //   let mins_per_day = 60 * 24;
    //   let proofs_per_day = mins_per_day / 10; // 10 min proofs
    //   let proof_cost = 40000; // assumes 1 microgas per gas unit 
    //   let subsidy_value = proofs_per_day * proof_cost;
    //   subsidy_value
    // }

    // // Operators may run out of balance to submit txs for the Validator. This is true for mining, where the operator receives no network subsidy.
    // fun refund_operator_tx_fees(vm: &signer, miner_addr: address) {
    //     // get operator for validator
    //     let oper_addr = ValidatorConfig::get_operator(miner_addr);
    //     // count OWNER's proofs submitted
    //     let proofs_in_epoch = MinerState::get_count_in_epoch(miner_addr);

    //     let cost = 0;
    //     // find cost from baseline
    //     if (proofs_in_epoch > 0) {
    //       cost = BASELINE_TX_COST * proofs_in_epoch;
    //     };

    //     // deduct from subsidy from Validator
    //     // send payment to operator
    //     if (cost > 0) {
    //       let owner_balance = DiemAccount::balance<GAS>(miner_addr);
    //       if (!(owner_balance > cost)) {
    //         cost = owner_balance;
    //       };

    //       DiemAccount::vm_make_payment_no_limit<GAS>(
    //         miner_addr,
    //         oper_addr,
    //         cost,
    //         b"tx fee refund",
    //         b"",
    //         vm
    //       );
    //     };
    // }


    //////// TEST HELPERS ///////
    public fun test_set_fullnode_fixtures(
      vm: &signer,
      previous_epoch_proofs: u64,
      current_proof_price: u64,
      current_cap: u64,
      current_subsidy_distributed: u64,
      current_proofs_verified: u64,
    ) acquires FullnodeSubsidy {
      Roles::assert_diem_root(vm);
      assert(is_testnet(), Errors::invalid_state(190108));
      let state = borrow_global_mut<FullnodeSubsidy>(@0x0);
      state.previous_epoch_proofs = previous_epoch_proofs;
      state.current_proof_price = current_proof_price;
      state.current_cap = current_cap;
      state.current_subsidy_distributed = current_subsidy_distributed;
      state.current_proofs_verified = current_proofs_verified;
    }
}
}