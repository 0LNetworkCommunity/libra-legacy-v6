//! account: alice, 1000000GAS, 0, validator

//! new-transaction
//! sender: diemroot
//! execute-as: alice
script {
    use 0x1::Audit;
    use 0x1::ValidatorConfig;
    // use 0x1::AutoPay;
    // use 0x1::TowerState;
    // use 0x1::GAS::GAS;
    use 0x1::Vouch;
    use 0x1::Testnet;
    use 0x1::Debug::print;

    fun main(vm: signer, _alice_sig: signer) {
        Testnet::remove_testnet(&vm);
        // // Test audit function val_audit_passing satisfying all conditions
        assert(ValidatorConfig::is_valid(@{{alice}}), 7257001);
        
        // // operator has gas from genesis
        // let oper = ValidatorConfig::get_operator(@{{alice}});
        // assert(DiemAccount::balance<GAS>(oper) == 1000000, 7357007003002);
        
        // // enable autopay
        // assert(!AutoPay::is_enabled(@{{alice}}), 7357007003003);
        // AutoPay::enable_autopay(&alice_sig);
        // assert(AutoPay::is_enabled(@{{alice}}), 7357007003004);

        // assert(TowerState::is_init(@{{alice}}), 7357007003005);
        assert(!Audit::val_audit_passing(@{{alice}}), 7357002);

        // // audit must pass
        print(&Vouch::unrelated_buddies_above_thresh(@{{alice}}));
        print(&Audit::val_audit_passing(@{{alice}}));

    }
}
// check: EXECUTED