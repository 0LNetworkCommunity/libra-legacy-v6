address DiemFramework {
module Burn {
  use DiemFramework::Wallet;
  use Std::FixedPoint32;
  use Std::Vector;
  use DiemFramework::DiemAccount;
  use DiemFramework::CoreAddresses;
  use DiemFramework::GAS::GAS;
  use Std::Signer;
  // use DiemFramework::Debug::print;
  use DiemFramework::Diem;
  use DiemFramework::TransactionFee;
  // use DiemFramework::DiemSystem;
  use DiemFramework::Receipts;

  struct BurnPreference has key {
    send_community: bool
  }

  struct DepositInfo has key {
    addr: vector<address>,
    deposits: vector<u64>,
    ratio: vector<FixedPoint32::FixedPoint32>,
  }

  // This function recalculates the index of the matching donations
  // for all community wallets.

  public fun reset_ratios(vm: &signer) acquires DepositInfo {
    CoreAddresses::assert_diem_root(vm);

    // First find the list of all community wallets
    // fail fast if none are found
    let list = Wallet::get_comm_list();
    let len = Vector::length(&list);
    if (len == 0) return;

    let i = 0;
    let global_deposits = 0;
    let deposit_vec = Vector::empty<u64>();

    // Now we loop through all the community wallets
    // and find the comulative deposits to that wallet.
    // we make a table from that (a new list)
    // we also take a tally of the global amount of deposits
    // Note that we are using a time-weighted index of deposits
    // which favors most recent deposits. (see DiemAccount::deposit_index_curve)

    while (i < len) {

      let addr = *Vector::borrow(&list, i);
      let cumu = DiemAccount::get_index_cumu_deposits(addr);
      global_deposits = global_deposits + cumu;
      Vector::push_back(&mut deposit_vec, cumu);
      i = i + 1;
    };
    // check if anything went wrong, and we don't have any cumulatives
    // to calculate.
    if (global_deposits == 0) return;

    // Now we loop through the table and calculate the ratio
    // since we now know the global total of the ajusted cumulative deposits.
    // and here we create another columns in our table (another list).
    // this is a list of fixedpoint ratios.
    let ratios_vec = Vector::empty<FixedPoint32::FixedPoint32>();
    let k = 0;
    while (k < len) {
      let cumu = *Vector::borrow(&deposit_vec, k);
      let ratio = FixedPoint32::create_from_rational(cumu, global_deposits);
      Vector::push_back(&mut ratios_vec, ratio);
      k = k + 1;
    };
    if (exists<DepositInfo>(@VMReserved)) {
      let d = borrow_global_mut<DepositInfo>(@VMReserved);
      d.addr = list;
      d.deposits = deposit_vec;
      d.ratio = ratios_vec;
    } else {
      move_to<DepositInfo>(vm, DepositInfo {
        addr: list,
        deposits: deposit_vec,
        ratio: ratios_vec,
      })
    };
  }

  fun get_address_list(): vector<address> acquires DepositInfo {
    if (!exists<DepositInfo>(@VMReserved))
      return Vector::empty<address>();

    *&borrow_global<DepositInfo>(@VMReserved).addr
  }

  // calculate the ratio which the community wallet should receive
  fun get_value(payee: address, value: u64): u64 acquires DepositInfo {
    if (!exists<DepositInfo>(@VMReserved)) 
      return 0;

    let d = borrow_global<DepositInfo>(@VMReserved);

    let (is_found, i) = Vector::index_of(&d.addr, &payee);
    if (is_found) {

      let len = Vector::length(&d.ratio);

      if (i + 1 > len) return 0;
      let ratio = *Vector::borrow(&d.ratio, i);
      if (FixedPoint32::is_zero(copy ratio)) return 0;
      return FixedPoint32::multiply_u64(value, ratio)
    };

    0
  }

  public fun process_network_burn(
    vm: &signer,
    all_vals: vector<address>,
    auction_entry_fee: u64,    
  ) acquires BurnPreference, DepositInfo {
    let fee_amount_remaining = TransactionFee::get_amount_to_distribute(vm);
    if (fee_amount_remaining == 0) return;

    let network_fee_coin = TransactionFee::get_transaction_fees_coins<GAS>(vm);

    let (recyclers, amount_to_comm) = calc_community_recycling(all_vals, auction_entry_fee);
    burn_or_recycle(vm, network_fee_coin, recyclers, amount_to_comm);
  }


  // TODO: this should only be public for testing.
  public fun burn_or_recycle(
    vm: &signer,
    network_fees: Diem::Diem<GAS>,
    burners: vector<address>,
    amount_to_comm: u64,
  ) acquires DepositInfo {
    // print(&4040);

    // print(&amount_to_comm);
    if ((amount_to_comm > 0) && (amount_to_comm > Vector::length(&burners))){
      // print(&404001);

      if (Diem::value(&network_fees) > amount_to_comm) {
              let split_to_community = Diem::withdraw(&mut network_fees, amount_to_comm);
        // print(&404002);
      maybe_recycle_burn(vm, burners, split_to_community);
      }

    };

    // print(&4041);

 
    // Everything else is burnt
    if (Diem::value(&network_fees) > 0) {
      Diem::vm_burn_this_coin(vm, network_fees);
    } else {
      Diem::destroy_zero(network_fees);
    };
    //  print(&4043); 
  }
  


  // We want the validators who are paying the entry fee to be
  // the counterparty to the donation in the burn recycling (donating to community wallet index);
  // For that we need to slice and dice: get the proportion each wallet gets
  // per the index. And then each validator pays an equal split of that amount.
  // WARN: lots of looping here
  public fun maybe_recycle_burn(
    vm: &signer,
    burners: vector<address>,
    coin_to_community: Diem::Diem<GAS>,
  ) acquires DepositInfo {
    // print(&6060);
    CoreAddresses::assert_vm(vm);
    let amount_to_comm = Diem::value(&coin_to_community);
    let len_burners = Vector::length(&burners);

    // get the proportion each communitt wallet should receive.
    let (comm_addr_list, _, comm_split_list) = get_ratios();

    // let len = Vector::length(&comm_addr_list);
    // print(&6061);

    let i = 0;
    // First lets loop through each community wallet.
    // then for each wallet, we loop through each "recycler" validator
    // so that we can send the donation on their behalf, for tracking
    // and governance purposes.
    while (i < Vector::length(&comm_addr_list)) {
      // print(&606101);

      let comm_wall = Vector::borrow(&comm_addr_list, i);
      let wall_split = Vector::borrow(&comm_split_list, i);

      // let pct = FixedPoint32::multiply_u64(100, *wall_split);
      // print(&pct);
      // print(&606102);
      let amount_to_wallet = FixedPoint32::multiply_u64(amount_to_comm, *wall_split);
      // print(&606103);
      let split_coin_to_wallet  = Diem::withdraw(&mut coin_to_community, amount_to_wallet);
      // print(&606104);

      // write the correct receipt amount to each validator who opted to send to community wallet. The communit wallets give some governance rights to donors.
      
      let k = 0;
      let per_val_split = amount_to_wallet / Vector::length(&burners);
      // every recycler sends the same amount.
      while (k < len_burners) {

        // print(&60610401);
        let burner = Vector::borrow(&burners, k);
        //  print(&60610402);
        let split_wallet_split_val = Diem::withdraw(&mut split_coin_to_wallet, per_val_split);
        //  print(&60610403);
        

        send_coin_to_comm_wallet(vm, *comm_wall, split_wallet_split_val);
        // print(&60610404);
        Receipts::write_receipt(vm, *burner, *comm_wall, per_val_split);
        // print(&60610405);
        k = k + 1;
      };
      
      // if there's anything left over per wallet. Likely from rounding. We burn it.
      if (Diem::value(&split_coin_to_wallet) > 0) {
        Diem::vm_burn_this_coin(vm, split_coin_to_wallet);
      } else {
        Diem::destroy_zero(split_coin_to_wallet);
      };
      i = i + 1;
    };

    // anything left over from the coins passed in, needs to be returned
    // to be handled by the caller.

    if (Diem::value(&coin_to_community) > 0) {
      Diem::vm_burn_this_coin(vm, coin_to_community);
    } else {
      Diem::destroy_zero(coin_to_community);
    };

  }

  fun send_coin_to_comm_wallet(
    vm: &signer,
    comm_wallet: address,
    coin: Diem::Diem<GAS>,
  ) {
    CoreAddresses::assert_vm(vm);
    DiemAccount::deposit(
      @VMReserved,
      comm_wallet,
      coin,
      b"epoch burn",
      b"",
      false,
    );
  }


    // based on the nominal consensus_reward, and the auction entry fee (clearing_price) we calculate where an eventual burn would go: pure burn, or recycle.
    // returns the list of addresses burning, and the proportion of fees to burn.
    // TODO: make public only for tests
    public fun calc_community_recycling(all_vals: vector<address>, clearing: u64): (vector<address>, u64) acquires BurnPreference {
      let burners = Vector::empty<address>();
      // let total_payments = 0;
      let total_payments_of_comm_senders = 0;
      // print(&5050);

      // find burn preferences of ALL previous validator set
      // the potential amount burned is only the entry fee (the auction clearing price)
      // let all_vals = DiemSystem::get_val_set_addr();
      // print(&5051);
      let len = Vector::length(&all_vals);
      let i = 0;
      while (i < len) {
        let a = Vector::borrow(&all_vals, i);

        // print(&5052);
        // total_payments = total_payments + clearing;

        let is_to_community = get_user_pref(a);
        // print(&5053);
        if (is_to_community) {
          Vector::push_back(&mut burners, *a);
          total_payments_of_comm_senders = total_payments_of_comm_senders + clearing;
        };
        // print(&5054);
        i = i + 1;
      };

      // print(&5055);
      // return the list of burners, for tracking, and the weighted average.
      (burners, total_payments_of_comm_senders)

    }

  // V6: Logic for burning updated

  // helper function for tx script for user to update burn preferences
  public fun set_send_community(sender: &signer, community: bool) acquires BurnPreference {
    let addr = Signer::address_of(sender);
    if (exists<BurnPreference>(addr)) {
      let b = borrow_global_mut<BurnPreference>(addr);
      b.send_community = community;
    } else {
      move_to<BurnPreference>(sender, BurnPreference {
        send_community: community
      });
    }
  }

  //////// GETTERS ////////
  public fun get_ratios(): 
    (vector<address>, vector<u64>, vector<FixedPoint32::FixedPoint32>) acquires DepositInfo 
  {
    let d = borrow_global<DepositInfo>(@VMReserved);
    (*&d.addr, *&d.deposits, *&d.ratio)
  }

  public fun get_user_pref(user: &address): bool acquires BurnPreference{
    if (exists<BurnPreference>(*user)) {
      borrow_global<BurnPreference>(*user).send_community
    } else {
      false
    }
  }

  //////// TEST HELPERS ////////
  
}
}
