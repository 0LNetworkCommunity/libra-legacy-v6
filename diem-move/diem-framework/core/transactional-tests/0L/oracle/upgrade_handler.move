//# init --validators Alice Bob Charlie

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;

  fun main(_dr: signer, sender: signer){
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
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  use DiemFramework::Upgrade;

  fun main(_dr: signer, sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, *&data);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::Oracle;
  use DiemFramework::Upgrade;
  use DiemFramework::VectorHelper;
  use Std::Vector;
  
  fun main(sender: signer, _: signer){
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
      assert!(VectorHelper::compare<address>(&voters, &validators), 7357123401011000);
  }
}
// check: EXECUTED