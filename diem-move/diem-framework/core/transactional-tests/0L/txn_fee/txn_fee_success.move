//# init --validators Alice Bob Carol Dave

// ALICE is CASE 1
// BOB is CASE 2
// CAROL is CASE 3
// DAVE is CASE 4

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
      //NOTE: Alice is Case 1, she validates and mines. Setting up mining.
        TowerState::test_helper_mock_mining(&sender, 5);

    }
}
//check: EXECUTED


//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    fun main(_dr: signer, sender: signer) {
      //NOTE: Carol is Case 3, she mines but does not validate. Setting up mining.
        TowerState::test_helper_mock_mining(&sender, 5);

    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  // 
  // use DiemFramework::Subsidy;
  use Std::Vector;
  use DiemFramework::Stats;
  
  use DiemFramework::GAS::GAS;
  use DiemFramework::DiemAccount;
  use DiemFramework::Cases;

  fun main(vm: signer, _: signer) {
    // check the case of a network density of 4 active validators.

    let vm = &vm;
    let validators = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut validators, @Bob);

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      Stats::process_set_votes(vm, &validators);
      i = i + 1;
    };

    assert!(DiemAccount::balance<GAS>(@Alice) == 10000000, 7357190102011000);
    assert!(DiemAccount::balance<GAS>(@Bob) == 10000000, 7357190102021000);
    assert!(DiemAccount::balance<GAS>(@Carol) == 10000000, 7357190102031000);
    assert!(DiemAccount::balance<GAS>(@Dave) == 10000000, 7357190102041000);

    assert!(Cases::get_case(vm, @Alice, 0, 15) == 1, 7357190102051000);
    assert!(Cases::get_case(vm, @Bob, 0, 15) == 2, 7357190102061000);
    assert!(Cases::get_case(vm, @Carol, 0, 15) == 3, 7357190102071000);
    assert!(Cases::get_case(vm, @Dave, 0, 15) == 4, 7357190102081000);
  }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Subsidy;
    use DiemFramework::TransactionFee;
    use DiemFramework::Diem;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        let vm = &vm;
        let coin = Diem::mint<GAS>(vm, 1000);
        TransactionFee::pay_fee(coin);
        let bal = TransactionFee::get_amount_to_distribute(vm);
        assert!(bal == 1000, 7357190103011000);

        let (validators, _) = DiemSystem::get_fee_ratio(vm, 0, 15);
        //TODO: The fee ratio is unused in this proposal.
        Subsidy::process_fees(vm, &validators);

        assert!(DiemAccount::balance<GAS>(@Alice) == 10001000, 7357190103021000);
        assert!(DiemAccount::balance<GAS>(@Bob) == 10000000, 7357190103031000);
        assert!(DiemAccount::balance<GAS>(@Carol) == 10000000, 7357190103041000);
        assert!(DiemAccount::balance<GAS>(@Dave) == 10000000, 7357190103051000);
    }
}
// check: EXECUTED