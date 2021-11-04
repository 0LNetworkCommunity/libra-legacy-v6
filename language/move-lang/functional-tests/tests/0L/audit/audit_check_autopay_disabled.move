//! account: alice, 1000000, 0, validator

// Test audit function val_audit_passing having autopay disabled
//! new-transaction
//! sender: diemroot
//! execute-as: alice
script {
    use 0x1::Audit;
    use 0x1::ValidatorConfig;
    use 0x1::AutoPay;
    use 0x1::TowerState;
    
    fun main(_: signer, alice_account: signer) {
        assert(ValidatorConfig::is_valid(@{{alice}}), 7357007001001);
        
        AutoPay::enable_autopay(&alice_account);
        AutoPay::disable_autopay(&alice_account);
        
        assert(!AutoPay::is_enabled(@{{alice}}), 7357007001003);       
        assert(TowerState::is_init(@{{alice}}), 7357007001004);
        assert(!Audit::val_audit_passing(@{{alice}}), 7357007001005);
    }
}
// check: EXECUTED