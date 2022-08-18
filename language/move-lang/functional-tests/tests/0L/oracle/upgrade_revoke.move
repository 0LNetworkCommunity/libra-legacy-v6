//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator

//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert(e == @{{alice}}, 735701);

      assert(Upgrade::has_upgrade() == false, 735702); 

      // revoke the vote
      Oracle::revoke_my_votes(&sender);
      let vec = Oracle::test_helper_query_oracle_votes();

      let len = Vector::length<address>(&vec);
      assert(len == 0, 735703);
  }
}
// check: EXECUTED


/// VOTES AGAIN FOR DIFFERENT PAYLOAD


//! new-transaction
//! sender: alice
script {
  use 0x1::Oracle;
  use 0x1::Vector;
  use 0x1::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"NEW PAYLOAD";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert(e == @{{alice}}, 735704);

      assert(Upgrade::has_upgrade() == false, 735705); 

      // duplicated vote
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let len = Vector::length<address>(&vec);
      assert(len == 1, 735706);
  }
}
// check: EXECUTED