// Do not add validators here, the settings added here will overwrite the genesis defaults which is what we are checking for.

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(_account: signer) {
        let num_validators = DiemSystem::validator_set_size();
        let index = 0;
        while (index < num_validators) {
            let addr = DiemSystem::get_ith_validator_address(index);
            assert!(DiemAccount::balance<GAS>(addr) == 10000000, 7357001);

            let oper = ValidatorConfig::get_operator(addr);
            assert!(DiemAccount::balance<GAS>(oper) == 1000000, 7357002);

            index = index + 1;
        };
    }
}
// check: "Keep(EXECUTED)"