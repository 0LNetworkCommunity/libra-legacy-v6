//# init --validators Alice Bob Charlie

//# block --proposer Bob --time 1 --round 1

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
      assert!(e == @Alice, 735701);

      assert!(Upgrade::has_upgrade() == false, 735702); 
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
      let data = b"WHATEVER"; // different vote
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Bob, 735703);

      assert!(Upgrade::has_upgrade() == false, 735704); 
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
        Oracle::handler(&sender, id, data);

        assert!(Upgrade::has_upgrade() == false, 735705); 
    }
}
// check: EXECUTED

//# block --proposer Bob --time 2 --round 2

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Upgrade;
    use Std::Vector;

    fun main(){
        let (upgraded_version, payload, voters, height) = 
          Upgrade::retrieve_latest_history();

        let validators = Vector::empty<address>();
        Vector::push_back(&mut validators, @Alice);
        Vector::push_back(&mut validators, @Charlie);

        assert!(Upgrade::has_upgrade(), 735706); 
        assert!(upgraded_version == 0, 735707);
        assert!(payload == b"hello", 735708);
        assert!(Vector::compare(&voters, &validators), 735709);
        assert!(height == 2, 735710);
    }
}
// check: EXECUTED