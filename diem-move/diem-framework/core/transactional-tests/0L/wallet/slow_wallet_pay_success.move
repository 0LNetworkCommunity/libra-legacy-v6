//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validator with 10M GAS
// Bob, Carol: non-validator with  1M GAS

//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;

    fun main(vm: signer, _: signer) {
        DiemAccount::slow_wallet_epoch_drip(&vm, 100);
        assert!(DiemAccount::unlocked_amount(@Alice) == 100, 735701);
    }
}
// check: EXECUTED

// Successful unlock and transfer.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735702);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);

        assert!(DiemAccount::balance<GAS>(@Bob) == 1000010, 735703);
    }
}
// check: EXECUTED