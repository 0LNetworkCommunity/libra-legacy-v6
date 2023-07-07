//# init --validators Alice

// Check if genesis subsidies have been distributed

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Subsidy;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    // use DiemFramework::Debug::print;

    fun main(vm: signer, _: signer) {
        let old_account_bal = DiemAccount::balance<GAS>(@Alice);
        // Test suite starts with a minimum of 10_000_000 GAS.

        Subsidy::genesis(&vm);
        let new_account_bal = DiemAccount::balance<GAS>(@Alice);
        assert!(new_account_bal > old_account_bal, 73570001);
        // The genesis subsidy includes a bootstrapping amount for an operator account, but also a small test amount for Infrastructure Escrow.
        assert!(new_account_bal-old_account_bal == 13500000, 73570002);
    }
}