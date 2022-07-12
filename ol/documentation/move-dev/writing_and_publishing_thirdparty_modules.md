# Testing and Publishing Third Party Modules

This guide will walk through the process of publishing, testing and verifying a third party module. In this guide we will be using the Persistance Demo module.

## Functional Tests
---
### Testing
>The Move test runner leverages the Rust test infrastructure (cargo test) where we can run all tests, or filenames which match a keyword: e.g cargo test persist will run persistence.move.

Functional tests can be found in  ```<path/to/ol>/language/move-lang/functional_tests/test/move ```

Functional tests for a move module are ran in a script. Move scripts and modules can be combined into a single file or separated.

**Combined Persistence-demo:**
```shell script
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator


module {{default}}::PersistenceDemo{
        use Std::Vector;
        use Std::Signer;
       // use 0x1::Testnet::is_testnet;

        // In Move the types for data storage are `resource struct`. Here a type State is being defined. Once a type is initialized in the global state, the resource is treated as if in-memory on the heap, the libra database is abstracted. The data is namespaced by an "access path" which includes the module name and user address. No special APIs are necessary for reading from the database, except permissioning each function which accesses a given struct, more below.
        struct State has key {
          hist: vector<u8>,
        }

        // The operation can only be performed on testnet
        // const ETESTNET : u64 = 04001;

        // For this demo, the `initialize` function writes a PersistenceDemo::State resource at the "sender" address. The access path will be <sender address>/PersistenceDemo/State/
        public fun initialize(sender: &signer){
          // `assert can be used to evaluate a bool and exit the program with an error code, e.g. testing if this is being run in testnet, and throwing error 01.
         // assert(is_testnet(), Errors::invalid_state(ETESTNET));
          // In the actual module, must assert that this is the sender is the association
          move_to<State>(sender, State{ hist: Vector::empty() });
        }


        // To read or write to a Resource Struct an `acquires` tag is needed to permission a function. NOTE all downsteam functions will also need permission on that data struct, i.e. need the same `acquires` parameters.
        public fun add_stuff(sender: &signer ) acquires State {
          //assert(is_testnet(), Errors::invalid_state(ETESTNET));

          // Resource Struct state is always "borrowed" and "moved" and generally cannot be copied. A struct can be mutably borrowed, if it is written to, useing `borrow_global_mut`. Note the Type State
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          // the `&` as in Rust makes the assignment to a borrowed value. Each Vector operation below with use a st.hist and return it before the next one can execute.
          let s = &mut st.hist;

          // Move has very limited data types. Vector is the most sophisticated and resembles a simplified Rust vector. Can be thought of as an array of a single type.
          Vector::push_back(s, 1);
          Vector::push_back(s, 2);
          Vector::push_back(s, 3);
        }

        // Similar to above, except removing state.
        public fun remove_stuff(sender: &signer) acquires State{
          //assert(is_testnet(), Errors::invalid_state(ETESTNET));
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          let s = &mut st.hist;

          Vector::pop_back<u8>(s);
          Vector::pop_back<u8>(s);
          Vector::remove<u8>(s, 0);
        }

        // Here are examples of read operations. Note the `aquires` here again.
        public fun isEmpty(sender: &signer): bool acquires State {
          //assert(is_testnet(), Errors::invalid_state(ETESTNET));

          // Note this is not a mutable borrow. Read only.
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::is_empty(&st.hist)
        }

        // Showing the Vector::length method
        public fun length(sender: &signer): u64 acquires State{
         // assert(is_testnet(), Errors::invalid_state(ETESTNET));
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::length(&st.hist)
        }

        // Showing the Vector::contains method
        public fun contains(sender: &signer, num: u8): bool acquires State {
          //assert(is_testnet(), Errors::invalid_state(ETESTNET));
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::contains(&st.hist, &num)
        }

    }


//! new-transaction
//! sender: alice
script {
    use {{default}}::PersistenceDemo;

    // This sender argument was populated by the test harness with a random address for `alice`, which can be accessed with sender variable or the helper `{alice}`
    fun main(sender: signer){ // alice's signer type added in tx.
      let sender = &sender;
      PersistenceDemo::initialize(sender);
      PersistenceDemo::add_stuff(sender);
      assert(PersistenceDemo::length(sender) == 3, 0);
      assert(PersistenceDemo::contains(sender, 1), 1);
    }}

    ///// The tags with `check` matches to a string in the VM output. Here we are checking for a correct execution.
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use {{default}}::PersistenceDemo;
    fun main(sender: signer){
        let sender = &sender;
      assert(PersistenceDemo::length(sender) == 2, 4);
    }
}

///// Checking the VM output for the string ABORTED

// check: ABORTED


///// DEMO 3: State is not initialized in BOB address
///// this will fail because bob does not have the data struct, and we tried to operate on it.
///// This is a new transaction.

//! new-transaction
//! sender: bob
script {
    use {{default}}::PersistenceDemo;
    fun main(sender: signer){
        let sender = &sender;
        PersistenceDemo::add_stuff(sender);
    }
}

///// Checking the VM output for the string `EXECUTION_FAILURE`

// check: EXECUTION_FAILURE

```

To run a functional test:
``` shell script
cd /language/move-lang/functional_tests/test/move/vector
cargo test persistence
```

### Publishing

Currently to test module and script publication the easiest tool for third party contracts seems to be move-cli



**Publishing Persistence-demo demo.move**

 The step of commands can be found in args.txt as well as the expected results in args.exp


```shell script
cd language/tools/move-cli/tests/testsuite/persistence_demo
move sandbox link -v
move sandbox publish src/modules --mode diem
move sandbox run src/scripts/persistence_test.move --signers 0x2
move sandbox run src/scripts/persistence_test_2.move --signers 0x2
move sandbox run src/scripts/persistence_test_3.move --signers 0x2

```
> Note: Providing -v at the end of command will return any print statements to the console
## Formal Verification
---

Also see this for a more recent guide: [move-prover-guide](/ol/documentation/devs/move-prover-guide.md)

---

This is a step by step guide to verifying the demo.move module at diem/language/move-stdlib/demo/demo.move
1. [Install move prover](/language/move-prover/doc/user/install.md)
> Note on the current version of Diem, Boogie 2.8.32 may need to be manually install to work
2.  As mentioned above to run the prover use the command ```cargo run --release --quiet --package move-prover --``` or set an alias to this in your shell's configuration file
3.  Move to the directory of demo.move
```shell script
cd <full_path>/diem/language/move-stdlib/demo
```

4. Run the script below to verify demo.move
```shell script
cargo run --release --quiet --package move-prover -- --Dependency <full_path>/diem/language/move-stdlib demo.move
```
Dependencies refer to all preexisting modules used within demo.move, this path can also be preset in the configuration file.

The solver will run and display results of the verification in terminal, the prover will also place the resulting boogie code in ```output.bpl```
