///////////////////////////////////////////////////////////////////////////
// 0L Module
// Subsidy 
///////////////////////////////////////////////////////////////////////////
// The logic for determining the appropriate level of subsidies at a given time in the network
// File Prefix for errors: 1901
///////////////////////////////////////////////////////////////////////////

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
    use 0x0::ValidatorUniverse;
    use 0x0::Globals;
    use 0x0::LibraTimestamp;
    // use 0x0::MinerState;
    use 0x0::Cases;

    // Subsidy ceiling yet to be updated from gas schedule.
    // Subsidy Ceiling = Max Trans Per Block (20) *
    // Max gas units per transaction (10_000_000) * blocks epoch (1_000_000)
    resource struct SubsidyInfo {
      burn_units: u64,
      burn_accounts: vector<address>
    }

    // Function code: 01 Prefix: 190101
    public fun initialize(account: &signer) {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190101014010);

      let burn_accounts = Globals::get_burn_accounts();

      move_to_sender<SubsidyInfo>(
        SubsidyInfo {// TODO : SubsidyInfo Constants can be hard coded in the Calc module instead of being a mutable resource.
          burn_units: 0,
          burn_accounts: burn_accounts
        });
    }

    // Minting subsidy called in the EpochPrologue/reconfiguration for the next validator set's upcoming epoch subsidies.
    // Function code: 02 Prefix: 190102
    public fun mint_subsidy(account: &signer) {

      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190102014010);
      //// Important Constant ////
      let subsidy_ceiling_gas = Globals::get_subsidy_ceiling_gas();

      // NOTE: Balance should be zero in this account at time of minting, because subsidies have
      // been paid in previous step.
      let old_gas_balance = LibraAccount::balance<GAS::T>(0x0);

      // TODO: mint_subsidy needs LibraAccount Balance, but reconfig is failing because there is
      // no balance initialized.
      let minted_coins = Libra::mint<GAS::T>(account, subsidy_ceiling_gas);
      LibraAccount::vm_deposit_with_metadata<GAS::T>(
        account,
        0x0,
        minted_coins,
        x"", x""
      );

      //Check if balance is increased
      let new_gas_balance = LibraAccount::balance<GAS::T>(0x0);

      // confirm transaction math.
      Transaction::assert(new_gas_balance == old_gas_balance + subsidy_ceiling_gas, 8002);
    }

    // Method to calculate subsidy split for an epoch.
    // This method should be used to get the units at the beginning of the epoch.
    // Function code: 07 Prefix: 190107
    public fun calculate_Subsidy()
    :u64 acquires SubsidyInfo {
      // let sender = Signer::address_of(account);
      Transaction::assert(Transaction::sender() == 0x0, 190107014010);
      
      // skip genesis
      //TODO use genesis timestamp.
      // Transaction::assert(start_height >= 0, 190107025120);
      Transaction::assert(!LibraTimestamp::is_genesis(), 190107025120);

      // Gets the proxy for liveliness from Stats
      let node_density = Stats::network_density();
      // Gets the transaction fees in the epoch
      // TODO: Check the balance here
      let txn_fee_amount = LibraAccount::balance<GAS::T>(0xFEE);

      // Calculate the split for subsidy and burn
      let (subsidy_units, burn_units) = subsidy_curve(
        Globals::get_subsidy_ceiling_gas(),
        4u64, // minimum number of nodes to be in consensus.
        Globals::get_max_node_density(),
        node_density
      );

      // // Deducting the txn fees from subsidy_units to get maximum subsidy for all validators
      let subsidy_info = borrow_global_mut<SubsidyInfo>(0x0);

      // //deduct transaction fees from minimum guarantee.
      subsidy_units = subsidy_units - txn_fee_amount;
      burn_units = burn_units + txn_fee_amount; //Adding the fee amount to be burned
      subsidy_info.burn_units = burn_units;
      subsidy_units
    }

    // Function code: 03 Prefix: 190103
    use 0x0::Debug::print;
    public fun process_subsidy(
      vm_sig: &signer,
      outgoing_validators: &vector<address>,
      outgoing_validator_weights: &vector<u64>,
      subsidy_units: u64,
      total_voting_power: u64,
      current_block_height: u64) {
      // Need to check for association or vm account
      let sender = Signer::address_of(vm_sig);
      Transaction::assert(sender == 0x0, 190103014010);

      let length = Vector::length<address>(outgoing_validators);

      let k = 0;
      while (k < length) {

        let node_address = *(Vector::borrow<address>(outgoing_validators, k));
        let voting_power = *(Vector::borrow<u64>(outgoing_validator_weights, k));
        print(&0x00000050B51D10000);
        print(&voting_power);
        print(&total_voting_power);

        
        if (total_voting_power == 0) total_voting_power = 1;
        // Accounting.
        // Validators get paid for successfully proposing blocks.
        // Validators are skipped from proposing if they have low network connectivity.
        // Proposer election is done in Rust with leader reputation.
        // TODO: Update this division of rewards.
        // % weight for calculating the subsidy units
        let subsidy_allowed = FixedPoint32::divide_u64(subsidy_units * voting_power, FixedPoint32::create_from_rational(total_voting_power, 1));

        // Subsidy is only paid if both mining and validation are active in the epoch

        // TODO: replace for Cases
        if(Cases::get_case(node_address, current_block_height) == 1){
          // Transfer gas from vm address to validator
          LibraAccount::pay_from<GAS::T>(vm_sig, node_address, subsidy_allowed);
        };

        k = k + 1;
      };

    }

    // Function code: 04 Prefix: 190104
    fun subsidy_curve(subsidy_ceiling_gas: u64, min_node_density: u64, max_node_density: u64, node_density: u64): (u64, u64) {
      //Slope calculation assuming (4, subsidy_ceiling_gas) and (300, 0)

      // Return early if we know the value is below 4.
      // This applies only to test environments where there is network of 1.
      if (node_density <= 4u64) {
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

    // Function code: 05 Prefix: 190105
    public fun burn_subsidy(account: &signer) acquires SubsidyInfo{
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190105014010);

      let subsidy_info = borrow_global<SubsidyInfo>(0x0);
      Transaction::assert(Vector::length(&subsidy_info.burn_accounts) > 0, 8005);

      //Preburning coins to burn account
      let burn_accounts = &subsidy_info.burn_accounts;
      let to_burn_coins = LibraAccount::withdraw_from<GAS::T>(account, subsidy_info.burn_units);
      let burn_address = Vector::borrow(burn_accounts, 0);
      Libra::preburn_to_address<GAS::T>({{*burn_address}}, to_burn_coins);

      // Burn coin and check if market_cap is decreased
      let old_market_cap = Libra::market_cap<GAS::T>();
      Libra::burn<GAS::T>(account, {{*burn_address}});

      Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap - (subsidy_info.burn_units as u128), 8006);
    }

    // Function code: 06 Prefix: 190106
    public fun genesis(account: &signer) {
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190106014010);
      mint_subsidy(account);

      // Get eligible validators list
      let genesis_validators = ValidatorUniverse::get_eligible_validators(account);
      let len = Vector::length(&genesis_validators);

      // Calculate subsidy equally for all the validators based on subsidy curve
      // Calculate the split for subsidy and burn
      // let subsidy_info = borrow_global_mut<SubsidyInfo>(0x0);
      let (subsidy_units, _burn_units) = subsidy_curve(
        Globals::get_subsidy_ceiling_gas(),
        4,
        Globals::get_max_node_density(),
        len
      );

      // Distribute gas coins to initial validators
      let distribution_units = subsidy_units / len;
      let i = 0;
      while (i < len) {
        let node_address = *(Vector::borrow<address>(&genesis_validators, i));
        let old_association_balance = LibraAccount::balance<GAS::T>(sender);
        let old_validator_balance = LibraAccount::balance<GAS::T>(node_address);

        //Transfer gas from association to validator
        LibraAccount::pay_from<GAS::T>(account, node_address, distribution_units);
        Transaction::assert(LibraAccount::balance<GAS::T>(sender) == old_association_balance - distribution_units, 8008);
        // confirm the calculations, and that the ending balance is incremented accordingly.
        Transaction::assert(LibraAccount::balance<GAS::T>(node_address) == old_validator_balance + distribution_units, 8009);
        i = i + 1;
      };
    }

    fun add_burn_account(account:&signer, new_burn_account: address) acquires SubsidyInfo {

      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190107014010);

      //TODO:0L:Need to check if account exists already
      //Get mutable burn accounts vector from association
      let subsidy_info = borrow_global_mut<SubsidyInfo>(0x0);
      Vector::push_back(&mut subsidy_info.burn_accounts, new_burn_account);
    }

    public fun get_burn_accounts_size(account: &signer): u64 acquires SubsidyInfo {

      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 190107014011);

      let subsidy_info = borrow_global<SubsidyInfo>(0x0);
      Vector::length(&subsidy_info.burn_accounts)
    }
  }
}
