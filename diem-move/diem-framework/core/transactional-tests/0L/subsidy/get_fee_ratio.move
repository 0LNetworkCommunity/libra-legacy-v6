//# init --validators Alice Bob
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    fun main(_dr: signer, sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    fun main(_dr: signer, sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use Std::Vector;
  use DiemFramework::Stats;
  use Std::FixedPoint32;
  use DiemFramework::DiemSystem;

  fun main(vm: signer, _: signer) {
    // check the case of a network density of 4 active validators.

    let vm = &vm;
    let voters = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut voters, @Bob);

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      Stats::process_set_votes(vm, &voters);
      Stats::inc_prop(vm, @Alice);
      Stats::inc_prop(vm, @Bob);
      i = i + 1;
    };

    let (validators, fee_ratios) = DiemSystem::get_fee_ratio(vm, 0, 15);
    assert!(Vector::length(&validators) == 2, 735701);
    assert!(Vector::length(&fee_ratios) == 2, 735702);
    assert!(
      *(Vector::borrow<FixedPoint32::FixedPoint32>(&fee_ratios, 1)) 
        == FixedPoint32::create_from_raw_value(2147483648u64),
      735703
    );

  }
}
// check: EXECUTED