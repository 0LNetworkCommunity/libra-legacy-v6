address 0x1 {

/// The `Genesis` module defines the Move initialization entry point of the Diem framework
/// when executing from a fresh state.
///
/// > TODO: Currently there are a few additional functions called from Rust during genesis.
/// > Document which these are and in which order they are called.
module Genesis {
    use 0x1::AccountFreezing;
    use 0x1::ChainId;
    use 0x1::DualAttestation;
    use 0x1::Diem;
    use 0x1::DiemAccount;
    use 0x1::DiemBlock;
    use 0x1::DiemConfig;
    use 0x1::DiemSystem;
    use 0x1::DiemTimestamp;
    use 0x1::DiemTransactionPublishingOption;
    use 0x1::DiemVersion;
    use 0x1::TransactionFee;
    use 0x1::DiemVMConfig;
    use 0x1::Stats;
    use 0x1::ValidatorUniverse;
    use 0x1::GAS;
    use 0x1::AutoPay;
    use 0x1::Oracle;
    use 0x1::Hash;
    // use 0x1::FullnodeSubsidy;
    use 0x1::Epoch;
    use 0x1::TowerState;
    use 0x1::Wallet;
    use 0x1::Migrations;

    /// Initializes the Diem framework.
    fun initialize(
        dm_account: signer,
        // tc_account: signer, /////// 0L /////////
        dm_auth_key: vector<u8>,
        // tc_auth_key: vector<u8>, /////// 0L /////////
        initial_script_allow_list: vector<vector<u8>>,
        is_open_module: bool,
        instruction_schedule: vector<u8>,
        native_schedule: vector<u8>,
        chain_id: u8,
    ) {
        let dm_account = &dm_account;
        // let tc_account = &tc_account; /////// 0L /////////

        DiemAccount::initialize(dm_account, x"00000000000000000000000000000000");

        ChainId::initialize(dm_account, chain_id);

        // On-chain config setup
        DiemConfig::initialize(dm_account);

        // Currency setup
        Diem::initialize(dm_account);

        // Currency setup
        // XUS::initialize(dm_account, tc_account); /////// 0L /////////

        /////// 0L /////////
        GAS::initialize(
            dm_account,
            // tc_account, /////// 0L /////////
        );

        AccountFreezing::initialize(dm_account);

        TransactionFee::initialize(dm_account); /////// 0L /////////

        DiemSystem::initialize_validator_set(
            dm_account,
        );
        DiemVersion::initialize(
            dm_account,
        );
        DualAttestation::initialize(
            dm_account,
        );
        DiemBlock::initialize_block_metadata(dm_account);

        /////// 0L /////////
        // DiemAccount::create_burn_account(dm_account, x"00000000000000000000000000000000");
        // Outside of testing, brick the diemroot account.
        if (chain_id == 1 || chain_id == 7) {
            dm_auth_key = Hash::sha3_256(b"Protests rage across the nation");
        };

        let dm_rotate_key_cap = DiemAccount::extract_key_rotation_capability(dm_account);
        DiemAccount::rotate_authentication_key(&dm_rotate_key_cap, dm_auth_key);
        DiemAccount::restore_key_rotation_capability(dm_rotate_key_cap);

        DiemTransactionPublishingOption::initialize(
            dm_account,
            initial_script_allow_list,
            is_open_module,
        );

        DiemVMConfig::initialize(
            dm_account,
            instruction_schedule,
            native_schedule,
            chain_id /////// 0L /////////
        );

        /////// 0L /////////
        // let tc_rotate_key_cap = DiemAccount::extract_key_rotation_capability(tc_account);
        // DiemAccount::rotate_authentication_key(&tc_rotate_key_cap, tc_auth_key);
        // DiemAccount::restore_key_rotation_capability(tc_rotate_key_cap);
        Stats::initialize(dm_account);
        ValidatorUniverse::initialize(dm_account);
        AutoPay::initialize(dm_account);
        // FullnodeSubsidy::init_fullnode_sub(dm_account);
        Oracle::initialize(dm_account);
        TowerState::init_miner_list_and_stats(dm_account);
        TowerState::init_difficulty(dm_account);
        Wallet::init(dm_account);
        DiemAccount::vm_init_slow(dm_account);
        Migrations::init(dm_account);

        // After we have called this function, all invariants which are guarded by
        // `DiemTimestamp::is_operating() ==> ...` will become active and a verification condition.
        // See also discussion at function specification.
        DiemTimestamp::set_time_has_started(dm_account);
        Epoch::initialize(dm_account); /////// 0L /////////
    }

    /// For verification of genesis, the goal is to prove that all the invariants which
    /// become active after the end of this function hold. This cannot be achieved with
    /// modular verification as we do in regular continuous testing. Rather, this module must
    /// be verified **together** with the module(s) which provides the invariant.
    ///
    /// > TODO: currently verifying this module together with modules providing invariants
    /// > (see above) times out. This can likely be solved by making more of the initialize
    /// > functions called by this function opaque, and prove the according invariants locally to
    /// > each module.
    spec initialize {
        /// Assume that this is called in genesis state (no timestamp).
        requires DiemTimestamp::is_genesis();
    }

}
}
