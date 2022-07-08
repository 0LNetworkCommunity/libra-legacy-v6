//# init --validators Alice Bob Carol

//! account: alice, 300GAS
 //! account: bob, 100GAS
 //! account: carol, 10000GAS

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::MakeWhole;
    use Std::Vector;

    fun main(vm: signer, _dr: signer) {
        let payees: vector<address> = Vector::empty<address>();
        let amounts: vector<u64> = Vector::empty<u64>();

        Vector::push_back<address>(&mut payees, @Alice);
        Vector::push_back<u64>(&mut amounts, 42);
        Vector::push_back<address>(&mut payees, @Bob);
        Vector::push_back<u64>(&mut amounts, 360);
        MakeWhole::make_whole_test(&vm, payees, amounts);
    }
}
// check: "Keep(EXECUTED)"

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MakeWhole;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use Std::Signer;

    fun main(_dr: signer, sender: signer) {
        let addr = Signer::address_of(&sender);
        let expected_amount = 42;
        let initial = DiemAccount::balance<GAS>(addr);
        let (_, idx) = MakeWhole::query_make_whole_payment(addr);
        assert!(MakeWhole::claim_make_whole_payment(&sender, idx) == expected_amount, 7);
        let current = DiemAccount::balance<GAS>(addr);
        assert!(current - initial == expected_amount, 1);
    }
}
// check: "VMExecutionFailure(ABORTED { code: 22017,"

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MakeWhole;
    use Std::Signer;

    fun main(_dr: signer, sender: signer) {
        use DiemFramework::Debug::print;
        print(&11);
        let addr = Signer::address_of(&sender);
        let (_, idx) = MakeWhole::query_make_whole_payment(addr);
        //make sure it doesn't run twice
        MakeWhole::claim_make_whole_payment(&sender, idx);
        print(&12);
    }
}
// check: "VMExecutionFailure(ABORTED { code: 22016,"

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::MakeWhole;

    fun main(_dr: signer, sender: signer) {
        use DiemFramework::Debug::print;
        print(&21);
        //carol should not be able to claim bob's payment
        let (_, idx) = MakeWhole::query_make_whole_payment(@Bob);
        MakeWhole::claim_make_whole_payment(&sender, idx);
        print(&22);
    }
}
// check: ABORTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::MakeWhole;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use Std::Signer;

    fun main(_dr: signer, sender: signer) {
        let addr = Signer::address_of(&sender);
        let expected_amount = 360;
        let initial = DiemAccount::balance<GAS>(addr);
        let (_, idx) = MakeWhole::query_make_whole_payment(addr);
        assert!(MakeWhole::claim_make_whole_payment(&sender, idx) == expected_amount, 7);
        let current = DiemAccount::balance<GAS>(addr);
        assert!(current - initial == expected_amount, 1);
    }
}
// check: "Keep(EXECUTED)"

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::MakeWhole;
    use Std::Signer;

    fun main(_dr: signer, sender: signer) {
        let addr = Signer::address_of(&sender);
        let expected_amount = 0;
        let (amt, idx) = MakeWhole::query_make_whole_payment(addr);

        assert!(amt == expected_amount, 11);
        assert!(idx == 0, 12);
    }
}
// check: "Keep(EXECUTED)"