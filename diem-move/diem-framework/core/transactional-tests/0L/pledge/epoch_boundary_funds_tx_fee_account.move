//# init --validators Alice Bob Carol Dave Eve

// Confirms that Infra Escrow is withdrawn
// from pledge accounts at time of epoch boundary prologue

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::Mock;
    use DiemFramework::EpochBoundary;
    use DiemFramework::TransactionFee;
    // use DiemFramework::Debug::print;
    use Std::Vector;



    fun main(vm: signer, _: signer) {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012002);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012003);

        // all validators compliant
        Mock::all_good_validators(&vm);

        let fees = TransactionFee::get_fees_collected();
        // print(&fees);
        assert!(fees == 0, 7357008012004);

        EpochBoundary::test_settle(&vm, 10);

        let fees = TransactionFee::get_fees_collected();
        // print(&fees);
        assert!(fees == 0, 7357008012004);

        let vals = Vector::singleton(@Alice);
        Vector::push_back(&mut vals, @Bob);
        Mock::mock_bids(&vm, &vals);

        EpochBoundary::test_prepare(&vm, &vals, 2);

        let fees = TransactionFee::get_fees_collected();
        // print(&fees);
        // There's a decimal precision issue, and 1 micro is lost.
        // left in each each pledge accounts.
        assert!(fees == 4999995, 7357008012004);
// 
    }
}
// check: EXECUTED