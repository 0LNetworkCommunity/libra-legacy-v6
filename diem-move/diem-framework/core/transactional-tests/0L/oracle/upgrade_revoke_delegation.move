//# init --validators Alice Bob

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;

    fun main(dr: signer, _: signer) {
        TowerState::test_helper_set_weight_vm(&dr, @Alice, 10);
        assert!(NodeWeight::proof_of_weight(@Alice) == 10, 735701);
        TowerState::test_helper_set_weight_vm(&dr, @Bob, 10);
        assert!(NodeWeight::proof_of_weight(@Bob) == 10, 735702);
    }
}
//check: EXECUTED


//// JIM PROXIES LUCY to vote on upgrades
//// THOMAS PROXIES ALICE to vote on upgrades


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Oracle;

  fun main(_: signer, sender: signer){
   Oracle::enable_delegation(&sender);
   Oracle::delegate_vote(&sender, @Alice);
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;

  fun main(_: signer, sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 735703);
      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Bob, 735704);

      Oracle::revoke_my_votes(&sender);

      let vec = Oracle::test_helper_query_oracle_votes();
      assert!(Vector::length<address>(&vec) == 0, 735705);

  }
}
// check: EXECUTED