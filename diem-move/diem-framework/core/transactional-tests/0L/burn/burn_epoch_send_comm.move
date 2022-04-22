//! account: alice, 10000000GAS, 0, validator
//! account: bob, 10000000GAS  // community wallet
//! account: carol, 10000000GAS // community wallet

// make Alice a case 1 validator, so that she is in the next validator set.

//! new-transaction
//! sender: alice
script {    
    use DiemFramework::TowerState;
    use DiemFramework::Burn;
    use DiemFramework::Audit;
    use DiemFramework::Debug::print;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        // set alice burn preferences as sending to community wallets.
        Burn::set_send_community(&sender);
        print(&@DiemFramework);
        // validator needs to qualify for next epoch for the burn to register
        Audit::test_helper_make_passing(&sender);
        print(&AutoPay::is_enabled(@{{alice}}));


        print(&Audit::val_audit_passing(@{{alice}}));

        AutoPay::enable_autopay(&sender);
        print(&AutoPay::is_enabled(@{{alice}}));
        print(&Audit::val_audit_passing(@{{alice}}));

    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::Cases;

    fun main(sender: signer) {
        let sender = &sender;
        let voters = Vector::singleton<address>(@{{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        assert!(Cases::get_case(sender, @{{alice}}, 0 , 15) == 1, 7357300103011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{bob}}, 500000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert!(bal == 1500000, 7357003);
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
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Debug::print;

  fun main(_vm: signer) {
    // bob's community wallet increased after epoch change.
    let bal = DiemAccount::balance<GAS>(@{{bob}});
    print(&bal);
    assert!(bal == 2100399, 7357004);
  }
}

// check: EXECUTED