//# init --parent-vasps Bob Carol

// todo: Do we need the alice validator? See the old syntax below.
//       Mixing --parent-vasps with --validators gives strange errors
//// Old syntax for reference, delete it after fixing this test
// ! account: alice, 1000000GAS, 0, validator
// ! account: bob, 10GAS,
// ! account: carol, 10GAS,

// META: transfers between Bob and Carol (not slow wallets) works fine
//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, account: signer) {
        assert!(DiemAccount::balance<GAS>(@Bob) == 10000000, 735701);

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Bob) == 10000010, 735702);
    }
}
// check: EXECUTED