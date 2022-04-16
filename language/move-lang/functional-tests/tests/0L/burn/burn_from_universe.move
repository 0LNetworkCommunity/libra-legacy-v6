//! account: alice, 10000000GAS, 0, validator
//! account: bob, 1000000GAS

// Alice is CASE 4 validator, and falls out of validator set

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Cases;
    use 0x1::Debug::print;

    fun main(sender: signer) {
        // let sender = &sender;
        // let voters = Vector::singleton<address>(@{{alice}});
        // let i = 1;
        // while (i < 16) {
        //     // Mock the validator doing work for 15 blocks, and stats being updated.
        //     Stats::process_set_votes(sender, &voters);
        //     i = i + 1;
        // };

        // did not send any votes. 
        print(&111);
        assert(Cases::get_case(&sender, @{{alice}}, 0 , 15) == 4, 7357300103011000);
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
    let val_plus_oper_start = 10000000u128 + 1000000u128; //10M + 1M
    let burn = 1000000u128; //1M
    let subsidy = 0u128;
    print(&new_cap);

    assert(new_cap == (val_plus_oper_start + subsidy - burn), 7357002);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@{{alice}});
    assert(bal == (10000000 - (burn as u64)), 7357003);
  }
}

// check: EXECUTED