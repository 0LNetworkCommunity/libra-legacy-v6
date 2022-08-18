//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator



//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::NodeWeight;
    fun main(sender: signer) {
        TowerState::test_helper_set_weight_vm(&sender, @{{alice}}, 10);
        assert(NodeWeight::proof_of_weight(@{{alice}}) == 10, 735701);
        TowerState::test_helper_set_weight_vm(&sender, @{{bob}}, 10);
        assert(NodeWeight::proof_of_weight(@{{bob}}) == 10, 735702);
    }
}
//check: EXECUTED

//// JIM PROXIES LUCY to vote on upgrades
//// THOMAS PROXIES ALICE to vote on upgrades

//! new-transaction
//! sender: bob
script {
  use 0x1::Oracle;
  fun main(sender: signer){
   Oracle::enable_delegation(&sender);
   Oracle::delegate_vote(&sender, @{{alice}});
  }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert(e == @{{alice}}, 735703);
      let e = *Vector::borrow<address>(&vec, 1);
      assert(e == @{{bob}}, 735704);

      Oracle::revoke_my_votes(&sender);

      let vec = Oracle::test_helper_query_oracle_votes();
      assert(Vector::length<address>(&vec) == 0, 735705);

  }
}
// check: EXECUTED

