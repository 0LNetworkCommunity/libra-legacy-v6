//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validator with 10M GAS
// Bob, Carol: non-validator with  1M GAS

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    // use DiemFramework::DiemConfig;
    use DiemFramework::Testnet;
    use DiemFramework::EpochBoundary;

    fun main(vm: signer, _: signer) {
        // transfers are always enabled on testnet, unsetting testnet would make transfers
        // not work, unless the conditions are met.
        Testnet::remove_testnet(&vm);
        // assert!(!DiemConfig::check_transfer_enabled(), 735701);
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
    use DiemFramework::Debug::print;

    fun main() {
        print(&777);
        print(&DiemAccount::unlocked_amount(@Alice));
        assert!(DiemAccount::unlocked_amount(@Alice) == 1000000000, 735703);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735704);
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
// check: EXECUTED