//# init --validators Alice
//# --addresses Bob=0x2e3a0b7a741dae873bf0f203a82dfd52
//# --private-keys Bob=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8

//# run --signers DiemRoot
//#     --args @Bob
//#     -- 0x1::DiemAccount::test_harness_create_user


// Alice is a Validator
// Bob is a community wallet.
// We are checking that by default, Bob does not receive any funds from Alice's burn, because she has not opted to recycle.
// Tests that Alice burns the cost-to-exist on every epoch, 
// (is NOT sending to community index)

//# run --admin-script --signers DiemRoot Alice
script {    
    use DiemFramework::TowerState;
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Burn;
    use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.
        let mk_cap_genesis = Diem::market_cap<GAS>();
        print(&mk_cap_genesis);

        // Validator and Operator payment 10m & 1M 
        // for Alice only
        // (for operator which is not explicit in tests)
        assert!(mk_cap_genesis == 10000000 + 1000000, 7357000);

        TowerState::test_helper_mock_mining(&sender, 5);
        
        // alice's preferences are set to always burn
        Burn::set_send_community(&sender, false);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::Cases;

    fun main(dr: signer, _account: signer) {
        let dr = &dr;
        let voters = Vector::singleton<address>(@Alice);
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(dr, &voters);
            i = i + 1;
        };

        assert!(Cases::get_case(dr, @Alice, 0, 15) == 1, 7357300103011000);
    }
}

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(vm: signer, _account: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Bob, 1000000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 1000000, 7357003);
  }
}

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  use DiemFramework::Debug::print;

  fun main() {
    let new_cap = Diem::market_cap<GAS>();
    let val_plus_oper_start = 11000000u128; //10M + 1M
    let burn = 148000000u128; //1M
    let subsidy = 296000000u128;
    print(&new_cap);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 1000000, 7357004);

    assert!(new_cap == (val_plus_oper_start + subsidy - burn), 7357004);


  }
}