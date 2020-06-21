address 0x0 {
  module Subsidy {
    use 0x0::Transaction;
    use 0x0::GAS;
    use 0x0::Libra;
    use 0x0::Signer;
    use 0x0::LibraAccount;
    use 0x0::Vector;

    resource struct SubsidyInfo {
      subsidy_ceiling: u64,
      burn_accounts: vector<address>
    }

    struct T { }
    
    public fun initialize(account: &signer) {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18, 1002);
      move_to_sender<SubsidyInfo>(
        SubsidyInfo { 
          subsidy_ceiling: 10, 
          burn_accounts: Vector::empty<address>()
        });
    }

    public fun mint_subsidy(account: &signer) acquires SubsidyInfo{
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 1002);
      
      //Acquire subsidy info
      let subsidy_info = borrow_global<SubsidyInfo>(sender);
      let old_gas_balance = LibraAccount::balance<GAS::T>(sender);

      //Mint gas coin not returning the coin
      let minted_coins = Libra::mint<GAS::T>(account, subsidy_info.subsidy_ceiling);
      LibraAccount::deposit_to(account, minted_coins);

      //Check if balance is increased
      let new_gas_balance = LibraAccount::balance<GAS::T>(sender);
      Transaction::assert(new_gas_balance == old_gas_balance + subsidy_info.subsidy_ceiling, 1003);
    }

    // pub fun calculate_Subsidy(blockheight: u8){
    //   // Gets the proxy for liveness from Stats
    //   Stats.network_heuristics().signer_density_lookback(blockheight)

    //   // Gets the fees paid in the block from Stdlib.BlockMetadata
    //   // let fees_in_epoch = Stdlib.BlockMetadata.[Get fees paid]

    //   // subsidy_Curve(node_density) {
    //     // Returns the split bestween subsidy_units, burn_units according to curve.
    //     // return (subsidy_units, burn_units);
    //   //}
    // }

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

    public fun burn_subsidy(account: &signer, amount: u64) {
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 1002);
      
      //Preburning coins to association
      //TODO:OL:Need to change to list of accounts
      let to_burn_coins = LibraAccount::withdraw_from<GAS::T>(account, amount);
      Libra::preburn_to<GAS::T>(account, to_burn_coins);

      //Burn coin and check if market_cap is decreased
      let old_market_cap = Libra::market_cap<GAS::T>();
      Libra::burn<GAS::T>(account, sender);
      Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap - (amount as u128), 1005);
    }

    public fun add_burn_account(account:&signer, new_burn_account: address) acquires SubsidyInfo {
      //Need to check for association or vm account
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 1002);

      //TODO:OL:Need to check if account exists already
      //Get mutable burn accounts vector from association
      let subsidy_info = borrow_global_mut<SubsidyInfo>(sender);
      Vector::push_back(&mut subsidy_info.burn_accounts, new_burn_account);
    }

    public fun get_burn_accounts_size(account: &signer): u64 acquires SubsidyInfo {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 1002); 

      let subsidy_info = borrow_global<SubsidyInfo>(sender);
      Vector::length(&subsidy_info.burn_accounts)
    }
  }
}
