// ALICE is CASE 1
//! account: alice, 1000000GAS, 0, validator

// BOB is CASE 2
//! account: bob, 1000000GAS, 0, validator

// BOB is CASE 3
//! account: carol, 1000000GAS, 0, validator

// BOB is CASE 4
//! account: dave, 1000000GAS, 0, validator

//! new-transaction
//! sender: alice
script {
    use DiemFramework::TowerState;
    fun main(sender: signer) {
        //NOTE: Alice is Case 1, she validates and mines. Setting up mining.
        let mining_proofs = 5;
        TowerState::test_helper_mock_mining(&sender, mining_proofs);

    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use DiemFramework::TowerState;
    fun main(sender: signer) {
        let mining_proofs = 5;
      //NOTE: Carol is Case 3, she mines but does not validate. Setting up mining.
        TowerState::test_helper_mock_mining(&sender, mining_proofs);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  // 
  // use DiemFramework::Subsidy;
  use Std::Vector;
  use DiemFramework::Stats;
  use DiemFramework::GAS::GAS;
  use DiemFramework::DiemAccount;
  use DiemFramework::Cases;

  fun main(vm: signer) {
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

    assert!(DiemAccount::balance<GAS>(@Alice) == 1000000, 7357190102011000);
    assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 7357190102021000);
    assert!(DiemAccount::balance<GAS>(@Carol) == 1000000, 7357190102031000);
    assert!(DiemAccount::balance<GAS>(@Dave) == 1000000, 7357190102041000);

    assert!(Cases::get_case(vm, @Alice, 0, 15) == 1, 7357190102051000);
    assert!(Cases::get_case(vm, @Bob, 0, 15) == 2, 7357190102061000);
    assert!(Cases::get_case(vm, @Carol, 0, 15) == 3, 7357190102071000);
    assert!(Cases::get_case(vm, @Dave, 0, 15) == 4, 7357190102081000);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::Subsidy;
  use DiemFramework::GAS::GAS;
  use DiemFramework::DiemAccount;
  use DiemFramework::DiemSystem;

  fun main(vm: signer) {
    let (validators, _) = DiemSystem::get_fee_ratio(&vm, 0, 15);
    let subsidy_amount = 1000000;
    let mining_proofs = 5; // mocked above
    // from Subsidy::BASELINE_TX_COST * genesis proof for account
    let refund_to_operator = 4336 * mining_proofs; 
    Subsidy::process_subsidy(&vm, subsidy_amount, &validators);
    // starting balance + subsidy amount - refund operator tx fees for mining
    assert!(
      DiemAccount::balance<GAS>(@Alice) == 1000000 + subsidy_amount - refund_to_operator,
      7357190102091000
    );
    // 995764

    assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 7357190102101000);
    assert!(DiemAccount::balance<GAS>(@Carol) == 1000000, 7357190102111000);
    assert!(DiemAccount::balance<GAS>(@Dave) == 1000000, 7357190102121000);
  }
}
// check: EXECUTED
