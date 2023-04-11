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
  // use DiemFramework::Debug::print;

  struct BurnPreference has key {
    send_community: bool
  }

  struct BurnState has key {
    addr: vector<address>,
    deposits: vector<u64>,
    ratio: vector<FixedPoint32::FixedPoint32>,
    lifetime_burned: u64,
    lifetime_recycled: u64,
  }

  /// At the end of the epoch, after everyone has been paid
  /// subsidies (validators, oracle, maybe future infrastructure)
  /// then the remaining fees are burned or recycled
  /// Note that most of the time, the amount of fees produced by the Fee Makers
  /// is much larger than the amount of fees available burn.
  /// So we need to find the proportion of the fees that each Fee Maker has
  /// produced, and then do a weighted burn/recycle.
  public fun epoch_burn_fees(
      vm: &signer,
      total_fees_collected: u64,
  )  acquires BurnPreference, BurnState {
      CoreAddresses::assert_vm(vm);

      // extract fees
      let coins = TransactionFee::vm_withdraw_all_coins<GAS>(vm);

      if (Diem::value(&coins) == 0) {
        Diem::destroy_zero(coins);
        return
      };

      // print(&Diem::value(&coins));
      // get the list of fee makers
      let fee_makers = TransactionFee::get_fee_makers();
      // print(&fee_makers);

      let len = Vector::length(&fee_makers);

      // for every user in the list burn their fees per Burn.move preferences
      let i = 0;
      while (i < len) {
          let user = Vector::borrow(&fee_makers, i);
          let amount = TransactionFee::get_epoch_fees_made(*user);
          let share = FixedPoint32::create_from_rational(amount, total_fees_collected);
          // print(&share);

          let to_withdraw = FixedPoint32::multiply_u64(Diem::value(&coins), share);
          // print(&to_withdraw);

          if (to_withdraw > 0 && to_withdraw <= Diem::value(&coins)) {
            let user_share = Diem::withdraw(&mut coins, to_withdraw);
            // print(&user_share);

            burn_or_recycle_user_fees(vm, *user, user_share);
          };
          

          i = i + 1;
      };

    // Transaction fee account should be empty at the end of the epoch
    // Superman 3 decimal errors. https://www.youtube.com/watch?v=N7JBXGkBoFc
    // anything that is remaining should be burned
    Diem::vm_burn_this_coin(vm, coins); 
  }

  /// initialize, usually for testnet.
  public fun initialize(vm: &signer) {
    CoreAddresses::assert_vm(vm);

    move_to<BurnState>(vm, BurnState {
        addr: Vector::empty(),
        deposits: Vector::empty(),
        ratio: Vector::empty(),
        lifetime_burned: 0,
        lifetime_recycled: 0,
      })
  }

  /// Migration script for hard forks
  public fun vm_migration(vm: &signer, 
    addr_list: vector<address>,
    deposit_vec: vector<u64>,
    ratios_vec: vector<FixedPoint32::FixedPoint32>,
    lifetime_burned: u64, // these get reset on final supply V6. Future upgrades need to decide what to do with this
    lifetime_recycled: u64,
  ) {

    // TODO: assert genesis when timesetamp is working again.
    CoreAddresses::assert_vm(vm);

    move_to<BurnState>(vm, BurnState {
        addr: addr_list,
        deposits: deposit_vec,
        ratio: ratios_vec,
        lifetime_burned,
        lifetime_recycled,
      })
  }

  public fun reset_ratios(vm: &signer) acquires BurnState {
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

    if (exists<BurnState>(@VMReserved)) {
      let d = borrow_global_mut<BurnState>(@VMReserved);
      d.addr = list;
      d.deposits = deposit_vec;
      d.ratio = ratios_vec;
    } else { // hot migration
      move_to<BurnState>(vm, BurnState {
        addr: list,
        deposits: deposit_vec,
        ratio: ratios_vec,
        lifetime_burned: 0,
        lifetime_recycled: 0,
      })
    }
  }

  fun get_address_list(): vector<address> acquires BurnState {
    if (!exists<BurnState>(@VMReserved))
      return Vector::empty<address>();

    *&borrow_global<BurnState>(@VMReserved).addr
  }

  // calculate the ratio which the community wallet should receive
  fun get_payee_value(payee: address, value: u64): u64 acquires BurnState {
    if (!exists<BurnState>(@VMReserved)) 
      return 0;

    let d = borrow_global<BurnState>(@VMReserved);
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
  ) acquires BurnState, BurnPreference {
    CoreAddresses::assert_vm(vm);
    // print(&5050);
    if (exists<BurnPreference>(payer)) {
      
      if (borrow_global<BurnPreference>(payer).send_community) {
        // print(&5051);
        recycle(vm, payer, &mut user_share);

      }
    };

    // Superman 3
    let state = borrow_global_mut<BurnState>(@VMReserved);
    // print(&state.lifetime_burned);
    state.lifetime_burned = state.lifetime_burned + Diem::value(&user_share);
    // print(&state.lifetime_burned);
    Diem::vm_burn_this_coin(vm, user_share);
  }


  fun recycle(vm: &signer, payer: address, coin: &mut Diem<GAS>) acquires BurnState {
    let list = { get_address_list() }; // NOTE devs, the added scope drops the borrow which is used below.
    let len = Vector::length<address>(&list);
    let total_coin_value_to_recycle = Diem::value(coin);

    // There could be errors in the array, and underpayment happen.
    let value_sent = 0;

    let i = 0;
    while (i < len) {

      let payee = *Vector::borrow<address>(&list, i);
      // print(&payee);
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

    // if there is anything remaining it's a superman 3 issue
    // so we send it back to the transaction fee account
    // makes it easier to track since we know no burns should be happening.
    // which is what would happen if the coin didn't get emptied here
    let remainder_amount = Diem::value(coin);
    if (remainder_amount > 0) {
      let last_coin = Diem::withdraw(coin, remainder_amount);
      // use pay_fee which doesn't track the sender, so we're not double counting the receipts, even though it's a small amount.
      TransactionFee::pay_fee(last_coin);
    };

    // update the root state tracker
    let state = borrow_global_mut<BurnState>(@VMReserved);
    // print(&state.lifetime_recycled);
    state.lifetime_recycled = state.lifetime_recycled + value_sent;
    // print(&state.lifetime_recycled);
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
    (vector<address>, vector<u64>, vector<FixedPoint32::FixedPoint32>) acquires BurnState 
  {
    let d = borrow_global<BurnState>(@VMReserved);
    (*&d.addr, *&d.deposits, *&d.ratio)
  }

  public fun get_lifetime_tracker(): (u64, u64) acquires BurnState {
    let state = borrow_global<BurnState>(@VMReserved);
    (state.lifetime_burned, state.lifetime_recycled)
  }

  //////// TEST HELPERS ////////
  
}
}
