//# init --validators Alice Bob Carol Dave

// ALICE is CASE 1
// BOB is CASE 2
// BOB is CASE 3
// BOB is CASE 4

// Scenario: If alice is the only validator to do work
// then she's the only one to get paid when we process the subsidy.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
      // only alice does good work
      Mock::mock_case_1(&vm, @Alice, 0, 15);

      // implied that the other validators failed to sign blocks
        
    }
}


//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::Subsidy;
  use DiemFramework::GAS::GAS;
  use DiemFramework::DiemAccount;
  use DiemFramework::DiemSystem;

  fun main(vm: signer, _: signer) {
    let (validators, _) = DiemSystem::get_fee_ratio(&vm, 0, 15);
    let subsidy_amount = 5000;

    Subsidy::process_subsidy(&vm, subsidy_amount, &validators);

    let validator_init_balance = 10000000;
    
    assert!(DiemAccount::balance<GAS>(@Alice) > validator_init_balance, 735701);
    assert!(DiemAccount::balance<GAS>(@Bob) == validator_init_balance, 735702);
    assert!(DiemAccount::balance<GAS>(@Carol) == validator_init_balance, 735703);
    assert!(DiemAccount::balance<GAS>(@Dave) == validator_init_balance, 735704);
  }
}