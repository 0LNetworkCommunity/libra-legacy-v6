//! account: alice

//! new-transaction
//! sender: diemroot
script {
  // use 0x1::Decimal;
  use 0x1::Bonding;
  // use 0x1::Debug::print;

  fun main(_diemroot: signer) {
    let add_to_reserve = 300;
    let reserve = 100;
    let supply = 1;
    Bonding::deposit_calc(add_to_reserve, reserve, supply);

    let add_to_reserve = 10;
    let reserve = 100;
    let supply = 10000;
    Bonding::deposit_calc(add_to_reserve, reserve, supply);
  }
}