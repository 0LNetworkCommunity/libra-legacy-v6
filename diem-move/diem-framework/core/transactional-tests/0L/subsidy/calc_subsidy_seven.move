//# init --validators Alice

// This test is to check if subsidy calculations are impacted by dummy node statistics.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::Subsidy;
  use DiemFramework::Globals;

  fun main(vm: signer, _: signer) {
    let expected_subsidy = Subsidy::subsidy_curve(
      Globals::get_subsidy_ceiling_gas(),
      7,
      Globals::get_max_validators_per_set(),
    );

    // assumes no tx fees were paid

    let (subsidy, _) = Subsidy::calculate_subsidy(&vm, 7);
    assert!(subsidy == expected_subsidy, 7357190101021000);

  }
}
// check: EXECUTED