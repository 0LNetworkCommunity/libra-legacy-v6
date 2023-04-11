
<a name="0x1_Genesis"></a>

# Module `0x1::Genesis`

The <code><a href="Genesis.md#0x1_Genesis">Genesis</a></code> module defines the Move initialization entry point of the Diem framework
when executing from a fresh state.

> TODO: Currently there are a few additional functions called from Rust during genesis.
> Document which these are and in which order they are called.


-  [Function `initialize`](#0x1_Genesis_initialize)
-  [Function `initialize_internal`](#0x1_Genesis_initialize_internal)
-  [Function `create_initialize_owners_operators`](#0x1_Genesis_create_initialize_owners_operators)


<pre><code><b>use</b> <a href="AccountFreezing.md#0x1_AccountFreezing">0x1::AccountFreezing</a>;
<b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="ChainId.md#0x1_ChainId">0x1::ChainId</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemBlock.md#0x1_DiemBlock">0x1::DiemBlock</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemConsensusConfig.md#0x1_DiemConsensusConfig">0x1::DiemConsensusConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption">0x1::DiemTransactionPublishingOption</a>;
<b>use</b> <a href="DiemVMConfig.md#0x1_DiemVMConfig">0x1::DiemVMConfig</a>;
<b>use</b> <a href="DiemVersion.md#0x1_DiemVersion">0x1::DiemVersion</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="DualAttestation.md#0x1_DualAttestation">0x1::DualAttestation</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash">0x1::Hash</a>;
<b>use</b> <a href="InfraEscrow.md#0x1_InfraEscrow">0x1::InfraEscrow</a>;
<b>use</b> <a href="Migrations.md#0x1_Migrations">0x1::Migrations</a>;
<b>use</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment">0x1::MultiSigPayment</a>;
<b>use</b> <a href="MusicalChairs.md#0x1_MusicalChairs">0x1::MusicalChairs</a>;
<b>use</b> <a href="Oracle.md#0x1_Oracle">0x1::Oracle</a>;
<b>use</b> <a href="ParallelExecutionConfig.md#0x1_ParallelExecutionConfig">0x1::ParallelExecutionConfig</a>;
<b>use</b> <a href="ProofOfFee.md#0x1_ProofOfFee">0x1::ProofOfFee</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig">0x1::ValidatorOperatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Genesis_initialize"></a>

## Function `initialize`

Initializes the Diem framework.


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize">initialize</a>(dr_account: signer, dr_auth_key: vector&lt;u8&gt;, initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;, is_open_module: bool, instruction_schedule: vector&lt;u8&gt;, native_schedule: vector&lt;u8&gt;, chain_id: u8, initial_diem_version: u64, consensus_config: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize">initialize</a>(
    dr_account: signer,
    // tc_account: signer, //////// 0L ////////
    dr_auth_key: vector&lt;u8&gt;,
    // tc_auth_key: vector&lt;u8&gt;, //////// 0L ////////
    initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;,
    is_open_module: bool,
    instruction_schedule: vector&lt;u8&gt;,
    native_schedule: vector&lt;u8&gt;,
    chain_id: u8,
    initial_diem_version: u64,
    consensus_config: vector&lt;u8&gt;,
) {
    <a href="Genesis.md#0x1_Genesis_initialize_internal">initialize_internal</a>(
        &dr_account,
        // &tc_account, /////// 0L /////////
        dr_auth_key,
        // tc_auth_key, /////// 0L /////////
        initial_script_allow_list,
        is_open_module,
        instruction_schedule,
        native_schedule,
        chain_id,
        initial_diem_version,
        consensus_config,
    )
}
</code></pre>



</details>

<details>
<summary>Specification</summary>

For verification of genesis, the goal is to prove that all the invariants which
become active after the end of this function hold. This cannot be achieved with
modular verification as we do in regular continuous testing. Rather, this module must
be verified **together** with the module(s) which provides the invariant.

> TODO: currently verifying this module together with modules providing invariants
> (see above) times out. This can likely be solved by making more of the initialize
> functions called by this function opaque, and prove the according invariants locally to
> each module.

Assume that this is called in genesis state (no timestamp).


<pre><code><b>requires</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_genesis">DiemTimestamp::is_genesis</a>();
</code></pre>



</details>

<a name="0x1_Genesis_initialize_internal"></a>

## Function `initialize_internal`

Initializes the Diem Framework. Internal so it can be used by both genesis code, and for testing purposes


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize_internal">initialize_internal</a>(dr_account: &signer, dr_auth_key: vector&lt;u8&gt;, initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;, is_open_module: bool, instruction_schedule: vector&lt;u8&gt;, native_schedule: vector&lt;u8&gt;, chain_id: u8, initial_diem_version: u64, consensus_config: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize_internal">initialize_internal</a>(
    dr_account: &signer,
    // tc_account: &signer, /////// 0L /////////
    dr_auth_key: vector&lt;u8&gt;,
    // tc_auth_key: vector&lt;u8&gt;, /////// 0L /////////
    initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;,
    is_open_module: bool,
    instruction_schedule: vector&lt;u8&gt;,
    native_schedule: vector&lt;u8&gt;,
    chain_id: u8,
    initial_diem_version: u64,
    consensus_config: vector&lt;u8&gt;,
) {
    <a href="DiemAccount.md#0x1_DiemAccount_initialize">DiemAccount::initialize</a>(dr_account, x"00000000000000000000000000000000");

    <a href="ChainId.md#0x1_ChainId_initialize">ChainId::initialize</a>(dr_account, chain_id);

    // On-chain config setup
    <a href="DiemConfig.md#0x1_DiemConfig_initialize">DiemConfig::initialize</a>(dr_account);

    // Consensus config setup
    <a href="DiemConsensusConfig.md#0x1_DiemConsensusConfig_initialize">DiemConsensusConfig::initialize</a>(dr_account);

    // Parallel execution config setup
    <a href="ParallelExecutionConfig.md#0x1_ParallelExecutionConfig_initialize_parallel_execution">ParallelExecutionConfig::initialize_parallel_execution</a>(dr_account);

    // Currency setup
    <a href="Diem.md#0x1_Diem_initialize">Diem::initialize</a>(dr_account);

    /////// 0L /////////
    // // Currency setup
    // <a href="XUS.md#0x1_XUS_initialize">XUS::initialize</a>(dr_account, tc_account);
    // <a href="XDX.md#0x1_XDX_initialize">XDX::initialize</a>(dr_account, tc_account);
    <a href="GAS.md#0x1_GAS_initialize">GAS::initialize</a>(dr_account);

    <a href="AccountFreezing.md#0x1_AccountFreezing_initialize">AccountFreezing::initialize</a>(dr_account);
    <a href="TransactionFee.md#0x1_TransactionFee_initialize">TransactionFee::initialize</a>(dr_account); /////// 0L /////////
    <a href="TransactionFee.md#0x1_TransactionFee_initialize_epoch_fee_maker_registry">TransactionFee::initialize_epoch_fee_maker_registry</a>(dr_account); /////// 0L /////////

    <a href="DiemSystem.md#0x1_DiemSystem_initialize_validator_set">DiemSystem::initialize_validator_set</a>(dr_account);
    <a href="DiemVersion.md#0x1_DiemVersion_initialize">DiemVersion::initialize</a>(dr_account, initial_diem_version);
    <a href="DualAttestation.md#0x1_DualAttestation_initialize">DualAttestation::initialize</a>(dr_account);
    <a href="DiemBlock.md#0x1_DiemBlock_initialize_block_metadata">DiemBlock::initialize_block_metadata</a>(dr_account);

    /////// 0L /////////
    // DiemAccount::create_burn_account(dr_account, x"00000000000000000000000000000000");
    // Outside of testing, brick the diemroot account.
    <b>if</b> (chain_id == 1 || chain_id == 7) {
        dr_auth_key = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash_sha3_256">Hash::sha3_256</a>(b"Protests rage across the nation");
    };

    // Rotate auth keys for DiemRoot and TreasuryCompliance accounts <b>to</b> the given
    // values
    <b>let</b> dr_rotate_key_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(dr_account);
    <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&dr_rotate_key_cap, dr_auth_key);
    <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(dr_rotate_key_cap);

    /////// 0L /////////
    // <b>let</b> tc_rotate_key_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(tc_account);
    // <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&tc_rotate_key_cap, tc_auth_key);
    // <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(tc_rotate_key_cap);

    <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_initialize">DiemTransactionPublishingOption::initialize</a>(
        dr_account,
        initial_script_allow_list,
        is_open_module,
    );

    <a href="DiemVMConfig.md#0x1_DiemVMConfig_initialize">DiemVMConfig::initialize</a>(
        dr_account,
        instruction_schedule,
        native_schedule,
        chain_id /////// 0L /////////
    );

    <a href="DiemConsensusConfig.md#0x1_DiemConsensusConfig_set">DiemConsensusConfig::set</a>(dr_account, consensus_config);

    /////// 0L /////////
    // <b>let</b> tc_rotate_key_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(tc_account);
    // <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&tc_rotate_key_cap, tc_auth_key);
    // <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(tc_rotate_key_cap);
    <a href="Stats.md#0x1_Stats_initialize">Stats::initialize</a>(dr_account);
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_initialize">ValidatorUniverse::initialize</a>(dr_account);
    <a href="AutoPay.md#0x1_AutoPay_initialize">AutoPay::initialize</a>(dr_account);
    // FullnodeSubsidy::init_fullnode_sub(dr_account);
    <a href="Oracle.md#0x1_Oracle_initialize">Oracle::initialize</a>(dr_account);
    <a href="TowerState.md#0x1_TowerState_init_miner_list_and_stats">TowerState::init_miner_list_and_stats</a>(dr_account);
    <a href="TowerState.md#0x1_TowerState_init_difficulty">TowerState::init_difficulty</a>(dr_account);
    <a href="DonorDirected.md#0x1_DonorDirected_init_root_registry">DonorDirected::init_root_registry</a>(dr_account);
    <a href="DiemAccount.md#0x1_DiemAccount_vm_init_slow">DiemAccount::vm_init_slow</a>(dr_account);
    <a href="Migrations.md#0x1_Migrations_init">Migrations::init</a>(dr_account);
    <a href="MusicalChairs.md#0x1_MusicalChairs_initialize">MusicalChairs::initialize</a>(dr_account);
    <a href="InfraEscrow.md#0x1_InfraEscrow_initialize_infra_pledge">InfraEscrow::initialize_infra_pledge</a>(dr_account);

    // After we have called this function, all invariants which are guarded by
    // `<a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; ...` will become active and a verification condition.
    // See also discussion at function specification.
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_set_time_has_started">DiemTimestamp::set_time_has_started</a>(dr_account);
    <a href="Epoch.md#0x1_Epoch_initialize">Epoch::initialize</a>(dr_account); /////// 0L /////////

    // Initialize Root Security metered services
    <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_init">MultiSigPayment::root_init</a>(dr_account); //////// 0L ////////

    <a href="ProofOfFee.md#0x1_ProofOfFee_init_genesis_baseline_reward">ProofOfFee::init_genesis_baseline_reward</a>(dr_account);
    // <b>if</b> this is tesnet, fund the root account so the smoketests can run. They <b>use</b> <a href="PaymentScripts.md#0x1_PaymentScripts">PaymentScripts</a> functions <b>to</b> test many things.
    // TODO(0L): make this only tun in testsnet. Though we need <b>to</b> make smoketest always initialize in test mode.
    // <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
      <b>let</b> val = 10000000;
      <a href="DiemAccount.md#0x1_DiemAccount_add_currency">DiemAccount::add_currency</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;(dr_account);
      <b>let</b> coin = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;(dr_account, val);
      <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>(
        dr_account,
        @DiemRoot,
        @DiemRoot,
        coin,
        x"",
        x"",
      )

    // }
}
</code></pre>



</details>

<a name="0x1_Genesis_create_initialize_owners_operators"></a>

## Function `create_initialize_owners_operators`

Sets up the initial validator set for the Diem network.
The validator "owner" accounts, their UTF-8 names, and their authentication
keys are encoded in the <code>owners</code>, <code>owner_names</code>, and <code>owner_auth_key</code> vectors.
Each validator signs consensus messages with the private key corresponding to the Ed25519
public key in <code>consensus_pubkeys</code>.
Each validator owner has its operation delegated to an "operator" (which may be
the owner). The operators, their names, and their authentication keys are encoded
in the <code>operators</code>, <code>operator_names</code>, and <code>operator_auth_keys</code> vectors.
Finally, each validator must specify the network address
(see diem/types/src/network_address/mod.rs) for itself and its full nodes.


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_create_initialize_owners_operators">create_initialize_owners_operators</a>(dr_account: signer, owners: vector&lt;signer&gt;, owner_names: vector&lt;vector&lt;u8&gt;&gt;, owner_auth_keys: vector&lt;vector&lt;u8&gt;&gt;, consensus_pubkeys: vector&lt;vector&lt;u8&gt;&gt;, operators: vector&lt;signer&gt;, operator_names: vector&lt;vector&lt;u8&gt;&gt;, operator_auth_keys: vector&lt;vector&lt;u8&gt;&gt;, validator_network_addresses: vector&lt;vector&lt;u8&gt;&gt;, full_node_network_addresses: vector&lt;vector&lt;u8&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_create_initialize_owners_operators">create_initialize_owners_operators</a>(
    dr_account: signer,
    owners: vector&lt;signer&gt;,
    owner_names: vector&lt;vector&lt;u8&gt;&gt;,
    owner_auth_keys: vector&lt;vector&lt;u8&gt;&gt;,
    consensus_pubkeys: vector&lt;vector&lt;u8&gt;&gt;,
    operators: vector&lt;signer&gt;,
    operator_names: vector&lt;vector&lt;u8&gt;&gt;,
    operator_auth_keys: vector&lt;vector&lt;u8&gt;&gt;,
    validator_network_addresses: vector&lt;vector&lt;u8&gt;&gt;,
    full_node_network_addresses: vector&lt;vector&lt;u8&gt;&gt;,
) {
    <b>let</b> num_owners = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&owners);
    <b>let</b> num_owner_names = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&owner_names);
    <b>assert</b>!(num_owners == num_owner_names, 0);
    <b>let</b> num_owner_keys = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&owner_auth_keys);
    <b>assert</b>!(num_owner_names == num_owner_keys, 0);
    <b>let</b> num_operators = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&operators);
    <b>assert</b>!(num_owner_keys == num_operators, 0);
    <b>let</b> num_operator_names = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&operator_names);
    <b>assert</b>!(num_operators == num_operator_names, 0);
    <b>let</b> num_operator_keys = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&operator_auth_keys);
    <b>assert</b>!(num_operator_names == num_operator_keys, 0);
    <b>let</b> num_validator_network_addresses = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&validator_network_addresses);
    <b>assert</b>!(num_operator_keys == num_validator_network_addresses, 0);
    <b>let</b> num_full_node_network_addresses = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&full_node_network_addresses);
    <b>assert</b>!(num_validator_network_addresses == num_full_node_network_addresses, 0);

    <b>let</b> i = 0;
    <b>let</b> dummy_auth_key_prefix = x"00000000000000000000000000000000";
    <b>while</b> (i &lt; num_owners) {
        <b>let</b> owner = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&owners, i);
        <b>let</b> owner_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(owner);
        <b>let</b> owner_name = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&owner_names, i);
        // create each validator account and rotate its auth key <b>to</b> the correct value
        <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account">DiemAccount::create_validator_account</a>(
            &dr_account, owner_address, <b>copy</b> dummy_auth_key_prefix, owner_name
        );

        <b>let</b> owner_auth_key = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&owner_auth_keys, i);
        <b>let</b> rotation_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(owner);
        <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&rotation_cap, owner_auth_key);
        <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(rotation_cap);

        <b>let</b> operator = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&operators, i);
        <b>let</b> operator_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(operator);
        <b>let</b> operator_name = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&operator_names, i);
        // create the operator account + rotate its auth key <b>if</b> it does not already exist
        <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_exists_at">DiemAccount::exists_at</a>(operator_address)) {
            <a href="DiemAccount.md#0x1_DiemAccount_create_validator_operator_account">DiemAccount::create_validator_operator_account</a>(
                &dr_account, operator_address, <b>copy</b> dummy_auth_key_prefix, <b>copy</b> operator_name
            );
            <b>let</b> operator_auth_key = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&operator_auth_keys, i);
            <b>let</b> rotation_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(operator);
            <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&rotation_cap, operator_auth_key);
            <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(rotation_cap);
        };
        // assign the operator <b>to</b> its validator
        <b>assert</b>!(<a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_get_human_name">ValidatorOperatorConfig::get_human_name</a>(operator_address) == operator_name, 0);
        <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_operator">ValidatorConfig::set_operator</a>(owner, operator_address);

        // <b>use</b> the operator account set up the validator config
        <b>let</b> validator_network_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&validator_network_addresses, i);
        <b>let</b> full_node_network_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&full_node_network_addresses, i);
        <b>let</b> consensus_pubkey = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&consensus_pubkeys, i);
        <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_config">ValidatorConfig::set_config</a>(
            operator,
            owner_address,
            consensus_pubkey,
            validator_network_address,
            full_node_network_address
        );

        // finally, add this validator <b>to</b> the validator set
        <a href="DiemSystem.md#0x1_DiemSystem_add_validator">DiemSystem::add_validator</a>(&dr_account, owner_address);

        i = i + 1;
    }
}
</code></pre>



</details>
