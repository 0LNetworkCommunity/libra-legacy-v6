//# init --validators Dummy
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8

///// Setting up the test fixtures for the transactions below. 
///// The tags below create validators, giving them 10 000 000 GAS coins.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(vm: signer, _: signer) {
      Wallet::vm_remove_comm(&vm, @Alice);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 0, 7357002);
    }
}

// check: EXECUTED