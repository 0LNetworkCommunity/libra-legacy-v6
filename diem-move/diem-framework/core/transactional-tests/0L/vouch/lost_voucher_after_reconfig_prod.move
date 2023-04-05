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

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::Mock;
    use DiemFramework::Vouch;
    use Std::Vector;
    use DiemFramework::EpochBoundary;
    // use DiemFramework::Debug::print;
    use DiemFramework::ProofOfFee;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, eve_sig: signer) {
        // give the nodes bids
        Mock::pof_default(&vm);
        // make the nodes compliant
        Mock::all_good_validators(&vm);


        // mock some vals vouching for Alice, including Eve.
        let v = Vector::singleton<address>(@Bob);
        Vector::push_back(&mut v, @Eve);

        Vouch::vm_migrate(&vm, @Alice, v);

        let c = Vouch::buddies_in_set(@Alice);

        let len = Vector::length(&c);
        assert!(len == 2, 735701);

        // invalidate eve so she doesn't join next epoch.
        ProofOfFee::set_bid(&eve_sig, 0, 0);
        // mock the epoch boundary
        EpochBoundary::reconfigure(&vm, 15);

        let c = Vouch::buddies_in_set(@Alice);
        // print(&c);
        let len = Vector::length(&c);
        assert!(len == 1, 735702);

        // Important: Alice should not be dropped in the new 
        // epoch even though her voucher dropped off
        assert!(DiemSystem::is_validator(@Alice), 735703);
        assert!(!DiemSystem::is_validator(@Eve), 735704);
    }
}