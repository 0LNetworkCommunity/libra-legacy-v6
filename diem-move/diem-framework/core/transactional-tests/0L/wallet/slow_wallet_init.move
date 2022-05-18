//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

// Tests that the slow wallet list at 0x0 is initialized at genesis, with validators (1)
//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DiemAccount;
    use Std::Vector;

    fun main() {
      let list = DiemAccount::get_slow_list();
      // alice, the validator, is already a slow wallet.
      assert!(Vector::length<address>(&list) ==1, 735701);
    }
}
// check: EXECUTED