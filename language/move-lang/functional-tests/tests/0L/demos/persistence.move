//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: alice
script {
    use 0x1::PersistenceDemo;
    fun main(sender: &signer){ // alice's signer type added in tx.
      PersistenceDemo::initialize(sender);

      PersistenceDemo::add_stuff(sender);
      assert(PersistenceDemo::length(sender) == 3, 0);
      assert(PersistenceDemo::contains(sender, 1), 1);
    }
}
// check: EXECUTED