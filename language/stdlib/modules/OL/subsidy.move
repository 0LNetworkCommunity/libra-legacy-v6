address 0x0 {
  module Subsidy {
    use 0x0::Transaction;
    use 0x0::GAS;
    use 0x0::Libra;
    use 0x0::Signer;
    use 0x0::LibraAccount;
    use 0x0::Vector;
    use 0x0::FixedPoint32;
    use 0x0::Stats;
    use 0x0::Debug;

    // Subsidy ceiling yet to be updated from gas schedule.
    // Subsidy Ceiling = Max Trans Per Block (20) *
    // Max gas units per transaction (10_000_000) * blocks epoch (1_000_000)
    resource struct SubsidyInfo {
      subsidy_ceiling_gas: u64,
      min_node_density: u64,
      max_node_density: u64,
      subsidy_units: u64,
      burn_units: u64,
      burn_accounts: vector<address>
    }

    public fun initialize(account: &signer) {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18, 8001);

      let burn_accounts = Vector::empty();
      Vector::push_back(&mut burn_accounts, 0xDEADDEAD);

      move_to_sender<SubsidyInfo>(
        SubsidyInfo {// TODO : SubsidyInfo Constants can be hard coded in the Calc module instead of being a mutable resource.
          // subsidy ceiling is
          subsidy_ceiling_gas: 296, //TODO:OL:Update this with actually subsidy ceiling in in GAS
          min_node_density: 4,
          max_node_density: 300,
          subsidy_units: 0,
          burn_units: 0,
          burn_accounts: burn_accounts
        });
    }

    // Minting subsidy called in the EpochPrologue/reconfiguration for the next validator set's upcoming epoch subsidies.
    public fun mint_subsidy(account: &signer) {


      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);
      Debug::print(&0x50B51DE0000000000000000000001001);
      //// Important Constant ////
      let subsidy_ceiling_gas = 296u64; //TODO:OL:Update this with actually subsidy ceiling in in GAS
      //// Important Constant ////

      //Acquire subsidy info
      // let subsidy_info = borrow_global<SubsidyInfo>(0xA550C18);

      // NOTE: Balance should be zero in this account at time of minting, because subsidies have
      // been paid in previous step.
      Debug::print(&0x50B51DE0000000000000000000001002);
      //Debug::print(account);

      let old_gas_balance = LibraAccount::balance<GAS::T>(0xA550C18);

      // TODO: mint_subsidy needs LibraAccount Balance, but reconfig is failing because there is
      // no balance initialized.
      let minted_coins = Libra::mint<GAS::T>(account, subsidy_ceiling_gas);
      LibraAccount::vm_deposit_with_metadata<GAS::T>(
        account,
        0xA550C18,
        minted_coins,
        x"", x""
      );
      Debug::print(&0x50B51DE0000000000000000000001003);

      //Check if balance is increased
      let new_gas_balance = LibraAccount::balance<GAS::T>(0xA550C18);
      Debug::print(&new_gas_balance);
      Debug::print(&0x50B51DE0000000000000000000001004);


      // confirm transaction math.
      Transaction::assert(new_gas_balance == old_gas_balance + subsidy_ceiling_gas, 8002);
    }

    // Method to calculate subsidy split for an epoch.
    // This method should be used to get the units at the beginning of the epoch.
    public fun calculate_Subsidy(account: &signer, start_height: u64, end_height: u64)
    :u64 acquires SubsidyInfo {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);
      Debug::print(&0x50B51DE0000000000000000000002001);

      // Gets the proxy for liveness from Stats
      let node_density = Stats::network_heuristics(start_height, end_height);
      Debug::print(&0x50B51DE0000000000000000000002002);

      // Gets the transaction fees in the epoch
      // TODO: Check the balance here
      let txn_fee_amount = LibraAccount::balance<GAS::T>(0xFEE);
      Debug::print(&0x50B51DE0000000000000000000002003);

      // Calculate the split for subsidy and burn
      let subsidy_info = borrow_global_mut<SubsidyInfo>(0xA550C18);
      Debug::print(&0x50B51DE0000000000000000000002004);
      Debug::print(&subsidy_info.subsidy_ceiling_gas);
      Debug::print(&subsidy_info.min_node_density);
      Debug::print(&subsidy_info.max_node_density);
      Debug::print(&node_density);

      let (subsidy_units, burn_units) = subsidy_curve(
        subsidy_info.subsidy_ceiling_gas,
        subsidy_info.min_node_density,
        subsidy_info.max_node_density,
        node_density
      );
      Debug::print(&0x50B51DE0000000000000000000002005);

      // Deducting the txn fees from subsidy_units to get maximum subsidy for all validators
      subsidy_units = subsidy_units - txn_fee_amount;
      burn_units = burn_units + txn_fee_amount; //Adding the fee amount to be burned
      subsidy_info.burn_units = burn_units;
      Debug::print(&0x50B51DE0000000000000000000002006);
      subsidy_units
    }

    public fun process_subsidy(account: &signer, outgoing_validators: &vector<address>,
                               outgoing_validator_weights: &vector<u64>, subsidy_units: u64,
                               total_voting_power: u64) {
      // Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);
      Debug::print(&0x50B51DE0000000000000000000003001);


      let length = Vector::length<address>(outgoing_validators);
      Debug::print(&0x50B51DE0000000000000000000003002);

      let k = 0;
      while (k < length) {
        Debug::print(&0x50B51DE000000000000000000003003);

        let node_address = *(Vector::borrow<address>(outgoing_validators, k));
        let voting_power = *(Vector::borrow<u64>(outgoing_validator_weights, k));

        // % weight for calculating the subsidy units
        let subsidy_allowed = FixedPoint32::divide_u64(subsidy_units * voting_power,
                          FixedPoint32::create_from_rational(total_voting_power, 1));

        //Get balances before transfer from association and node_address
        // TODO: The GAS for subsidy needs to be stored elsewhere than association account. Perhaps 0x0?
        // this fails on the first epoch as there is no gas.
        let old_association_balance = LibraAccount::balance<GAS::T>(sender);
        let old_validator_balance = LibraAccount::balance<GAS::T>(node_address);

        //Transfer gas from association to validator
        LibraAccount::pay_from<GAS::T>(account, node_address, subsidy_allowed);
        Transaction::assert(LibraAccount::balance<GAS::T>(sender) == old_association_balance - subsidy_allowed, 8004);
        // confirm the calculations, and that the ending balance is incremented accordingly.
        Transaction::assert(LibraAccount::balance<GAS::T>(node_address) == old_validator_balance + subsidy_allowed, 8004);
        k = k + 1;
      };

    }

    fun subsidy_curve(subsidy_ceiling_gas: u64, min_node_density: u64, max_node_density: u64, node_density: u64): (u64, u64) {
      //Slope calculation assuming (4, subsidy_ceiling_gas) and (300, 0)
      Debug::print(&0x50B51DE0000000000000000000004001);

      // Return early if we know the value is below 4.
      // This applies only to test environments where there is network of 1.
      if (node_density <= 4u64) {
        Debug::print(&0x50B51DE00000000000000000DEAD4002);
        return (subsidy_ceiling_gas, 0u64)
      };

      let slope = FixedPoint32::divide_u64(
        (subsidy_ceiling_gas),
        FixedPoint32::create_from_rational(max_node_density - min_node_density, 1)
        );
      //y-intercept
      let intercept = slope * max_node_density;
      //calculating subsidy and burn units
      // NOTE: confirm order of operations here:
      let subsidy_units = intercept - slope * node_density;
      let burn_units = subsidy_ceiling_gas - subsidy_units;
      (subsidy_units, burn_units)
    }

    public fun burn_subsidy(account: &signer) acquires SubsidyInfo{
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);
      Debug::print(&0x50B51DE0000000000000000000005001);


      let subsidy_info = borrow_global<SubsidyInfo>(0xA550C18);
      Transaction::assert(Vector::length(&subsidy_info.burn_accounts) > 0, 8005);

      //Preburning coins to burn account
      let burn_accounts = &subsidy_info.burn_accounts;
      let to_burn_coins = LibraAccount::withdraw_from<GAS::T>(account, subsidy_info.burn_units);
      let burn_address = Vector::borrow(burn_accounts, 0);
      Libra::preburn_to_address<GAS::T>({{*burn_address}}, to_burn_coins);

      Debug::print(&0x50B51DE0000000000000000000005002);

      // Burn coin and check if market_cap is decreased
      let old_market_cap = Libra::market_cap<GAS::T>();
      Libra::burn<GAS::T>(account, {{*burn_address}});
      Debug::print(&0x50B51DE0000000000000000000005003);

      Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap - (subsidy_info.burn_units as u128), 8006);
    }

    fun add_burn_account(account:&signer, new_burn_account: address) acquires SubsidyInfo {
      Debug::print(&0x50B51DE0000000000000000000006001);

      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);

      //TODO:OL:Need to check if account exists already
      //Get mutable burn accounts vector from association
      let subsidy_info = borrow_global_mut<SubsidyInfo>(0xA550C18);
      Vector::push_back(&mut subsidy_info.burn_accounts, new_burn_account);
    }

    public fun get_burn_accounts_size(account: &signer): u64 acquires SubsidyInfo {
      Debug::print(&0x50B51DE0000000000000000000007001);

      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);

      let subsidy_info = borrow_global<SubsidyInfo>(0xA550C18);
      Vector::length(&subsidy_info.burn_accounts)
    }
  }
}
