//# init --parent-vasps X Alice Y Bob Z Carol
// X Y Z:               validators with 10M GAS
// Alice Bob Carol: non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MakeWhole;
    use DiemFramework::Testnet;

    fun main(vm: signer, alice_sig: signer) {
        assert!(Testnet::is_testnet(), 7357001); // these functions need testnet helper
        MakeWhole::test_helper_vm_offer(&vm, &alice_sig, 42, b"carpe underpay")
    }
}

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::MakeWhole;

    fun main(vm: signer, bob_sig: signer) {
        MakeWhole::test_helper_vm_offer(&vm, &bob_sig, 360, b"carpe underpay")
    }
}

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MakeWhole;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::Debug::print;

    fun main(_vm: signer, sig: signer) {
        let addr = Signer::address_of(&sig);
        let expected_amount = 42;
        let initial = DiemAccount::balance<GAS>(addr);
        let amount = MakeWhole::query_make_whole_payment(addr);
        assert!(amount == expected_amount, 7357002);

        let claimed = MakeWhole::claim_make_whole_payment(&sig);
        let current = DiemAccount::balance<GAS>(addr);
        print(&current);
        print(&initial);
        print(&amount);
        print(&claimed);
        assert!(current - initial == expected_amount, 7357003);

        // tries to claim again, and is 0;
        let claimed_again = MakeWhole::claim_make_whole_payment(&sig);
        assert!(claimed_again == 0, 7357004);
    }
}