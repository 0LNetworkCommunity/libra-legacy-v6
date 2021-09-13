//! account: alice, 1000000, 0, validator

// Test audit function val_audit_passing having autopay disabled
//! new-transaction
//! sender: diemroot
//! execute-as: alice
script {
    use 0x1::Audit;
    use 0x1::ValidatorConfig;
    use 0x1::AutoPay2;
    use 0x1::MinerState;
    
    fun main(_: signer, alice_account: signer) {
        assert(ValidatorConfig::is_valid(@{{alice}}), 7357007001001);
        
        AutoPay2::enable_autopay(&alice_account);
        AutoPay2::disable_autopay(&alice_account);
        
        assert(!AutoPay2::is_enabled(@{{alice}}), 7357007001003);       
        assert(MinerState::is_init(@{{alice}}), 7357007001004);
        assert(!Audit::val_audit_passing(@{{alice}}), 7357007001005);
    }
}
// check: EXECUTED