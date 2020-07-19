// The genesis module. This defines the majority of the Move functions that
// are executed, and the order in which they are executed in genesis. Note
// however, that there are certain calls that remain in Rust code in
// genesis (for now).
address 0x0 {
module GenesisOL {
    // use 0x0::Association;
    use 0x0::Event;
    use 0x0::GAS;
    use 0x0::Globals;
    use 0x0::Libra;
    use 0x0::LibraAccount;
    use 0x0::LibraBlock;
    use 0x0::LibraConfig;
    use 0x0::LibraSystem;
    use 0x0::LibraTimestamp;
    use 0x0::LibraTransactionTimeout;
    use 0x0::LibraVersion;
    use 0x0::LibraWriteSetManager;
    use 0x0::Stats;
    use 0x0::Testnet;
    use 0x0::Transaction;
    use 0x0::TransactionFee;
    use 0x0::Unhosted;
    use 0x0::ValidatorUniverse;
    use 0x0::Subsidy;
    use 0x0::Signer;

    fun initialize(
        vm: &signer,
        config_account: &signer,
        fee_account: &signer,
        burn_account: &signer,
    ) {
        let dummy_auth_key_prefix = x"00000000000000000000000000000000";

        // Association root setup
        // Association::initialize(vm);

        //TODO: Does the VM need the privilege to add a currency?
        // Association::grant_privilege<Libra::AddCurrency>(vm, vm);

        //TODO: Do these initializations need to be from a config account?
        // On-chain config setup
        Event::publish_generator(config_account);
        LibraConfig::initialize(config_account, vm);
        // Currency setup
        Libra::initialize(config_account);

        // Stats module
        Stats::initialize(vm);

        // Validator Universe setup
        ValidatorUniverse::initialize(vm);
        //Subsidy module setup and burn account initialization
        Subsidy::initialize(vm);

        // Set that this is testnet
        Testnet::initialize(vm);

        // Event and currency setup
        Event::publish_generator(vm);
        GAS::initialize(vm);

        LibraAccount::initialize(vm);
        Unhosted::publish_global_limits_definition(vm);


        //Create the vm's account
        // TODO: Do we need to do this?
        LibraAccount::create_genesis_account<GAS::T>(
            Signer::address_of(vm),
            copy dummy_auth_key_prefix,
        );

        //Granting minting and burn capability to vm account
        Libra::grant_mint_capability_to_association<GAS::T>(vm);
        Libra::grant_burn_capability_to_association<GAS::T>(vm);

        //TODO: Do we still need preburn.
        Libra::publish_preburn(vm, Libra::new_preburn<GAS::T>());

        // Register transaction fee accounts
        LibraAccount::create_fee_account<GAS::T>(
            vm,
            0xFEE,
            copy dummy_auth_key_prefix
        );

        // TransactionFee::initialize(tc_account, fee_account);
        TransactionFee::initialize(fee_account);

        // Create a burn account and publish preburn
        LibraAccount::create_burn_account<GAS::T>(
            vm,
            0xDEADDEAD, //burn_account_addr,
            copy dummy_auth_key_prefix
        );
        //TODO: Do we still need preburn?
        Libra::publish_preburn(burn_account, Libra::new_preburn<GAS::T>());

        //TODO: What do we need this for?
        // Create the config account
        LibraAccount::create_genesis_account<GAS::T>(
            LibraConfig::default_config_address(),
            copy dummy_auth_key_prefix
        );

        LibraTransactionTimeout::initialize(vm);
        LibraSystem::initialize_validator_set(config_account);
        LibraVersion::initialize(config_account);
        LibraBlock::initialize_block_metadata(vm);
        LibraWriteSetManager::initialize(vm);
        LibraTimestamp::initialize(vm);

        let no_owner_auth_key = x"0100000000000000000000000000000000000000000000000000000000001ee7";

        /////////////////////////////////////////////////////
        //TODO: Why does the vm have an authentication key?
        // if this is removed most tests fail.
        LibraAccount::rotate_authentication_key(vm, copy no_owner_auth_key);
        /////////////////////////////////////////////////////

        // Brick the other accounts after being created.
        LibraAccount::rotate_authentication_key(config_account, copy no_owner_auth_key);
        LibraAccount::rotate_authentication_key(fee_account, copy no_owner_auth_key);
        LibraAccount::rotate_authentication_key(burn_account, copy no_owner_auth_key);

        // Sanity check all the econ constants are what we expect.
        // This will initialize epoch_length and validator count for each epoch
        if (Testnet::is_testnet()) {
          Transaction::assert(Globals::get_epoch_length() == 15, 9992001);
          Transaction::assert(Globals::get_max_validator_per_epoch() == 10, 9992002);
          Transaction::assert(Globals::get_subsidy_ceiling_gas() == 296, 9992003);
          Transaction::assert(Globals::get_max_node_density() == 300, 9992004);
        } else {
          Transaction::assert(Globals::get_epoch_length() == 2736000, 9992001);
          Transaction::assert(Globals::get_max_validator_per_epoch() == 300, 9992002);
          Transaction::assert(Globals::get_subsidy_ceiling_gas() == 547200, 9992003);
          Transaction::assert(Globals::get_max_node_density() == 300, 9992004);
        };


        // Mint subsidy for the initial validator set, not to be confused with the minting for the
        // genesis block.
        Subsidy::mint_subsidy(vm);
    }

}
}
