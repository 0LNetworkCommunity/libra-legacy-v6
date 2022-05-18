//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#                  Carol=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//#                     Carol=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d

//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,

//# run --admin-script --signers DiemRoot DiemRoot
script {
use DiemFramework::DiemAccount;
use DiemFramework::DiemConfig;
use DiemFramework::Testnet;
use DiemFramework::EpochBoundary;
fun main(vm: signer, _: signer) {
    // transfers are always enabled on testnet, unsetting testnet would make transfers
    // not work, unless the conditions are met.
    Testnet::remove_testnet(&vm);
    assert!(!DiemConfig::check_transfer_enabled(), 735701);
    assert!(DiemAccount::unlocked_amount(@Alice) == 0, 735702);

    // TODO: simulate epoch boundary with testsuite directives. 
    // Annoying to do with production values. Note: after an epoch change event
    // subsequent transactions appear expired after long epochs in tests. 
    // Using reconfigure() for now.

    EpochBoundary::reconfigure(&vm, 30);
}
}

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    fun main() {
        assert!(DiemAccount::unlocked_amount(@Alice) == 0, 735703);
        assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735704);
    }
}
// check: EXECUTED

// Alice tries to send the payment anyways.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    fun main(_dr: signer, account: signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: ABORTED