
<a name="0x1_Genesis"></a>

# Module `0x1::Genesis`

The <code><a href="Genesis.md#0x1_Genesis">Genesis</a></code> module defines the Move initialization entry point of the Diem framework
when executing from a fresh state.

> TODO: Currently there are a few additional functions called from Rust during genesis.
> Document which these are and in which order they are called.


-  [Function `initialize`](#0x1_Genesis_initialize)


<pre><code><b>use</b> <a href="AccountFreezing.md#0x1_AccountFreezing">0x1::AccountFreezing</a>;
<b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="ChainId.md#0x1_ChainId">0x1::ChainId</a>;
<b>use</b> <a href="DualAttestation.md#0x1_DualAttestation">0x1::DualAttestation</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Hash.md#0x1_Hash">0x1::Hash</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemBlock.md#0x1_DiemBlock">0x1::DiemBlock</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption">0x1::DiemTransactionPublishingOption</a>;
<b>use</b> <a href="DiemVMConfig.md#0x1_DiemVMConfig">0x1::DiemVMConfig</a>;
<b>use</b> <a href="DiemVersion.md#0x1_DiemVersion">0x1::DiemVersion</a>;
<b>use</b> <a href="Oracle.md#0x1_Oracle">0x1::Oracle</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
</code></pre>



<a name="0x1_Genesis_initialize"></a>

## Function `initialize`

Initializes the Diem framework.


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize">initialize</a>(lr_account: &signer, lr_auth_key: vector&lt;u8&gt;, initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;, is_open_module: bool, instruction_schedule: vector&lt;u8&gt;, native_schedule: vector&lt;u8&gt;, chain_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Genesis.md#0x1_Genesis_initialize">initialize</a>(
    lr_account: &signer,
    lr_auth_key: vector&lt;u8&gt;,
    initial_script_allow_list: vector&lt;vector&lt;u8&gt;&gt;,
    is_open_module: bool,
    instruction_schedule: vector&lt;u8&gt;,
    native_schedule: vector&lt;u8&gt;,
    chain_id: u8,
) {
    <a href="DiemAccount.md#0x1_DiemAccount_initialize">DiemAccount::initialize</a>(lr_account, x"00000000000000000000000000000000");

    <a href="ChainId.md#0x1_ChainId_initialize">ChainId::initialize</a>(lr_account, chain_id);

    // On-chain config setup
    <a href="DiemConfig.md#0x1_DiemConfig_initialize">DiemConfig::initialize</a>(lr_account);

    // Currency setup
    <a href="Diem.md#0x1_Diem_initialize">Diem::initialize</a>(lr_account);

    // Currency setup
    // <a href="Coin1.md#0x1_Coin1_initialize">Coin1::initialize</a>(lr_account, tc_account);

    <a href="GAS.md#0x1_GAS_initialize">GAS::initialize</a>(
        lr_account,
        // lr_account,
    );
    <a href="AccountFreezing.md#0x1_AccountFreezing_initialize">AccountFreezing::initialize</a>(lr_account);

    <a href="TransactionFee.md#0x1_TransactionFee_initialize">TransactionFee::initialize</a>(lr_account);

    <a href="DiemSystem.md#0x1_DiemSystem_initialize_validator_set">DiemSystem::initialize_validator_set</a>(
        lr_account,
    );
    <a href="DiemVersion.md#0x1_DiemVersion_initialize">DiemVersion::initialize</a>(
        lr_account,
    );
    <a href="DualAttestation.md#0x1_DualAttestation_initialize">DualAttestation::initialize</a>(
        lr_account,
    );
    <a href="DiemBlock.md#0x1_DiemBlock_initialize_block_metadata">DiemBlock::initialize_block_metadata</a>(lr_account);

    // outside of testing, brick the diemroot account.
    <b>if</b> (chain_id == 1 || chain_id == 7) {
        lr_auth_key = <a href="Hash.md#0x1_Hash_sha3_256">Hash::sha3_256</a>(b"Protests rage across the nation");
    };
    <b>let</b> lr_rotate_key_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">DiemAccount::extract_key_rotation_capability</a>(lr_account);
    <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">DiemAccount::rotate_authentication_key</a>(&lr_rotate_key_cap, lr_auth_key);
    <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">DiemAccount::restore_key_rotation_capability</a>(lr_rotate_key_cap);

    <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_initialize">DiemTransactionPublishingOption::initialize</a>(
        lr_account,
        initial_script_allow_list,
        is_open_module,
    );

    <a href="DiemVMConfig.md#0x1_DiemVMConfig_initialize">DiemVMConfig::initialize</a>(
        lr_account,
        instruction_schedule,
        native_schedule,
        chain_id // 0L change
    );

    /////// 0L /////////
    <a href="Stats.md#0x1_Stats_initialize">Stats::initialize</a>(lr_account);
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_initialize">ValidatorUniverse::initialize</a>(lr_account);
    <a href="AutoPay.md#0x1_AutoPay_initialize">AutoPay::initialize</a>(lr_account);
    <a href="Subsidy.md#0x1_Subsidy_init_fullnode_sub">Subsidy::init_fullnode_sub</a>(lr_account);
    <a href="Oracle.md#0x1_Oracle_initialize">Oracle::initialize</a>(lr_account);
    // FullnodeState::global_init(lr_account);
    // After we have called this function, all invariants which are guarded by
    // `<a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; ...` will become active and a verification condition.
    // See also discussion at function specification.
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_set_time_has_started">DiemTimestamp::set_time_has_started</a>(lr_account);
    <a href="Epoch.md#0x1_Epoch_initialize">Epoch::initialize</a>(lr_account);

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


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
