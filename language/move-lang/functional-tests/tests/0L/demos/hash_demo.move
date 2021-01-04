///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator


//! new-transaction
//! sender: alice
script {
    use 0x1::Hash;
    use 0x1::Debug::print;

    // This sender argument was populated by the test harness with a random address for `alice`, which can be accessed with sender variable or the helper `{alice}`
    fun main(_sender: &signer){ // alice's signer type added in tx.
      let hashed = Hash::sha3_256(b"test");
      print(&hashed);

      let hashed_addr = Hash::sha3_256();
      print(&hashed_addr);
      // PersistenceDemo::add_stuff(sender);
      // assert(PersistenceDemo::length(sender) == 3, 0);
      // assert(PersistenceDemo::contains(sender, 1), 1);
    }
}

// check: EXECUTED
