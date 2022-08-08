//# init --validators Alice Bob Carol Dave Eve

// All nodes except Eve mined above threshold. 

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 735701);
    }
}
//check: EXECUTED


//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 4);
        assert!(TowerState::get_count_in_epoch(@Bob) == 4, 735702);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 3);
        assert!(TowerState::get_count_in_epoch(@Carol) == 3, 735703);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 2);
        assert!(TowerState::get_count_in_epoch(@Dave) == 2, 735704);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::NodeWeight;
    use DiemFramework::ValidatorUniverse;
    use DiemFramework::TowerState;

    fun main(vm: signer, _: signer) {
        // Base Case: If validator universe vector length is less than the 
        // validator set size limit (N), return vector itself.
        // N equals to the vector length.

        let vm = &vm;
        //Check the size of the validator universe.
        let vec =  ValidatorUniverse::get_eligible_validators();
        let len = Vector::length<address>(&vec);
        assert!(len == 5, 7357140102011000);

        TowerState::reconfig(vm, &vec);

        // This is the base case: check case of the validator set limit being 
        // less than universe size.
        let top_n_is_under = NodeWeight::top_n_accounts(vm, 3);
        assert!(Vector::length<address>(&top_n_is_under) == 3, 735705);

        // Check eve is NOT in that list.
        assert!(
            Vector::contains<address>(&top_n_is_under, &@Eve) != true, 
            7357140102031000
        );

        // case of querying the full validator universe.
        let top_n_is_equal = NodeWeight::top_n_accounts(vm, len);
        // One of the nodes did not vote, so they will be excluded from list.

        assert!(Vector::length<address>(&top_n_is_equal) == len, 735706);

        // Check eve IS on that list.
        assert!(Vector::contains<address>(&top_n_is_equal, &@Eve), 735707);
        
        // case of querying a larger n than the validator universe.
        // Check if we ask for a larger set we also get 
        let top_n_is_over = NodeWeight::top_n_accounts(vm, 9);
        assert!(Vector::length<address>(&top_n_is_over) == len, 735708);
    }
}
// check: EXECUTED