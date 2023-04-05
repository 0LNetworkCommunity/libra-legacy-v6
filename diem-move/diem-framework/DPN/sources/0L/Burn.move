address DiemFramework {
module Burn {
  use DiemFramework::DonorDirected;
  use Std::FixedPoint32;
  use Std::Vector;
  use DiemFramework::DiemAccount;
  use DiemFramework::CoreAddresses;
  use DiemFramework::GAS::GAS;
  use DiemFramework::TransactionFee;
  use Std::Signer;
  use DiemFramework::Diem::{Self, Diem};

  struct BurnPreference has key {
    send_community: bool
  }

  struct DepositInfo has key {
    addr: vector<address>,
    deposits: vector<u64>,
    ratio: vector<FixedPoint32::FixedPoint32>,
  }


  public fun epoch_burn_fees(
      vm: &signer,
  )  acquires BurnPreference, DepositInfo {
      CoreAddresses::assert_vm(vm);

      // extract fees
      let coins = TransactionFee::vm_withdraw_all_coins<GAS>(vm);

      // get the list of fee makers
      let fee_makers = TransactionFee::get_fee_makers();
      
      let len = Vector::length(&fee_makers);

      // for every user in the list burn their fees per Burn.move preferences
      let i = 0;
      while (i < len) {
          let user = Vector::borrow(&fee_makers, i);
          let amount = TransactionFee::get_epoch_fees_made(*user);
          let user_share = Diem::withdraw(&mut coins, amount);
          burn_or_recycle_user_fees(vm, *user, user_share);

          i = i + 1;
      };

    // Transaction fee account should be empty at the end of the epoch
    // Superman 3 decimal errors. https://www.youtube.com/watch?v=N7JBXGkBoFc
    // anything that is remaining should be burned
    Diem::vm_burn_this_coin(vm, coins); 
  }


  public fun reset_ratios(vm: &signer) acquires DepositInfo {
    CoreAddresses::assert_diem_root(vm);
    let list = DonorDirected::get_root_registry();

    let len = Vector::length(&list);
    let i = 0;
    let global_deposits = 0;
    let deposit_vec = Vector::empty<u64>();

    while (i < len) {

      let addr = *Vector::borrow(&list, i);
      let cumu = DiemAccount::get_index_cumu_deposits(addr);

      global_deposits = global_deposits + cumu;
      Vector::push_back(&mut deposit_vec, cumu);
      i = i + 1;
    };

    if (global_deposits == 0) return;

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
    }
  }

  fun get_address_list(): vector<address> acquires DepositInfo {
    if (!exists<DepositInfo>(@VMReserved))
      return Vector::empty<address>();

    *&borrow_global<DepositInfo>(@VMReserved).addr
  }

  // calculate the ratio which the community wallet should receive
  fun get_payee_value(payee: address, value: u64): u64 acquires DepositInfo {
    if (!exists<DepositInfo>(@VMReserved)) 
      return 0;

    let d = borrow_global<DepositInfo>(@VMReserved);
    let _contains = Vector::contains(&d.addr, &payee);
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

  public fun burn_or_recycle_user_fees(
    vm: &signer, payer: address, user_share: Diem<GAS>
  ) acquires DepositInfo, BurnPreference {
    CoreAddresses::assert_vm(vm);
    if (exists<BurnPreference>(payer)) {
      if (borrow_global<BurnPreference>(payer).send_community) {
        recycle(vm, payer, &mut user_share);
      }
    };

    // Superman 3
    Diem::vm_burn_this_coin(vm, user_share);
  }


  fun recycle(vm: &signer, payer: address, coin: &mut Diem<GAS>) acquires DepositInfo {
    let list = get_address_list();
    let len = Vector::length<address>(&list);


    let total_coin_value_to_recycle = Diem::value(coin);

    // There could be errors in the array, and underpayment happen.
    let value_sent = 0;

    let i = 0;
    while (i < len) {

      let payee = *Vector::borrow<address>(&list, i);
      let amount_to_payee = get_payee_value(payee, total_coin_value_to_recycle);
      let to_deposit = Diem::withdraw(coin, amount_to_payee);

      DiemAccount::vm_deposit_with_metadata<GAS>(
          vm,
          payer,
          payee,
          to_deposit,
          b"recycle",
          b"",
      );
      value_sent = value_sent + amount_to_payee;      
      i = i + 1;
    };
  }

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

  //////// TEST HELPERS ////////
  
}
}
