//# init
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8

// Do not add validators here, the settings added here will overwrite
// the genesis defaults which is what we are checking for.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main() {
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