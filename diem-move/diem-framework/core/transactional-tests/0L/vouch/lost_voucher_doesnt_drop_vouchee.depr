//# init --validators Alice Bob Carol Dave Eve Frank Gertie

// Scenario: Many validators. Alice received vouches from only
// Bob and Eve. Eve is about to fall out of the set.
// This should not afect Alice

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 3
// FRANK is CASE 1
// GERTIE is CASE 1

//# block --proposer Alice --time 1 --round 0

// NewBlockEvent

//# run --admin-script --signers DiemRoot Alice
script {
    // use DiemFramework::DiemAccount;
    use DiemFramework::Vouch;

    fun main(_:signer, sender: signer) {
      Vouch::init(&sender);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;
    use DiemFramework::Vouch;
    use Std::Vector;
    use DiemFramework::EpochBoundary;
    use DiemFramework::DiemSystem;
    use DiemFramework::Jail;

    fun main(_:signer, vm: signer) {
        // give the nodes bids
        Mock::pof_default(&vm);
        // make the nodes compliant
        Mock::all_good_validators(&vm);

        // except eve who is case 4
        Jail::jail(&vm, @Eve);

        // mock some vals vouching for Alice, including Eve
        // who is about to fall out of the set.
        let v = Vector::singleton<address>(@Bob);
        Vector::push_back(&mut v, @Eve);

        Vouch::vm_migrate(&vm, @Alice, v);

        // let b = Vouch::get_buddies(@Alice);
        let c = Vouch::buddies_in_set(@Alice);

        let len = Vector::length(&c);
        assert!(len == 2, 735701);

        ///// NEW EPOCH
        EpochBoundary::reconfigure(&vm, 15);

        assert!(DiemSystem::is_validator(@Alice), 735702);

        assert!(!DiemSystem::is_validator(@Eve), 735703);

        // let b = Vouch::get_buddies(@Alice);
        let c = Vouch::buddies_in_set(@Alice);

        let len = Vector::length(&c);
        assert!(len == 1, 735704);
        
        assert!(DiemSystem::is_validator(@Alice), 735705);
        assert!(!DiemSystem::is_validator(@Eve), 735706);
    }
}

// //# run --admin-script --signers DiemRoot DiemRoot
// script {
//     use DiemFramework::Mock;
//     use DiemFramework::Vouch;
//     use Std::Vector;
//     use DiemFramework::EpochBoundary;
//     use DiemFramework::DiemSystem;

//     fun main(_:signer, vm: signer) {
//         assert!(DiemSystem::is_validator(@Alice), 735704);

//         Mock::mock_case_1(&vm, @Alice, 0, 15);
//         Mock::mock_case_1(&vm, @Bob, 0, 15);
//         Mock::mock_case_1(&vm, @Carol, 0, 15);
//         Mock::mock_case_1(&vm, @Dave, 0, 15);
//         Mock::mock_case_1(&vm, @Frank, 0, 15);
//         Mock::mock_case_1(&vm, @Gertie, 0, 15);

//         let c = Vouch::buddies_in_set(@Alice);
//         let len = Vector::length(&c);
//         assert!(len == 1, 735705);
//         ///// NEW EPOCH
//         EpochBoundary::reconfigure(&vm, 15);

//         assert!(DiemSystem::is_validator(@Alice), 735706);

//         // let b = Vouch::get_buddies(@Alice);
//         let c = Vouch::buddies_in_set(@Alice);

//         let len = Vector::length(&c);
//         assert!(len == 1, 735707);
//     }
// }