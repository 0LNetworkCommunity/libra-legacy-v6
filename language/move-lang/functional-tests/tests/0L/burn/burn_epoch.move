//! account: alice, 10000000GAS, 0, validator
//! account: bob, 0GAS

// Tests that Alice burns the cost-to-exist on every epoch, (is NOT sending to community index)


//! new-transaction
//! sender: alice
script {    
    use 0x1::TowerState;
    use 0x1::Diem;
    use 0x1::GAS::GAS;
    use 0x1::Burn;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.
        let mk_cap_genesis = Diem::market_cap<GAS>();

        // Validator and Operator payment 10m & 1M (for operator which is not explicit in tests)
        assert(mk_cap_genesis == 10000000 + 1000000, 7357000);

        TowerState::test_helper_mock_mining(&sender, 5);

        // alice's preferences are set to always burn
        Burn::set_send_community(&sender, false);

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
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{bob}}, 1000000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal == 1000000, 7357001);
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
  use 0x1::Diem;
  use 0x1::Debug::print;

  fun main(_vm: signer) {
    let new_cap = Diem::market_cap<GAS>();
    let val_plus_oper_start = 11000000u128; //10M + 1M
    let burn = 148000000u128; //1M
    let subsidy = 296000000u128;
    print(&new_cap);

    assert(new_cap == (val_plus_oper_start + subsidy - burn), 7357002);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal == 1000000, 7357003);
  }
}

// check: EXECUTED