//# init --validators Alice Bob

// Alice is CASE 4 validator, and falls out of validator set

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Cases;
    use DiemFramework::Debug::print;
    use DiemFramework::TowerState;
    use Std::Vector;
    use DiemFramework::Stats;

    fun main(sender: signer, _: signer) {
        let sender = &sender;
        let voters = Vector::singleton<address>(@Alice);
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        TowerState::test_helper_mock_mining_vm(sender, @Alice, 5 );
        // did not send any votes. 
        print(&111);
        print(&Cases::get_case(sender, @Alice, 0 , 15));
        print(&Cases::get_case(sender, @Bob, 0 , 15));

        // assert!(Cases::get_case(&sender, @Alice, 1 , 15) == 4, 7357300103011000);
        // assert!(Cases::get_case(&sender, @Bob, 0 , 15) == 4, 7357300103011000);
    }
}

///////////////////////////////////////////
// Trigger reconfiguration at 61 seconds //
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
    // let val_plus_oper_start = 10000000u128 + 1000000u128; //10M + 1M
    // let burn = 148000000u128; // 50% of validator subsidy
    // let subsidy = 0u128;
    print(&3333333);
    print(&new_cap);

    // assert!(new_cap == (val_plus_oper_start + subsidy - burn), 7357002);

    // should not change bob's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@Alice);
    print(&bal);
    // assert!(bal == (10000000 - (burn as u64)), 7357003);
  }
}