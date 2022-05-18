//# init --validators Alice
//#      --addresses Eve=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#      --private-keys Eve=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d

// Adding new validator epoch info

//# run --admin-script --signers DiemRoot DiemRoot
script{
use DiemFramework::ValidatorUniverse;
use Std::Vector;
// use DiemFramework::TestFixtures;
// use DiemFramework::DiemAccount;

fun main(vm: signer, _: signer) {
    let len = Vector::length<address>(
        &ValidatorUniverse::get_eligible_validators(&vm)
    );
    assert!(len == 1, 73570);
}
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script{
use DiemFramework::ValidatorUniverse;
use DiemFramework::TestFixtures;
use DiemFramework::TowerState;
// use DiemFramework::FullnodeState;

fun main(_dr: signer, eve_sig: signer) {
    let eve_sig = &eve_sig;
    TowerState::init_miner_state(
        eve_sig,
        &TestFixtures::easy_chal(),
        &TestFixtures::easy_sol(),
        TestFixtures::easy_difficulty(), // difficulty
        TestFixtures::security(), // security
    );
    // FullnodeState::init(eve_sig);

    TowerState::test_helper_mock_mining(eve_sig, 5);
    ValidatorUniverse::add_self(eve_sig);
}
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script{
    use Std::Vector;
    use DiemFramework::ValidatorUniverse;

    fun main(vm: signer, _: signer) {
        let len = Vector::length<address>(
            &ValidatorUniverse::get_eligible_validators(&vm
        ));
        assert!(len == 2, 73570);
    }
}
// check: EXECUTED
