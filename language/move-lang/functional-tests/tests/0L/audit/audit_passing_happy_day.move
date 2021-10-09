//! account: alice, 1000000GAS, 0, validator

//! new-transaction
//! sender: diemroot
//! execute-as: alice
script {
    use 0x1::Audit;
    use 0x1::ValidatorConfig;
    use 0x1::AutoPay;
    use 0x1::MinerState;
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;
    
    fun main(_: signer, alice_account: signer) {
        // Test audit function val_audit_passing satisfying all conditions
        assert(ValidatorConfig::is_valid(@{{alice}}), 7357007003001);
        
        // operator has gas from genesis
        let oper = ValidatorConfig::get_operator(@{{alice}});
        assert(DiemAccount::balance<GAS>(oper) == 1000000, 7357007003002);
        
        // enable autopay
        assert(!AutoPay::is_enabled(@{{alice}}), 7357007003003);
        AutoPay::enable_autopay(&alice_account);
        assert(AutoPay::is_enabled(@{{alice}}), 7357007003004);

        assert(MinerState::is_init(@{{alice}}), 7357007003005);

        // audit must pass
        assert(Audit::val_audit_passing(@{{alice}}), 7357007003006);
    }
}
// check: EXECUTED