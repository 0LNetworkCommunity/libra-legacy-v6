//# init --validators Alice Bob Charlie Jim Lucy Thomas

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    fun main(sender: signer, _: signer) {
        TowerState::test_helper_set_weight_vm(&sender, @Alice, 10);
        assert!(NodeWeight::proof_of_weight(@Alice) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Bob, 10);
        assert!(NodeWeight::proof_of_weight(@Bob) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Charlie, 10);
        assert!(NodeWeight::proof_of_weight(@Charlie) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Jim, 31);
        assert!(NodeWeight::proof_of_weight(@Jim) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Lucy, 31);
        assert!(NodeWeight::proof_of_weight(@Lucy) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Thomas, 31);
        assert!(NodeWeight::proof_of_weight(@Thomas) == 31, 7357300101011088);
    }
}

//// JIM PROXIES LUCY to vote on upgrades
//// THOMAS PROXIES ALICE to vote on upgrades

//# run --admin-script --signers DiemRoot Lucy
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Jim
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Lucy);
      assert!(Oracle::check_number_delegates(@Lucy) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Thomas
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Alice);
      assert!(Oracle::check_number_delegates(@Alice) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Lucy);
      assert!(Oracle::check_number_delegates(@Lucy) == 2, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::remove_delegate_vote(&sender);
      assert!(Oracle::check_number_delegates(@Lucy) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 7357123401011000);
      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Thomas, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 2);
      assert!(e == @Bob, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED


// THOMAS SHOULD NOT BE ABLE TO VOTE, SINCE ALICE ALREADY VOTED FOR THEM


//# run --admin-script --signers DiemRoot Thomas
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      //already voted, must ensure vote not counted again
      let id = 2;
      let data = b"bello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = Vector::length<address>(&vec);
      assert!(e == 3, 7357123401011002);
    }
  }
}
// check: ABORTED