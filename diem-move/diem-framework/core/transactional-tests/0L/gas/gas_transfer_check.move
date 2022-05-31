//# init --parent-vasps Alice Bob
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS

// Transfers between accounts is disabled
//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Testnet;
    fun main(_dr: signer, account: signer) {
        // transfers are enabled in testnet, need to disable testnet to
        // check that they are disabled otherwise
        Testnet::remove_testnet(&account);
        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
        assert!(DiemAccount::balance<GAS>(@Alice) == 9999990, 0);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000010, 1);
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}

////////// Transfers should fail ////////
// check: VMExecutionFailure
/////////////////////////////////////////

// //! new-transaction
// // Transfers from diemroot to other accounts is enabled
// //! sender: diemroot
// //! gas-currency: GAS
// script {
// use DiemFramework::Diem;
// use DiemFramework::DiemAccount;
// use DiemFramework::GAS;
// ;
// fun main(account: signer) {
//     let coin = Diem::mint<GAS::T>(account, 10);
//     DiemAccount::deposit(account, @Bob, coin);
//     assert!(DiemAccount::balance<GAS>(@Bob) == 10, 4);
// }
// }
// // check: EXECUTED
