//# init --validators Alice Bob Carol Dave Eve Frank Gertie

// Testing if EVE a CASE 3 Validator gets dropped.

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

    fun main(_: signer, sender: signer) {
      Vouch::init(&sender);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;
    use DiemFramework::Vouch;
    use Std::Vector;
    use DiemFramework::EpochBoundary;
    use DiemFramework::Debug::print;

    fun main(vm: signer, _: signer) {
        Mock::mock_case_1(&vm, @Alice, 0, 15);
        Mock::mock_case_1(&vm, @Bob, 0, 15);
        Mock::mock_case_1(&vm, @Carol, 0, 15);
        Mock::mock_case_1(&vm, @Dave, 0, 15);
        // EVE will be the case 4
        Mock::mock_case_1(&vm, @Frank, 0, 15);
        Mock::mock_case_1(&vm, @Gertie, 0, 15);

        // mock some vals vouching for Alice, including Eve.
        let v = Vector::singleton<address>(@Bob);
        Vector::push_back(&mut v, @Eve);

        Vouch::vm_migrate(&vm, @Alice, v);

        // let b = Vouch::get_buddies(@Alice);
        let c = Vouch::buddies_in_set(@Alice);

        let len = Vector::length(&c);
        assert!(len == 2, 735701);

        // mock the epoch boundary
        EpochBoundary::reconfigure(&vm, 15);

        let c = Vouch::buddies_in_set(@Alice);
        print(&c);
        let len = Vector::length(&c);
        assert!(len == 1, 735702);
    }
}