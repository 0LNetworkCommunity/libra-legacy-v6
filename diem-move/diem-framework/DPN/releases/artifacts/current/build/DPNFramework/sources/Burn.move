address DiemFramework {
module Burn {
  use DiemFramework::Wallet;
  use Std::FixedPoint32;
  use Std::Vector;
  use DiemFramework::DiemAccount;
  use DiemFramework::CoreAddresses;
  use DiemFramework::GAS::GAS;
  use Std::Signer;
  use DiemFramework::Debug::print;
  use DiemFramework::Diem;
  use DiemFramework::TransactionFee;
  use DiemFramework::DiemSystem;
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
    print(&300000);
    print(&len);
    while (i < len) {

      let addr = *Vector::borrow(&list, i);
      let cumu = DiemAccount::get_index_cumu_deposits(addr);
      print(&cumu);
      global_deposits = global_deposits + cumu;
      Vector::push_back(&mut deposit_vec, cumu);
      i = i + 1;
    };

    print(&300001);

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
      print(&cumu);

      let ratio = FixedPoint32::create_from_rational(cumu, global_deposits);
      print(&ratio);

      Vector::push_back(&mut ratios_vec, ratio);
      k = k + 1;
    };
    print(&300002);
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
    print(&300003);
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
    let contains = Vector::contains(&d.addr, &payee);
    print(&contains);
    let (is_found, i) = Vector::index_of(&d.addr, &payee);
    if (is_found) {
      print(&is_found);
      let len = Vector::length(&d.ratio);
      print(&i);
      print(&len);
      if (i + 1 > len) return 0;
      let ratio = *Vector::borrow(&d.ratio, i);
      if (FixedPoint32::is_zero(copy ratio)) return 0;
      print(&ratio);
      return FixedPoint32::multiply_u64(value, ratio)
    };

    0
  }

  public fun burn_network_fees(
    vm: &signer,
    clearing: u64 // what was the clearing price of the auction for purposes of calculating recycling.
  ) acquires DepositInfo, BurnPreference {
    // let amount_remaining = TransactionFee::get_amount_to_distribute(vm);
    let coins = TransactionFee::get_transaction_fees_coins<GAS>(vm);

    let (burners, amount_to_comm) = get_community_recycling(clearing);
    let len_burners = Vector::length(&burners);
    if (amount_to_comm < len_burners) {
      Diem::vm_burn_this_coin(vm, coins);
      return
    };


    let (comm_addr_list, _, comm_split_list) = get_ratios();

    let len = Vector::length(&comm_addr_list);

    let i = 0;
  

    while (i < len) {
      let comm_wall = Vector::borrow(&comm_addr_list, i);
      let wall_split = Vector::borrow(&comm_split_list, i);

      let coin_val = FixedPoint32::multiply_u64(amount_to_comm, *wall_split);
      let split = Diem::withdraw(&mut coins, coin_val);

      send_coin_to_comm_wallet(vm, *comm_wall, split);

      // write the correct receipt amount to each validator who opted to send to community wallet. The communit wallets give some governance rights to donors.
      let k = 0;
      while (k < len_burners) {
        let burner = Vector::borrow(&burners, k);
        let this_split = coin_val/len_burners;
        Receipts::write_receipt(vm, *burner, *comm_wall, this_split);
        k = k + 1;
      };
      
    };

    // anything that is remaining should be burnt
    Diem::vm_burn_this_coin(vm, coins);
    
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
    fun get_community_recycling(clearing: u64): (vector<address>, u64) acquires BurnPreference {
      let burners = Vector::empty<address>();
      // let total_payments = 0;
      let total_payments_of_comm_senders = 0;

      // reward and clearing price per validator
      // let (_, clearing, _) = ProofOfFee::get_consensus_reward();

      // find burn preferences of ALL previous validator set
      // the potential amount burned is only the entry fee (the auction clearing price)
      let all_vals = DiemSystem::get_val_set_addr();

      let len = Vector::length(&all_vals);
      let i = 0;
      while (i < len) {
        let a = Vector::borrow(&all_vals, i);


        // total_payments = total_payments + clearing;

        let is_to_community = get_user_pref(a);

        if (is_to_community) {
          Vector::push_back(&mut burners, *a);
          total_payments_of_comm_senders = total_payments_of_comm_senders + clearing;
        };

        i = i + 1;
      };

      // // find burn preferences of ALL Infra Escrow pledgers.
      // let all_pledged = PledgeAccounts::get_all_pledgers(&@VMReserved);

      // // The pledgers paid from Infra Escrow, the nominal consensus reward.
      // // add those up and find proportions.
      
      // let len = Vector::length(&all_pledged);
      // let i = 0;
      // while (i < len) {
      //   let a = Vector::borrow(&all_pledged, i);

      //   total_payments = total_payments + reward;

      //   let is_to_community = Burn::get_user_pref(a);

      //   if (is_to_community) {
      //     Vector::push_back(&mut burners, a);
      //     total_payments_of_comm_senders = total_payments_of_comm_senders + reward;
      //   };

      //   i = i + 1;
      // };


      // let ratio = FixedPoint32::create_from_rational(total_payments_of_comm_senders, total_payments)

      // return the list of burners, for tracking, and the weighted average.
      (burners, total_payments_of_comm_senders)

    }

  // public fun epoch_start_burn(
  //   vm: &signer, payer: address, value: u64
  // ) acquires DepositInfo, BurnPreference {
  //   CoreAddresses::assert_vm(vm);

  //   if (exists<BurnPreference>(payer)) {
  //     if (borrow_global<BurnPreference>(payer).send_community) {
  //       return send(vm, payer, value)
  //     } else {
  //       return burn(vm, payer, value)
  //     }
  //   } else {
  //     burn(vm, payer, value);
  //   }; 
  // }

  // fun burn(vm: &signer, addr: address, value: u64) {
  //     DiemAccount::vm_burn_from_balance<GAS>(
  //       addr,
  //       value,
  //       b"burn",
  //       vm,
  //     );      
  // }


  // fun send(vm: &signer, payer: address, value: u64) acquires DepositInfo {
  //   let list = get_address_list();
  //   let len = Vector::length<address>(&list);
  //   print(&list);
    
  //   // There could be errors in the array, and underpayment happen.
  //   let value_sent = 0;

  //   let i = 0;
  //   while (i < len) {
  //     let payee = *Vector::borrow<address>(&list, i);
  //     print(&payee);
  //     let val = get_value(payee, value);
  //     print(&val);
      
  //     DiemAccount::vm_make_payment_no_limit<GAS>(
  //         payer,
  //         payee,
  //         val,
  //         b"epoch start send",
  //         b"",
  //         vm,
  //     );
  //     value_sent = value_sent + val;      
  //     i = i + 1;
  //   };

  //   // prevent under-burn due to issues with index.
  //   let diff = value - value_sent;
  //   if (diff > 0) {
  //     burn(vm, payer, diff)
  //   };    
  // }

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
    borrow_global<BurnPreference>(*user).send_community
  }

  //////// TEST HELPERS ////////
  
}
}
