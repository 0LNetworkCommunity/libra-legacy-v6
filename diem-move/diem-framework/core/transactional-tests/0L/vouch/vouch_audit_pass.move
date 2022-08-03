//# init --validators Alice Bob Carol Dave Eve

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Audit;
    use DiemFramework::ValidatorConfig;
    use Std::Vector;
    use DiemFramework::Vouch;
    use DiemFramework::Testnet;

    fun main(vm: signer, alice_sig: signer) {
        // NOTE: when you remove testnet, you will not see the specific error
        // code of the assert!() that fails. You will only see a writeset rejection.
        Testnet::remove_testnet(&vm);

        assert!(ValidatorConfig::is_valid(@Alice), 7257001);
        
        Vouch::init(&alice_sig);

        let buddies = Vector::singleton<address>(@Bob);
        Vector::push_back(&mut buddies, @Carol);
        Vector::push_back(&mut buddies, @Dave);
        Vector::push_back(&mut buddies, @Eve);

        Vouch::vm_migrate(&vm, @Alice, buddies);

        assert!(Audit::val_audit_passing(@Alice), 7357002);
    }
}