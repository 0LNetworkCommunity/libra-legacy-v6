//! account: alice, 300GAS
 //! account: bob, 100GAS
 //! account: carol, 10000GAS



 //! new-transaction
 //! sender: diemroot
 script {
     use 0x1::MakeWhole;
     use 0x1::Vector;

     fun main(vm: signer) {
         let payees: vector<address> = Vector::empty<address>();
         let amounts: vector<u64> = Vector::empty<u64>();

         Vector::push_back<address>(&mut payees, @{{alice}});
         Vector::push_back<u64>(&mut amounts, 42);

         Vector::push_back<address>(&mut payees, @{{bob}});
         Vector::push_back<u64>(&mut amounts, 360);
         MakeWhole::make_whole_test(&vm, payees, amounts);

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
     //use 0x1::Debug::print;

     fun main(sig: signer) {
         let addr = Signer::address_of(&sig);
         let expected_amount = 42;

         let initial = DiemAccount::balance<GAS>(addr);

         let (_, idx) = MakeWhole::query_make_whole_payment(addr);

        assert(MakeWhole::claim_make_whole_payment(&sig, idx) == expected_amount, 7);

         let current = DiemAccount::balance<GAS>(addr);

         assert(current - initial == expected_amount, 1);

     }
 }
  // check: "VMExecutionFailure(ABORTED { code: 22017,"

 //! new-transaction
 //! sender: alice
 script {
     use 0x1::MakeWhole;
     use 0x1::Signer;
     //use 0x1::Debug::print;

     fun main(sig: signer) {
         let addr = Signer::address_of(&sig);

         let (_, idx) = MakeWhole::query_make_whole_payment(addr);

         //make sure it doesn't run twice
        MakeWhole::claim_make_whole_payment(&sig, idx);

     }
 }
  // check: "VMExecutionFailure(ABORTED { code: 22016,"


 //! new-transaction
 //! sender: carol
 script {
     use 0x1::MakeWhole;

     fun main(sig: signer) {
        //carol should not be able to claim bob's payment
         let (_, idx) = MakeWhole::query_make_whole_payment(@{{bob}});

         MakeWhole::claim_make_whole_payment(&sig, idx);

     }
 }
   // check: ABORTED


 //! new-transaction
 //! sender: bob
 script {
     use 0x1::MakeWhole;
     use 0x1::DiemAccount;
     use 0x1::GAS::GAS;
     use 0x1::Signer;

     fun main(sig: signer) {
         let addr = Signer::address_of(&sig);
         let expected_amount = 360;

         let initial = DiemAccount::balance<GAS>(addr);

         let (_, idx) = MakeWhole::query_make_whole_payment(addr);

        assert(MakeWhole::claim_make_whole_payment(&sig, idx) == expected_amount, 7);

         let current = DiemAccount::balance<GAS>(addr);

         assert(current - initial == expected_amount, 1);

     }
 }
   // check: "Keep(EXECUTED)"



 //! new-transaction
 //! sender: carol
 script {
     use 0x1::MakeWhole;
     use 0x1::Signer;

     fun main(sig: signer) {
         let addr = Signer::address_of(&sig);
         let expected_amount = 0;

         let (amt, idx) = MakeWhole::query_make_whole_payment(addr);

         assert(amt == expected_amount, 11);
         assert(idx == 0, 12);
     }
 }
   // check: "Keep(EXECUTED)"
  