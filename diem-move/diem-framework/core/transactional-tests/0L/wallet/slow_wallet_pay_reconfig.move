//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#                  Carol=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//#                     Carol=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d

//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,

// Go through an epoch boundary once to trigger reconfigure

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

// This transaction should fail because alice is a slow wallet, and has no GAS unlocked.
//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::unlocked_amount(@Alice) == 10, 735701);
        assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 15, 735701);
    }
}
// check: EXECUTED