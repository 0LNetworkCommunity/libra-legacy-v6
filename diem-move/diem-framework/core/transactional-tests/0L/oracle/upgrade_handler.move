//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator

//! new-transaction
//! sender: alice
script {
  use DiemFramework::Oracle;
  use DiemFramework::Vector;
  use DiemFramework::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 

      // duplicated vote
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let len = Vector::length<address>(&vec);
      assert!(len == 1, 7357123401011000);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
  use DiemFramework::Oracle;
  use DiemFramework::Vector;
  use DiemFramework::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Bob, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
  }
}
// check: EXECUTED

//! new-transaction
//! sender: charlie
script {
  use DiemFramework::Oracle;
  use DiemFramework::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, *&data);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
  }
}
// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::Oracle;
  use DiemFramework::Upgrade;
  use DiemFramework::Vector;
  
  fun main(sender: signer){
      let data = b"hello";
      Oracle::check_upgrade(&sender);

      // check if payload and history are recorded correctly
      assert!(Upgrade::has_upgrade() == true, 7357123401011000); 
      assert!(Upgrade::get_payload() == *&data, 7357123401011000);

      let (upgraded_version, payload, voters, _) = Upgrade::retrieve_latest_history();
      assert!(upgraded_version == 0, 7357123401011000);
      assert!(payload == data, 7357123401011000);

      let validators = Vector::empty<address>();
      Vector::push_back(&mut validators, @Alice);
      Vector::push_back(&mut validators, @Charlie);
      assert!(Vector::compare(&voters, &validators), 7357123401011000);
  }
}
// check: EXECUTED