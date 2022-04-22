// This test is to check if Proof of weight is intialized properly

//# init --validators Alice
//! account: bob, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
    
    use DiemFramework::DiemSystem;
    use DiemFramework::NodeWeight;
    use DiemFramework::ValidatorUniverse;
    fun main(_account: signer) {
        // Valida
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 2, 7357220101011000);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357220101021000);
        assert!(NodeWeight::proof_of_weight(@Alice) == 0, 7357220101031000);
        assert!(ValidatorUniverse::exists_jailedbit(@Alice), 7357220101041000);
    }
}
// check: EXECUTED
