// DEMOWARE: this is to test the Decimal implementation for curved bonding cases.
address DiemFramework {
module Bonding {
  use DiemFramework::Decimal;
  use DiemFramework::Debug::print;

  struct CurveState has key {
    is_deprecated: bool,
    reserve: u128, //todo: change to Diem<XUS>,
    supply_issued: u128,
  }

  struct Token has key, store { 
    value: u128
  }

  // fun sunset() {
  //   // if true state.is_deprecated == true
  //   // allow holders to redeem at the spot price at sunset.
  //   // cannot receive new deposits
  //   //TBD
  // }

  ///////// Initialization /////////
  public fun initialize_curve(
    service: &signer,
    deposit: u128, // Diem<XUS>,
    supply_init: u128,
  ) {
    // let deposit_value = Diem::value<XUS>(&deposit);
    assert!(deposit > 0, 7357001);

    let init_state = CurveState {
      is_deprecated: false, // deprecate mode
      reserve: deposit,
      supply_issued: supply_init,
    };

    // This initializes the contract, and stores the contract state at the address of sender. TDB where the state gets stored.
    move_to<CurveState>(service, init_state);

    let first_token = Token { 
      value: supply_init
    };

    // minting the first coin, sponsor is recipent of initial coin.
    move_to<Token>(service, first_token);
  }

  /////////// Calculations /////////
  public fun deposit_calc(add_to_reserve: u128, reserve: u128, supply: u128): u128 {

    let one = Decimal::new(true, 1, 0);
    print(&one);

    let add_dec = Decimal::new(true, add_to_reserve, 0);
    print(&add_dec);

    let reserve_dec = Decimal::new(true, reserve, 0);
    print(&reserve_dec);

    let supply_dec = Decimal::new(true, supply, 0);
    print(&supply_dec);

    // formula: 
    // supply * sqrt(one+(add_to_reserve/reserve))

    let a = Decimal::div(&add_dec, &reserve_dec);
    print(&a);
    let b = Decimal::add(&one, &a);
    print(&b);
    let c = Decimal::sqrt(&b);
    print(&c);
    let d = Decimal::mul(&supply_dec, &c);
    print(&d);
    let int = Decimal::borrow_int(&Decimal::trunc(&d));
    print(int);

    return *int
  }

//   fun withdraw_curve(remove_from_supply: u128, supply: u128, reserve: u128):u128 {
//     // TODO: 
//     // formula: reserve * (one - remove_from_supply/supply )^2
//     // let one = Decimal::new(true, 1, 0);
//     
//     
//   }


  ///////// API /////////
  // this simulates the depositing and getting a minted token out, but just using integers, not coin types for now.
  public fun test_bond_to_mint(_sender: &signer, service_addr: address, deposit: u128): u128 acquires CurveState {
    assert!(exists<CurveState>(service_addr), 73570002);
    let state = borrow_global_mut<CurveState>(service_addr);

    let post_supply = deposit_calc(deposit, state.reserve, state.supply_issued);
    print(&post_supply);
    assert!(post_supply > state.supply_issued, 73570003);
    let mint = post_supply - state.supply_issued;
    print(&mint);
    // update the new curve state
    state.reserve = state.reserve + deposit;
    state.supply_issued = state.supply_issued + mint;
    // print(&state);
    mint
  }

//   public fun burn_to_withdraw(sender: &signer, service_addr: address, burn_value: u128):Decimal acquires CurveState, Token {

//     assert!(exists<CurveState>(service_addr), 73570002);
//     let sender_addr = Signer::address_of(sender);
//     assert!(exists<Token>(sender_addr), 73570003);
//     assert!(Coin::balance(sender_addr) >= burn_value, 73570004);

//     let state = borrow_global_mut<CurveState>(service_addr);

//     // Calculate the reserve change.
//     let remove_from_supply = Decimal::new(burn_value);
//     let withdraw_value = withdraw_curve(remove_from_supply, service_addr, state.reserve);

//     withdraw_token_from(sender, burn_value);
//     // new curve state
//     state.reserve = state.reserve - withdraw_value;
//     state.supply = state.supply - burn_value;
//     withdraw_value
//   }


//   // Merges a GAS coin.
//   fun deposit_gas_and_merge(sender: &signer, coin: GAS) acquires Token {
//     //TODO: merges gas coin to bonding curve reserve
//   }

//   // Splits a coin to be used.
//   fun withdraw_token_and_split_gas(sender: &signer, sub_value: Decimal) acquires Token {
//    //TODO:
//   }


//   ///////// GETTERS /////////

  public fun get_curve_state(sponsor_address: address): (u128, u128) acquires CurveState {
    let state = borrow_global<CurveState>(sponsor_address); 
    (state.reserve, state.supply_issued)
  }

//   public fun get_user_balance(addr: address): Decimal acquires Token {
//     let state = borrow_global<Token>(addr);
//     state.value
//   }

//   // This is a steady state getter
//   public fun calc_spot_price_from_state(sponsor_addr: address): Decimal acquires CurveState {
//     let state = borrow_global_mut<CurveState>(sponsor_addr);
//     state.kappa * (state.reserve/state.supply)
//   }


//   ///////// TEST /////////

//   // // NOTE:  This "invariant" may not be invariant with rounding issues.
//   // public fun test_get_curve_invariant(sponsor_addr: address):Decimal acquires CurveState {
//   //   let state = borrow_global_mut<CurveState>(sponsor_addr);
//   //   let two = FixedPoint32::create_from_raw_value(2);
//   //   let zero = FixedPoint32::create_from_raw_value(0);

//   //   // TOOD: when we have native math lib the formula will be:
//   //   // (state.supply, to power of state.kappa) / state.reserve
//   //   if (state.kappa == two ) {
//   //     return (state.supply * state.supply) / state.reserve
//   //   };
//   //   zero
//   // }



}
}