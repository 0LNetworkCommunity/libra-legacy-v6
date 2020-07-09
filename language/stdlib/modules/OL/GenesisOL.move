// The genesis module. This defines the majority of the Move functions that
// are executed, and the order in which they are executed in genesis. Note
// however, that there are certain calls that remain in Rust code in
// genesis (for now).
address 0x0 {
module GenesisOL {
    use 0x0::Association;
    use 0x0::Event;
    use 0x0::GAS;
    use 0x0::Libra;
    use 0x0::LibraAccount;
    use 0x0::LibraBlock;
    use 0x0::LibraConfig;
    use 0x0::LibraSystem;
    use 0x0::LibraTimestamp;
    use 0x0::LibraTransactionTimeout;
    use 0x0::LibraVersion;
    use 0x0::LibraWriteSetManager;
    use 0x0::Signer;
    use 0x0::Stats;
    use 0x0::Testnet;
    use 0x0::TransactionFee;
    use 0x0::Unhosted;
    use 0x0::ValidatorUniverse;
    use 0x0::Subsidy;
    // use 0x0::Redeem;
    use 0x0::ReconfigureOL;

    fun initialize(
        association: &signer,
        config_account: &signer,
        fee_account: &signer,
        burn_account: &signer,
        burn_account_addr: address,
        genesis_auth_key: vector<u8>,
    ) {
        let dummy_auth_key_prefix = x"00000000000000000000000000000000";

        // Association root setup
        Association::initialize(association);
        Association::grant_privilege<Libra::AddCurrency>(association, association);

        // On-chain config setup
        Event::publish_generator(config_account);
        LibraConfig::initialize(config_account, association);

        // Currency setup
        Libra::initialize(config_account);

        // Reconfigure module setup
        // This will initialize epoch_length and validator count for each epoch
        let epoch_length = 15;
        let validator_count_per_epoch = 10;
        ReconfigureOL::initialize(association, epoch_length, validator_count_per_epoch);

        // Redeem::initialize(association);

        // Stats module
        Stats::initialize(association);

        // Validator Universe setup
        ValidatorUniverse::initialize(association);
        //Subsidy module setup and burn account initialization
        Subsidy::initialize(association);

        // Set that this is testnet
        Testnet::initialize(association);

        // Event and currency setup
        Event::publish_generator(association);
        GAS::initialize(association);

        LibraAccount::initialize(association);
        Unhosted::publish_global_limits_definition(association);
        LibraAccount::create_genesis_account<GAS::T>(
            Signer::address_of(association),
            copy dummy_auth_key_prefix,
        );
        //Granting minting and burn capability to association
        Libra::grant_mint_capability_to_association<GAS::T>(association);
        Libra::grant_burn_capability_to_association<GAS::T>(association);
        Libra::publish_preburn(association, Libra::new_preburn<GAS::T>());

        // Register transaction fee accounts
        LibraAccount::create_testnet_account<GAS::T>(0xFEE, copy dummy_auth_key_prefix);
        // TransactionFee::initialize(tc_account, fee_account);
        TransactionFee::initialize(fee_account);

        // Create a burn account and publish preburn
        LibraAccount::create_burn_account<GAS::T>(
            association,
            burn_account_addr,
            copy dummy_auth_key_prefix
        );
        Libra::publish_preburn(burn_account, Libra::new_preburn<GAS::T>());

        // Create the config account
        LibraAccount::create_genesis_account<GAS::T>(
            LibraConfig::default_config_address(),
            dummy_auth_key_prefix
        );

        LibraTransactionTimeout::initialize(association);
        LibraSystem::initialize_validator_set(config_account);
        LibraVersion::initialize(config_account);

        LibraBlock::initialize_block_metadata(association);
        LibraWriteSetManager::initialize(association);
        LibraTimestamp::initialize(association);
        LibraAccount::rotate_authentication_key(association, copy genesis_auth_key);
        LibraAccount::rotate_authentication_key(config_account, copy genesis_auth_key);
        LibraAccount::rotate_authentication_key(fee_account, copy genesis_auth_key);
        LibraAccount::rotate_authentication_key(burn_account, copy genesis_auth_key);
    }

}
}
