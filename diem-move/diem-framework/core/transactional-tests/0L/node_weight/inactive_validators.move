//# init --validators Alice Bob Carol Dave Eve

// In this test only Alice mines above threshold.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::NodeWeight;
    use DiemFramework::ValidatorUniverse;
    use DiemFramework::TowerState;
    // use DiemFramework::Debug::print;
    

    fun main(vm: signer, _: signer) {
        let vm = &vm;

        // Base Case: If validator universe vector length is less than the 
        // validator set size limit (N), return vector itself.
        // N equals to the vector length.

        //Check the size of the validator universe.
        let vec =  ValidatorUniverse::get_eligible_validators();
        let len = Vector::length<address>(&vec);
        assert!(len == 5, 7357140102011000);

        TowerState::reconfig(vm, &vec);

        // This is the base case: check case of the validator set limit being 
        // less than universe size.
        // NOTE: there's a known issue when many validators have the same
        // weight, the nodes included will be those LAST included in the validator universe.
        let top_n_is_under = NodeWeight::top_n_accounts(vm, 3);
        // print(&top_n_is_under);
        assert!(Vector::length<address>(&top_n_is_under) == 3, 7357140102021000);

        // Check BOB is NOT in that list.
        assert!(!Vector::contains<address>(&top_n_is_under, &@Bob), 7357140102031000);
        assert!(Vector::contains<address>(&top_n_is_under, &@Alice), 7357140102041000);
        // case of querying the full validator universe.

        let top_n_is_equal = NodeWeight::top_n_accounts(vm, len);
        // One of the nodes did not vote, so they will be excluded from list.

        assert!(Vector::length<address>(&top_n_is_equal) == len, 7357140102051000);

        // Check Bob IS on that list.
        assert!(Vector::contains<address>(&top_n_is_equal, &@Bob), 7357140102061000);
        
        // case of querying a larger n than the validator universe.
        // Check if we ask for a larger set we also get 
        let top_n_is_over = NodeWeight::top_n_accounts(vm, 9);
        assert!(Vector::length<address>(&top_n_is_over) == len, 7357140102071000);

        // Check Bob IS on that list.
        assert!(Vector::contains<address>(&top_n_is_equal, &@Bob), 7357140102081000);
    }
}
// check: EXECUTED