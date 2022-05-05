//! account: alice

//! new-transaction
//! sender: diemroot
script {
  use 0x1::Bonding;

  fun main(_diemroot: signer) {
    let add_to_reserve = 300;
    let reserve = 100;
    let supply = 1;
    let res = Bonding::deposit_calc(add_to_reserve, reserve, supply);
    assert(res == 2, 73501);

    

    let add_to_reserve = 10;
    let reserve = 100;
    let supply = 10000;
    let res = Bonding::deposit_calc(add_to_reserve, reserve, supply);
    assert(res == 10488, 73502);
  }
}