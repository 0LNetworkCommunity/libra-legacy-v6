//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validators with 10M GAS
// Bob, Carol: non-validators with  1M GAS

// META: transfers between Bob and Carol (not slow wallets) works fine
//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000010, 735702);
    }
}
// check: EXECUTED