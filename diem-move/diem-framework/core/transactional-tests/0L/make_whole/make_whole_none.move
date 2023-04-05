//# init --parent-vasps X Carol
// X:         validators with 10M GAS
// Carol: non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::MakeWhole;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    // use DiemFramework::Debug::print;

    fun main(_vm: signer, sig: signer) {
        let addr = Signer::address_of(&sig);
        let expected_amount = 0;
        let initial = DiemAccount::balance<GAS>(addr);
        let amount = MakeWhole::query_make_whole_payment(addr);
        assert!(amount == expected_amount, 7357001);

        let _claimed = MakeWhole::claim_make_whole_payment(&sig);
        let current = DiemAccount::balance<GAS>(addr);
        // print(&current);
        // print(&initial);
        // print(&amount);
        // print(&claimed);

        assert!(current - initial == expected_amount, 7357002);
    }
}