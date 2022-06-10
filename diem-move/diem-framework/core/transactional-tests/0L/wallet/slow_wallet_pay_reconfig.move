//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validator with 10M GAS
// Bob, Carol: non-validator with  1M GAS

// Go through an epoch boundary once to trigger reconfigure

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::unlocked_amount(@Alice) == 10, 735701);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000005, 735701);
    }
}