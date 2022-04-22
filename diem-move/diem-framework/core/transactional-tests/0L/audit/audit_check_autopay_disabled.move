//# init --validators Alice

// Test audit function val_audit_passing having autopay disabled
//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Audit;
    use DiemFramework::ValidatorConfig;
    use DiemFramework::AutoPay;
    use DiemFramework::TowerState;
    use Std::Signer;

    fun main(_dr: signer, sender: signer) {
        let alice_addr = Signer::address_of(&sender);
        assert!(ValidatorConfig::is_valid(alice_addr), 7357007001001);
        
        AutoPay::enable_autopay(&sender);
        AutoPay::disable_autopay(&sender);
        
        assert!(!AutoPay::is_enabled(alice_addr), 7357007001003);       
        assert!(TowerState::is_init(alice_addr), 7357007001004);
        assert!(!Audit::val_audit_passing(alice_addr), 7357007001005);
    }
}
// check: EXECUTED