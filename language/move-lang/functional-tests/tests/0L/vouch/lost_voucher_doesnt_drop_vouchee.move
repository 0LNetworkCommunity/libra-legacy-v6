// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 1
//! account: frank, 1000000, 0, validator

// GERTIE is CASE 1
//! account: gertie, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: alice
script {
    // use 0x1::DiemAccount;
    use 0x1::Vouch;
    fun main(sender: signer) {
      Vouch::init(&sender);
    }

}
//! new-transaction
//! sender: diemroot
script {
    use 0x1::Mock;
    use 0x1::Vouch;
    use 0x1::Vector;
    use 0x1::EpochBoundary;
    use 0x1::DiemSystem;

    fun main(vm: signer) {

        Mock::mock_case_1(&vm, @{{alice}}, 0, 15);
        Mock::mock_case_1(&vm, @{{bob}}, 0, 15);
        Mock::mock_case_1(&vm, @{{carol}}, 0, 15);
        Mock::mock_case_1(&vm, @{{dave}}, 0, 15);
        // EVE will be the case 4
        Mock::mock_case_1(&vm, @{{frank}}, 0, 15);
        Mock::mock_case_1(&vm, @{{gertie}}, 0, 15);

        // mock some vals vouching for alice, including eve.
        let v = Vector::singleton<address>(@{{bob}});
        Vector::push_back(&mut v, @{{eve}});

        Vouch::vm_migrate(&vm, @{{alice}}, v);

        // let b = Vouch::get_buddies(@{{alice}});
        let c = Vouch::buddies_in_set(@{{alice}});

        let len = Vector::length(&c);
        assert(len == 2, 735701);

        ///// NEW EPOCH
        EpochBoundary::reconfigure(&vm, 15);

        assert(DiemSystem::is_validator(@{{alice}}), 735702);

        assert(!DiemSystem::is_validator(@{{eve}}), 735703);

        // let b = Vouch::get_buddies(@{{alice}});
        let c = Vouch::buddies_in_set(@{{alice}});

        let len = Vector::length(&c);
        assert(len == 1, 735701);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::Mock;
    use 0x1::Vouch;
    use 0x1::Vector;
    use 0x1::EpochBoundary;
    use 0x1::DiemSystem;

    fun main(vm: signer) {
        assert(DiemSystem::is_validator(@{{alice}}), 735704);

        Mock::mock_case_1(&vm, @{{alice}}, 0, 15);
        Mock::mock_case_1(&vm, @{{bob}}, 0, 15);
        Mock::mock_case_1(&vm, @{{carol}}, 0, 15);
        Mock::mock_case_1(&vm, @{{dave}}, 0, 15);
        Mock::mock_case_1(&vm, @{{frank}}, 0, 15);
        Mock::mock_case_1(&vm, @{{gertie}}, 0, 15);

        let c = Vouch::buddies_in_set(@{{alice}});

        let len = Vector::length(&c);
        assert(len == 1, 735705);
        ///// NEW EPOCH
        EpochBoundary::reconfigure(&vm, 15);

        assert(DiemSystem::is_validator(@{{alice}}), 735706);

        // let b = Vouch::get_buddies(@{{alice}});
        let c = Vouch::buddies_in_set(@{{alice}});

        let len = Vector::length(&c);
        assert(len == 1, 735707);
    }
}
//check: EXECUTED
