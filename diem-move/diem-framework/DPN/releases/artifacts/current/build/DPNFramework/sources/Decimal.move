address DiemFramework {
module Decimal {
    // The Move Decimal data structure is optimized for readability and compatibility.
    // In particular it is indended for compatibility with the underlying rust_decimal crate https://github.com/paupino/rust-decimal. In that library a new decimal type is initialized with Decimal::from_i128_with_scale(mantissa: i128, scale: u32)
    // Note: While the underlying Rust crate type has optimal storage characteristics, this Move decimal representation is NOT optimized for storage.

    struct Decimal has key, store, drop {
        sign: bool,
        int: u128,
        scale: u8, // max intger is number 28
    }

    // while stored in u128, the largest integer possible in the rust_decimal vm dependency is 2^96
    const MAX_RUST_DECIMAL_U128: u128 = 79228162514264337593543950335;

    // pair decimal ops
    const ADD: u8 = 1;
    const SUB: u8 = 2;
    const MUL: u8 = 3;
    const DIV: u8 = 4;
    const POW: u8 = 5;
    const ROUND: u8 = 6;

    // single ops
    const SQRT: u8 = 100;
    const TRUNC: u8 = 101;

    const ROUND_MID_TO_EVEN: u8 = 0; // This is the default in the rust_decimal lib.
    const ROUND_MID_FROM_ZERO: u8 = 1;



    native public fun demo(sign: bool, int: u128, scale: u8): (bool, u128, u8);

    native public fun single(op_id: u8, sign: bool, int: u128, scale: u8): (bool, u128, u8);

    native public fun pair(
      op_id: u8,
      rounding_strategy_id: u8,
      // left number
      sign_1: bool,
      int_1: u128,
      scale_1: u8,
      // right number
      sign_2: bool,
      int_2: u128,
      scale_3: u8
    ): (bool, u128, u8);

    public fun new(sign: bool, int: u128, scale: u8): Decimal {

      assert!(int < MAX_RUST_DECIMAL_U128, 01);

      // check scale < 28
      assert!(scale < 28, 02);

      return Decimal {
        sign: sign,
        int: int,
        scale: scale
      }
    }

    /////// SUGAR /////////
    public fun trunc(d: &Decimal): Decimal {
      let (sign, int, scale) = single(TRUNC, *&d.sign, *&d.int, *&d.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

    public fun sqrt(d: &Decimal): Decimal {
      let (sign, int, scale) = single(SQRT, *&d.sign, *&d.int, *&d.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

    public fun add(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(ADD, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

    public fun sub(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(SUB, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }
    public fun mul(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(MUL, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

     public fun div(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(DIV, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }


    public fun rescale(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(0, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

    public fun round(l: &Decimal, r: &Decimal, strategy: u8): Decimal {
      let (sign, int, scale) = pair(ROUND, strategy, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }


    public fun power(l: &Decimal, r: &Decimal): Decimal {
      let (sign, int, scale) = pair(POW, ROUND_MID_TO_EVEN, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
      return Decimal {
        sign: sign,
        int: int,
        scale: scale,
      }
    }

    ///// GETTERS /////

    // unwrap creates a new decimal instance
    public fun unwrap(d: &Decimal): (bool, u128, u8) {
      return (*&d.sign, *&d.int, *&d.scale)
    }

    // borrow sign
    public fun borrow_sign(d: &Decimal): &bool {
      return &d.sign
    }

    // borrows the value of the integer
    public fun borrow_int(d: &Decimal): &u128 {
      return &d.int
    }

    // borrow sign
    public fun borrow_scale(d: &Decimal): &u8 {
      return &d.scale
    }
}
}
