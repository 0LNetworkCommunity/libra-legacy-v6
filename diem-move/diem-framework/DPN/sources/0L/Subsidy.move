///////////////////////////////////////////////////////////////////////////
// 0L Module
// Subsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies 
// at a given time in the network
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

// Providing validator services is competitive.
// The network should always aim to pay the "normal profit" to validators, aka their opportunity cost.
// With Proof-of-Fee the validators are incentivised to reveal their preference, their internal valuation of the seat in the validator set.
// Proof of Fee begins each epoch announcing the reward for successful validation ("baseline reward"), and the prospective validators bid a price for the seat, effectively reducing the reward and as such the cost to the network.

// The issue with blockchain infrastructure provision is that fees from ordering (transaction fees), have historically been insuficcient to cover the opportunity costs of the most highly skilled validators, at a high level of network security. This is why subsidies are paid out.

// Normally in BFT networks Proof of Stake is employed, an the shortfall between collected transaction fees, and the cost of security is paid by depositors on the chain, as account service fees (implemented as "inflation"; new issuance).

// In 0L, the subsidies for such shortfall come from pre-established and non-dilutive Infrastructure Escrow Pledges, whereby early network participants pledged funds for this purpose. See Pledge.move.

// At every epoch the 0x0 (root account) draws from the Infra Escrow Pledges. The amount is the "nominal cost" of the epoch (consensus_reward * successful_validators).  from the pledger's accounts, and places it in the temporary Network Fee account.

// The prospective validators fee to enter the validator set (the auction "clearing price"), is also placed into the Network Fee account. This means that the "net cost" to then network is lower.

// All excess fees (than necessary for costs) in the Network Fee account are burnt. This means that the infra escrow may overpay nominally, howver that capital is returned as capital (i.e. excess infra escrow moves from an Opex account to a Capex account).

// Note: The burn logic is unmodified from V5 to V6. The burn observes the escrow provider set in Burn.move. Either excess infra subsidies are burnt entirely, or the the Pledger can opt to have the burn recycled by the Matching Donation algorithm.

// The arithmetic is as follows:

