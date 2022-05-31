//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validator with 10M GAS
// Bob, Carol: non-validator with  1M GAS

// META: transfers between bob and carol (not slow wallets) works fine.
// Note this test also exists standalone as _meta_pay_from. But keep a transaction
// here for comprehension.

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000010, 735701);
    }
}
// check: EXECUTED

// This transaction should fail because alice is a slow wallet, and has no GAS unlocked.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::unlocked_amount(@Alice) == 0, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: ABORTED
// Error: Transaction discarded. VMStatus: status ABORTED of type Execution with sub status 120128