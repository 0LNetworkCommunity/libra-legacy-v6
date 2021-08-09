//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator

//! block-prologue
//! proposer: bob
//! block-time: 1
//! round: 1

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
      let data = b"WHATEVER"; // different vote
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 1);
      assert(e == @{{bob}}, 735703);

      assert(Upgrade::has_upgrade() == false, 735704); 
  }
}
// check: EXECUTED

//! new-transaction
//! sender: charlie
script {
  use 0x1::Oracle;
  use 0x1::Upgrade;

  fun main(sender: signer){
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);

      assert(Upgrade::has_upgrade() == false, 735705); 
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 2
//! round: 2

//! new-transaction
//! sender: diemroot
script {
  use 0x1::Upgrade;
  use 0x1::Vector;

  fun main(){
    let (upgraded_version, payload, voters, height) = 
      Upgrade::retrieve_latest_history();

    let validators = Vector::empty<address>();
    Vector::push_back(&mut validators, @{{alice}});
    Vector::push_back(&mut validators, @{{charlie}});

    assert(Upgrade::has_upgrade(), 735706); 
    assert(upgraded_version == 0, 735707);
    assert(payload == b"hello", 735708);
    assert(Vector::compare(&voters, &validators), 735709);
    assert(height == 2, 735710);
  }
}
// check: EXECUTED