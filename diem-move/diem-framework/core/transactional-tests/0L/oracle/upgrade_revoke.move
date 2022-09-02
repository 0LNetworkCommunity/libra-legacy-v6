//# init --validators Alice Bob Charlie

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;

  fun main(_: signer, sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 735701);

      assert!(Upgrade::has_upgrade() == false, 735702); 

      // revoke the vote
      Oracle::revoke_my_votes(&sender);
      let vec = Oracle::test_helper_query_oracle_votes();

      let len = Vector::length<address>(&vec);
      assert!(len == 0, 735703);
  }
}


// VOTES AGAIN FOR DIFFERENT PAYLOAD


//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;

  fun main(_: signer, sender: signer){
      let id = 1;
      let data = b"NEW PAYLOAD";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 735704);

      assert!(Upgrade::has_upgrade() == false, 735705); 

      // duplicated vote
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let len = Vector::length<address>(&vec);
      assert!(len == 1, 735706);
  }
}