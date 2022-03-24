//! account: alice, 300GAS
//! account: bob, 100GAS
//! account: carol, 10000GAS



//! new-transaction
//! sender: diemroot
script {
    use 0x1::Migrations;
    use 0x1::MigrateMakeWhole;
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::Vector;

    fun main(vm: signer) {
        Migrations::init(&vm);
        
        let alice_initial = DiemAccount::balance<GAS>(@{{alice}});
        let bob_initial = DiemAccount::balance<GAS>(@{{bob}});
        let carol_initial = DiemAccount::balance<GAS>(@{{carol}});

        let payees: vector<address> = Vector::empty<address>();
        let amounts: vector<u64> = Vector::empty<u64>();
 
        Vector::push_back<address>(&mut payees, @{{alice}});
        Vector::push_back<u64>(&mut amounts, 42);

        Vector::push_back<address>(&mut payees, @{{bob}});
        Vector::push_back<u64>(&mut amounts, 360);
        MigrateMakeWhole::make_whole(&vm, &payees, &amounts);

        let alice_current = DiemAccount::balance<GAS>(@{{alice}});
        let bob_current = DiemAccount::balance<GAS>(@{{bob}});
        let carol_current = DiemAccount::balance<GAS>(@{{carol}});

        assert(alice_current - alice_initial == 42, 1);
        assert(bob_current - bob_initial == 360, 2);
        assert(carol_current - carol_initial == 0, 3);

        //make sure it doesn't run twice
        MigrateMakeWhole::make_whole(&vm, &payees, &amounts);

        let alice_current = DiemAccount::balance<GAS>(@{{alice}});
        let bob_current = DiemAccount::balance<GAS>(@{{bob}});
        let carol_current = DiemAccount::balance<GAS>(@{{carol}});

        assert(alice_current - alice_initial == 42, 1);
        assert(bob_current - bob_initial == 360, 2);
        assert(carol_current - carol_initial == 0, 3);
        
    }
}
// check: "Keep(EXECUTED)"