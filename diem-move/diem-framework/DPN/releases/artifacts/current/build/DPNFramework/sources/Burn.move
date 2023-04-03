address DiemFramework {
module Burn {
  use DiemFramework::DonorDirected;
  use Std::FixedPoint32;
  use Std::Vector;
  use DiemFramework::DiemAccount;
  use DiemFramework::CoreAddresses;
  use DiemFramework::GAS::GAS;
  use Std::Signer;
  use DiemFramework::Debug::print;

  struct BurnPreference has key {
    send_community: bool
  }

  struct DepositInfo has key {
    addr: vector<address>,
    deposits: vector<u64>,
    ratio: vector<FixedPoint32::FixedPoint32>,
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

    let ratios_vec = Vector::empty<FixedPoint32::FixedPoint32>();
    let k = 0;
    while (k < len) {
      let cumu = *Vector::borrow(&deposit_vec, k);

      let ratio = FixedPoint32::create_from_rational(cumu, global_deposits);
      print(&ratio);

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

  public fun epoch_start_burn(
    vm: &signer, payer: address, value: u64
  ) acquires DepositInfo, BurnPreference {
    CoreAddresses::assert_vm(vm);

    if (exists<BurnPreference>(payer)) {
      if (borrow_global<BurnPreference>(payer).send_community) {
        return send(vm, payer, value)
      } else {
        return burn(vm, payer, value)
      }
    } else {
      burn(vm, payer, value);
    }; 
  }

  fun burn(vm: &signer, addr: address, value: u64) {
      DiemAccount::vm_burn_from_balance<GAS>(
        addr,
        value,
        b"burn",
        vm,
      );      
  }


  fun send(vm: &signer, payer: address, value: u64) acquires DepositInfo {
    let list = get_address_list();
    let len = Vector::length<address>(&list);
    print(&list);
    
    // There could be errors in the array, and underpayment happen.
    let value_sent = 0;

    let i = 0;
    while (i < len) {
      let payee = *Vector::borrow<address>(&list, i);
      print(&payee);
      let val = get_value(payee, value);
      print(&val);
      
      DiemAccount::vm_make_payment_no_limit<GAS>(
          payer,
          payee,
          val,
          b"epoch start send",
          b"",
          vm,
      );
      value_sent = value_sent + val;      
      i = i + 1;
    };

    // prevent under-burn due to issues with index.
    // let diff = value - value_sent;
    // if (diff > 0) {
    //   burn(vm, payer, diff)
    // };    
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
