#[test_only]
module DiemFramework::OnChainConfigTests {
    use DiemFramework::DiemConfig;
    use DiemFramework::Genesis;

    #[test(account = @0x1)]
    #[expected_failure(abort_code = 2)]
    fun init_before_genesis(account: signer) {
        DiemConfig::initialize(&account);
    }

    #[test(account = @0x2, dr = @DiemRoot)]
    #[expected_failure(abort_code = 1)]
    fun invalid_address_init(account: signer, dr: signer) {
        Genesis::setup(&dr);
        DiemConfig::initialize(&account);
    }

    #[test(dr = @DiemRoot)]
    #[expected_failure(abort_code = 261)]
    fun invalid_get(dr: signer) {
        Genesis::setup(&dr);
        DiemConfig::get<u64>();
    }

    #[test(account = @0x1, dr = @DiemRoot)]
    #[expected_failure(abort_code = 516)]
    fun invalid_set(account: signer, dr: signer) {
        Genesis::setup(&dr);
        DiemConfig::set_for_testing(&account, 0);
    }

    #[test(account = @0x1, dr = @DiemRoot)]
    #[expected_failure(abort_code = 2)]
    fun invalid_publish(account: signer, dr: signer) {
        Genesis::setup(&dr);
        DiemConfig::publish_new_config_for_testing(&account, 0);
    }
}
