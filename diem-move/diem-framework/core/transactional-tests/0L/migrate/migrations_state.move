
//# init --validators Alice

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Migrations;

    fun main(vm: signer) { // alice's signer type added in tx.
      Migrations::init(&vm);
      let test = b"test";
      Migrations::push(&vm, 1, test);
      // second run should have no effect.
      let test = b"test";
      Migrations::push(&vm, 1, test);
    }
}
