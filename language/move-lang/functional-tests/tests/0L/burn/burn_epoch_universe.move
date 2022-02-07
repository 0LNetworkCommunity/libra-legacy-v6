//! account: alice, 10000000GAS, 0, validator
//! account: bob, 1000000GAS
//! account: carol, 1000000GAS

// Alice is CASE 2 validator

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Cases;

    fun main(sender: signer) {
        // let sender = &sender;
        // let voters = Vector::singleton<address>(@{{alice}});
        // let i = 1;
        // while (i < 16) {
        //     // Mock the validator doing work for 15 blocks, and stats being updated.
        //     Stats::process_set_votes(sender, &voters);
        //     i = i + 1;
        // };

        assert(Cases::get_case(&sender, @{{alice}}, 0 , 15) == 4, 7357300103011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: bob
script {
    use 0x1::Wallet;
    use 0x1::Vector;
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x1::Wallet;
    use 0x1::Vector;
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 2, 7357002);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{bob}}, 500000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal == 1500000, 7357001);
  }
}
// check: EXECUTED



//////////////////////////////////////////////
/// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;

  fun main(_vm: signer) {
    let bal_alice = DiemAccount::balance<GAS>(@{{alice}});
    print(&bal_alice);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal == 1500000, 7357002);
  }
}

// check: EXECUTED