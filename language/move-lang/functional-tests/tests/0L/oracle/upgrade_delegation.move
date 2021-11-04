//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator
//! account: jim, 1000000, 0, validator
//! account: lucy, 1000000, 0, validator
//! account: thomas, 1000000, 0, validator


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
        TowerState::test_helper_set_weight_vm(&sender, @{{charlie}}, 10);
        assert(NodeWeight::proof_of_weight(@{{charlie}}) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{jim}}, 31);
        assert(NodeWeight::proof_of_weight(@{{jim}}) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{lucy}}, 31);
        assert(NodeWeight::proof_of_weight(@{{lucy}}) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @{{thomas}}, 31);
        assert(NodeWeight::proof_of_weight(@{{thomas}}) == 31, 7357300101011088);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: lucy
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: jim
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @{{lucy}});
      assert(Oracle::check_number_delegates(@{{lucy}}) == 1, 5);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: thomas
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @{{alice}});
      assert(Oracle::check_number_delegates(@{{alice}}) == 1, 5);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: charlie
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @{{lucy}});
      assert(Oracle::check_number_delegates(@{{lucy}}) == 2, 5);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: charlie
script {
  use 0x1::Oracle;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::remove_delegate_vote(&sender);
      assert(Oracle::check_number_delegates(@{{lucy}}) == 1, 5);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert(e == @{{alice}}, 7357123401011000);
      let e = *Vector::borrow<address>(&vec, 1);
      assert(e == @{{thomas}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
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
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 2);
      assert(e == @{{bob}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED




//! new-transaction
//! sender: thomas
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Hash;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      //already voted, must ensure vote not counted again
      let id = 2;
      let data = b"bello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = Vector::length<address>(&vec);
      assert(e == 3, 7357123401011002);
    }
  }
}
// check: EXECUTED



//! new-transaction
//! sender: lucy
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  use 0x1::Hash;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 3);
      assert(e == @{{lucy}}, 7357123401011000);
      let e = *Vector::borrow<address>(&vec, 4);
      assert(e == @{{jim}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED


//! new-transaction
//! sender: jim
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      // ensure jim's vote is not counted twice
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = Vector::length<address>(&vec);
      assert(e == 5, 7357123401011002);
    }
  }
}
// check: EXECUTED

//! new-transaction
//! sender: charlie
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;
  use 0x1::Hash;
  fun main(sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 5);
      assert(e == @{{charlie}}, 7357123401011000);

      assert(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
    }
  }
}
// check: EXECUTED




// //! block-prologue
// //! proposer: bob
// //! block-time: 1
// //! round: 2

// //! block-prologue
// //! proposer: bob
// //! block-time: 2
// //! round: 2

// //! new-transaction
// //! sender: diemroot
// script {
//   use 0x1::Upgrade;
//   use 0x1::Vector;
//   fun main(){
//     let (upgraded_version, payload, voters, height) = Upgrade::retrieve_latest_history();

//     let validators = Vector::empty<address>();
//     Vector::push_back(&mut validators, @{{alice}});
//     Vector::push_back(&mut validators, @{{charlie}});
//     assert(upgraded_version == 0, 7357123401011000);
//     assert(payload == b"hello", 7357123401011000);
//     assert(Vector::compare(&voters, &validators), 7357123401011000);
//     assert(height == 1, 7357123401011000);
//   }
// }
// // check: EXECUTED
