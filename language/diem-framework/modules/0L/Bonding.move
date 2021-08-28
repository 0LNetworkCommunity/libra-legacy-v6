address 0x1 {
module Bonding {
  // use 0x1::Signer;
  use 0x1::Decimal;
  use 0x1::Debug::print;

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
    assert(deposit > 0, 7357001);

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
  public fun deposit_calc(add_to_reserve: u128, reserve: u128, supply: u128) {

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
    // let add_to_reserve = 10;
    // let reserve = 100;
    // let supply = 10000;

    let a = Decimal::div(&add_dec, &reserve_dec);
    print(&a);
    let b = Decimal::add(&one, &a);
    print(&b);
    let c = Decimal::sqrt(&b);
    print(&c);
    let d = Decimal::mul(&supply_dec, &c);
    print(&d);
    let int = Decimal::borrow_int(&d);
    print(int);
  }

//   fun withdraw_curve(remove_from_supply: Decimal, supply: Decimal, reserve: Decimal):Decimal {
//     // TODO:
//     // let one = Decimal::new(1);
//     // reserve * (one - remove_from_supply/supply )^2
//     return Decimal::new(1);
//   }


//   ///////// API /////////
//   public fun bond_to_mint(sender: &signer, service_addr: address, deposit: XUS):Decimal acquires CurveState, Token {
//     assert(exists<CurveState>(service_addr), 73570002);
//     let state = borrow_global_mut<CurveState>(service_addr);

//     let delta_reserve = Coin::balance<XUS>(deposit);
//     // supply is a Decimal
//     let post_supply: Decimal = curve(delta_reserve, state.supply, state.reserve);
    
//     let mint: Decimal = Decimal::sub(depost_supply, Decimal::new(state.supply));
//     let mint_int: u128 = Decimal::to_u128(mint);

//     deposit_token_to(sender, mint_int);

//     // new curve state
//     state.reserve = state.reserve + add_to_reserve;
//     state.supply = state.supply + mint_int;
//     mint
//   }

//   public fun burn_to_withdraw(sender: &signer, service_addr: address, burn_value: u128):Decimal acquires CurveState, Token {

//     assert(exists<CurveState>(service_addr), 73570002);
//     let sender_addr = Signer::address_of(sender);
//     assert(exists<Token>(sender_addr), 73570003);
//     assert(Coin::balance(sender_addr) >= burn_value, 73570004);

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


//   // Merges a token.
//   fun deposit_token_to(sender: &signer, new_value: Decimal) acquires Token {
//     let to_addr = Signer::address_of(sender);
//     if (!exists<Token>(to_addr)) {
//       move_to<Token>(sender, Token { value: new_value });
//     } else {
//       let user_token = borrow_global_mut<Token>(to_addr);
//       user_token.value = user_token.value + new_value;
//     }
//   }

//   // Splits a coin to be used.
//   fun withdraw_token_from(sender: &signer, sub_value: Decimal) acquires Token {
//     let from_addr = Signer::address_of(sender);
//     assert(exists<Token>(from_addr), 73570005);
//     let user_token = borrow_global_mut<Token>(from_addr);
//     user_token.value = user_token.value - sub_value;
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