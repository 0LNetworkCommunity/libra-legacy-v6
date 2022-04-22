
 //! account: carol, 10000GAS



 //! new-transaction
 //! sender: carol
 script {
     use 0x1::MakeWhole;
     use 0x1::DiemAccount;
     use 0x1::GAS::GAS;
     use 0x1::Signer;
     use 0x1::Debug::print;

     fun main(sig: signer) {
        let addr = Signer::address_of(&sig);
        let expected_amount = 0;

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

