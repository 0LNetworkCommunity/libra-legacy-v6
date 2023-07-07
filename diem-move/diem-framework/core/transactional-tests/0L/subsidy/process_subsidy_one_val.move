//# init --validators Alice Bob Carol Dave


// Scenario: If alice is the only validator to do work
// then she's the only one to get paid when we process the subsidy.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Mock;
    use DiemFramework::DiemAccount;
    use DiemFramework::TransactionFee;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Diem;

    fun main(vm: signer, b_sig: signer) {
      // alice does good work
      Mock::mock_case_1(&vm, @Alice, 0, 15);

      let validator_init_balance = 10000000;
      assert!(DiemAccount::balance<GAS>(@Alice) == validator_init_balance, 735700);

      // need to also mock network fees being paid.
      // have Bob pay into the network fees.
      let fees = 4444444;
      let c = DiemAccount::vm_genesis_simple_withdrawal(&vm, &b_sig, fees);
      let c_value = Diem::value(&c);
      TransactionFee::pay_fee(c);

      let v = TransactionFee::get_fees_collected();
      assert!( c_value == v, 735701);
      // implied that the other validators failed to sign blocks
        
    }
}



//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::Subsidy;
  use DiemFramework::GAS::GAS;
  use DiemFramework::DiemAccount;
  use DiemFramework::DiemSystem;
  use DiemFramework::ProofOfFee;

  fun main(vm: signer, _: signer) {
    let (validators, _) = DiemSystem::get_fee_ratio(&vm, 0, 15);
    // let subsidy_amount = 5000;

    Subsidy::process_fees(&vm, &validators);

    let validator_init_balance = 10000000;

    let (cr, _, _) = ProofOfFee::get_consensus_reward();

    assert!(cr == 1000000, 735702);
    
    // Alice should get paid exactly what was advertised at the start of the auction, at start of epoch.
    assert!(DiemAccount::balance<GAS>(@Alice) > validator_init_balance, 735703);
    assert!(DiemAccount::balance<GAS>(@Alice) == validator_init_balance + cr, 735704);

    // bob paid into the network fees.
    assert!(DiemAccount::balance<GAS>(@Bob) < validator_init_balance, 735705);
    assert!(DiemAccount::balance<GAS>(@Carol) == validator_init_balance, 735706);
    assert!(DiemAccount::balance<GAS>(@Dave) == validator_init_balance, 735707);
  }
}