//! account: alice, 10000000GAS, 0, validator
//! account: bob, 148000000GAS, 0, validator

// Alice is CASE 4 validator, and falls out of validator set

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Cases;
    use 0x1::Debug::print;
    use 0x1::TowerState;
    use 0x1::Vector;
    use 0x1::Stats;

    fun main(sender: signer) {
        let sender = &sender;
        let voters = Vector::singleton<address>(@{{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        TowerState::test_helper_mock_mining_vm(sender, @{{alice}}, 5 );
        // did not send any votes. 
        print(&111);
        print(&Cases::get_case(sender, @{{alice}}, 0 , 15));
        print(&Cases::get_case(sender, @{{bob}}, 0 , 15));

        // assert(Cases::get_case(&sender, @{{alice}}, 1 , 15) == 4, 7357300103011000);
        // assert(Cases::get_case(&sender, @{{bob}}, 0 , 15) == 4, 7357300103011000);

    }
}
//check: EXECUTED


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
    // let val_plus_oper_start = 10000000u128 + 1000000u128; //10M + 1M
    // let burn = 148000000u128; // 50% of validator subsidy
    // let subsidy = 0u128;
    print(&3333333);
    print(&new_cap);

    // assert(new_cap == (val_plus_oper_start + subsidy - burn), 7357002);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@{{alice}});
    print(&bal);
    // assert(bal == (10000000 - (burn as u64)), 7357003);
  }
}

// check: EXECUTED