// nominal_cost_to_network = consensus_reward * successful_validators
// net_cost_to_network = (consensus_reward - pof_auction_fees) * successful_validators
// epoch_fees = sum(tx_fees) + sum(pof_auction_fees) + sum(infra_escrow_drawdown) + sum(other_potential_future_fees).
// epoch_capitalization = epoch_fees - net_cost_to_network.



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
    // use DiemFramework::Globals;
    // use DiemFramework::DiemTimestamp;
    use DiemFramework::TransactionFee;
    use DiemFramework::ProofOfFee;
    // use DiemFramework::ValidatorConfig;
    // use DiemFramework::TowerState;
    // use Std::FixedPoint32;
    // use DiemFramework::Debug::print;


    // const BASELINE_TX_COST: u64 = 4336; // microgas
    

  // V6: No need to calculate the subsidy, this is done by proof of fee's consensus reward thermostat.


    // // Draw the 
    // public fun process_subsidy(
    //   vm: &signer,
    //   // subsidy_units: u64,
    //   outgoing_set: &vector<address>,
    // ) {
    //   CoreAddresses::assert_vm(vm);
    //   // Get the split of payments from Stats.
    //   let len = Vector::length<address>(outgoing_set);

    //   let node_address = *(Vector::borrow<address>(outgoing_set, i));
    //   // Transfer gas from vm address to validator
    //   let minted_coins = Diem::mint<GAS>(vm, subsidy_granted);
    //   DiemAccount::vm_deposit_with_metadata<GAS>(
    //     vm,
    //     node_address,
    //     minted_coins,
    //     b"validator subsidy",
    //     b""
    //   );

    //   V6: the operator does not produce Towers any longer.

    //   // refund operator tx fees for mining
    //   refund_operator_tx_fees(vm, node_address);
    //     i = i + 1;
    //   };
    // }

    // // Function code: 02 Prefix: 190102
    // // Calculating the "net cost to network".
    // public fun calculate_subsidy(vm: &signer, network_density: u64): (u64, u64) {
    //   CoreAddresses::assert_vm(vm);
    //   // skip genesis
    //   assert!(!DiemTimestamp::is_genesis(), Errors::invalid_state(190102));


    //   // // Gets the transaction fees in the epoch
    //   // let txn_fee_amount = TransactionFee::get_fees_collected();
    //   // // Calculate the split for subsidy and burn
    //   // let subsidy_ceiling_gas = Globals::get_subsidy_ceiling_gas();
    //   // // TODO: This metric network density is different than 
    //   // // DiemSystem::get_fee_ratio which actually checks the cases.

    //   // // let network_density = Stats::network_density(vm, height_start, height_end);
    //   // let max_node_count = Globals::get_val_set_at_genesis();
    //   // let guaranteed_minimum = subsidy_curve(
    //   //   subsidy_ceiling_gas,
    //   //   network_density,
    //   //   max_node_count,
    //   // );
    //   // let subsidy = 0;
    //   // let subsidy_per_node = 0;
    //   // // deduct transaction fees from guaranteed minimum.
    //   // if (guaranteed_minimum > txn_fee_amount ){
    //   //   subsidy = guaranteed_minimum - txn_fee_amount;

    //   //   if (subsidy > subsidy_ceiling_gas) {
    //   //     subsidy = subsidy_ceiling_gas
    //   //   };
        
    //   //   // return global subsidy and subsidy per node.
    //   //   // TODO: we are doing this computation twice at reconfigure time.
    //   //   if ((subsidy > network_density) && (network_density > 0)) {
    //   //     subsidy_per_node = subsidy/network_density;
    //   //   };
    //   // };
    //   (subsidy, subsidy_per_node)
    // }

    // // Function code: 03 Prefix: 190103
    // public fun subsidy_curve(
    //   subsidy_ceiling_gas: u64,
    //   network_density: u64,
    //   max_node_count: u64
    // ): u64 {
    //   let min_node_count = 4u64;

    //   // Return early if we know the value is below 4.
    //   // This applies only to test environments where there is network of 1.
    //   if (network_density <= min_node_count) {
    //     return subsidy_ceiling_gas
    //   };

    //   if (network_density >= max_node_count) {
    //     return 0u64
    //   };

    //   let slope = FixedPoint32::divide_u64(
    //     subsidy_ceiling_gas,
    //     FixedPoint32::create_from_rational(max_node_count - min_node_count, 1)
    //   );
    //   // y-intercept
    //   let intercept = slope * max_node_count;
    //   // calculating subsidy and burn units
    //   // NOTE: confirm order of operations here:
    //   let guaranteed_minimum = intercept - slope * network_density;
    //   guaranteed_minimum
    // }

    // Todo: Can be private, used only in tests
    // Function code: 04 Prefix: 190104

    // TODO: check if there is balance (which is the case in a fork). Otherwise we are likely in test mode.
    public fun genesis(vm_sig: &signer) { // Todo: rename to "genesis_deposit" ?
      // Need to check for association or vm account
      let vm_addr = Signer::address_of(vm_sig);
      assert!(vm_addr == @DiemRoot, Errors::requires_role(190104));

      // Get eligible validators list
      let genesis_validators = ValidatorUniverse::get_eligible_validators();
      let len = Vector::length(&genesis_validators);
      // ten coins for validator, sufficient for first epoch of transactions,
      // and an extra which the validator will send to operator.
      // Validator should have 10_000_000 at the end after the Operator has been bootsrapped, and the InfraEscrow started.
      let subsidy = 13500000;
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


    // Process the rewards of the outgoin successful validators in an epoch.
    public fun process_fees(
      vm: &signer,
      // subsidy_units: u64,
      outgoing_set: &vector<address>,
    ) {
      CoreAddresses::assert_vm(vm);
      // Get the split of payments from Stats.
      let len = Vector::length<address>(outgoing_set);

      // reward per validator
      // print(&70001);
      let (reward_per, _, _) = ProofOfFee::get_consensus_reward();

      // // equal subsidy for all active validators
      // let subsidy_granted;
      // TODO: This calculation is duplicated with get_subsidy
      if (reward_per < 1 ) return; // arithmetic safety check

      // We draw from the network fee account.
      // It should already be funded with:
      // 1. Tx fees
      // 2. Proof of Fee, entry fees at clearning price
      // 3. Infra Escrow drawdown.
      // as such there should be sufficient coins to pay (we should not get an overdrawn error), and we check for that above.
      
      let nominal_cost_to_network = reward_per * len;
      // print(&70002);
      let balance_in_network_account = TransactionFee::get_fees_collected();
      // print(&balance_in_network_account);
      
      if (
        // the sum of consensus rewards should not be more than the
        // fees collected
        (nominal_cost_to_network > balance_in_network_account) || 
        // do nothing if fees are 0 (expected only in test mode)
        (balance_in_network_account < 1)
      ) return;

      // print(&70003);
      let check_sum = 0;      
      let i = 0;
      while (i < len) {
        // V6: there is no more minting in V6. Only drawing the
        // baseline reward from Network Fees account.

        // print(&700031);

        let coin = TransactionFee::get_transaction_fees_coins_amount(vm, reward_per);

        // safety
        if (Diem::value(&coin) < 1) {
          Diem::destroy_zero(coin);
          return
        };
        // print(&700032);

        check_sum = check_sum + Diem::value(&coin);
        // print(&700033);
        let val = Vector::borrow(outgoing_set, i);
        // print(val);
        DiemAccount::deposit<GAS> (
          @VMReserved,
          *val,
          coin,
          b"consensus_reward",
          b"",
          false,
        );
        // print(&700034);
        i = i + 1;
      };

      // V6: validators get their consensus_reward from the network fees account (transaction fees account). Any remainder at end of epoch is burnt (by Epoch Boundary calling TransactionFee)
    }

    // NOTE: 0L: removed code: operators no longer send tower proofs.
}
}