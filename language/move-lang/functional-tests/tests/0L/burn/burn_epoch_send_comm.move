//! account: alice, 10000000GAS, 0, validator
//! account: bob, 10000000GAS
//! account: carol, 10000000GAS

// // make Alice a case 1 validator, so that she is in the next validator set.

//! new-transaction
//! sender: alice
script {    
    use 0x1::MinerState;
    use 0x1::Burn;
    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        MinerState::test_helper_mock_mining(&sender, 5);
        // set alice burn preferences as sending to community wallets.
        Burn::set_send_community(&sender);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Stats;
    use 0x1::Vector;
    use 0x1::Cases;

    fun main(sender: signer) {
        let sender = &sender;
        let voters = Vector::singleton<address>(@{{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        assert(Cases::get_case(sender, @{{alice}}, 0 , 15) == 1, 7357300103011000);
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
  // use 0x1::Debug::print;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{bob}}, 500000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    // print(&bal);
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
  // use 0x1::Debug::print;

  fun main(_vm: signer) {
    let bal = DiemAccount::balance<GAS>(@{{alice}});

    // print(&bal);


    // bob's community wallet increased after epoch change.
    let bal = DiemAccount::balance<GAS>(@{{bob}});

    // print(&bal);
    assert(bal == 2100399, 7357002);
  }
}

// check: EXECUTED