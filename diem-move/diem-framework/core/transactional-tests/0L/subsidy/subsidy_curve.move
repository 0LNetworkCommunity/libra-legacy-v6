//! account: alice, 1000000, 0 , validator

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::Subsidy;
  use DiemFramework::Globals;

  fun main(_vm: signer) {
    // expected subsidy for <= 4 should be the subsidy ceiling

    let expected_subsidy = Subsidy::subsidy_curve(
      Globals::get_subsidy_ceiling_gas(),
      1, // one validator suceeded
      Globals::get_max_validators_per_set(),
    );
    assert!(expected_subsidy == Globals::get_subsidy_ceiling_gas(), 7357001);

    let expected_subsidy = Subsidy::subsidy_curve(
      Globals::get_subsidy_ceiling_gas(),
      4, // four suceeded, should be the same as 1
      Globals::get_max_validators_per_set(),
    );
    assert!(expected_subsidy == Globals::get_subsidy_ceiling_gas(), 7357002);

    let expected_subsidy = Subsidy::subsidy_curve(
      Globals::get_subsidy_ceiling_gas(),
      99, // 99, should be 3083333
      Globals::get_max_validators_per_set(),
    );

    assert!(expected_subsidy == 3083333, 7357002);

    // subsidy should be 0 if over the max validator limit
    let expected_subsidy = Subsidy::subsidy_curve(
      Globals::get_subsidy_ceiling_gas(),
      Globals::get_max_validators_per_set(), // all validators succeeded
      Globals::get_max_validators_per_set(),
    );
    assert!(expected_subsidy == 0, 7357003);

  }
}
// check: EXECUTED