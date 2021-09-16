
//! account: alice, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Migrations;

    fun main(vm: signer) { // alice's signer type added in tx.
      Migrations::init(&vm);
      let test = b"test";
      Migrations::push(&vm, 1, test);
      // second run should have no effect.
      let test = b"test";
      Migrations::push(&vm, 1, test);
    }
}
