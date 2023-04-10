//# init --validators Alice Bob Carol Dave Eve

// Check that at genesis in test mode, we have a funded infrastructure escrow pledge.


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::PledgeAccounts;

    fun main(_vm: signer, _: signer) {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012002);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012003);

        // get the infrastructure escrow amount at genesis.
        let amount = PledgeAccounts::get_available_to_beneficiary(&@VMReserved);
        assert!(amount == (DiemSystem::validator_set_size() * 2500000), 7357008012004);


    }
}
// check: EXECUTED
