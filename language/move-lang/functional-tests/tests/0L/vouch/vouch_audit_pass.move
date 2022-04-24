//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0, validator
//! account: carol, 1000000GAS, 0, validator
//! account: dave, 1000000GAS, 0, validator
//! account: eve, 1000000GAS, 0, validator

//! new-transaction
//! sender: diemroot
//! execute-as: alice
script {
    use 0x1::Audit;
    use 0x1::ValidatorConfig;
    use 0x1::Vector;
    use 0x1::Vouch;
    use 0x1::Testnet;

    fun main(vm: signer, alice_sig: signer) {
        /// NOTE: when you remove testnet, you will not see the specific error code of the assert() that fails. You will only see a writeset rejection.
        Testnet::remove_testnet(&vm);

        assert(ValidatorConfig::is_valid(@{{alice}}), 7257001);
        
        Vouch::init(&alice_sig);

        let buddies = Vector::singleton<address>(@{{bob}});
        Vector::push_back(&mut buddies, @{{carol}});
        Vector::push_back(&mut buddies, @{{dave}});
        Vector::push_back(&mut buddies, @{{eve}});

        Vouch::vm_migrate(&vm, @{{alice}}, buddies);

        assert(Audit::val_audit_passing(@{{alice}}), 7357002);


    }
}
// check: EXECUTED
