//# init --validators Alice Bob Carol

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  
  fun main(vm: signer, _account: signer) {
    // bobs_indexed amount changes
    let index_before = DiemAccount::get_index_cumu_deposits(@Bob);
    let index_carol_before = DiemAccount::get_index_cumu_deposits(@Carol);

    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>( @Alice, @Bob, 100000, x"", x"", &vm);
    let index_after = DiemAccount::get_index_cumu_deposits(@Bob);
    assert!(index_after > index_before, 735701);

    // carol's amount DOES NOT change
    // send to community wallet Bob
    let carol_after = DiemAccount::get_index_cumu_deposits(@Carol);
    assert!(index_carol_before == carol_after, 735702)
  }
}