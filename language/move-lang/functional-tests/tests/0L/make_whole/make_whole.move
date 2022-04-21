//! account: alice, 300GAS
 //! account: bob, 100GAS
 //! account: carol, 10000GAS

 //! new-transaction
 //! sender: diemroot
 //! execute-as: alice
 script {
     use 0x1::MakeWhole;
    //  use 0x1::Vector;

     fun main(vm: signer, alice_sig: signer) {
         
         MakeWhole::vm_offer_credit(&vm, &alice_sig, 42, b"carpe underpay")

     }
 }
 // check: EXECUTED


 //! new-transaction
 //! sender: diemroot
 //! execute-as: bob
 script {
     use 0x1::MakeWhole;
    //  use 0x1::Vector;

     fun main(vm: signer, bob_sig: signer) {
         
         MakeWhole::vm_offer_credit(&vm, &bob_sig, 360, b"carpe underpay" )

     }
 }
 // check: "Keep(EXECUTED)"



 //! new-transaction
 //! sender: alice
 script {
     use 0x1::MakeWhole;
     use 0x1::DiemAccount;
     use 0x1::GAS::GAS;
     use 0x1::Signer;
     use 0x1::Debug::print;

     fun main(sig: signer) {
        let addr = Signer::address_of(&sig);
        let expected_amount = 42;

        let initial = DiemAccount::balance<GAS>(addr);

        let amount = MakeWhole::query_make_whole_payment(addr);

        assert(amount == expected_amount, 7357001);

        let claimed = MakeWhole::claim_make_whole_payment(&sig);

        let current = DiemAccount::balance<GAS>(addr);
        print(&current);
        print(&initial);
        print(&amount);
        print(&claimed);

        assert(current - initial == expected_amount, 7357002);

     }
 }
  // check: EXECUTED
