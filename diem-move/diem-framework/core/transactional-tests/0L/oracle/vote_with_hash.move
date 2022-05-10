//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    fun main(sender: signer) {
        TowerState::test_helper_set_weight_vm(&sender, @Alice, 10);
        assert!(NodeWeight::proof_of_weight(@Alice) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Bob, 10);
        assert!(NodeWeight::proof_of_weight(@Bob) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Carol, 10);
        assert!(NodeWeight::proof_of_weight(@Carol) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Dave, 31);
        assert!(NodeWeight::proof_of_weight(@Dave) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Eve, 31);
        assert!(NodeWeight::proof_of_weight(@Eve) == 31, 7357300101011088);
    }
}
//check: EXECUTED




//! new-transaction
//! sender: alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Bob, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use DiemFramework::Hash;
  fun main(sender: signer){
      let id = 2;
      let data = b"bello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 2);
      assert!(e == @Carol, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert!(false, 7357123401011003);
      };
      
  }
}
// check: EXECUTED

//! new-transaction
//! sender: dave
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 3);
      assert!(e == @Dave, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert!(false, 7357123401011003);
      };
  }
}
// check: EXECUTED

//! new-transaction
//! sender: eve
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use DiemFramework::Hash;
  fun main(sender: signer){
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 4);
      assert!(e == @Eve, 7357123401011000);

      if (Oracle::upgrade_vote_type() == 0) {
          //One validator, one vote
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else if (Oracle::upgrade_vote_type() == 1) {
          //Weighted vote based on mining
          assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
          assert!(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
      }
      else {
          //test must be upgraded for new vote type
          assert!(false, 7357123401011003);
      };
  }
}
// check: EXECUTED


