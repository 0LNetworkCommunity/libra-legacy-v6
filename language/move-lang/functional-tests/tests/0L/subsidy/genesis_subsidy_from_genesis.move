// Do not add validators here, the settings added here will overwrite the genesis defaults which is what we are checking for.

//! new-transaction
//! sender: libraroot
script {
    use 0x1::LibraSystem;
    use 0x1::LibraAccount;
    use 0x1::GAS::GAS;
    use 0x1::Debug::print;

    fun main(_account: &signer) {
        let num_validators = LibraSystem::validator_set_size();
        let index = 0;
        while (index < num_validators) {
            let addr = LibraSystem::get_ith_validator_address(index);
            print(&LibraAccount::balance<GAS>(addr));
            assert(LibraAccount::balance<GAS>(addr) == 249753600, 7357001);
            index = index + 1;
        };
    }
}
// check: "Keep(EXECUTED)"