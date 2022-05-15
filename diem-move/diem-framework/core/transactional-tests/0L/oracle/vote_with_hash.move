//# init --validators Alice Bob Carol Dave Eve

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    fun main(dr: signer, _: signer) {
        TowerState::test_helper_set_weight_vm(&dr, @Alice, 10);
        assert!(NodeWeight::proof_of_weight(@Alice) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&dr, @Bob, 10);
        assert!(NodeWeight::proof_of_weight(@Bob) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&dr, @Carol, 10);
        assert!(NodeWeight::proof_of_weight(@Carol) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&dr, @Dave, 31);
        assert!(NodeWeight::proof_of_weight(@Dave) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&dr, @Eve, 31);
        assert!(NodeWeight::proof_of_weight(@Eve) == 31, 7357300101011088);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
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


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
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

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
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

//# run --admin-script --signers DiemRoot Dave
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
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

//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
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