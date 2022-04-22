address 0x1 {
module Burn {
  use 0x1::Wallet;
  use 0x1::FixedPoint32;
  use 0x1::Vector;
  use 0x1::DiemAccount;
  use 0x1::CoreAddresses;
  use 0x1::GAS::GAS;
  use 0x1::Signer;
  use 0x1::Debug::print;

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
    let list = Wallet::get_comm_list();
    print(&300400100);

    let len = Vector::length(&list);
    let i = 0;
    let global_deposits = 0;
    let deposit_vec = Vector::empty<u64>();
print(&300400200);
    while (i < len) {

      let addr = *Vector::borrow(&list, i);
      let cumu = DiemAccount::get_index_cumu_deposits(addr);
      // print(&cumu);
      global_deposits = global_deposits + cumu;
      Vector::push_back(&mut deposit_vec, cumu);
      i = i + 1;
    };
print(&300400300);
print(&deposit_vec);
    let ratios_vec = Vector::empty<FixedPoint32::FixedPoint32>();
    let k = 0;
    while (k < len) {
      let cumu = *Vector::borrow(&deposit_vec, k);

      if (cumu == 0) {
        k = k + 1; 
        continue
      };
print(&300400400);
print(&ratios_vec);

      let ratio = FixedPoint32::create_from_rational(cumu, global_deposits);
      Vector::push_back(&mut ratios_vec, ratio);
      k = k + 1;
    };
print(&300400500);

    if (exists<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS())) {
      print(&300400501);

      let d = borrow_global_mut<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS());
      d.addr = list;
      d.deposits = deposit_vec;
      d.ratio = ratios_vec;
    } else {
    print(&300400502);

      move_to<DepositInfo>(vm, DepositInfo {
        addr: list,
        deposits: deposit_vec,
        ratio: ratios_vec,
      })
    }
  }

  fun get_address_list(): vector<address> acquires DepositInfo {
    if (!exists<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS())) return Vector::empty<address>();
    *&borrow_global<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS()).addr
  }

  fun get_value(payee: address, value: u64): u64 acquires DepositInfo {
    print(&3005201);
    if (!exists<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS())) return 0;
    print(&3005202);

    let d = borrow_global<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS());
    print(&3005203);

    let (is_found, i) = Vector::index_of(&d.addr, &payee);
    print(&3005204);
    if (is_found) {
      let ratio = *Vector::borrow(&d.ratio, i);
      return FixedPoint32::multiply_u64(value, ratio)
    };
    0
  }

  public fun epoch_start_burn(vm: &signer, payer: address, value: u64) acquires DepositInfo, BurnPreference {
    CoreAddresses::assert_vm(vm);
    print(&300500);
    if (exists<BurnPreference>(payer)) {
      print(&300510);
      if (borrow_global<BurnPreference>(payer).send_community) {

        return send(vm, payer, value)
      } else {
        return burn(vm, payer, value)
      }
    } else {
      print(&300520);

      send(vm, payer, value);
    };
      print(&300530);

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
    // print(&list);
    let i = 0;
    while (i < len) {
      let payee = *Vector::borrow<address>(&list, i);
      // print(&payee);

      let val = get_value(payee, value);
      // print(&val);

      DiemAccount::vm_make_payment_no_limit<GAS>(
          payer,
          payee,
          val,
          b"epoch start send",
          b"",
          vm,
      );
      
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
  public fun get_ratios(): (vector<address>, vector<u64>, vector<FixedPoint32::FixedPoint32>) acquires DepositInfo {
    let d = borrow_global<DepositInfo>(CoreAddresses::VM_RESERVED_ADDRESS());
    (*&d.addr, *&d.deposits, *&d.ratio)

  }

  //////// TEST HELPERS ////////
  
}
}
