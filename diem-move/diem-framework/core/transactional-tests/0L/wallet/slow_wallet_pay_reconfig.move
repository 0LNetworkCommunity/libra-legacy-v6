//# init --parent-vasps Carol Bob X Alice
// Carol, X:       validator with 10M GAS
// Bob, Alice: non-validator with  1M GAS

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemAccount;

    fun main(_: signer, account: signer) {
        // before epoch change, need to mock alice's end-user address as a slow wallet
        DiemAccount::set_slow(&account);
    }
}

// Go through an epoch boundary once to trigger reconfigure

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Carol --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    // use DiemFramework::Debug::print;

    fun main(_dr: signer, account: signer) {

        // print(&DiemAccount::balance<GAS>(@Alice));
        // print(&DiemAccount::unlocked_amount(@Alice));
        // print(&DiemAccount::balance<GAS>(@Bob));

        assert!(DiemAccount::balance<GAS>(@Alice) == 1000000, 735701);
        assert!(DiemAccount::unlocked_amount(@Alice) == 10, 735702);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735703);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000005, 735704);
    }
}