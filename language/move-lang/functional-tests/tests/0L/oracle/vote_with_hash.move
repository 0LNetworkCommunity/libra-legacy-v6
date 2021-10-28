//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::NodeWeight;
    fun main(sender: signer) {
        TowerState::test_helper_set_weight_vm(&sender, @{{alice}}, 10);
        assert(NodeWeight::proof_of_weight(@{{alice}}) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{bob}}, 10);
        assert(NodeWeight::proof_of_weight(@{{bob}}) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{carol}}, 10);
        assert(NodeWeight::proof_of_weight(@{{carol}}) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{dave}}, 31);
        assert(NodeWeight::proof_of_weight(@{{dave}}) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{eve}}, 31);
        assert(NodeWeight::proof_of_weight(@{{eve}}) == 31, 7357300101011088);
    }
}
//check: EXECUTED




//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert(e == @{{alice}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 1);
      assert(e == @{{bob}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  use 0x1::Hash;
  fun main(sender: signer){
      let id = 2;
      let data = b"bello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 2);
      assert(e == @{{carol}}, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert(false, 7357123401011003);
      };
      
  }
}
// check: EXECUTED

//! new-transaction
//! sender: dave
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 3);
      assert(e == @{{dave}}, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert(false, 7357123401011003);
      };
  }
}
// check: EXECUTED

//! new-transaction
//! sender: eve
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  use 0x1::Hash;
  fun main(sender: signer){
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 4);
      assert(e == @{{eve}}, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert(false, 7357123401011003);
      };
  }
}
// check: EXECUTED


