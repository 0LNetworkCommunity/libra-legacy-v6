//# init --parent-vasps Alice Bob
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS

// Scenario: trying to transfer more coins than are unlocked 
// from your Slow wallet will fail.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Testnet;
    fun main(dr: signer, account: signer) {
        // transfers are enabled in testnet, need to disable testnet to
        // check that they are disabled otherwise
        Testnet::remove_testnet(&dr);
        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        
        // There has been no epoch drip to put unlocked coins in account.
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");

        assert!(DiemAccount::balance<GAS>(@Alice) == 9999990, 0);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000010, 1);
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}

////////// Transfers should fail ////////
// check: VMExecutionFailure
/////////////////////////////////////////