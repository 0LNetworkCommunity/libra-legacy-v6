//! account: alice, 300GAS
 //! account: bob, 100GAS
 //! account: carol, 10000GAS



 //! new-transaction
 //! sender: diemroot
 script {
     use 0x1::MakeWhole;
     use 0x1::DiemAccount;
     use 0x1::GAS::GAS;
     use 0x1::Vector;

     fun main(vm: signer) {

         let alice_initial = DiemAccount::balance<GAS>(@{{alice}});
         let bob_initial = DiemAccount::balance<GAS>(@{{bob}});
         let carol_initial = DiemAccount::balance<GAS>(@{{carol}});

         let payees: vector<address> = Vector::empty<address>();
         let amounts: vector<u64> = Vector::empty<u64>();

         Vector::push_back<address>(&mut payees, @{{alice}});
         Vector::push_back<u64>(&mut amounts, 42);

         Vector::push_back<address>(&mut payees, @{{bob}});
         Vector::push_back<u64>(&mut amounts, 360);
         MakeWhole::make_whole_test(&vm, payees, amounts);

        let alice = DiemAccount::test_helper_create_signer(&vm, @{{alice}});
        let bob = DiemAccount::test_helper_create_signer(&vm, @{{bob}});
        let carol = DiemAccount::test_helper_create_signer(&vm, @{{carol}});

        DiemAccount::claim_make_whole_payment(&alice);
        DiemAccount::claim_make_whole_payment(&bob);
        DiemAccount::claim_make_whole_payment(&carol);


         let alice_current = DiemAccount::balance<GAS>(@{{alice}});
         let bob_current = DiemAccount::balance<GAS>(@{{bob}});
         let carol_current = DiemAccount::balance<GAS>(@{{carol}});

         assert(alice_current - alice_initial == 42, 1);
         assert(bob_current - bob_initial == 360, 2);
         assert(carol_current - carol_initial == 0, 3);

         //make sure it doesn't run twice
        DiemAccount::claim_make_whole_payment(&alice);
        DiemAccount::claim_make_whole_payment(&bob);
        DiemAccount::claim_make_whole_payment(&carol);

         let alice_current = DiemAccount::balance<GAS>(@{{alice}});
         let bob_current = DiemAccount::balance<GAS>(@{{bob}});
         let carol_current = DiemAccount::balance<GAS>(@{{carol}});

         assert(alice_current - alice_initial == 42, 1);
         assert(bob_current - bob_initial == 360, 2);
         assert(carol_current - carol_initial == 0, 3);

     }
 }
 // check: "Keep(EXECUTED)"