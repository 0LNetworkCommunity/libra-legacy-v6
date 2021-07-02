address 0x1 {
module Burn {
  use 0x1::Wallet;
  use 0x1::FixedPoint32;
  use 0x1::Vector;
  use 0x1::LibraAccount;
  use 0x1::CoreAddresses;
  use 0x1::GAS::GAS;

  resource struct DepositInfo {
    addr: vector<address>,
    deposits: vector<u64>,
    ratio: vector<FixedPoint32::FixedPoint32>,
    total: u64,
  }


  public fun set_ratios(vm: &signer) acquires DepositInfo {
    CoreAddresses::assert_libra_root(vm);

    let list = Wallet::get_comm_list();
    let len = Vector::length(&list);
    let i = 0;
    let global_deposits = 0;
    let deposit_vec = Vector::empty<u64>();
    while (i < len) {
      let addr = *Vector::borrow(&list, i);
      let cumu = LibraAccount::get_cumulative_deposits(addr);
      global_deposits = global_deposits + cumu;
      Vector::push_back(&mut deposit_vec, cumu);
      i = i + 1;
    };

    let ratios_vec = Vector::empty<FixedPoint32::FixedPoint32>();
    while (i < len) {
      let cumu = *Vector::borrow(&deposit_vec, i);
      let ratio = FixedPoint32::create_from_rational(cumu, global_deposits);
      Vector::push_back(&mut ratios_vec, ratio);
      i = i + 1;
    };
    let d = borrow_global_mut<DepositInfo>(0x0);
    d.addr = list;
    d.deposits = deposit_vec;
    d.ratio = ratios_vec;
    d.total = global_deposits;
  }

  fun get_address_list(): vector<address> acquires DepositInfo {
    *&borrow_global<DepositInfo>(0x0).addr
  }
  fun get_value(payee: address, value: u64): u64 acquires DepositInfo {
    let d = borrow_global<DepositInfo>(0x0);
    let (_, i) = Vector::index_of(&d.addr, &payee);
    let ratio = *Vector::borrow(&d.ratio, i);
    FixedPoint32::multiply_u64(value, ratio)
  }

  public fun epoch_start_burn(vm: &signer, payer: address, value: u64) acquires DepositInfo{
    let list = get_address_list();
    let len = Vector::length<address>(&list);
    let i = 0;
    while (i < len) {
      let payee = *Vector::borrow<address>(&list, i);
      let val = get_value(payee, value);
      
      LibraAccount::vm_make_payment_no_limit<GAS>(
          payer,
          payee,
          val,
          b"epoch start",
          b"epoch start",
          vm,
      );
      i = i + 1;
    };
  }
}
}