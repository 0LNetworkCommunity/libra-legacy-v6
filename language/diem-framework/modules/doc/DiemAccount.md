
<a name="0x1_DiemAccount"></a>

# Module `0x1::DiemAccount`

The <code><a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a></code> module manages accounts. It defines the <code><a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a></code> resource and
numerous auxiliary data structures. It also defines the prolog and epilog that run
before and after every transaction.


-  [Resource `DiemAccount`](#0x1_DiemAccount_DiemAccount)
-  [Resource `Balance`](#0x1_DiemAccount_Balance)
-  [Struct `WithdrawCapability`](#0x1_DiemAccount_WithdrawCapability)
-  [Struct `KeyRotationCapability`](#0x1_DiemAccount_KeyRotationCapability)
-  [Resource `AccountOperationsCapability`](#0x1_DiemAccount_AccountOperationsCapability)
-  [Resource `DiemWriteSetManager`](#0x1_DiemAccount_DiemWriteSetManager)
-  [Struct `SentPaymentEvent`](#0x1_DiemAccount_SentPaymentEvent)
-  [Struct `ReceivedPaymentEvent`](#0x1_DiemAccount_ReceivedPaymentEvent)
-  [Struct `AdminTransactionEvent`](#0x1_DiemAccount_AdminTransactionEvent)
-  [Struct `CreateAccountEvent`](#0x1_DiemAccount_CreateAccountEvent)
-  [Struct `Escrow`](#0x1_DiemAccount_Escrow)
-  [Resource `AutopayEscrow`](#0x1_DiemAccount_AutopayEscrow)
-  [Resource `EscrowList`](#0x1_DiemAccount_EscrowList)
-  [Struct `EscrowSettings`](#0x1_DiemAccount_EscrowSettings)
-  [Resource `CumulativeDeposits`](#0x1_DiemAccount_CumulativeDeposits)
-  [Resource `SlowWallet`](#0x1_DiemAccount_SlowWallet)
-  [Resource `SlowWalletList`](#0x1_DiemAccount_SlowWalletList)
-  [Constants](#@Constants_0)
-  [Function `scary_create_signer_for_migrations`](#0x1_DiemAccount_scary_create_signer_for_migrations)
-  [Function `new_escrow`](#0x1_DiemAccount_new_escrow)
-  [Function `process_escrow`](#0x1_DiemAccount_process_escrow)
-  [Function `initialize_escrow`](#0x1_DiemAccount_initialize_escrow)
-  [Function `initialize_escrow_root`](#0x1_DiemAccount_initialize_escrow_root)
-  [Function `initialize`](#0x1_DiemAccount_initialize)
-  [Function `create_user_account_with_proof`](#0x1_DiemAccount_create_user_account_with_proof)
-  [Function `create_user_account_with_coin`](#0x1_DiemAccount_create_user_account_with_coin)
-  [Function `create_validator_account_with_proof`](#0x1_DiemAccount_create_validator_account_with_proof)
-  [Function `upgrade_validator_account_with_proof`](#0x1_DiemAccount_upgrade_validator_account_with_proof)
-  [Function `has_published_account_limits`](#0x1_DiemAccount_has_published_account_limits)
-  [Function `should_track_limits_for_account`](#0x1_DiemAccount_should_track_limits_for_account)
-  [Function `deposit`](#0x1_DiemAccount_deposit)
-  [Function `tiered_mint`](#0x1_DiemAccount_tiered_mint)
-  [Function `cancel_burn`](#0x1_DiemAccount_cancel_burn)
-  [Function `withdraw_from_balance`](#0x1_DiemAccount_withdraw_from_balance)
-  [Function `withdraw_from`](#0x1_DiemAccount_withdraw_from)
    -  [Access Control](#@Access_Control_1)
-  [Function `preburn`](#0x1_DiemAccount_preburn)
-  [Function `extract_withdraw_capability`](#0x1_DiemAccount_extract_withdraw_capability)
-  [Function `restore_withdraw_capability`](#0x1_DiemAccount_restore_withdraw_capability)
-  [Function `process_community_wallets`](#0x1_DiemAccount_process_community_wallets)
-  [Function `vm_make_payment_no_limit`](#0x1_DiemAccount_vm_make_payment_no_limit)
-  [Function `vm_burn_from_balance`](#0x1_DiemAccount_vm_burn_from_balance)
-  [Function `pay_from`](#0x1_DiemAccount_pay_from)
-  [Function `onboarding_gas_transfer`](#0x1_DiemAccount_onboarding_gas_transfer)
-  [Function `genesis_fund_operator`](#0x1_DiemAccount_genesis_fund_operator)
-  [Function `rotate_authentication_key`](#0x1_DiemAccount_rotate_authentication_key)
    -  [Access Control](#@Access_Control_2)
-  [Function `extract_key_rotation_capability`](#0x1_DiemAccount_extract_key_rotation_capability)
-  [Function `restore_key_rotation_capability`](#0x1_DiemAccount_restore_key_rotation_capability)
-  [Function `add_currencies_for_account`](#0x1_DiemAccount_add_currencies_for_account)
-  [Function `make_account`](#0x1_DiemAccount_make_account)
-  [Function `create_authentication_key`](#0x1_DiemAccount_create_authentication_key)
-  [Function `create_diem_root_account`](#0x1_DiemAccount_create_diem_root_account)
-  [Function `create_treasury_compliance_account`](#0x1_DiemAccount_create_treasury_compliance_account)
-  [Function `create_designated_dealer`](#0x1_DiemAccount_create_designated_dealer)
-  [Function `create_parent_vasp_account`](#0x1_DiemAccount_create_parent_vasp_account)
-  [Function `create_child_vasp_account`](#0x1_DiemAccount_create_child_vasp_account)
-  [Function `create_signer`](#0x1_DiemAccount_create_signer)
-  [Function `balance_for`](#0x1_DiemAccount_balance_for)
-  [Function `balance`](#0x1_DiemAccount_balance)
-  [Function `add_currency`](#0x1_DiemAccount_add_currency)
    -  [Access Control](#@Access_Control_3)
-  [Function `accepts_currency`](#0x1_DiemAccount_accepts_currency)
-  [Function `sequence_number_for_account`](#0x1_DiemAccount_sequence_number_for_account)
-  [Function `sequence_number`](#0x1_DiemAccount_sequence_number)
-  [Function `authentication_key`](#0x1_DiemAccount_authentication_key)
-  [Function `delegated_key_rotation_capability`](#0x1_DiemAccount_delegated_key_rotation_capability)
-  [Function `delegated_withdraw_capability`](#0x1_DiemAccount_delegated_withdraw_capability)
-  [Function `withdraw_capability_address`](#0x1_DiemAccount_withdraw_capability_address)
-  [Function `key_rotation_capability_address`](#0x1_DiemAccount_key_rotation_capability_address)
-  [Function `exists_at`](#0x1_DiemAccount_exists_at)
-  [Function `module_prologue`](#0x1_DiemAccount_module_prologue)
-  [Function `script_prologue`](#0x1_DiemAccount_script_prologue)
-  [Function `writeset_prologue`](#0x1_DiemAccount_writeset_prologue)
-  [Function `multi_agent_script_prologue`](#0x1_DiemAccount_multi_agent_script_prologue)
-  [Function `prologue_common`](#0x1_DiemAccount_prologue_common)
-  [Function `epilogue`](#0x1_DiemAccount_epilogue)
-  [Function `epilogue_common`](#0x1_DiemAccount_epilogue_common)
-  [Function `writeset_epilogue`](#0x1_DiemAccount_writeset_epilogue)
-  [Function `create_validator_account`](#0x1_DiemAccount_create_validator_account)
-  [Function `create_validator_operator_account`](#0x1_DiemAccount_create_validator_operator_account)
-  [Function `vm_deposit_with_metadata`](#0x1_DiemAccount_vm_deposit_with_metadata)
-  [Function `vm_migrate_slow_wallet`](#0x1_DiemAccount_vm_migrate_slow_wallet)
-  [Function `init_cumulative_deposits`](#0x1_DiemAccount_init_cumulative_deposits)
-  [Function `maybe_update_deposit`](#0x1_DiemAccount_maybe_update_deposit)
-  [Function `deposit_index_curve`](#0x1_DiemAccount_deposit_index_curve)
-  [Function `get_cumulative_deposits`](#0x1_DiemAccount_get_cumulative_deposits)
-  [Function `get_index_cumu_deposits`](#0x1_DiemAccount_get_index_cumu_deposits)
-  [Function `is_init`](#0x1_DiemAccount_is_init)
-  [Function `migrate_cumu_deposits`](#0x1_DiemAccount_migrate_cumu_deposits)
-  [Function `vm_init_slow`](#0x1_DiemAccount_vm_init_slow)
-  [Function `set_slow`](#0x1_DiemAccount_set_slow)
-  [Function `slow_wallet_epoch_drip`](#0x1_DiemAccount_slow_wallet_epoch_drip)
-  [Function `decrease_unlocked_tracker`](#0x1_DiemAccount_decrease_unlocked_tracker)
-  [Function `increase_unlocked_tracker`](#0x1_DiemAccount_increase_unlocked_tracker)
-  [Function `is_slow`](#0x1_DiemAccount_is_slow)
-  [Function `unlocked_amount`](#0x1_DiemAccount_unlocked_amount)
-  [Function `get_slow_list`](#0x1_DiemAccount_get_slow_list)
-  [Function `test_helper_create_signer`](#0x1_DiemAccount_test_helper_create_signer)
-  [Function `test_remove_slow`](#0x1_DiemAccount_test_remove_slow)
-  [Module Specification](#@Module_Specification_4)
    -  [Access Control](#@Access_Control_5)
        -  [Key Rotation Capability](#@Key_Rotation_Capability_6)
        -  [Withdraw Capability](#@Withdraw_Capability_7)
        -  [Authentication Key](#@Authentication_Key_8)
        -  [Balance](#@Balance_9)
    -  [Persistence of Resources](#@Persistence_of_Resources_10)
    -  [Other invariants](#@Other_invariants_11)
    -  [Helper Functions and Schemas](#@Helper_Functions_and_Schemas_12)
        -  [Capabilities](#@Capabilities_13)
        -  [Prologue](#@Prologue_14)


<pre><code><b>use</b> <a href="AccountFreezing.md#0x1_AccountFreezing">0x1::AccountFreezing</a>;
<b>use</b> <a href="AccountLimits.md#0x1_AccountLimits">0x1::AccountLimits</a>;
<b>use</b> <a href="Ancestry.md#0x1_Ancestry">0x1::Ancestry</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/BCS.md#0x1_BCS">0x1::BCS</a>;
<b>use</b> <a href="ChainId.md#0x1_ChainId">0x1::ChainId</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DesignatedDealer.md#0x1_DesignatedDealer">0x1::DesignatedDealer</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemId.md#0x1_DiemId">0x1::DiemId</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption">0x1::DiemTransactionPublishingOption</a>;
<b>use</b> <a href="DualAttestation.md#0x1_DualAttestation">0x1::DualAttestation</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event">0x1::Event</a>;
<b>use</b> <a href="FIFO.md#0x1_FIFO">0x1::FIFO</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Hash.md#0x1_Hash">0x1::Hash</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="Receipts.md#0x1_Receipts">0x1::Receipts</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="SlidingNonce.md#0x1_SlidingNonce">0x1::SlidingNonce</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="VASP.md#0x1_VASP">0x1::VASP</a>;
<b>use</b> <a href="VDF.md#0x1_VDF">0x1::VDF</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig">0x1::ValidatorOperatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
<b>use</b> <a href="Wallet.md#0x1_Wallet">0x1::Wallet</a>;
<b>use</b> <a href="XUS.md#0x1_XUS">0x1::XUS</a>;
</code></pre>



<a name="0x1_DiemAccount_DiemAccount"></a>

## Resource `DiemAccount`

An <code>address</code> is a Diem Account iff it has a published DiemAccount resource.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>authentication_key: vector&lt;u8&gt;</code>
</dt>
<dd>
 The current authentication key.
 This can be different from the key used to create the account
</dd>
<dt>
<code>withdraw_capability: <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;</code>
</dt>
<dd>
 A <code>withdraw_capability</code> allows whoever holds this capability
 to withdraw from the account. At the time of account creation
 this capability is stored in this option. It can later be removed
 by <code>extract_withdraw_capability</code> and also restored via <code>restore_withdraw_capability</code>.
</dd>
<dt>
<code>key_rotation_capability: <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">DiemAccount::KeyRotationCapability</a>&gt;</code>
</dt>
<dd>
 A <code>key_rotation_capability</code> allows whoever holds this capability
 the ability to rotate the authentication key for the account. At
 the time of account creation this capability is stored in this
 option. It can later be "extracted" from this field via
 <code>extract_key_rotation_capability</code>, and can also be restored via
 <code>restore_key_rotation_capability</code>.
</dd>
<dt>
<code>received_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">DiemAccount::ReceivedPaymentEvent</a>&gt;</code>
</dt>
<dd>
 Event handle to which ReceivePaymentEvents are emitted when
 payments are received.
</dd>
<dt>
<code>sent_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">DiemAccount::SentPaymentEvent</a>&gt;</code>
</dt>
<dd>
 Event handle to which SentPaymentEvents are emitted when
 payments are sent.
</dd>
<dt>
<code>sequence_number: u64</code>
</dt>
<dd>
 The current sequence number of the account.
 Incremented by one each time a transaction is submitted by
 this account.
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_Balance"></a>

## Resource `Balance`

A resource that holds the total value of currency of type <code>Token</code>
currently held by the account.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt; has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;</code>
</dt>
<dd>
 Stores the value of the balance in its balance field. A coin has
 a <code>value</code> field. The amount of money in the balance is changed
 by modifying this field.
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_WithdrawCapability"></a>

## Struct `WithdrawCapability`

The holder of WithdrawCapability for account_address can withdraw Diem from
account_address/DiemAccount/balance.
There is at most one WithdrawCapability in existence for a given address.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a> has store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>account_address: address</code>
</dt>
<dd>
 Address that WithdrawCapability was associated with when it was created.
 This field does not change.
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_KeyRotationCapability"></a>

## Struct `KeyRotationCapability`

The holder of KeyRotationCapability for account_address can rotate the authentication key for
account_address (i.e., write to account_address/DiemAccount/authentication_key).
There is at most one KeyRotationCapability in existence for a given address.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a> has store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>account_address: address</code>
</dt>
<dd>
 Address that KeyRotationCapability was associated with when it was created.
 This field does not change.
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_AccountOperationsCapability"></a>

## Resource `AccountOperationsCapability`

A wrapper around an <code>AccountLimitMutationCapability</code> which is used to check for account limits
and to record freeze/unfreeze events.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>limits_cap: <a href="AccountLimits.md#0x1_AccountLimits_AccountLimitMutationCapability">AccountLimits::AccountLimitMutationCapability</a></code>
</dt>
<dd>

</dd>
<dt>
<code>creation_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">DiemAccount::CreateAccountEvent</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_DiemWriteSetManager"></a>

## Resource `DiemWriteSetManager`

A resource that holds the event handle for all the past WriteSet transactions that have been committed on chain.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>upgrade_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">DiemAccount::AdminTransactionEvent</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_SentPaymentEvent"></a>

## Struct `SentPaymentEvent`

Message for sent events


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a> has drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>amount: u64</code>
</dt>
<dd>
 The amount of Diem<Token> sent
</dd>
<dt>
<code>currency_code: vector&lt;u8&gt;</code>
</dt>
<dd>
 The code symbol for the currency that was sent
</dd>
<dt>
<code>payee: address</code>
</dt>
<dd>
 The address that was paid
</dd>
<dt>
<code>metadata: vector&lt;u8&gt;</code>
</dt>
<dd>
 Metadata associated with the payment
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_ReceivedPaymentEvent"></a>

## Struct `ReceivedPaymentEvent`

Message for received events


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a> has drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>amount: u64</code>
</dt>
<dd>
 The amount of Diem<Token> received
</dd>
<dt>
<code>currency_code: vector&lt;u8&gt;</code>
</dt>
<dd>
 The code symbol for the currency that was received
</dd>
<dt>
<code>payer: address</code>
</dt>
<dd>
 The address that sent the coin
</dd>
<dt>
<code>metadata: vector&lt;u8&gt;</code>
</dt>
<dd>
 Metadata associated with the payment
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_AdminTransactionEvent"></a>

## Struct `AdminTransactionEvent`

Message for committed WriteSet transaction.


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">AdminTransactionEvent</a> has drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>committed_timestamp_secs: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_CreateAccountEvent"></a>

## Struct `CreateAccountEvent`

Message for creation of a new account


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">CreateAccountEvent</a> has drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>created: address</code>
</dt>
<dd>
 Address of the created account
</dd>
<dt>
<code>role_id: u64</code>
</dt>
<dd>
 Role of the created account
</dd>
</dl>


</details>

<a name="0x1_DiemAccount_Escrow"></a>

## Struct `Escrow`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt; has store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>to_account: address</code>
</dt>
<dd>

</dd>
<dt>
<code>escrow: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_AutopayEscrow"></a>

## Resource `AutopayEscrow`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>&lt;Token&gt; has store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">DiemAccount::Escrow</a>&lt;Token&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_EscrowList"></a>

## Resource `EscrowList`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>&lt;Token&gt; has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>accounts: vector&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">DiemAccount::EscrowSettings</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_EscrowSettings"></a>

## Struct `EscrowSettings`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a> has store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>account: address</code>
</dt>
<dd>

</dd>
<dt>
<code>share: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_CumulativeDeposits"></a>

## Resource `CumulativeDeposits`

Separate struct to track cumulative deposits


<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: u64</code>
</dt>
<dd>
 Store the cumulative deposits made to this account.
 not all accounts will have this enabled.
</dd>
<dt>
<code>index: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_SlowWallet"></a>

## Resource `SlowWallet`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>unlocked: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>transferred: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DiemAccount_SlowWalletList"></a>

## Resource `SlowWalletList`



<pre><code><b>struct</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_DiemAccount_MAX_U64"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a>: u128 = 18446744073709551615;
</code></pre>



<a name="0x1_DiemAccount_BOOTSTRAP_COIN_VALUE"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>: u64 = 1000000;
</code></pre>



<a name="0x1_DiemAccount_EACCOUNT"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a></code> resource is not in the required state


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>: u64 = 12010;
</code></pre>



<a name="0x1_DiemAccount_EACCOUNT_OPERATIONS_CAPABILITY"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a></code> was not in the required state


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT_OPERATIONS_CAPABILITY">EACCOUNT_OPERATIONS_CAPABILITY</a>: u64 = 120122;
</code></pre>



<a name="0x1_DiemAccount_EADD_EXISTING_CURRENCY"></a>

Tried to add a balance in a currency that this account already has


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EADD_EXISTING_CURRENCY">EADD_EXISTING_CURRENCY</a>: u64 = 120115;
</code></pre>



<a name="0x1_DiemAccount_EBELOW_MINIMUM_VALUE_BOOTSTRAP_COIN"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EBELOW_MINIMUM_VALUE_BOOTSTRAP_COIN">EBELOW_MINIMUM_VALUE_BOOTSTRAP_COIN</a>: u64 = 120125;
</code></pre>



<a name="0x1_DiemAccount_ECANNOT_CREATE_AT_CORE_CODE"></a>

An account cannot be created at the reserved core code address of 0x1


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_ECANNOT_CREATE_AT_CORE_CODE">ECANNOT_CREATE_AT_CORE_CODE</a>: u64 = 120124;
</code></pre>



<a name="0x1_DiemAccount_ECANNOT_CREATE_AT_VM_RESERVED"></a>

An account cannot be created at the reserved VM address of 0x0


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_ECANNOT_CREATE_AT_VM_RESERVED">ECANNOT_CREATE_AT_VM_RESERVED</a>: u64 = 120110;
</code></pre>



<a name="0x1_DiemAccount_ECOIN_DEPOSIT_IS_ZERO"></a>

Tried to deposit a coin whose value was zero


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_ECOIN_DEPOSIT_IS_ZERO">ECOIN_DEPOSIT_IS_ZERO</a>: u64 = 12012;
</code></pre>



<a name="0x1_DiemAccount_EDEPOSIT_EXCEEDS_LIMITS"></a>

Tried to deposit funds that would have surpassed the account's limits


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EDEPOSIT_EXCEEDS_LIMITS">EDEPOSIT_EXCEEDS_LIMITS</a>: u64 = 12013;
</code></pre>



<a name="0x1_DiemAccount_EGAS"></a>

An invalid amount of gas units was provided for execution of the transaction


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EGAS">EGAS</a>: u64 = 120120;
</code></pre>



<a name="0x1_DiemAccount_EINSUFFICIENT_BALANCE"></a>

The account does not hold a large enough balance in the specified currency


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>: u64 = 12015;
</code></pre>



<a name="0x1_DiemAccount_EKEY_ROTATION_CAPABILITY_ALREADY_EXTRACTED"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a></code> for this account has already been extracted


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EKEY_ROTATION_CAPABILITY_ALREADY_EXTRACTED">EKEY_ROTATION_CAPABILITY_ALREADY_EXTRACTED</a>: u64 = 12019;
</code></pre>



<a name="0x1_DiemAccount_EMALFORMED_AUTHENTICATION_KEY"></a>

The provided authentication had an invalid length


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EMALFORMED_AUTHENTICATION_KEY">EMALFORMED_AUTHENTICATION_KEY</a>: u64 = 12018;
</code></pre>



<a name="0x1_DiemAccount_EPAYEE_CANT_ACCEPT_CURRENCY_TYPE"></a>

Attempted to send funds in a currency that the receiving account does not hold.
e.g., <code><a href="Diem.md#0x1_Diem">Diem</a>&lt;<a href="XDX.md#0x1_XDX">XDX</a>&gt;</code> to an account that exists, but does not have a <code><a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="XDX.md#0x1_XDX">XDX</a>&gt;</code> resource


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EPAYEE_CANT_ACCEPT_CURRENCY_TYPE">EPAYEE_CANT_ACCEPT_CURRENCY_TYPE</a>: u64 = 120118;
</code></pre>



<a name="0x1_DiemAccount_EPAYEE_DOES_NOT_EXIST"></a>

Attempted to send funds to an account that does not exist


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EPAYEE_DOES_NOT_EXIST">EPAYEE_DOES_NOT_EXIST</a>: u64 = 120117;
</code></pre>



<a name="0x1_DiemAccount_EPAYER_DOESNT_HOLD_CURRENCY"></a>

Tried to withdraw funds in a currency that the account does hold


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EPAYER_DOESNT_HOLD_CURRENCY">EPAYER_DOESNT_HOLD_CURRENCY</a>: u64 = 120119;
</code></pre>



<a name="0x1_DiemAccount_EROLE_CANT_STORE_BALANCE"></a>

Tried to create a balance for an account whose role does not allow holding balances


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EROLE_CANT_STORE_BALANCE">EROLE_CANT_STORE_BALANCE</a>: u64 = 12014;
</code></pre>



<a name="0x1_DiemAccount_ESLOW_WALLET_TRANSFERS_DISABLED_SYSTEMWIDE"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_ESLOW_WALLET_TRANSFERS_DISABLED_SYSTEMWIDE">ESLOW_WALLET_TRANSFERS_DISABLED_SYSTEMWIDE</a>: u64 = 120127;
</code></pre>



<a name="0x1_DiemAccount_EWITHDRAWAL_EXCEEDS_LIMITS"></a>

The withdrawal of funds would have exceeded the the account's limits


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_EXCEEDS_LIMITS">EWITHDRAWAL_EXCEEDS_LIMITS</a>: u64 = 12016;
</code></pre>



<a name="0x1_DiemAccount_EWITHDRAWAL_NOT_FOR_COMMUNITY_WALLET"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_NOT_FOR_COMMUNITY_WALLET">EWITHDRAWAL_NOT_FOR_COMMUNITY_WALLET</a>: u64 = 120126;
</code></pre>



<a name="0x1_DiemAccount_EWITHDRAWAL_SLOW_WAL_EXCEEDS_UNLOCKED_LIMIT"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_SLOW_WAL_EXCEEDS_UNLOCKED_LIMIT">EWITHDRAWAL_SLOW_WAL_EXCEEDS_UNLOCKED_LIMIT</a>: u64 = 120128;
</code></pre>



<a name="0x1_DiemAccount_EWITHDRAW_CAPABILITY_ALREADY_EXTRACTED"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a></code> for this account has already been extracted


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAW_CAPABILITY_ALREADY_EXTRACTED">EWITHDRAW_CAPABILITY_ALREADY_EXTRACTED</a>: u64 = 12017;
</code></pre>



<a name="0x1_DiemAccount_EWITHDRAW_CAPABILITY_NOT_EXTRACTED"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a></code> for this account is not extracted


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAW_CAPABILITY_NOT_EXTRACTED">EWITHDRAW_CAPABILITY_NOT_EXTRACTED</a>: u64 = 120111;
</code></pre>



<a name="0x1_DiemAccount_EWRITESET_MANAGER"></a>

The <code><a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a></code> was not in the required state


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_EWRITESET_MANAGER">EWRITESET_MANAGER</a>: u64 = 120123;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EACCOUNT_DNE"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EACCOUNT_DNE">PROLOGUE_EACCOUNT_DNE</a>: u64 = 1004;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EACCOUNT_FROZEN"></a>

Prologue errors. These are separated out from the other errors in this
module since they are mapped separately to major VM statuses, and are
important to the semantics of the system.


<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EACCOUNT_FROZEN">PROLOGUE_EACCOUNT_FROZEN</a>: u64 = 1000;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EBAD_CHAIN_ID"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EBAD_CHAIN_ID">PROLOGUE_EBAD_CHAIN_ID</a>: u64 = 1007;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EBAD_TRANSACTION_FEE_CURRENCY"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EBAD_TRANSACTION_FEE_CURRENCY">PROLOGUE_EBAD_TRANSACTION_FEE_CURRENCY</a>: u64 = 1012;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT">PROLOGUE_ECANT_PAY_GAS_DEPOSIT</a>: u64 = 1005;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY">PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY</a>: u64 = 1001;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER">PROLOGUE_EINVALID_WRITESET_SENDER</a>: u64 = 1010;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_EMODULE_NOT_ALLOWED"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EMODULE_NOT_ALLOWED">PROLOGUE_EMODULE_NOT_ALLOWED</a>: u64 = 1009;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ESCRIPT_NOT_ALLOWED"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESCRIPT_NOT_ALLOWED">PROLOGUE_ESCRIPT_NOT_ALLOWED</a>: u64 = 1008;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH">PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH</a>: u64 = 1013;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG">PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG</a>: u64 = 1011;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW">PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW</a>: u64 = 1003;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD">PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD</a>: u64 = 1002;
</code></pre>



<a name="0x1_DiemAccount_PROLOGUE_ETRANSACTION_EXPIRED"></a>



<pre><code><b>const</b> <a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ETRANSACTION_EXPIRED">PROLOGUE_ETRANSACTION_EXPIRED</a>: u64 = 1006;
</code></pre>



<a name="0x1_DiemAccount_scary_create_signer_for_migrations"></a>

## Function `scary_create_signer_for_migrations`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_scary_create_signer_for_migrations">scary_create_signer_for_migrations</a>(vm: &signer, addr: address): signer
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_scary_create_signer_for_migrations">scary_create_signer_for_migrations</a>(vm: &signer, addr: address): signer {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_new_escrow"></a>

## Function `new_escrow`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_new_escrow">new_escrow</a>&lt;Token: store&gt;(account: &signer, payer: address, payee: address, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_new_escrow">new_escrow</a>&lt;Token: store&gt;(
    account: &signer,
    payer: address,
    payee: address,
    amount: u64,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a> {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(account);

    // Formal verification <b>spec</b>: should not get anyone <b>else</b>'s balance <b>struct</b>
    <b>let</b> balance_struct = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
    <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>&lt;Token&gt;(&<b>mut</b> balance_struct.coin, amount);

    <b>let</b> new_escrow = <a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a> {
        to_account: payee,
        escrow: coin,
    };
    <b>let</b> state = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>&lt;Token&gt;&gt;(payer);
    <a href="FIFO.md#0x1_FIFO_push">FIFO::push</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt;&gt;(&<b>mut</b> state.list, new_escrow);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_process_escrow"></a>

## Function `process_escrow`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_process_escrow">process_escrow</a>&lt;Token: store&gt;(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_process_escrow">process_escrow</a>&lt;Token: store&gt;(
    account: &signer
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>, <a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(account);

    <b>let</b> account_list = &borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>&lt;Token&gt;&gt;(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
    ).accounts;
    <b>let</b> account_len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;(account_list);
    <b>let</b> account_idx = 0;
    <b>while</b> (account_idx &lt; account_len) {
        <b>let</b> <a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a> {account: account_addr, share: percentage}
            = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;(account_list, account_idx);

        //get transfer limit room
        <b>let</b> (limit_room, withdrawal_allowed)
            = <a href="AccountLimits.md#0x1_AccountLimits_max_withdrawal">AccountLimits::max_withdrawal</a>&lt;Token&gt;(*account_addr);

        <b>if</b> (!withdrawal_allowed) {
            account_idx = account_idx + 1;
            <b>continue</b>
        };

        limit_room = <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(
            limit_room ,
            <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(*percentage, 100)
        );
        <b>let</b> amount_sent: u64 = 0;

        <b>let</b> payment_list = &<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>&lt;Token&gt;&gt;(*account_addr).list;
        <b>let</b> num_payments = <a href="FIFO.md#0x1_FIFO_len">FIFO::len</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt;&gt;(payment_list);
        // Pay out escrow until limit is reached
        <b>while</b> (limit_room &gt; 0 && num_payments &gt; 0) {
            <b>let</b> <a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt; {to_account, escrow} = <a href="FIFO.md#0x1_FIFO_pop">FIFO::pop</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt;&gt;(payment_list);
            <b>let</b> recipient_coins = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(to_account);
            <b>let</b> payment_size = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;Token&gt;(&escrow);
            <b>if</b> (payment_size &gt; limit_room) {
                <b>let</b> (coin1, coin2) = <a href="Diem.md#0x1_Diem_split">Diem::split</a>&lt;Token&gt;(escrow, limit_room);
                <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>&lt;Token&gt;(&<b>mut</b> recipient_coins.coin, coin2);
                <b>let</b> new_escrow = <a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a> {
                    to_account: to_account,
                    escrow: coin1,
                };
                <a href="FIFO.md#0x1_FIFO_push_LIFO">FIFO::push_LIFO</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt;&gt;(payment_list, new_escrow);
                amount_sent = amount_sent + limit_room;
                limit_room = 0;
            } <b>else</b> {
                // This entire escrow is being paid out
                <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>&lt;Token&gt;(&<b>mut</b> recipient_coins.coin, escrow);
                limit_room = limit_room - payment_size;
                amount_sent = amount_sent + payment_size;
                num_payments = num_payments - 1;
            }
        };
        //<b>update</b> account limits
        <b>if</b> (amount_sent &gt; 0) {
            _ = <a href="AccountLimits.md#0x1_AccountLimits_update_withdrawal_limits">AccountLimits::update_withdrawal_limits</a>&lt;Token&gt;(
                amount_sent,
                *account_addr,
                &borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(
                    <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
                ).limits_cap
            );
        };

        account_idx = account_idx + 1;
    }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_initialize_escrow"></a>

## Function `initialize_escrow`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow">initialize_escrow</a>&lt;Token: store&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow">initialize_escrow</a>&lt;Token: store&gt;(
    sender: &signer
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a> {
    <b>let</b> account = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>&lt;Token&gt;&gt;(account)) {
        move_to&lt;<a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a>&lt;Token&gt;&gt;(
            sender,
            <a href="DiemAccount.md#0x1_DiemAccount_AutopayEscrow">AutopayEscrow</a> { list: <a href="FIFO.md#0x1_FIFO_empty">FIFO::empty</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Escrow">Escrow</a>&lt;Token&gt;&gt;() }
        );
        <b>let</b> escrow_list = &<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>&lt;Token&gt;&gt;(
            <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
        ).accounts;
        <b>let</b> idx = 0;
        <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;(escrow_list);
        <b>let</b> found = <b>false</b>;
        <b>while</b> (idx &lt; len) {
            <b>let</b> account_addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;(escrow_list, idx).account;
            <b>if</b> (account_addr == account) {
                found = <b>true</b>;
                <b>break</b>
            };
            idx = idx + 1;
        };
        <b>if</b> (!found){
            // Share initialized <b>to</b> 100
            <b>let</b> default_percentage: u64 = 100;
            <b>let</b> settings = <a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a> { account: account, share: default_percentage };
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;(escrow_list, settings);
        };
    };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_initialize_escrow_root"></a>

## Function `initialize_escrow_root`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow_root">initialize_escrow_root</a>&lt;Token: store&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow_root">initialize_escrow_root</a>&lt;Token: store&gt;(sender: &signer) {
    move_to&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>&lt;Token&gt;&gt;(
        sender,
        <a href="DiemAccount.md#0x1_DiemAccount_EscrowList">EscrowList</a>&lt;Token&gt; { accounts: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_EscrowSettings">EscrowSettings</a>&gt;() }
    );
}
</code></pre>



</details>

<a name="0x1_DiemAccount_initialize"></a>

## Function `initialize`

Initialize this module. This is only callable from genesis.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize">initialize</a>(dr_account: &signer, dummy_auth_key_prefix: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_initialize">initialize</a>(
    dr_account: &signer,
    dummy_auth_key_prefix: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    // Operational constraint, not a privilege constraint.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);

    <a href="DiemAccount.md#0x1_DiemAccount_create_diem_root_account">create_diem_root_account</a>(
        <b>copy</b> dummy_auth_key_prefix,
    );
    /////// 0L /////////
    // <a href="DiemAccount.md#0x1_DiemAccount_create_treasury_compliance_account">create_treasury_compliance_account</a>(
    //     dr_account,
    //     <b>copy</b> dummy_auth_key_prefix,
    // );
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>include</b> <a href="CoreAddresses.md#0x1_CoreAddresses_AbortsIfNotDiemRoot">CoreAddresses::AbortsIfNotDiemRoot</a>{account: dr_account};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountAbortsIf">CreateDiemRootAccountAbortsIf</a>{auth_key_prefix: dummy_auth_key_prefix};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountAbortsIf">CreateTreasuryComplianceAccountAbortsIf</a>{auth_key_prefix: dummy_auth_key_prefix};
<b>aborts_if</b> <b>exists</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>())
    <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountModifies">CreateDiemRootAccountModifies</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountEnsures">CreateDiemRootAccountEnsures</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountModifies">CreateTreasuryComplianceAccountModifies</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountEnsures">CreateTreasuryComplianceAccountEnsures</a>;
</code></pre>



</details>

<a name="0x1_DiemAccount_create_user_account_with_proof"></a>

## Function `create_user_account_with_proof`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_proof">create_user_account_with_proof</a>(sender: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;, difficulty: u64, security: u64): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_proof">create_user_account_with_proof</a>(
    sender: &signer,
    challenge: &vector&lt;u8&gt;,
    solution: &vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
):address <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>, <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    // TODO: extract address_duplicated <b>with</b> <a href="TowerState.md#0x1_TowerState_init_miner_state">TowerState::init_miner_state</a>
    <b>let</b> (new_account_address, auth_key_prefix) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(challenge);
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="Roles.md#0x1_Roles_new_user_role_with_proof">Roles::new_user_role_with_proof</a>(&new_signer);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_signer);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_signer, <b>false</b>);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_signer, auth_key_prefix);

    <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, new_account_address, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);
    // Init the miner state
    // this verifies the <a href="VDF.md#0x1_VDF">VDF</a> proof, which we <b>use</b> <b>to</b> rate limit account creation.
    // account will not be created <b>if</b> this step fails.
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="TowerState.md#0x1_TowerState_init_miner_state">TowerState::init_miner_state</a>(&new_signer, challenge, solution, difficulty, security);
    <a href="Ancestry.md#0x1_Ancestry_init">Ancestry::init</a>(sender, &new_signer);
    new_account_address
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_user_account_with_coin"></a>

## Function `create_user_account_with_coin`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_coin">create_user_account_with_coin</a>(sender: &signer, new_account: address, new_account_authkey_prefix: vector&lt;u8&gt;, value: u64): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_coin">create_user_account_with_coin</a>(
    sender: &signer,
    new_account: address,
    new_account_authkey_prefix: vector&lt;u8&gt;,
    value: u64,
):address <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>, <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account);
    <a href="Roles.md#0x1_Roles_new_user_role_with_proof">Roles::new_user_role_with_proof</a>(&new_signer);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_signer);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_signer, <b>false</b>);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_signer, new_account_authkey_prefix);

    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account);
    <a href="Ancestry.md#0x1_Ancestry_init">Ancestry::init</a>(sender, &new_signer);

    // <b>if</b> the initial coin sent is the minimum amount, don't check transfer limits.
    <b>if</b> (value &lt;= <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>) {
        <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, new_account, value);
        new_account
    }
    // otherwise, <b>if</b> the onboarder wants <b>to</b> send more, then it must respect the transfer limits.
    <b>else</b> {
        <b>let</b> with_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">extract_withdraw_capability</a>(sender);
        <a href="DiemAccount.md#0x1_DiemAccount_pay_from">pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
            &with_cap,
            new_account,
            value,
            b"account generation",
            b"",
        );
        <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">restore_withdraw_capability</a>(with_cap);
        new_account
    }


}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_validator_account_with_proof"></a>

## Function `create_validator_account_with_proof`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account_with_proof">create_validator_account_with_proof</a>(sender: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;, difficulty: u64, security: u64, ow_human_name: vector&lt;u8&gt;, op_address: address, op_auth_key_prefix: vector&lt;u8&gt;, op_consensus_pubkey: vector&lt;u8&gt;, op_validator_network_addresses: vector&lt;u8&gt;, op_fullnode_network_addresses: vector&lt;u8&gt;, op_human_name: vector&lt;u8&gt;): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account_with_proof">create_validator_account_with_proof</a>(
    sender: &signer,
    challenge: &vector&lt;u8&gt;,
    solution: &vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
    ow_human_name: vector&lt;u8&gt;,
    op_address: address,
    op_auth_key_prefix: vector&lt;u8&gt;,
    op_consensus_pubkey: vector&lt;u8&gt;,
    op_validator_network_addresses: vector&lt;u8&gt;,
    op_fullnode_network_addresses: vector&lt;u8&gt;,
    op_human_name: vector&lt;u8&gt;,
):address <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> { //////// 0L ////////
    <b>let</b> sender_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    // Rate limit spam accounts.
    // check the validator is in set before creating
    <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(sender_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(120101));
    <b>assert</b>(<a href="TowerState.md#0x1_TowerState_can_create_val_account">TowerState::can_create_val_account</a>(sender_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(120102));
    // Check there's enough balance for bootstrapping both operator and validator account
    <b>assert</b>(
        <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr) &gt; 2 * <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>)
    );

    // Create Owner Account
    <b>let</b> (new_account_address, auth_key_prefix) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(challenge);
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);

    // <b>if</b> the new account <b>exists</b>, the function is meant <b>to</b> be upgrading the account.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address)) {
      <b>return</b> <a href="DiemAccount.md#0x1_DiemAccount_upgrade_validator_account_with_proof">upgrade_validator_account_with_proof</a>(
        sender,
        challenge,
        solution,
        difficulty,
        security,
        ow_human_name,
        op_address,
        op_auth_key_prefix,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses,
        op_human_name,
      )
    };

    // TODO: Perhaps this needs <b>to</b> be moved <b>to</b> the epoch boundary, so that it is only the VM which can escalate these privileges.
    <a href="Roles.md#0x1_Roles_new_validator_role_with_proof">Roles::new_validator_role_with_proof</a>(&new_signer, &<a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()));
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_signer);
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_publish_with_proof">ValidatorConfig::publish_with_proof</a>(&new_signer, ow_human_name);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_signer, <b>false</b>);

    // This also verifies the <a href="VDF.md#0x1_VDF">VDF</a> proof, which we <b>use</b> <b>to</b> rate limit account creation.
    <a href="TowerState.md#0x1_TowerState_init_miner_state">TowerState::init_miner_state</a>(&new_signer, challenge, solution, difficulty, security);

    // Create OP Account
    <b>let</b> new_op_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(op_address);
    <a href="Roles.md#0x1_Roles_new_validator_operator_role_with_proof">Roles::new_validator_operator_role_with_proof</a>(&new_op_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_op_account);
    <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_publish_with_proof">ValidatorOperatorConfig::publish_with_proof</a>(&new_op_account, op_human_name);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_op_account, <b>false</b>);
    // Link owner <b>to</b> OP
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_operator">ValidatorConfig::set_operator</a>(&new_signer, op_address);
    // OP sends network info <b>to</b> Owner config"
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_config">ValidatorConfig::set_config</a>(
        &new_op_account, // signer
        new_account_address,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses
    );

    // User can join validator universe list, but will only join <b>if</b>
    // the mining is above the threshold in the preceeding period.
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">ValidatorUniverse::add_self</a>(&new_signer);
    <a href="Jail.md#0x1_Jail_init">Jail::init</a>(&new_signer);

    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_signer, auth_key_prefix);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_op_account, op_auth_key_prefix);

    <a href="TowerState.md#0x1_TowerState_reset_rate_limit">TowerState::reset_rate_limit</a>(sender);



    // Transfer for owner
    <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, new_account_address, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);
    // Transfer for operator <b>as</b> well
    <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, op_address, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);

    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);

    <a href="Ancestry.md#0x1_Ancestry_init">Ancestry::init</a>(sender, &new_signer);
    <a href="Vouch.md#0x1_Vouch_init">Vouch::init</a>(&new_signer);
    <a href="Vouch.md#0x1_Vouch_vouch_for">Vouch::vouch_for</a>(sender, new_account_address);
    <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(&new_signer);

    new_account_address
}
</code></pre>



</details>

<a name="0x1_DiemAccount_upgrade_validator_account_with_proof"></a>

## Function `upgrade_validator_account_with_proof`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_upgrade_validator_account_with_proof">upgrade_validator_account_with_proof</a>(sender: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;, difficulty: u64, security: u64, ow_human_name: vector&lt;u8&gt;, op_address: address, op_auth_key_prefix: vector&lt;u8&gt;, op_consensus_pubkey: vector&lt;u8&gt;, op_validator_network_addresses: vector&lt;u8&gt;, op_fullnode_network_addresses: vector&lt;u8&gt;, op_human_name: vector&lt;u8&gt;): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_upgrade_validator_account_with_proof">upgrade_validator_account_with_proof</a>(
    sender: &signer,
    challenge: &vector&lt;u8&gt;,
    solution: &vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
    ow_human_name: vector&lt;u8&gt;,
    op_address: address,
    op_auth_key_prefix: vector&lt;u8&gt;,
    op_consensus_pubkey: vector&lt;u8&gt;,
    op_validator_network_addresses: vector&lt;u8&gt;,
    op_fullnode_network_addresses: vector&lt;u8&gt;,
    op_human_name: vector&lt;u8&gt;,
):address <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> { //////// 0L ////////
    <b>let</b> sender_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    // Rate limit spam accounts.
    <b>assert</b>(<a href="TowerState.md#0x1_TowerState_can_create_val_account">TowerState::can_create_val_account</a>(sender_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(120103));
    // Check there's enough balance for bootstrapping both operator and validator account
    <b>assert</b>(
        <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr) &gt; 2 * <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>)
    );
    // Create Owner Account
    <b>let</b> (new_account_address, _auth_key_prefix) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(challenge);
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);

    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    // <b>assert</b>(<a href="TowerState.md#0x1_TowerState_is_init">TowerState::is_init</a>(new_account_address), 120104);
    // verifies the <a href="VDF.md#0x1_VDF">VDF</a> proof, since we are not calling <a href="TowerState.md#0x1_TowerState">TowerState</a> init.

    // <b>if</b> the account already has a tower started just verify the block zero submitted
    <b>if</b> (<a href="TowerState.md#0x1_TowerState_is_init">TowerState::is_init</a>(new_account_address)) {
      <b>let</b> valid = <a href="VDF.md#0x1_VDF_verify">VDF::verify</a>(
          challenge,
          solution,
          &difficulty,
          &security,
      );

      <b>assert</b>(valid, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(120105));
    } <b>else</b> {
      // otherwise initialize this <a href="TowerState.md#0x1_TowerState">TowerState</a> <b>with</b> a block 0.

      <b>let</b> proof = <a href="TowerState.md#0x1_TowerState_create_proof_blob">TowerState::create_proof_blob</a>(
        *challenge,
        *solution,
        *&difficulty,
        *&security,
      );

      <a href="TowerState.md#0x1_TowerState_commit_state">TowerState::commit_state</a>(&new_signer, proof);
    };



    // TODO: Perhaps this needs <b>to</b> be moved <b>to</b> the epoch boundary, so that it is only the VM which can escalate these privileges.
    // <a href="Upgrade.md#0x1_Upgrade">Upgrade</a> the user
    <a href="Roles.md#0x1_Roles_upgrade_user_to_validator">Roles::upgrade_user_to_validator</a>(&new_signer, &<a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()));
    // <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_signer);
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_publish_with_proof">ValidatorConfig::publish_with_proof</a>(&new_signer, ow_human_name);

    // currencies already added for owner account
    // <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_signer, <b>false</b>);

    // checks the operator account has not been created yet.

    // Create OP Account
    <b>let</b> new_op_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(op_address);
    <a href="Roles.md#0x1_Roles_new_validator_operator_role_with_proof">Roles::new_validator_operator_role_with_proof</a>(&new_op_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_op_account);
    <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_publish_with_proof">ValidatorOperatorConfig::publish_with_proof</a>(&new_op_account, op_human_name);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_op_account, <b>false</b>);

    // Link owner <b>to</b> OP
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_operator">ValidatorConfig::set_operator</a>(&new_signer, op_address);
    // OP sends network info <b>to</b> Owner config"
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_set_config">ValidatorConfig::set_config</a>(
        &new_op_account, // signer
        new_account_address,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses
    );
    // User can join validator universe list, but will only join <b>if</b>
    // the mining is above the threshold in the preceeding period.
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">ValidatorUniverse::add_self</a>(&new_signer);
    <a href="Jail.md#0x1_Jail_init">Jail::init</a>(&new_signer);

    // no need <b>to</b> make the owner address.

    // <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_signer, auth_key_prefix);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_op_account, op_auth_key_prefix);

    <a href="TowerState.md#0x1_TowerState_reset_rate_limit">TowerState::reset_rate_limit</a>(sender);
    // the miner who is upgrading may have coins, but better safe...
    // Transfer for owner
    <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, new_account_address, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);
    // Transfer for operator <b>as</b> well
    <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender, op_address, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);
    <b>let</b> new_signer = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);

    <a href="Ancestry.md#0x1_Ancestry_init">Ancestry::init</a>(sender, &new_signer);
    <a href="Vouch.md#0x1_Vouch_init">Vouch::init</a>(&new_signer);
    <a href="Vouch.md#0x1_Vouch_vouch_for">Vouch::vouch_for</a>(sender, new_account_address);

    <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(&new_signer);
    new_account_address
}
</code></pre>



</details>

<a name="0x1_DiemAccount_has_published_account_limits"></a>

## Function `has_published_account_limits`

Return <code><b>true</b></code> if <code>addr</code> has already published account limits for <code>Token</code>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_has_published_account_limits">has_published_account_limits</a>&lt;Token: store&gt;(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_has_published_account_limits">has_published_account_limits</a>&lt;Token: store&gt;(addr: address): bool {
    <b>if</b> (<a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(addr)) {
        <a href="VASP.md#0x1_VASP_has_account_limits">VASP::has_account_limits</a>&lt;Token&gt;(addr)
    }
    <b>else</b> {
        <a href="AccountLimits.md#0x1_AccountLimits_has_window_published">AccountLimits::has_window_published</a>&lt;Token&gt;(addr)
    }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_should_track_limits_for_account"></a>

## Function `should_track_limits_for_account`

Returns whether we should track and record limits for the <code>payer</code> or <code>payee</code> account.
Depending on the <code>is_withdrawal</code> flag passed in we determine whether the
<code>payer</code> or <code>payee</code> account is being queried. <code><a href="VASP.md#0x1_VASP">VASP</a>-&gt;any</code> and
<code>any-&gt;<a href="VASP.md#0x1_VASP">VASP</a></code> transfers are tracked in the VASP.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_should_track_limits_for_account">should_track_limits_for_account</a>&lt;Token: store&gt;(payer: address, payee: address, is_withdrawal: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_should_track_limits_for_account">should_track_limits_for_account</a>&lt;Token: store&gt;(
    payer: address, payee: address, is_withdrawal: bool
): bool {
    <b>if</b> (is_withdrawal) {
        <a href="DiemAccount.md#0x1_DiemAccount_has_published_account_limits">has_published_account_limits</a>&lt;Token&gt;(payer) &&
        <a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(payer) &&
        !<a href="VASP.md#0x1_VASP_is_same_vasp">VASP::is_same_vasp</a>(payer, payee)
    } <b>else</b> {
        <a href="DiemAccount.md#0x1_DiemAccount_has_published_account_limits">has_published_account_limits</a>&lt;Token&gt;(payee) &&
        <a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(payee) &&
        !<a href="VASP.md#0x1_VASP_is_same_vasp">VASP::is_same_vasp</a>(payee, payer)
    }
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>aborts_if</b> <b>false</b>;
<b>ensures</b> result == <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, is_withdrawal);
</code></pre>




<a name="0x1_DiemAccount_spec_should_track_limits_for_account"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(
   payer: address, payee: address, is_withdrawal: bool
): bool {
   <b>if</b> (is_withdrawal) {
       <a href="DiemAccount.md#0x1_DiemAccount_spec_has_published_account_limits">spec_has_published_account_limits</a>&lt;Token&gt;(payer) &&
       <a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(payer) &&
       !<a href="VASP.md#0x1_VASP_spec_is_same_vasp">VASP::spec_is_same_vasp</a>(payer, payee)
   } <b>else</b> {
       <a href="DiemAccount.md#0x1_DiemAccount_spec_has_published_account_limits">spec_has_published_account_limits</a>&lt;Token&gt;(payee) &&
       <a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(payee) &&
       !<a href="VASP.md#0x1_VASP_spec_is_same_vasp">VASP::spec_is_same_vasp</a>(payee, payer)
   }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_deposit"></a>

## Function `deposit`

Record a payment of <code>to_deposit</code> from <code>payer</code> to <code>payee</code> with the attached <code>metadata</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>&lt;Token: store&gt;(payer: address, payee: address, to_deposit: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;, metadata: vector&lt;u8&gt;, metadata_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>&lt;Token: store&gt;(
    payer: address,
    payee: address,
    to_deposit: <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;,
    metadata: vector&lt;u8&gt;,
    metadata_signature: vector&lt;u8&gt;
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <a href="AccountFreezing.md#0x1_AccountFreezing_assert_not_frozen">AccountFreezing::assert_not_frozen</a>(payee);

    // Check that the `to_deposit` coin is non-zero
    <b>let</b> deposit_value = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&to_deposit);
    <b>assert</b>(deposit_value &gt; 0, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_ECOIN_DEPOSIT_IS_ZERO">ECOIN_DEPOSIT_IS_ZERO</a>));
    // Check that an account <b>exists</b> at `payee`
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payee), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EPAYEE_DOES_NOT_EXIST">EPAYEE_DOES_NOT_EXIST</a>));
    /////// 0L /////////
    // // Check that `payee` can accept payments in `Token`
    // <b>assert</b>(
    //     <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee),
    //     <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_EPAYEE_CANT_ACCEPT_CURRENCY_TYPE">EPAYEE_CANT_ACCEPT_CURRENCY_TYPE</a>)
    // );

    // Check that the payment complies <b>with</b> dual attestation rules
    <a href="DualAttestation.md#0x1_DualAttestation_assert_payment_ok">DualAttestation::assert_payment_ok</a>&lt;Token&gt;(
        payer, payee, deposit_value, <b>copy</b> metadata, metadata_signature
    );
    // Ensure that this deposit is compliant <b>with</b> the account limits on
    // this account.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_should_track_limits_for_account">should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>false</b>)) {
        <b>assert</b>(
            <a href="AccountLimits.md#0x1_AccountLimits_update_deposit_limits">AccountLimits::update_deposit_limits</a>&lt;Token&gt;(
                deposit_value,
                <a href="VASP.md#0x1_VASP_parent_address">VASP::parent_address</a>(payee),
                &borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()).limits_cap
            ),
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EDEPOSIT_EXCEEDS_LIMITS">EDEPOSIT_EXCEEDS_LIMITS</a>)
        )
    };

    // Deposit the `to_deposit` coin
    <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee).coin, to_deposit);

    // Log a received event
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a>&gt;(
        &<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events,
        <a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a> {
            amount: deposit_value,
            currency_code: <a href="Diem.md#0x1_Diem_currency_code">Diem::currency_code</a>&lt;Token&gt;(),
            payer,
            metadata
        }
    );

    //////// 0L ////////
    // <b>if</b> the account wants <b>to</b> be tracked add tracking
    <a href="DiemAccount.md#0x1_DiemAccount_maybe_update_deposit">maybe_update_deposit</a>(payee, deposit_value);

}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee);
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payee));
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee);
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).withdraw_capability
    == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).withdraw_capability);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).authentication_key
    == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).authentication_key);
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events));
<b>let</b> amount = to_deposit.value;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIf">DepositAbortsIf</a>&lt;Token&gt;{amount: amount};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositOverflowAbortsIf">DepositOverflowAbortsIf</a>&lt;Token&gt;{amount: amount};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEnsures">DepositEnsures</a>&lt;Token&gt;{amount: amount};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEmits">DepositEmits</a>&lt;Token&gt;{amount: amount};
</code></pre>




<a name="0x1_DiemAccount_DepositAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIf">DepositAbortsIf</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    amount: u64;
    metadata_signature: vector&lt;u8&gt;;
    metadata: vector&lt;u8&gt;;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIfRestricted">DepositAbortsIfRestricted</a>&lt;Token&gt;;
    <b>include</b> <a href="AccountFreezing.md#0x1_AccountFreezing_AbortsIfFrozen">AccountFreezing::AbortsIfFrozen</a>{account: payee};
    <b>aborts_if</b> !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payee) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_DepositOverflowAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositOverflowAbortsIf">DepositOverflowAbortsIf</a>&lt;Token&gt; {
    payee: address;
    amount: u64;
    <b>aborts_if</b> <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payee) + amount &gt; max_u64() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_LIMIT_EXCEEDED">Errors::LIMIT_EXCEEDED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_DepositAbortsIfRestricted"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIfRestricted">DepositAbortsIfRestricted</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    amount: u64;
    metadata_signature: vector&lt;u8&gt;;
    metadata: vector&lt;u8&gt;;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>aborts_if</b> amount == 0 <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>include</b> <a href="DualAttestation.md#0x1_DualAttestation_AssertPaymentOkAbortsIf">DualAttestation::AssertPaymentOkAbortsIf</a>&lt;Token&gt;{value: amount};
    <b>include</b>
        <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>false</b>) ==&gt;
        <a href="AccountLimits.md#0x1_AccountLimits_UpdateDepositLimitsAbortsIf">AccountLimits::UpdateDepositLimitsAbortsIf</a>&lt;Token&gt; {
            addr: <a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payee),
        };
    <b>aborts_if</b>
        <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>false</b>) &&
            !<a href="AccountLimits.md#0x1_AccountLimits_spec_update_deposit_limits">AccountLimits::spec_update_deposit_limits</a>&lt;Token&gt;(amount, <a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payee))
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_LIMIT_EXCEEDED">Errors::LIMIT_EXCEEDED</a>;
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;Token&gt;;
}
</code></pre>




<a name="0x1_DiemAccount_DepositEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEnsures">DepositEnsures</a>&lt;Token&gt; {
    payee: address;
    amount: u64;
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payee) == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payee)) + amount;
}
</code></pre>




<a name="0x1_DiemAccount_DepositEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEmits">DepositEmits</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    amount: u64;
    metadata: vector&lt;u8&gt;;
    <b>let</b> handle = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events;
    <b>let</b> msg = <a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a> {
        amount,
        currency_code: <a href="Diem.md#0x1_Diem_spec_currency_code">Diem::spec_currency_code</a>&lt;Token&gt;(),
        payer,
        metadata
    };
    emits msg <b>to</b> handle;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_tiered_mint"></a>

## Function `tiered_mint`

Mint 'mint_amount' to 'designated_dealer_address' for 'tier_index' tier.
Max valid tier index is 3 since there are max 4 tiers per DD.
Sender should be treasury compliance account and receiver authorized DD.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_tiered_mint">tiered_mint</a>&lt;Token: store&gt;(tc_account: &signer, designated_dealer_address: address, mint_amount: u64, tier_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_tiered_mint">tiered_mint</a>&lt;Token: store&gt;(
    tc_account: &signer,
    designated_dealer_address: address,
    mint_amount: u64,
    tier_index: u64,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>let</b> coin = <a href="DesignatedDealer.md#0x1_DesignatedDealer_tiered_mint">DesignatedDealer::tiered_mint</a>&lt;Token&gt;(
        tc_account, mint_amount, designated_dealer_address, tier_index
    );
    // Use the reserved address <b>as</b> the payer because the funds did not come from an existing
    // balance
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>(), designated_dealer_address, coin, x"", x"")
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(designated_dealer_address);
<b>modifies</b> <b>global</b>&lt;<a href="DesignatedDealer.md#0x1_DesignatedDealer_Dealer">DesignatedDealer::Dealer</a>&gt;(designated_dealer_address);
<b>modifies</b> <b>global</b>&lt;<a href="DesignatedDealer.md#0x1_DesignatedDealer_TierInfo">DesignatedDealer::TierInfo</a>&lt;Token&gt;&gt;(designated_dealer_address);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(designated_dealer_address);
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(designated_dealer_address));
<b>modifies</b> <b>global</b>&lt;<a href="Diem.md#0x1_Diem_CurrencyInfo">Diem::CurrencyInfo</a>&lt;Token&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a>());
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintAbortsIf">TieredMintAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEnsures">TieredMintEnsures</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEmits">TieredMintEmits</a>&lt;Token&gt;;
</code></pre>




<a name="0x1_DiemAccount_TieredMintAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintAbortsIf">TieredMintAbortsIf</a>&lt;Token&gt; {
    tc_account: signer;
    designated_dealer_address: address;
    mint_amount: u64;
    tier_index: u64;
    <b>include</b> <a href="DesignatedDealer.md#0x1_DesignatedDealer_TieredMintAbortsIf">DesignatedDealer::TieredMintAbortsIf</a>&lt;Token&gt;{dd_addr: designated_dealer_address, amount: mint_amount};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIf">DepositAbortsIf</a>&lt;Token&gt;{payer: <a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>(),
        payee: designated_dealer_address, amount: mint_amount, metadata: x"", metadata_signature: x""};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositOverflowAbortsIf">DepositOverflowAbortsIf</a>&lt;Token&gt;{payee: designated_dealer_address, amount: mint_amount};
}
</code></pre>




<a name="0x1_DiemAccount_TieredMintEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEnsures">TieredMintEnsures</a>&lt;Token&gt; {
    designated_dealer_address: address;
    mint_amount: u64;
    <b>let</b> dealer_balance = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(designated_dealer_address).coin.value;
    <b>let</b> post post_dealer_balance = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(designated_dealer_address).coin.value;
    <b>let</b> currency_info = <b>global</b>&lt;<a href="Diem.md#0x1_Diem_CurrencyInfo">Diem::CurrencyInfo</a>&lt;Token&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a>());
    <b>let</b> post post_currency_info = <b>global</b>&lt;<a href="Diem.md#0x1_Diem_CurrencyInfo">Diem::CurrencyInfo</a>&lt;Token&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a>());
}
</code></pre>


Total value of the currency increases by <code>amount</code>.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEnsures">TieredMintEnsures</a>&lt;Token&gt; {
    <b>ensures</b> post_currency_info == update_field(currency_info, total_value, currency_info.total_value + mint_amount);
}
</code></pre>


The balance of designated dealer increases by <code>amount</code>.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEnsures">TieredMintEnsures</a>&lt;Token&gt; {
    <b>ensures</b> post_dealer_balance == dealer_balance + mint_amount;
}
</code></pre>




<a name="0x1_DiemAccount_TieredMintEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TieredMintEmits">TieredMintEmits</a>&lt;Token&gt; {
    tc_account: signer;
    designated_dealer_address: address;
    mint_amount: u64;
    tier_index: u64;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEmits">DepositEmits</a>&lt;Token&gt;{
        payer: <a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>(),
        payee: designated_dealer_address,
        amount: mint_amount,
        metadata: x""
    };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_cancel_burn"></a>

## Function `cancel_burn`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_cancel_burn">cancel_burn</a>&lt;Token: store&gt;(account: &signer, preburn_address: address, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_cancel_burn">cancel_burn</a>&lt;Token: store&gt;(
    account: &signer,
    preburn_address: address,
    amount: u64,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>let</b> coin = <a href="Diem.md#0x1_Diem_cancel_burn">Diem::cancel_burn</a>&lt;Token&gt;(account, preburn_address, amount);
    // record both sender and recipient <b>as</b> `preburn_address`: the coins are moving from
    // `preburn_address`'s `Preburn` <b>resource</b> <b>to</b> its balance
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>(preburn_address, preburn_address, coin, x"", x"")
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CancelBurnAbortsIf">CancelBurnAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="Diem.md#0x1_Diem_CancelBurnWithCapEmits">Diem::CancelBurnWithCapEmits</a>&lt;Token&gt;;
<b>include</b> <a href="Diem.md#0x1_Diem_CancelBurnWithCapEnsures">Diem::CancelBurnWithCapEnsures</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEnsures">DepositEnsures</a>&lt;Token&gt;{payee: preburn_address};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositEmits">DepositEmits</a>&lt;Token&gt;{
    payer: preburn_address,
    payee: preburn_address,
    amount: amount,
    metadata: x""
};
</code></pre>




<a name="0x1_DiemAccount_CancelBurnAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CancelBurnAbortsIf">CancelBurnAbortsIf</a>&lt;Token&gt; {
    account: signer;
    preburn_address: address;
    amount: u64;
    <b>include</b> <a href="Diem.md#0x1_Diem_CancelBurnAbortsIf">Diem::CancelBurnAbortsIf</a>&lt;Token&gt;;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIf">DepositAbortsIf</a>&lt;Token&gt;{
        payer: preburn_address,
        payee: preburn_address,
        amount: amount,
        metadata: x"",
        metadata_signature: x""
    };
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositOverflowAbortsIf">DepositOverflowAbortsIf</a>&lt;Token&gt;{payee: preburn_address, amount: amount};
}
</code></pre>



</details>

<a name="0x1_DiemAccount_withdraw_from_balance"></a>

## Function `withdraw_from_balance`

Helper to withdraw <code>amount</code> from the given account balance and return the withdrawn Diem<Token>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from_balance">withdraw_from_balance</a>&lt;Token: store&gt;(payer: address, payee: address, balance: &<b>mut</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">DiemAccount::Balance</a>&lt;Token&gt;, amount: u64): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from_balance">withdraw_from_balance</a>&lt;Token: store&gt;(
    payer: address,
    payee: address,
    balance: &<b>mut</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;,
    amount: u64
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt; <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <a href="AccountFreezing.md#0x1_AccountFreezing_assert_not_frozen">AccountFreezing::assert_not_frozen</a>(payer);
    // Make sure that this withdrawal is compliant <b>with</b> the limits on
    // the account <b>if</b> it's a inter-<a href="VASP.md#0x1_VASP">VASP</a> transfer,
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_should_track_limits_for_account">should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>true</b>)) {
        <b>let</b> can_withdraw = <a href="AccountLimits.md#0x1_AccountLimits_update_withdrawal_limits">AccountLimits::update_withdrawal_limits</a>&lt;Token&gt;(
                amount,
                <a href="VASP.md#0x1_VASP_parent_address">VASP::parent_address</a>(payer),
                &borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()).limits_cap
        );
        <b>assert</b>(can_withdraw, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_EXCEEDS_LIMITS">EWITHDRAWAL_EXCEEDS_LIMITS</a>));
    };
    <b>let</b> coin = &<b>mut</b> balance.coin;
    // Abort <b>if</b> this withdrawal would make the `payer`'s balance go negative
    <b>assert</b>(<a href="Diem.md#0x1_Diem_value">Diem::value</a>(coin) &gt;= amount, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>));
    <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(coin, amount)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer));
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceAbortsIf">WithdrawFromBalanceAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceEnsures">WithdrawFromBalanceEnsures</a>&lt;Token&gt;;
</code></pre>




<a name="0x1_DiemAccount_WithdrawFromBalanceAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceAbortsIf">WithdrawFromBalanceAbortsIf</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    balance: <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;;
    amount: u64;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceNoLimitsAbortsIf">WithdrawFromBalanceNoLimitsAbortsIf</a>&lt;Token&gt;;
    <b>include</b>
        <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>true</b>) ==&gt;
        <a href="AccountLimits.md#0x1_AccountLimits_UpdateWithdrawalLimitsAbortsIf">AccountLimits::UpdateWithdrawalLimitsAbortsIf</a>&lt;Token&gt; {
            addr: <a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer),
        };
    <b>aborts_if</b>
        <a href="DiemAccount.md#0x1_DiemAccount_spec_should_track_limits_for_account">spec_should_track_limits_for_account</a>&lt;Token&gt;(payer, payee, <b>true</b>) &&
        (   !<a href="DiemAccount.md#0x1_DiemAccount_spec_has_account_operations_cap">spec_has_account_operations_cap</a>() ||
            !<a href="AccountLimits.md#0x1_AccountLimits_spec_update_withdrawal_limits">AccountLimits::spec_update_withdrawal_limits</a>&lt;Token&gt;(amount, <a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer))
        )
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_LIMIT_EXCEEDED">Errors::LIMIT_EXCEEDED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_WithdrawFromBalanceNoLimitsAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceNoLimitsAbortsIf">WithdrawFromBalanceNoLimitsAbortsIf</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    balance: <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;;
    amount: u64;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>include</b> <a href="AccountFreezing.md#0x1_AccountFreezing_AbortsIfFrozen">AccountFreezing::AbortsIfFrozen</a>{account: payer};
    <b>aborts_if</b> balance.coin.value &lt; amount <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_LIMIT_EXCEEDED">Errors::LIMIT_EXCEEDED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_WithdrawFromBalanceEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceEnsures">WithdrawFromBalanceEnsures</a>&lt;Token&gt; {
    balance: <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;;
    amount: u64;
    result: <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;;
    <b>ensures</b> balance.coin.value == <b>old</b>(balance.coin.value) - amount;
    <b>ensures</b> result.value == amount;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_withdraw_from"></a>

## Function `withdraw_from`

Withdraw <code>amount</code> <code><a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;</code>'s from the account balance under
<code>cap.account_address</code>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>&lt;Token: store&gt;(cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>, payee: address, amount: u64, metadata: vector&lt;u8&gt;): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>&lt;Token: store&gt;(
    cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>,
    payee: address,
    amount: u64,
    metadata: vector&lt;u8&gt;,
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt; <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <b>let</b> payer = cap.account_address;
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payer), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>assert</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EPAYER_DOESNT_HOLD_CURRENCY">EPAYER_DOESNT_HOLD_CURRENCY</a>));

    /////// 0L /////////
    // Do not attempt sending <b>to</b> a payee that does not have balance
    <b>assert</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EPAYER_DOESNT_HOLD_CURRENCY">EPAYER_DOESNT_HOLD_CURRENCY</a>));

    <b>let</b> account_balance = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
    // Load the payer's account and emit an event <b>to</b> record the withdrawal
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a>&gt;(
        &<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events,
        <a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a> {
            amount,
            currency_code: <a href="Diem.md#0x1_Diem_currency_code">Diem::currency_code</a>&lt;Token&gt;(),
            payee,
            metadata
        },
    );
    <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from_balance">withdraw_from_balance</a>&lt;Token&gt;(payer, payee, account_balance, amount)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> payer = cap.account_address;
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer));
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability
            == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability);
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events));
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromAbortsIf">WithdrawFromAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceEnsures">WithdrawFromBalanceEnsures</a>&lt;Token&gt;{balance: <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer)};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawOnlyFromCapAddress">WithdrawOnlyFromCapAddress</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromEmits">WithdrawFromEmits</a>&lt;Token&gt;;
</code></pre>




<a name="0x1_DiemAccount_WithdrawFromAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromAbortsIf">WithdrawFromAbortsIf</a>&lt;Token&gt; {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    payee: address;
    amount: u64;
    <b>let</b> payer = cap.account_address;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;Token&gt;;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceAbortsIf">WithdrawFromBalanceAbortsIf</a>&lt;Token&gt;{payer, balance: <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer)};
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payer) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>aborts_if</b> !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
}
</code></pre>



<a name="@Access_Control_1"></a>

### Access Control



<a name="0x1_DiemAccount_WithdrawOnlyFromCapAddress"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawOnlyFromCapAddress">WithdrawOnlyFromCapAddress</a>&lt;Token&gt; {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
}
</code></pre>


Can only withdraw from the balances of cap.account_address [[H19]][PERMISSION].


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawOnlyFromCapAddress">WithdrawOnlyFromCapAddress</a>&lt;Token&gt; {
    <b>ensures</b> <b>forall</b> addr: address <b>where</b> <b>old</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)) && addr != cap.account_address:
        <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(addr) == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(addr));
}
</code></pre>




<a name="0x1_DiemAccount_WithdrawFromEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromEmits">WithdrawFromEmits</a>&lt;Token&gt; {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    payee: address;
    amount: u64;
    metadata: vector&lt;u8&gt;;
    <b>let</b> payer = cap.account_address;
    <b>let</b> handle = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events;
    <b>let</b> msg = <a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a> {
        amount,
        currency_code: <a href="Diem.md#0x1_Diem_spec_currency_code">Diem::spec_currency_code</a>&lt;Token&gt;(),
        payee,
        metadata
    };
    emits msg <b>to</b> handle;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_preburn"></a>

## Function `preburn`

Withdraw <code>amount</code> <code><a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;</code>'s from <code>cap.address</code> and send them to the <code>Preburn</code>
resource under <code>dd</code>.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_preburn">preburn</a>&lt;Token: store&gt;(dd: &signer, cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_preburn">preburn</a>&lt;Token: store&gt;(
    dd: &signer,
    cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>,
    amount: u64
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <a href="Diem.md#0x1_Diem_preburn_to">Diem::preburn_to</a>&lt;Token&gt;(dd, <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>(cap, <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(dd), amount, x""))
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> dd_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(dd);
<b>let</b> payer = cap.account_address;
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer));
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability
        == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability);
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(dd_addr).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(dd_addr).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(dd_addr).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(dd_addr).received_events));
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnAbortsIf">PreburnAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEnsures">PreburnEnsures</a>&lt;Token&gt;{dd, payer};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEmits">PreburnEmits</a>&lt;Token&gt;;
</code></pre>




<a name="0x1_DiemAccount_PreburnAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnAbortsIf">PreburnAbortsIf</a>&lt;Token&gt; {
    dd: signer;
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    amount: u64;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>{};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromAbortsIf">WithdrawFromAbortsIf</a>&lt;Token&gt;{payee: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(dd)};
    <b>include</b> <a href="Diem.md#0x1_Diem_PreburnToAbortsIf">Diem::PreburnToAbortsIf</a>&lt;Token&gt;{account: dd};
}
</code></pre>




<a name="0x1_DiemAccount_PreburnEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEnsures">PreburnEnsures</a>&lt;Token&gt; {
    dd: signer;
    payer: address;
    amount: u64;
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
    <b>let</b> payer_balance = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer).coin.value;
    <b>let</b> post post_payer_balance = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer).coin.value;
}
</code></pre>


The balance of payer decreases by <code>amount</code>.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEnsures">PreburnEnsures</a>&lt;Token&gt; {
    <b>ensures</b> post_payer_balance == payer_balance - amount;
}
</code></pre>


The value of preburn at <code>dd_addr</code> increases by <code>amount</code>;


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEnsures">PreburnEnsures</a>&lt;Token&gt; {
    <b>include</b> <a href="Diem.md#0x1_Diem_PreburnToEnsures">Diem::PreburnToEnsures</a>&lt;Token&gt;{amount, account: dd};
}
</code></pre>




<a name="0x1_DiemAccount_PreburnEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreburnEmits">PreburnEmits</a>&lt;Token&gt; {
    dd: signer;
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    amount: u64;
    <b>let</b> dd_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(dd);
    <b>include</b> <a href="Diem.md#0x1_Diem_PreburnWithResourceEmits">Diem::PreburnWithResourceEmits</a>&lt;Token&gt;{preburn_address: dd_addr};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromEmits">WithdrawFromEmits</a>&lt;Token&gt;{payee: dd_addr, metadata: x""};
}
</code></pre>



</details>

<a name="0x1_DiemAccount_extract_withdraw_capability"></a>

## Function `extract_withdraw_capability`

Return a unique capability granting permission to withdraw from
the sender's account balance.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">extract_withdraw_capability</a>(sender: &signer): <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">extract_withdraw_capability</a>(
    sender: &signer
): <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a> <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {

    <b>let</b> sender_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    /////// 0L /////////
    // Community wallets have own transfer mechanism.
    <b>let</b> community_wallets = <a href="Wallet.md#0x1_Wallet_get_comm_list">Wallet::get_comm_list</a>();
    <b>assert</b>(
        !<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&community_wallets, &sender_addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_NOT_FOR_COMMUNITY_WALLET">EWITHDRAWAL_NOT_FOR_COMMUNITY_WALLET</a>)
    );
    /////// 0L /////////
    <b>assert</b>(
        !<a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(sender_addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAW_CAPABILITY_ALREADY_EXTRACTED">EWITHDRAW_CAPABILITY_ALREADY_EXTRACTED</a>)
    );
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(sender_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender_addr);
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> account.withdraw_capability)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> sender_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender_addr);
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractWithdrawCapAbortsIf">ExtractWithdrawCapAbortsIf</a>{sender_addr};
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender_addr);
<b>ensures</b> result == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap">spec_get_withdraw_cap</a>(sender_addr));
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender_addr) == update_field(<b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender_addr)),
    withdraw_capability, <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_spec_none">Option::spec_none</a>());
<b>ensures</b> result.account_address == sender_addr;
</code></pre>




<a name="0x1_DiemAccount_ExtractWithdrawCapAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractWithdrawCapAbortsIf">ExtractWithdrawCapAbortsIf</a> {
    sender_addr: address;
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(sender_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>aborts_if</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_delegated_withdraw_capability">spec_holds_delegated_withdraw_capability</a>(sender_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_restore_withdraw_capability"></a>

## Function `restore_withdraw_capability`

Return the withdraw capability to the account it originally came from


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">restore_withdraw_capability</a>(cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">restore_withdraw_capability</a>(cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>)
<b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap.account_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    // Abort <b>if</b> the withdraw capability for this account is not extracted,
    // indicating that the withdraw capability is not unique.
    <b>assert</b>(
        <a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(cap.account_address),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAW_CAPABILITY_NOT_EXTRACTED">EWITHDRAW_CAPABILITY_NOT_EXTRACTED</a>)
    );
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap.account_address);
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> account.withdraw_capability, cap)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> cap_addr = cap.account_address;
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap_addr);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap_addr) == update_field(<b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap_addr)),
    withdraw_capability, <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_spec_some">Option::spec_some</a>(cap));
<b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
<b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(cap_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(cap_addr);
</code></pre>



</details>

<a name="0x1_DiemAccount_process_community_wallets"></a>

## Function `process_community_wallets`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_process_community_wallets">process_community_wallets</a>(vm: &signer, epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_process_community_wallets">process_community_wallets</a>(
    vm: &signer, epoch: u64
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()) <b>return</b>;

    print(&990100);
    // Migrate on the fly <b>if</b> state doesn't exist on upgrade.
    <b>if</b> (!<a href="Wallet.md#0x1_Wallet_is_init_comm">Wallet::is_init_comm</a>()) {
        <a href="Wallet.md#0x1_Wallet_init">Wallet::init</a>(vm);
        <b>return</b>
    };
    print(&990200);
    <b>let</b> all = <a href="Wallet.md#0x1_Wallet_list_transfers">Wallet::list_transfers</a>(0);
    print(&all);

    <b>let</b> v = <a href="Wallet.md#0x1_Wallet_list_tx_by_epoch">Wallet::list_tx_by_epoch</a>(epoch);
    <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;(&v);
    print(&len);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      print(&990201);
        <b>let</b> t: <a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a> = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&v, i);
        // TODO: Is this the best way <b>to</b> access a <b>struct</b> property from
        // outside a <b>module</b>?
        <b>let</b> (payer, payee, value, description) = <a href="Wallet.md#0x1_Wallet_get_tx_args">Wallet::get_tx_args</a>(*&t);
        <b>if</b> (<a href="Wallet.md#0x1_Wallet_is_frozen">Wallet::is_frozen</a>(payer)) {
          i = i + 1;
          <b>continue</b>
        };
        print(&990202);
        <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">vm_make_payment_no_limit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(payer, payee, value, description, b"", vm);
        print(&990203);
        <a href="Wallet.md#0x1_Wallet_mark_processed">Wallet::mark_processed</a>(vm, t);
        <a href="Wallet.md#0x1_Wallet_reset_rejection_counter">Wallet::reset_rejection_counter</a>(vm, payer);
        print(&990204);
        i = i + 1;
    };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_vm_make_payment_no_limit"></a>

## Function `vm_make_payment_no_limit`

This function bypasses transaction limits.
vm_make_payment on the other hand considers payment limits.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">vm_make_payment_no_limit</a>&lt;Token: store&gt;(payer: address, payee: address, amount: u64, metadata: vector&lt;u8&gt;, metadata_signature: vector&lt;u8&gt;, vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">vm_make_payment_no_limit</a>&lt;Token: store&gt;(
    payer : address,
    payee: address,
    amount: u64,
    metadata: vector&lt;u8&gt;,
    metadata_signature: vector&lt;u8&gt;,
    vm: &signer
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()) <b>return</b>;
    // don't try <b>to</b> send a 0 balance, will halt.
    <b>if</b> (amount &lt; 1) <b>return</b>;

    // Check payee can receive funds in this currency.
    <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee)) <b>return</b>;
    // <b>assert</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EROLE_CANT_STORE_BALANCE">EROLE_CANT_STORE_BALANCE</a>));

    // Check there is a payer
    <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payer)) <b>return</b>;
    // <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payer), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));

    // Check the payer is in possession of withdraw token.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(payer)) <b>return</b>;

    // TODO: review this in 5.1
    // VM should not force an account below 1GAS, since the account may not recover.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(payer) &lt; <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>) <b>return</b>;

    // prevent halting on low balance.
    // burn the remaining balance <b>if</b> the amount is greater than balance
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(payer) &lt; amount) {
      amount = <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(payer);
    };


    // VM can extract the withdraw token.
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
    <b>let</b> cap = <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> account.withdraw_capability);
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>&lt;Token&gt;(
        cap.account_address,
        payee,
        <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>(&cap, payee, amount, <b>copy</b> metadata),
        metadata,
        metadata_signature
    );

    <a href="Receipts.md#0x1_Receipts_write_receipt">Receipts::write_receipt</a>(vm, payer, payee, amount);

    <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">restore_withdraw_capability</a>(cap);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_vm_burn_from_balance"></a>

## Function `vm_burn_from_balance`

VM can burn from an account's balance for administrative purposes (e.g. at epoch boundaries)


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_burn_from_balance">vm_burn_from_balance</a>&lt;Token: store&gt;(addr: address, amount: u64, metadata: vector&lt;u8&gt;, vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_burn_from_balance">vm_burn_from_balance</a>&lt;Token: store&gt;(
    addr : address,
    amount: u64,
    metadata: vector&lt;u8&gt;,
    vm: &signer
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()) <b>return</b>;
    // don't try <b>to</b> send a 0 balance, will halt.
    <b>if</b> (amount &lt; 1) <b>return</b>;
    // Check there is a payer and has balance
    <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr)) <b>return</b>;
    <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)) <b>return</b>;

    // TODO: review this in 5.1
    // VM should not force an account below 1GAS, since the account may not recover.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr) &lt; <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>) <b>return</b>;

    // prevent halting on low balance.
    // burn the remaining balance <b>if</b> the amount is greater than balance
    // but leave 1GAS <b>to</b> be able <b>to</b> recover
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr) &lt; amount) {
      amount = <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr);
    };

    // Check the payer is in possession of withdraw token.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(addr)) <b>return</b>;

    // VM can extract the withdraw token.
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr);
    <b>let</b> cap = <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> account.withdraw_capability);
    <b>let</b> coin = <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>&lt;Token&gt;(&cap, addr, amount, <b>copy</b> metadata);
    <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>&lt;Token&gt;(vm, coin);
    <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">restore_withdraw_capability</a>(cap);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_pay_from"></a>

## Function `pay_from`

Withdraw <code>amount</code> Diem<Token> from the address embedded in <code><a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a></code> and
deposits it into the <code>payee</code>'s account balance.
The included <code>metadata</code> will appear in the <code><a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a></code> and <code><a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a></code>.
The <code>metadata_signature</code> will only be checked if this payment is
subject to the dual attestation protocol


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_pay_from">pay_from</a>&lt;Token: store&gt;(cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>, payee: address, amount: u64, metadata: vector&lt;u8&gt;, metadata_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_pay_from">pay_from</a>&lt;Token: store&gt;(
    cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>,
    payee: address,
    amount: u64,
    metadata: vector&lt;u8&gt;,
    metadata_signature: vector&lt;u8&gt;
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {

    // check amount <b>if</b> it is a slow wallet
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_is_slow">is_slow</a>(*&cap.account_address)) {
      <b>assert</b>(
            amount &lt; <a href="DiemAccount.md#0x1_DiemAccount_unlocked_amount">unlocked_amount</a>(*&cap.account_address),
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWITHDRAWAL_SLOW_WAL_EXCEEDS_UNLOCKED_LIMIT">EWITHDRAWAL_SLOW_WAL_EXCEEDS_UNLOCKED_LIMIT</a>)
        );

    };
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>&lt;Token&gt;(
        *&cap.account_address,
        payee,
        <a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">withdraw_from</a>(cap, payee, amount, <b>copy</b> metadata),
        metadata,
        metadata_signature
    );
    // in case of slow wallet <b>update</b> the tracker
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_is_slow">is_slow</a>(*&cap.account_address)) {
      <a href="DiemAccount.md#0x1_DiemAccount_decrease_unlocked_tracker">decrease_unlocked_tracker</a>(*&cap.account_address, amount);
    };

    // <b>if</b> a payee is a slow wallet and is receiving funds from ordinary or another slow wallet's unlocked funds, it counts toward unlocked coins.
    // the exceptional case is community wallets, which funds don't count toward unlocks.
    <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_is_slow">is_slow</a>(*&payee) && !<a href="Wallet.md#0x1_Wallet_is_comm">Wallet::is_comm</a>(*&cap.account_address)) {
      <a href="DiemAccount.md#0x1_DiemAccount_increase_unlocked_tracker">increase_unlocked_tracker</a>(*&payee, amount);
    };


}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> payer = cap.account_address;
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee);
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payer));
<b>modifies</b> <b>global</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_Window">AccountLimits::Window</a>&lt;Token&gt;&gt;(<a href="VASP.md#0x1_VASP_spec_parent_address">VASP::spec_parent_address</a>(payee));
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payer);
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(payee);
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer);
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payee);
<b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability
    == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).withdraw_capability);
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payer).received_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).sent_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).sent_events));
<b>ensures</b> <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_spec_guid_eq">Event::spec_guid_eq</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events,
                            <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(payee).received_events));
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromAbortsIf">PayFromAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromEnsures">PayFromEnsures</a>&lt;Token&gt;{payer};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromEmits">PayFromEmits</a>&lt;Token&gt;;
</code></pre>




<a name="0x1_DiemAccount_PayFromAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromAbortsIf">PayFromAbortsIf</a>&lt;Token&gt; {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    payee: address;
    amount: u64;
    metadata: vector&lt;u8&gt;;
    metadata_signature: vector&lt;u8&gt;;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIf">DepositAbortsIf</a>&lt;Token&gt;{payer: cap.account_address};
    <b>include</b> cap.account_address != payee ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_DepositOverflowAbortsIf">DepositOverflowAbortsIf</a>&lt;Token&gt;;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromAbortsIf">WithdrawFromAbortsIf</a>&lt;Token&gt;;
}
</code></pre>




<a name="0x1_DiemAccount_PayFromAbortsIfRestricted"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromAbortsIfRestricted">PayFromAbortsIfRestricted</a>&lt;Token&gt; {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>;
    payee: address;
    amount: u64;
    metadata: vector&lt;u8&gt;;
    metadata_signature: vector&lt;u8&gt; ;
    <b>let</b> payer = cap.account_address;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_DepositAbortsIfRestricted">DepositAbortsIfRestricted</a>&lt;Token&gt;{payer: cap.account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WithdrawFromBalanceNoLimitsAbortsIf">WithdrawFromBalanceNoLimitsAbortsIf</a>&lt;Token&gt;{payer, balance: <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer)};
    <b>aborts_if</b> !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_PayFromEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PayFromEnsures">PayFromEnsures</a>&lt;Token&gt; {
    payer: address;
    payee: address;
    amount: u64;
    <b>ensures</b> payer == payee ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payer) == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payer));
    <b>ensures</b> payer != payee ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payer) == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payer)) - amount;
    <b>ensures</b> payer != payee ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payee) == <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(payee)) + amount;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_onboarding_gas_transfer"></a>

## Function `onboarding_gas_transfer`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;Token: store&gt;(payer_sig: &signer, payee: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;Token: store&gt;(
    payer_sig: &signer,
    payee: address,
    value: u64,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>let</b> payer_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(payer_sig);
    <b>let</b> account_balance = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(payer_addr);
    <b>let</b> balance_coin = &<b>mut</b> account_balance.coin;

    // value needs <b>to</b> be greater than boostrapping value
    <b>assert</b>(
        value &gt;= <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EBELOW_MINIMUM_VALUE_BOOTSTRAP_COIN">EBELOW_MINIMUM_VALUE_BOOTSTRAP_COIN</a>)
    );

    // Doubly check balance <b>exists</b>.
    <b>assert</b>(
        <a href="Diem.md#0x1_Diem_value">Diem::value</a>(balance_coin) &gt; value,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>)
    );
    // Should <b>abort</b> <b>if</b> the
    <b>let</b> metadata = b"onboarding coin transfer";
    <b>let</b> coin_to_deposit = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(balance_coin, value);
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>&lt;Token&gt;(
        payer_addr,
        payee,
        coin_to_deposit,
        metadata,
        b""
    );
}
</code></pre>



</details>

<a name="0x1_DiemAccount_genesis_fund_operator"></a>

## Function `genesis_fund_operator`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_genesis_fund_operator">genesis_fund_operator</a>(vm: &signer, owner_sig: &signer, oper: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_genesis_fund_operator">genesis_fund_operator</a>(
  vm: &signer,
  owner_sig: &signer,
  oper: address,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <a href="DiemAccount.md#0x1_DiemAccount_onboarding_gas_transfer">onboarding_gas_transfer</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(owner_sig, oper, <a href="DiemAccount.md#0x1_DiemAccount_BOOTSTRAP_COIN_VALUE">BOOTSTRAP_COIN_VALUE</a>);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_rotate_authentication_key"></a>

## Function `rotate_authentication_key`

Rotate the authentication key for the account under cap.account_address


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">rotate_authentication_key</a>(cap: &<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">DiemAccount::KeyRotationCapability</a>, new_authentication_key: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">rotate_authentication_key</a>(
    cap: &<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>,
    new_authentication_key: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>  {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap.account_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>let</b> sender_account_resource = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap.account_address);
    // Don't allow rotating <b>to</b> clearly invalid key
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&new_authentication_key) == 32,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_EMALFORMED_AUTHENTICATION_KEY">EMALFORMED_AUTHENTICATION_KEY</a>)
    );
    sender_account_resource.authentication_key = new_authentication_key;
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateAuthenticationKeyAbortsIf">RotateAuthenticationKeyAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateAuthenticationKeyEnsures">RotateAuthenticationKeyEnsures</a>{addr: cap.account_address};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateOnlyKeyOfCapAddress">RotateOnlyKeyOfCapAddress</a>;
</code></pre>




<a name="0x1_DiemAccount_RotateAuthenticationKeyAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateAuthenticationKeyAbortsIf">RotateAuthenticationKeyAbortsIf</a> {
    cap: &<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>;
    new_authentication_key: vector&lt;u8&gt;;
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap.account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>aborts_if</b> len(new_authentication_key) != 32 <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>




<a name="0x1_DiemAccount_RotateAuthenticationKeyEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateAuthenticationKeyEnsures">RotateAuthenticationKeyEnsures</a> {
    addr: address;
    new_authentication_key: vector&lt;u8&gt;;
    <b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key == new_authentication_key;
}
</code></pre>



<a name="@Access_Control_2"></a>

### Access Control



<a name="0x1_DiemAccount_RotateOnlyKeyOfCapAddress"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateOnlyKeyOfCapAddress">RotateOnlyKeyOfCapAddress</a> {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>;
}
</code></pre>


Can only rotate the authentication_key of cap.account_address [[H18]][PERMISSION].


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RotateOnlyKeyOfCapAddress">RotateOnlyKeyOfCapAddress</a> {
    <b>ensures</b> <b>forall</b> addr: address <b>where</b> addr != cap.account_address && <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr)):
        <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_extract_key_rotation_capability"></a>

## Function `extract_key_rotation_capability`

Return a unique capability granting permission to rotate the sender's authentication key


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">extract_key_rotation_capability</a>(account: &signer): <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">DiemAccount::KeyRotationCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_extract_key_rotation_capability">extract_key_rotation_capability</a>(account: &signer): <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>
<b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>let</b> account_address = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    // Abort <b>if</b> we already extracted the unique key rotation capability for this account.
    <b>assert</b>(
        !<a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(account_address),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_EKEY_ROTATION_CAPABILITY_ALREADY_EXTRACTED">EKEY_ROTATION_CAPABILITY_ALREADY_EXTRACTED</a>)
    );
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(account_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(account_address);
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> account.key_rotation_capability)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractKeyRotationCapabilityAbortsIf">ExtractKeyRotationCapabilityAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractKeyRotationCapabilityEnsures">ExtractKeyRotationCapabilityEnsures</a>;
</code></pre>




<a name="0x1_DiemAccount_ExtractKeyRotationCapabilityAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractKeyRotationCapabilityAbortsIf">ExtractKeyRotationCapabilityAbortsIf</a> {
    account: signer;
    <b>let</b> account_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account);
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(account_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AbortsIfDelegatedKeyRotationCapability">AbortsIfDelegatedKeyRotationCapability</a>;
}
</code></pre>




<a name="0x1_DiemAccount_AbortsIfDelegatedKeyRotationCapability"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AbortsIfDelegatedKeyRotationCapability">AbortsIfDelegatedKeyRotationCapability</a> {
    account: signer;
    <b>aborts_if</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account)) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
}
</code></pre>




<a name="0x1_DiemAccount_ExtractKeyRotationCapabilityEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ExtractKeyRotationCapabilityEnsures">ExtractKeyRotationCapabilityEnsures</a> {
    account: signer;
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account));
}
</code></pre>



</details>

<a name="0x1_DiemAccount_restore_key_rotation_capability"></a>

## Function `restore_key_rotation_capability`

Return the key rotation capability to the account it originally came from


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">restore_key_rotation_capability</a>(cap: <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">DiemAccount::KeyRotationCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_restore_key_rotation_capability">restore_key_rotation_capability</a>(cap: <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>)
<b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap.account_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>let</b> account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(cap.account_address);
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> account.key_rotation_capability, cap)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_RestoreKeyRotationCapabilityAbortsIf">RestoreKeyRotationCapabilityAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_RestoreKeyRotationCapabilityEnsures">RestoreKeyRotationCapabilityEnsures</a>;
</code></pre>




<a name="0x1_DiemAccount_RestoreKeyRotationCapabilityAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RestoreKeyRotationCapabilityAbortsIf">RestoreKeyRotationCapabilityAbortsIf</a> {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>;
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(cap.account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(cap.account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>




<a name="0x1_DiemAccount_RestoreKeyRotationCapabilityEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_RestoreKeyRotationCapabilityEnsures">RestoreKeyRotationCapabilityEnsures</a> {
    cap: <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>;
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(cap.account_address);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_add_currencies_for_account"></a>

## Function `add_currencies_for_account`

Add balances for <code>Token</code> to <code>new_account</code>.  If <code>add_all_currencies</code> is true,
then add for both token types.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;Token: store&gt;(new_account: &signer, add_all_currencies: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;Token: store&gt;(
    new_account: &signer,
    add_all_currencies: bool,
) {
    <b>let</b> new_account_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(new_account);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currency">add_currency</a>&lt;Token&gt;(new_account);
    <b>if</b> (add_all_currencies) {
        /////// 0L /////////
        // <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;&gt;(new_account_addr)) {
        //     <a href="DiemAccount.md#0x1_DiemAccount_add_currency">add_currency</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;(new_account);
        // };
        <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(new_account_addr)) {
            <a href="DiemAccount.md#0x1_DiemAccount_add_currency">add_currency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account);
        };
    };
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> new_account_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(new_account);
<b>aborts_if</b> !<a href="Roles.md#0x1_Roles_spec_can_hold_balance_addr">Roles::spec_can_hold_balance_addr</a>(new_account_addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountAbortsIf">AddCurrencyForAccountAbortsIf</a>&lt;Token&gt;{addr: new_account_addr};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountEnsures">AddCurrencyForAccountEnsures</a>&lt;Token&gt;{addr: new_account_addr};
</code></pre>




<a name="0x1_DiemAccount_AddCurrencyForAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountAbortsIf">AddCurrencyForAccountAbortsIf</a>&lt;Token&gt; {
    addr: address;
    add_all_currencies: bool;
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;Token&gt;;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>include</b> add_all_currencies && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;&gt;(addr)
        ==&gt; <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;;
    <b>include</b> add_all_currencies && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(addr) /////// 0L /////////
        ==&gt; <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;;
}
</code></pre>




<a name="0x1_DiemAccount_AddCurrencyForAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountEnsures">AddCurrencyForAccountEnsures</a>&lt;Token&gt; {
    addr: address;
    add_all_currencies: bool;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;Token&gt;;
    <b>include</b> add_all_currencies && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;&gt;(addr)
        ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;;
    <b>include</b> add_all_currencies && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(addr) /////// 0L /////////
        ==&gt; <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_make_account"></a>

## Function `make_account`

Creates a new account with account at <code>new_account_address</code> with
authentication key <code>auth_key_prefix</code> | <code>fresh_address</code>.
Aborts if there is already an account at <code>new_account_address</code>.

Creating an account at address 0x0 will abort as it is a reserved address for the MoveVM.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account: signer, auth_key_prefix: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(
    new_account: signer,
    auth_key_prefix: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>let</b> new_account_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&new_account);

    /////// 0L /////////
    // // cannot create an account at the reserved address 0x0
    // <b>assert</b>(
    //     new_account_addr != <a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>(),
    //     <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_ECANNOT_CREATE_AT_VM_RESERVED">ECANNOT_CREATE_AT_VM_RESERVED</a>)
    // );

    <b>assert</b>(
        new_account_addr != <a href="CoreAddresses.md#0x1_CoreAddresses_CORE_CODE_ADDRESS">CoreAddresses::CORE_CODE_ADDRESS</a>(),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_ECANNOT_CREATE_AT_CORE_CODE">ECANNOT_CREATE_AT_CORE_CODE</a>)
    );

    // Construct authentication key.
    <b>let</b> authentication_key = <a href="DiemAccount.md#0x1_DiemAccount_create_authentication_key">create_authentication_key</a>(&new_account, auth_key_prefix);

    // Publish <a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a> (initially not frozen)
    <a href="AccountFreezing.md#0x1_AccountFreezing_create">AccountFreezing::create</a>(&new_account);
    // The <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> is published during <a href="Genesis.md#0x1_Genesis">Genesis</a>, so it should
    // always exist.  This is a sanity check.
    <b>assert</b>(
        <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT_OPERATIONS_CAPABILITY">EACCOUNT_OPERATIONS_CAPABILITY</a>)
    );
    // Emit the <a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">CreateAccountEvent</a>
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_emit_event">Event::emit_event</a>(
        &<b>mut</b> borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()).creation_events,
        <a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">CreateAccountEvent</a> { created: new_account_addr, role_id: <a href="Roles.md#0x1_Roles_get_role_id">Roles::get_role_id</a>(new_account_addr) },
    );
    // Publishing the account <b>resource</b> last makes it possible <b>to</b> prove invariants that simplify
    // <b>aborts_if</b>'s, etc.
    move_to(
        &new_account,
        <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
            authentication_key,
            withdraw_capability: <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_some">Option::some</a>(
                <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a> {
                    account_address: new_account_addr
            }),
            key_rotation_capability: <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_some">Option::some</a>(
                <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a> {
                    account_address: new_account_addr
            }),
            received_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_ReceivedPaymentEvent">ReceivedPaymentEvent</a>&gt;(&new_account),
            sent_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SentPaymentEvent">SentPaymentEvent</a>&gt;(&new_account),
            sequence_number: 0,
        }
    );

    <a href="Receipts.md#0x1_Receipts_init">Receipts::init</a>(&new_account);
    //////// 0L ////////
    // NOTE: <b>if</b> all accounts are <b>to</b> be slow set this
    // <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(&new_account);
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> new_account_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(new_account);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(new_account_addr);
<b>modifies</b> <b>global</b>&lt;<a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandleGenerator">Event::EventHandleGenerator</a>&gt;(new_account_addr);
<b>modifies</b> <b>global</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(new_account_addr);
<b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>requires</b> <b>exists</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(new_account_addr);
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_addr};
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_addr);
<b>ensures</b> <a href="AccountFreezing.md#0x1_AccountFreezing_spec_account_is_not_frozen">AccountFreezing::spec_account_is_not_frozen</a>(new_account_addr);
<b>let</b> account_ops_cap = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>let</b> post post_account_ops_cap = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>ensures</b> post_account_ops_cap == update_field(account_ops_cap, creation_events, account_ops_cap.creation_events);
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(new_account_addr);
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(new_account_addr);
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>{new_account_address: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(new_account)};
</code></pre>




<a name="0x1_DiemAccount_MakeAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a> {
    addr: address;
    auth_key_prefix: vector&lt;u8&gt;;
    <b>aborts_if</b> addr == <a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>aborts_if</b> addr == <a href="CoreAddresses.md#0x1_CoreAddresses_CORE_CODE_ADDRESS">CoreAddresses::CORE_CODE_ADDRESS</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_genesis">DiemTimestamp::is_genesis</a>()
        && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateAuthenticationKeyAbortsIf">CreateAuthenticationKeyAbortsIf</a>;
}
</code></pre>




<a name="0x1_DiemAccount_MakeAccountEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a> {
    new_account_address: address;
    <b>let</b> post handle = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()).creation_events;
    <b>let</b> post msg = <a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">CreateAccountEvent</a> {
        created: new_account_address,
        role_id: <a href="Roles.md#0x1_Roles_spec_get_role_id">Roles::spec_get_role_id</a>(new_account_address)
    };
    emits msg <b>to</b> handle;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_authentication_key"></a>

## Function `create_authentication_key`

Construct an authentication key, aborting if the prefix is not valid.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_authentication_key">create_authentication_key</a>(account: &signer, auth_key_prefix: vector&lt;u8&gt;): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_authentication_key">create_authentication_key</a>(account: &signer, auth_key_prefix: vector&lt;u8&gt;): vector&lt;u8&gt; {
    <b>let</b> authentication_key = auth_key_prefix;
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(
        &<b>mut</b> authentication_key, <a href="../../../../../../move-stdlib/docs/BCS.md#0x1_BCS_to_bytes">BCS::to_bytes</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_borrow_address">Signer::borrow_address</a>(account))
    );
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&authentication_key) == 32,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_EMALFORMED_AUTHENTICATION_KEY">EMALFORMED_AUTHENTICATION_KEY</a>)
    );
    authentication_key
}
</code></pre>



</details>

<details>
<summary>Specification</summary>


The specification of this function is abstracted to avoid the complexity of
vector concatenation of serialization results. The actual value of the key
is assumed to be irrelevant for callers. Instead the uninterpreted function
<code>spec_abstract_create_authentication_key</code> is used to represent the key value.
The aborts behavior is, however, preserved: the caller must provide a
key prefix of a specific length.


<pre><code><b>pragma</b> opaque;
<b>include</b> [abstract] <a href="DiemAccount.md#0x1_DiemAccount_CreateAuthenticationKeyAbortsIf">CreateAuthenticationKeyAbortsIf</a>;
<b>ensures</b> [abstract]
    result == <a href="DiemAccount.md#0x1_DiemAccount_spec_abstract_create_authentication_key">spec_abstract_create_authentication_key</a>(auth_key_prefix) &&
    len(result) == 32;
</code></pre>




<a name="0x1_DiemAccount_CreateAuthenticationKeyAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateAuthenticationKeyAbortsIf">CreateAuthenticationKeyAbortsIf</a> {
    auth_key_prefix: vector&lt;u8&gt;;
    <b>aborts_if</b> 16 + len(auth_key_prefix) != 32 <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>




<a name="0x1_DiemAccount_spec_abstract_create_authentication_key"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_abstract_create_authentication_key">spec_abstract_create_authentication_key</a>(auth_key_prefix: vector&lt;u8&gt;): vector&lt;u8&gt;;
</code></pre>



</details>

<a name="0x1_DiemAccount_create_diem_root_account"></a>

## Function `create_diem_root_account`

Creates the diem root account (during genesis). Publishes the Diem root role,
Publishes a SlidingNonce resource, sets up event generator, publishes
AccountOperationsCapability, WriteSetManager, and finally makes the account.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_diem_root_account">create_diem_root_account</a>(auth_key_prefix: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_diem_root_account">create_diem_root_account</a>(
    auth_key_prefix: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <b>let</b> dr_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(&dr_account);
    <a href="Roles.md#0x1_Roles_grant_diem_root_role">Roles::grant_diem_root_role</a>(&dr_account);
    <a href="SlidingNonce.md#0x1_SlidingNonce_publish">SlidingNonce::publish</a>(&dr_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&dr_account);

    <b>assert</b>(
        !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT_OPERATIONS_CAPABILITY">EACCOUNT_OPERATIONS_CAPABILITY</a>)
    );
    move_to(
        &dr_account,
        <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
            limits_cap: <a href="AccountLimits.md#0x1_AccountLimits_grant_mutation_capability">AccountLimits::grant_mutation_capability</a>(&dr_account),
            creation_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CreateAccountEvent">CreateAccountEvent</a>&gt;(&dr_account),
        }
    );
    <b>assert</b>(
        !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EWRITESET_MANAGER">EWRITESET_MANAGER</a>)
    );
    move_to(
        &dr_account,
        <a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a> {
            upgrade_events: <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">Self::AdminTransactionEvent</a>&gt;(&dr_account),
        }
    );
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(dr_account, <b>copy</b> auth_key_prefix);
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountModifies">CreateDiemRootAccountModifies</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountAbortsIf">CreateDiemRootAccountAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountEnsures">CreateDiemRootAccountEnsures</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>{new_account_address: <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()};
</code></pre>




<a name="0x1_DiemAccount_CreateDiemRootAccountModifies"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountModifies">CreateDiemRootAccountModifies</a> {
    <b>let</b> dr_addr = <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>();
    <b>modifies</b> <b>global</b>&lt;<a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandleGenerator">Event::EventHandleGenerator</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(dr_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(dr_addr);
}
</code></pre>




<a name="0x1_DiemAccount_CreateDiemRootAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountAbortsIf">CreateDiemRootAccountAbortsIf</a> {
    auth_key_prefix: vector&lt;u8&gt;;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
    <b>include</b> <a href="Roles.md#0x1_Roles_GrantRole">Roles::GrantRole</a>{addr: <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), role_id: <a href="Roles.md#0x1_Roles_DIEM_ROOT_ROLE_ID">Roles::DIEM_ROOT_ROLE_ID</a>};
    <b>aborts_if</b> <b>exists</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateAuthenticationKeyAbortsIf">CreateAuthenticationKeyAbortsIf</a>;
}
</code></pre>




<a name="0x1_DiemAccount_CreateDiemRootAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDiemRootAccountEnsures">CreateDiemRootAccountEnsures</a> {
    <b>let</b> dr_addr = <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>();
    <b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(dr_addr);
    <b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(dr_addr);
    <b>ensures</b> <b>exists</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(dr_addr);
    <b>ensures</b> <a href="Roles.md#0x1_Roles_spec_has_diem_root_role_addr">Roles::spec_has_diem_root_role_addr</a>(dr_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(dr_addr);
    <b>ensures</b> <a href="AccountFreezing.md#0x1_AccountFreezing_spec_account_is_not_frozen">AccountFreezing::spec_account_is_not_frozen</a>(dr_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(dr_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(dr_addr);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_treasury_compliance_account"></a>

## Function `create_treasury_compliance_account`

Create a treasury/compliance account at <code>new_account_address</code> with authentication key
<code>auth_key_prefix</code> | <code>new_account_address</code>.  Can only be called during genesis.
Also, publishes the treasury compliance role, the SlidingNonce resource, and
event handle generator, then makes the account.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_treasury_compliance_account">create_treasury_compliance_account</a>(dr_account: &signer, auth_key_prefix: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_treasury_compliance_account">create_treasury_compliance_account</a>(
    dr_account: &signer,
    auth_key_prefix: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account);
    <b>let</b> new_account_address = <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>();
    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="Roles.md#0x1_Roles_grant_treasury_compliance_role">Roles::grant_treasury_compliance_role</a>(&new_account, dr_account);
    <a href="SlidingNonce.md#0x1_SlidingNonce_publish">SlidingNonce::publish</a>(&new_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_account);
    <a href="DiemId.md#0x1_DiemId_publish_diem_id_domain_manager">DiemId::publish_diem_id_domain_manager</a>(&new_account);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account, auth_key_prefix)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque;
<b>let</b> tc_addr = <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>();
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountModifies">CreateTreasuryComplianceAccountModifies</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountAbortsIf">CreateTreasuryComplianceAccountAbortsIf</a>;
<b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotDiemRoot">Roles::AbortsIfNotDiemRoot</a>{account: dr_account};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>()};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountEnsures">CreateTreasuryComplianceAccountEnsures</a>;
<b>let</b> account_ops_cap = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>let</b> post post_account_ops_cap = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
<b>ensures</b> post_account_ops_cap == update_field(account_ops_cap, creation_events, account_ops_cap.creation_events);
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>{new_account_address: <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>()};
<b>aborts_if</b> <a href="DiemId.md#0x1_DiemId_tc_domain_manager_exists">DiemId::tc_domain_manager_exists</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateTreasuryComplianceAccountModifies"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountModifies">CreateTreasuryComplianceAccountModifies</a> {
    <b>let</b> tc_addr = <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>();
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(tc_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(tc_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(tc_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(tc_addr);
    <b>modifies</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
    <b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
    <b>modifies</b> <b>global</b>&lt;<a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_EventHandleGenerator">Event::EventHandleGenerator</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>());
    <b>modifies</b> <b>global</b>&lt;<a href="DiemId.md#0x1_DiemId_DiemIdDomainManager">DiemId::DiemIdDomainManager</a>&gt;(tc_addr);
}
</code></pre>




<a name="0x1_DiemAccount_CreateTreasuryComplianceAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountAbortsIf">CreateTreasuryComplianceAccountAbortsIf</a> {
    dr_account: signer;
    auth_key_prefix: vector&lt;u8&gt;;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
    <b>include</b> <a href="Roles.md#0x1_Roles_GrantRole">Roles::GrantRole</a>{addr: <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>(), role_id: <a href="Roles.md#0x1_Roles_TREASURY_COMPLIANCE_ROLE_ID">Roles::TREASURY_COMPLIANCE_ROLE_ID</a>};
    <b>aborts_if</b> <b>exists</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>())
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <a href="DiemId.md#0x1_DiemId_tc_domain_manager_exists">DiemId::tc_domain_manager_exists</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_CreateTreasuryComplianceAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateTreasuryComplianceAccountEnsures">CreateTreasuryComplianceAccountEnsures</a> {
    <b>let</b> tc_addr = <a href="CoreAddresses.md#0x1_CoreAddresses_TREASURY_COMPLIANCE_ADDRESS">CoreAddresses::TREASURY_COMPLIANCE_ADDRESS</a>();
    <b>ensures</b> <a href="Roles.md#0x1_Roles_spec_has_treasury_compliance_role_addr">Roles::spec_has_treasury_compliance_role_addr</a>(tc_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(tc_addr);
    <b>ensures</b> <b>exists</b>&lt;<a href="SlidingNonce.md#0x1_SlidingNonce_SlidingNonce">SlidingNonce::SlidingNonce</a>&gt;(tc_addr);
    <b>ensures</b> <a href="AccountFreezing.md#0x1_AccountFreezing_spec_account_is_not_frozen">AccountFreezing::spec_account_is_not_frozen</a>(tc_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(tc_addr);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(tc_addr);
    <b>ensures</b> <b>exists</b>&lt;<a href="DiemId.md#0x1_DiemId_DiemIdDomainManager">DiemId::DiemIdDomainManager</a>&gt;(tc_addr);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_designated_dealer"></a>

## Function `create_designated_dealer`

Create a designated dealer account at <code>new_account_address</code> with authentication key
<code>auth_key_prefix</code> | <code>new_account_address</code>, for non synthetic CoinType.
Creates Preburn resource under account 'new_account_address'


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_designated_dealer">create_designated_dealer</a>&lt;CoinType: store&gt;(creator_account: &signer, new_account_address: address, auth_key_prefix: vector&lt;u8&gt;, human_name: vector&lt;u8&gt;, add_all_currencies: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_designated_dealer">create_designated_dealer</a>&lt;CoinType: store&gt;(
    creator_account: &signer,
    new_account_address: address,
    auth_key_prefix: vector&lt;u8&gt;,
    human_name: vector&lt;u8&gt;,
    add_all_currencies: bool,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>let</b> new_dd_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_dd_account);
    <a href="Roles.md#0x1_Roles_new_designated_dealer_role">Roles::new_designated_dealer_role</a>(creator_account, &new_dd_account);
    <a href="DesignatedDealer.md#0x1_DesignatedDealer_publish_designated_dealer_credential">DesignatedDealer::publish_designated_dealer_credential</a>&lt;CoinType&gt;(&new_dd_account, creator_account, add_all_currencies);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;CoinType&gt;(&new_dd_account, add_all_currencies);
    <a href="DualAttestation.md#0x1_DualAttestation_publish_credential">DualAttestation::publish_credential</a>(&new_dd_account, creator_account, human_name);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_dd_account, auth_key_prefix)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDesignatedDealerAbortsIf">CreateDesignatedDealerAbortsIf</a>&lt;CoinType&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDesignatedDealerEnsures">CreateDesignatedDealerEnsures</a>&lt;CoinType&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateDesignatedDealerAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDesignatedDealerAbortsIf">CreateDesignatedDealerAbortsIf</a>&lt;CoinType&gt; {
    creator_account: signer;
    new_account_address: address;
    auth_key_prefix: vector&lt;u8&gt;;
    add_all_currencies: bool;
    <b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: creator_account};
    <b>aborts_if</b> <b>exists</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="DesignatedDealer.md#0x1_DesignatedDealer_Dealer">DesignatedDealer::Dealer</a>&gt;(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>include</b> <b>if</b> (add_all_currencies) <a href="DesignatedDealer.md#0x1_DesignatedDealer_AddCurrencyAbortsIf">DesignatedDealer::AddCurrencyAbortsIf</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;{dd_addr: new_account_address}
            <b>else</b> <a href="DesignatedDealer.md#0x1_DesignatedDealer_AddCurrencyAbortsIf">DesignatedDealer::AddCurrencyAbortsIf</a>&lt;CoinType&gt;{dd_addr: new_account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountAbortsIf">AddCurrencyForAccountAbortsIf</a>&lt;CoinType&gt;{addr: new_account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_address};
}
</code></pre>




<a name="0x1_DiemAccount_CreateDesignatedDealerEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateDesignatedDealerEnsures">CreateDesignatedDealerEnsures</a>&lt;CoinType&gt; {
    new_account_address: address;
    <b>ensures</b> <b>exists</b>&lt;<a href="DesignatedDealer.md#0x1_DesignatedDealer_Dealer">DesignatedDealer::Dealer</a>&gt;(new_account_address);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address);
    <b>ensures</b> <a href="Roles.md#0x1_Roles_spec_has_designated_dealer_role_addr">Roles::spec_has_designated_dealer_role_addr</a>(new_account_address);
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountEnsures">AddCurrencyForAccountEnsures</a>&lt;CoinType&gt;{addr: new_account_address};
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_parent_vasp_account"></a>

## Function `create_parent_vasp_account`

Create an account with the ParentVASP role at <code>new_account_address</code> with authentication key
<code>auth_key_prefix</code> | <code>new_account_address</code>.  If <code>add_all_currencies</code> is true, 0 balances for
all available currencies in the system will also be added.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_parent_vasp_account">create_parent_vasp_account</a>&lt;Token: store&gt;(creator_account: &signer, new_account_address: address, auth_key_prefix: vector&lt;u8&gt;, human_name: vector&lt;u8&gt;, add_all_currencies: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_parent_vasp_account">create_parent_vasp_account</a>&lt;Token: store&gt;(
    creator_account: &signer,  // TreasuryCompliance
    new_account_address: address,
    auth_key_prefix: vector&lt;u8&gt;,
    human_name: vector&lt;u8&gt;,
    add_all_currencies: bool
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="Roles.md#0x1_Roles_new_parent_vasp_role">Roles::new_parent_vasp_role</a>(creator_account, &new_account);
    <a href="VASP.md#0x1_VASP_publish_parent_vasp_credential">VASP::publish_parent_vasp_credential</a>(&new_account, creator_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_account);
    <a href="DualAttestation.md#0x1_DualAttestation_publish_credential">DualAttestation::publish_credential</a>(&new_account, creator_account, human_name);
    <a href="DiemId.md#0x1_DiemId_publish_diem_id_domains">DiemId::publish_diem_id_domains</a>(&new_account);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;Token&gt;(&new_account, add_all_currencies);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account, auth_key_prefix)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateParentVASPAccountAbortsIf">CreateParentVASPAccountAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateParentVASPAccountEnsures">CreateParentVASPAccountEnsures</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateParentVASPAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateParentVASPAccountAbortsIf">CreateParentVASPAccountAbortsIf</a>&lt;Token&gt; {
    creator_account: signer;
    new_account_address: address;
    auth_key_prefix: vector&lt;u8&gt;;
    add_all_currencies: bool;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: creator_account};
    <b>include</b> <a href="DiemId.md#0x1_DiemId_PublishDiemIdDomainsAbortsIf">DiemId::PublishDiemIdDomainsAbortsIf</a>{vasp_addr: new_account_address};
    <b>aborts_if</b> <b>exists</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>aborts_if</b> <a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountAbortsIf">AddCurrencyForAccountAbortsIf</a>&lt;Token&gt;{addr: new_account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_address};
}
</code></pre>




<a name="0x1_DiemAccount_CreateParentVASPAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateParentVASPAccountEnsures">CreateParentVASPAccountEnsures</a>&lt;Token&gt; {
    new_account_address: address;
    <b>include</b> <a href="VASP.md#0x1_VASP_PublishParentVASPEnsures">VASP::PublishParentVASPEnsures</a>{vasp_addr: new_account_address};
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address);
    <b>ensures</b> <a href="Roles.md#0x1_Roles_spec_has_parent_VASP_role_addr">Roles::spec_has_parent_VASP_role_addr</a>(new_account_address);
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountEnsures">AddCurrencyForAccountEnsures</a>&lt;Token&gt;{addr: new_account_address};
    <b>include</b> <a href="DiemId.md#0x1_DiemId_PublishDiemIdDomainsEnsures">DiemId::PublishDiemIdDomainsEnsures</a>{ vasp_addr: new_account_address };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_child_vasp_account"></a>

## Function `create_child_vasp_account`

Create an account with the ChildVASP role at <code>new_account_address</code> with authentication key
<code>auth_key_prefix</code> | <code>new_account_address</code> and a 0 balance of type <code>Token</code>. If
<code>add_all_currencies</code> is true, 0 balances for all avaialable currencies in the system will
also be added. This account will be a child of <code>creator</code>, which must be a ParentVASP.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_child_vasp_account">create_child_vasp_account</a>&lt;Token: store&gt;(parent: &signer, new_account_address: address, auth_key_prefix: vector&lt;u8&gt;, add_all_currencies: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_child_vasp_account">create_child_vasp_account</a>&lt;Token: store&gt;(
    parent: &signer,
    new_account_address: address,
    auth_key_prefix: vector&lt;u8&gt;,
    add_all_currencies: bool,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    <a href="Roles.md#0x1_Roles_new_child_vasp_role">Roles::new_child_vasp_role</a>(parent, &new_account);
    <a href="VASP.md#0x1_VASP_publish_child_vasp_credential">VASP::publish_child_vasp_credential</a>(
        parent,
        &new_account,
    );
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_account);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;Token&gt;(&new_account, add_all_currencies);
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account, auth_key_prefix)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateChildVASPAccountAbortsIf">CreateChildVASPAccountAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateChildVASPAccountEnsures">CreateChildVASPAccountEnsures</a>&lt;Token&gt;{
    parent_addr: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(parent),
    child_addr: new_account_address,
};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountEnsures">AddCurrencyForAccountEnsures</a>&lt;Token&gt;{addr: new_account_address};
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateChildVASPAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateChildVASPAccountAbortsIf">CreateChildVASPAccountAbortsIf</a>&lt;Token&gt; {
    parent: signer;
    new_account_address: address;
    auth_key_prefix: vector&lt;u8&gt;;
    add_all_currencies: bool;
    <b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotParentVasp">Roles::AbortsIfNotParentVasp</a>{account: parent};
    <b>aborts_if</b> <b>exists</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
    <b>include</b> <a href="VASP.md#0x1_VASP_PublishChildVASPAbortsIf">VASP::PublishChildVASPAbortsIf</a>{child_addr: new_account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyForAccountAbortsIf">AddCurrencyForAccountAbortsIf</a>&lt;Token&gt;{addr: new_account_address};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_address};
}
</code></pre>




<a name="0x1_DiemAccount_CreateChildVASPAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateChildVASPAccountEnsures">CreateChildVASPAccountEnsures</a>&lt;Token&gt; {
    parent_addr: address;
    child_addr: address;
    add_all_currencies: bool;
    <b>include</b> <a href="VASP.md#0x1_VASP_PublishChildVASPEnsures">VASP::PublishChildVASPEnsures</a>;
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(child_addr);
    <b>ensures</b> <a href="Roles.md#0x1_Roles_spec_has_child_VASP_role_addr">Roles::spec_has_child_VASP_role_addr</a>(child_addr);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_signer"></a>

## Function `create_signer`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(addr: address): signer
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(addr: address): signer;
</code></pre>



</details>

<a name="0x1_DiemAccount_balance_for"></a>

## Function `balance_for`

Helper to return the u64 value of the <code>balance</code> for <code>account</code>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_balance_for">balance_for</a>&lt;Token: store&gt;(balance: &<a href="DiemAccount.md#0x1_DiemAccount_Balance">DiemAccount::Balance</a>&lt;Token&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_balance_for">balance_for</a>&lt;Token: store&gt;(balance: &<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;): u64 {
    <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;Token&gt;(&balance.coin)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_balance"></a>

## Function `balance`

Return the current balance of the account at <code>addr</code>.
0L change, return zero if it doesn't hold balance. In case the VM calls this on a bad account it won't halt


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token: store&gt;(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token: store&gt;(addr: address): u64 <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    // <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)) { <b>return</b> 0 };
    <b>assert</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EPAYER_DOESNT_HOLD_CURRENCY">EPAYER_DOESNT_HOLD_CURRENCY</a>));
    <a href="DiemAccount.md#0x1_DiemAccount_balance_for">balance_for</a>(borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr))
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>aborts_if</b> !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_NOT_PUBLISHED">Errors::NOT_PUBLISHED</a>;
</code></pre>



</details>

<a name="0x1_DiemAccount_add_currency"></a>

## Function `add_currency`

Add a balance of <code>Token</code> type to the sending account


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_add_currency">add_currency</a>&lt;Token: store&gt;(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_add_currency">add_currency</a>&lt;Token: store&gt;(account: &signer) {
    // aborts <b>if</b> `Token` is not a currency type in the system
    <a href="Diem.md#0x1_Diem_assert_is_currency">Diem::assert_is_currency</a>&lt;Token&gt;();

    /////// 0L /////////
    // // Check that an account <b>with</b> this role is allowed <b>to</b> hold funds
    // <b>assert</b>(
    //     <a href="Roles.md#0x1_Roles_can_hold_balance">Roles::can_hold_balance</a>(account),
    //     <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_EROLE_CANT_STORE_BALANCE">EROLE_CANT_STORE_BALANCE</a>)
    // );

    // aborts <b>if</b> this account already has a balance in `Token`
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>assert</b>(!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EADD_EXISTING_CURRENCY">EADD_EXISTING_CURRENCY</a>));

    move_to(account, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;{ coin: <a href="Diem.md#0x1_Diem_zero">Diem::zero</a>&lt;Token&gt;() })
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyAbortsIf">AddCurrencyAbortsIf</a>&lt;Token&gt;;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;Token&gt;{addr: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account)};
</code></pre>




<a name="0x1_DiemAccount_AddCurrencyAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyAbortsIf">AddCurrencyAbortsIf</a>&lt;Token&gt; {
    account: signer;
}
</code></pre>


<code>Currency</code> must be valid


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyAbortsIf">AddCurrencyAbortsIf</a>&lt;Token&gt; {
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;Token&gt;;
}
</code></pre>


<code>account</code> cannot have an existing balance in <code>Currency</code>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyAbortsIf">AddCurrencyAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account)) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
}
</code></pre>


<code>account</code> must be allowed to hold balances.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyAbortsIf">AddCurrencyAbortsIf</a>&lt;Token&gt; {
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_AbortsIfAccountCantHoldBalance">AbortsIfAccountCantHoldBalance</a>;
}
</code></pre>




<a name="0x1_DiemAccount_AddCurrencyEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;Token&gt; {
    addr: address;
}
</code></pre>


This publishes a <code><a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Currency&gt;</code> to the caller's account


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AddCurrencyEnsures">AddCurrencyEnsures</a>&lt;Token&gt; {
    <b>ensures</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr);
    <b>ensures</b> <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)
        == <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;{ coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt; { value: 0 } };
}
</code></pre>



<a name="@Access_Control_3"></a>

### Access Control



<a name="0x1_DiemAccount_AbortsIfAccountCantHoldBalance"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AbortsIfAccountCantHoldBalance">AbortsIfAccountCantHoldBalance</a> {
    account: signer;
}
</code></pre>


This function must abort if the predicate <code>can_hold_balance</code> for <code>account</code> returns false
[[D1]][ROLE][[D2]][ROLE][[D3]][ROLE][[D4]][ROLE][[D5]][ROLE][[D6]][ROLE][[D7]][ROLE].


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AbortsIfAccountCantHoldBalance">AbortsIfAccountCantHoldBalance</a> {
    <b>aborts_if</b> !<a href="Roles.md#0x1_Roles_can_hold_balance">Roles::can_hold_balance</a>(account) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_accepts_currency"></a>

## Function `accepts_currency`

Return whether the account at <code>addr</code> accepts <code>Token</code> type coins


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_accepts_currency">accepts_currency</a>&lt;Token: store&gt;(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_accepts_currency">accepts_currency</a>&lt;Token: store&gt;(addr: address): bool {
    <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_sequence_number_for_account"></a>

## Function `sequence_number_for_account`

Helper to return the sequence number field for given <code>account</code>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_sequence_number_for_account">sequence_number_for_account</a>(account: &<a href="DiemAccount.md#0x1_DiemAccount_DiemAccount">DiemAccount::DiemAccount</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_sequence_number_for_account">sequence_number_for_account</a>(account: &<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>): u64 {
    account.sequence_number
}
</code></pre>



</details>

<a name="0x1_DiemAccount_sequence_number"></a>

## Function `sequence_number`

Return the current sequence number at <code>addr</code>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_sequence_number">sequence_number</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_sequence_number">sequence_number</a>(addr: address): u64 <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <a href="DiemAccount.md#0x1_DiemAccount_sequence_number_for_account">sequence_number_for_account</a>(borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr))
}
</code></pre>



</details>

<a name="0x1_DiemAccount_authentication_key"></a>

## Function `authentication_key`

Return the authentication key for this account


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_authentication_key">authentication_key</a>(addr: address): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_authentication_key">authentication_key</a>(addr: address): vector&lt;u8&gt; <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    *&borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key
}
</code></pre>



</details>

<a name="0x1_DiemAccount_delegated_key_rotation_capability"></a>

## Function `delegated_key_rotation_capability`

Return true if the account at <code>addr</code> has delegated its key rotation capability


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(addr: address): bool
<b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(&borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).key_rotation_capability)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_delegated_withdraw_capability"></a>

## Function `delegated_withdraw_capability`

Return true if the account at <code>addr</code> has delegated its withdraw capability


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_delegated_withdraw_capability">delegated_withdraw_capability</a>(addr: address): bool
<b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> {
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(&borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).withdraw_capability)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_withdraw_capability_address"></a>

## Function `withdraw_capability_address`

Return a reference to the address associated with the given withdraw capability


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_capability_address">withdraw_capability_address</a>(cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>): &address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_withdraw_capability_address">withdraw_capability_address</a>(cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>): &address {
    &cap.account_address
}
</code></pre>



</details>

<a name="0x1_DiemAccount_key_rotation_capability_address"></a>

## Function `key_rotation_capability_address`

Return a reference to the address associated with the given key rotation capability


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_key_rotation_capability_address">key_rotation_capability_address</a>(cap: &<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">DiemAccount::KeyRotationCapability</a>): &address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_key_rotation_capability_address">key_rotation_capability_address</a>(cap: &<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>): &address {
    &cap.account_address
}
</code></pre>



</details>

<a name="0x1_DiemAccount_exists_at"></a>

## Function `exists_at`

Checks if an account exists at <code>check_addr</code>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(check_addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(check_addr: address): bool {
    <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(check_addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_module_prologue"></a>

## Function `module_prologue`

The prologue for module transaction


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_module_prologue">module_prologue</a>&lt;Token: store&gt;(sender: signer, txn_sequence_number: u64, txn_public_key: vector&lt;u8&gt;, txn_gas_price: u64, txn_max_gas_units: u64, txn_expiration_time: u64, chain_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_module_prologue">module_prologue</a>&lt;Token: store&gt;(
    sender: signer,
    txn_sequence_number: u64,
    txn_public_key: vector&lt;u8&gt;,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    txn_expiration_time: u64,
    chain_id: u8,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>assert</b>(
        <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_is_module_allowed">DiemTransactionPublishingOption::is_module_allowed</a>(&sender),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EMODULE_NOT_ALLOWED">PROLOGUE_EMODULE_NOT_ALLOWED</a>),
    );

    <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;Token&gt;(
        &sender,
        txn_sequence_number,
        txn_public_key,
        txn_gas_price,
        txn_max_gas_units,
        txn_expiration_time,
        chain_id,
    )
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
<b>let</b> max_transaction_fee = txn_gas_price * txn_max_gas_units;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_ModulePrologueAbortsIf">ModulePrologueAbortsIf</a>&lt;Token&gt; {
    max_transaction_fee,
    txn_expiration_time_seconds: txn_expiration_time,
};
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender);
</code></pre>




<a name="0x1_DiemAccount_ModulePrologueAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ModulePrologueAbortsIf">ModulePrologueAbortsIf</a>&lt;Token&gt; {
    sender: signer;
    txn_sequence_number: u64;
    txn_public_key: vector&lt;u8&gt;;
    chain_id: u8;
    max_transaction_fee: u128;
    txn_expiration_time_seconds: u64;
    <b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
        transaction_sender,
        txn_sequence_number,
        txn_public_key,
        chain_id,
        max_transaction_fee,
        txn_expiration_time_seconds,
    };
}
</code></pre>


Aborts only in genesis. Does not need to be handled.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ModulePrologueAbortsIf">ModulePrologueAbortsIf</a>&lt;Token&gt; {
    <b>include</b> <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_AbortsIfNoTransactionPublishingOption">DiemTransactionPublishingOption::AbortsIfNoTransactionPublishingOption</a>;
}
</code></pre>


Covered: L75 (Match 9)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ModulePrologueAbortsIf">ModulePrologueAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> !<a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_spec_is_module_allowed">DiemTransactionPublishingOption::spec_is_module_allowed</a>(sender) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_script_prologue"></a>

## Function `script_prologue`

The prologue for script transaction


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_script_prologue">script_prologue</a>&lt;Token: store&gt;(sender: signer, txn_sequence_number: u64, txn_public_key: vector&lt;u8&gt;, txn_gas_price: u64, txn_max_gas_units: u64, txn_expiration_time: u64, chain_id: u8, script_hash: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_script_prologue">script_prologue</a>&lt;Token: store&gt;(
    sender: signer,
    txn_sequence_number: u64,
    txn_public_key: vector&lt;u8&gt;,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    txn_expiration_time: u64,
    chain_id: u8,
    script_hash: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>assert</b>(
        <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_is_script_allowed">DiemTransactionPublishingOption::is_script_allowed</a>(&sender, &script_hash),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESCRIPT_NOT_ALLOWED">PROLOGUE_ESCRIPT_NOT_ALLOWED</a>),
    );

    <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;Token&gt;(
        &sender,
        txn_sequence_number,
        txn_public_key,
        txn_gas_price,
        txn_max_gas_units,
        txn_expiration_time,
        chain_id,
    )
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
<b>let</b> max_transaction_fee = txn_gas_price * txn_max_gas_units;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_ScriptPrologueAbortsIf">ScriptPrologueAbortsIf</a>&lt;Token&gt;{
    max_transaction_fee,
    txn_expiration_time_seconds: txn_expiration_time,
};
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender);
</code></pre>




<a name="0x1_DiemAccount_ScriptPrologueAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ScriptPrologueAbortsIf">ScriptPrologueAbortsIf</a>&lt;Token&gt; {
    sender: signer;
    txn_sequence_number: u64;
    txn_public_key: vector&lt;u8&gt;;
    chain_id: u8;
    max_transaction_fee: u128;
    txn_expiration_time_seconds: u64;
    script_hash: vector&lt;u8&gt;;
    <b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {transaction_sender};
}
</code></pre>


Aborts only in Genesis. Does not need to be handled.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ScriptPrologueAbortsIf">ScriptPrologueAbortsIf</a>&lt;Token&gt; {
    <b>include</b> <a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_AbortsIfNoTransactionPublishingOption">DiemTransactionPublishingOption::AbortsIfNoTransactionPublishingOption</a>;
}
</code></pre>


Covered: L74 (Match 8)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_ScriptPrologueAbortsIf">ScriptPrologueAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> !<a href="DiemTransactionPublishingOption.md#0x1_DiemTransactionPublishingOption_spec_is_script_allowed">DiemTransactionPublishingOption::spec_is_script_allowed</a>(sender, script_hash) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_writeset_prologue"></a>

## Function `writeset_prologue`

The prologue for WriteSet transaction


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_writeset_prologue">writeset_prologue</a>(sender: signer, txn_sequence_number: u64, txn_public_key: vector&lt;u8&gt;, txn_expiration_time: u64, chain_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_writeset_prologue">writeset_prologue</a>(
    sender: signer,
    txn_sequence_number: u64,
    txn_public_key: vector&lt;u8&gt;,
    txn_expiration_time: u64,
    chain_id: u8,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER">PROLOGUE_EINVALID_WRITESET_SENDER</a>)
    );
    <b>assert</b>(<a href="Roles.md#0x1_Roles_has_diem_root_role">Roles::has_diem_root_role</a>(&sender), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER">PROLOGUE_EINVALID_WRITESET_SENDER</a>));

    // Currency code don't matter here <b>as</b> it won't be charged anyway. Gas constants are ommitted.
    <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;(
        &sender,
        txn_sequence_number,
        txn_public_key,
        0,
        0,
        txn_expiration_time,
        chain_id,
    )
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetPrologueAbortsIf">WritesetPrologueAbortsIf</a> {txn_expiration_time_seconds: txn_expiration_time};
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender);
<b>ensures</b> <a href="Roles.md#0x1_Roles_has_diem_root_role">Roles::has_diem_root_role</a>(sender);
</code></pre>




<a name="0x1_DiemAccount_WritesetPrologueAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetPrologueAbortsIf">WritesetPrologueAbortsIf</a> {
    sender: signer;
    txn_sequence_number: u64;
    txn_public_key: vector&lt;u8&gt;;
    txn_expiration_time_seconds: u64;
    chain_id: u8;
    <b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
}
</code></pre>


Covered: L146 (Match 0)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetPrologueAbortsIf">WritesetPrologueAbortsIf</a> {
    <b>aborts_if</b> transaction_sender != <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


Must abort if the signer does not have the DiemRoot role [[H9]][PERMISSION].
Covered: L146 (Match 0)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetPrologueAbortsIf">WritesetPrologueAbortsIf</a> {
    <b>aborts_if</b> !<a href="Roles.md#0x1_Roles_spec_has_diem_root_role_addr">Roles::spec_has_diem_root_role_addr</a>(transaction_sender) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;{
        transaction_sender,
        max_transaction_fee: 0,
    };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_multi_agent_script_prologue"></a>

## Function `multi_agent_script_prologue`

The prologue for multi-agent user transactions


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_multi_agent_script_prologue">multi_agent_script_prologue</a>&lt;Token: store&gt;(sender: signer, txn_sequence_number: u64, txn_sender_public_key: vector&lt;u8&gt;, secondary_signer_addresses: vector&lt;address&gt;, secondary_signer_public_key_hashes: vector&lt;vector&lt;u8&gt;&gt;, txn_gas_price: u64, txn_max_gas_units: u64, txn_expiration_time: u64, chain_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_multi_agent_script_prologue">multi_agent_script_prologue</a>&lt;Token: store&gt;(
    sender: signer,
    txn_sequence_number: u64,
    txn_sender_public_key: vector&lt;u8&gt;,
    secondary_signer_addresses: vector&lt;address&gt;,
    secondary_signer_public_key_hashes: vector&lt;vector&lt;u8&gt;&gt;,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    txn_expiration_time: u64,
    chain_id: u8,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {

    <b>let</b> num_secondary_signers = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&secondary_signer_addresses);

    // Number of <b>public</b> key hashes must match the number of secondary signers.
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&secondary_signer_public_key_hashes) == num_secondary_signers,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH">PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH</a>),
    );

    <b>let</b> i = 0;
    <b>while</b> ({
        <b>spec</b> {
            <b>assert</b> <b>forall</b> j in 0..i: <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(secondary_signer_addresses[j]);
            <b>assert</b> <b>forall</b> j in 0..i: secondary_signer_public_key_hashes[j]
                == <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(secondary_signer_addresses[j]).authentication_key;
        };
        (i &lt; num_secondary_signers)
    })
    {
        // Check that all secondary signers have accounts.
        <b>let</b> secondary_address = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&secondary_signer_addresses, i);
        <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(secondary_address), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EACCOUNT_DNE">PROLOGUE_EACCOUNT_DNE</a>));

        // Check that for each secondary signer, the provided <b>public</b> key hash
        // is equal <b>to</b> the authentication key stored on-chain.
        <b>let</b> signer_account = borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(secondary_address);
        <b>let</b> signer_public_key_hash = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&secondary_signer_public_key_hashes, i);
        <b>assert</b>(
            signer_public_key_hash == *&signer_account.authentication_key,
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY">PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY</a>),
        );
        i = i + 1;
    };

    <b>spec</b> {
        <b>assert</b> <b>forall</b> j in 0..num_secondary_signers: <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(secondary_signer_addresses[j]);
        <b>assert</b> <b>forall</b> j in 0..num_secondary_signers: secondary_signer_public_key_hashes[j]
            == <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(secondary_signer_addresses[j]).authentication_key;
    };

    <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;Token&gt;(
        &sender,
        txn_sequence_number,
        txn_sender_public_key,
        txn_gas_price,
        txn_max_gas_units,
        txn_expiration_time,
        chain_id,
    )
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
<b>let</b> max_transaction_fee = txn_gas_price * txn_max_gas_units;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MultiAgentScriptPrologueAbortsIf">MultiAgentScriptPrologueAbortsIf</a>&lt;Token&gt;{
    max_transaction_fee,
    txn_expiration_time_seconds: txn_expiration_time,
};
<b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender);
</code></pre>




<a name="0x1_DiemAccount_MultiAgentScriptPrologueAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_MultiAgentScriptPrologueAbortsIf">MultiAgentScriptPrologueAbortsIf</a>&lt;Token&gt; {
    sender: signer;
    txn_sequence_number: u64;
    txn_sender_public_key: vector&lt;u8&gt;;
    secondary_signer_addresses: vector&lt;address&gt;;
    secondary_signer_public_key_hashes: vector&lt;vector&lt;u8&gt;&gt;;
    chain_id: u8;
    max_transaction_fee: u128;
    txn_expiration_time_seconds: u64;
    <b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {transaction_sender, txn_public_key: txn_sender_public_key};
    <b>aborts_if</b> len(secondary_signer_addresses) != len(secondary_signer_public_key_hashes)
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>let</b> num_secondary_signers = len(secondary_signer_addresses);
    <b>aborts_if</b> <b>exists</b> i in 0..num_secondary_signers: !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(secondary_signer_addresses[i])
        <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
    <b>aborts_if</b> <b>exists</b> i in 0..num_secondary_signers:
        secondary_signer_public_key_hashes[i] != <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(secondary_signer_addresses[i]).authentication_key
    <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_prologue_common"></a>

## Function `prologue_common`

The common prologue is invoked at the beginning of every transaction
The main properties that it verifies:
- The account's auth key matches the transaction's public key
- That the account has enough balance to pay for all of the gas
- That the sequence number matches the transaction's sequence key


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;Token: store&gt;(sender: &signer, txn_sequence_number: u64, txn_public_key: vector&lt;u8&gt;, txn_gas_price: u64, txn_max_gas_units: u64, txn_expiration_time_seconds: u64, chain_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_common">prologue_common</a>&lt;Token: store&gt;(
    sender: &signer,
    txn_sequence_number: u64,
    txn_public_key: vector&lt;u8&gt;,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    txn_expiration_time_seconds: u64,
    chain_id: u8,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    // [PCA1]: Check that the chain ID stored on-chain matches the chain ID specified by the transaction
    <b>assert</b>(<a href="ChainId.md#0x1_ChainId_get">ChainId::get</a>() == chain_id, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EBAD_CHAIN_ID">PROLOGUE_EBAD_CHAIN_ID</a>));

    // [PCA2]: Verify that the transaction sender's account <b>exists</b>
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(transaction_sender), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EACCOUNT_DNE">PROLOGUE_EACCOUNT_DNE</a>));

    // [PCA3]: We check whether this account is frozen, <b>if</b> it is no transaction can be sent from it.
    <b>assert</b>(
        !<a href="AccountFreezing.md#0x1_AccountFreezing_account_is_frozen">AccountFreezing::account_is_frozen</a>(transaction_sender),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EACCOUNT_FROZEN">PROLOGUE_EACCOUNT_FROZEN</a>)
    );

    // Load the transaction sender's account
    <b>let</b> sender_account = borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(transaction_sender);

    // [PCA4]: Check that the hash of the transaction's <b>public</b> key matches the account's auth key
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Hash.md#0x1_Hash_sha3_256">Hash::sha3_256</a>(txn_public_key) == *&sender_account.authentication_key,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY">PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY</a>),
    );

    // [PCA5]: Check that the max transaction fee does not overflow a u64 value.
    <b>assert</b>(
        (txn_gas_price <b>as</b> u128) * (txn_max_gas_units <b>as</b> u128) &lt;= <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT">PROLOGUE_ECANT_PAY_GAS_DEPOSIT</a>),
    );

    <b>let</b> max_transaction_fee = txn_gas_price * txn_max_gas_units;

    // Don't grab the balance <b>if</b> the transaction fee is zero
    <b>if</b> (max_transaction_fee &gt; 0) {
        // [PCA6]: Check that the gas fee can be paid in this currency
        <b>assert</b>(
            <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">TransactionFee::is_coin_initialized</a>&lt;Token&gt;(),
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EBAD_TRANSACTION_FEE_CURRENCY">PROLOGUE_EBAD_TRANSACTION_FEE_CURRENCY</a>)
        );
        // [PCA7]: Check that the account has a balance in this currency
        <b>assert</b>(
            <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(transaction_sender),
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT">PROLOGUE_ECANT_PAY_GAS_DEPOSIT</a>)
        );
        <b>let</b> balance_amount = <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(transaction_sender);
        // [PCA8]: Check that the account can cover the maximum transaction fee

        <b>assert</b>(
            balance_amount &gt;= max_transaction_fee,
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT">PROLOGUE_ECANT_PAY_GAS_DEPOSIT</a>)
        );
    };

    // [PCA9]: Check that the transaction hasn't expired
    <b>assert</b>(
        <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>() &lt; txn_expiration_time_seconds,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ETRANSACTION_EXPIRED">PROLOGUE_ETRANSACTION_EXPIRED</a>)
    );

    // [PCA10]: Check that the transaction's sequence number will not overflow.
    <b>assert</b>(
        (txn_sequence_number <b>as</b> u128) &lt; <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG">PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG</a>)
    );

    // [PCA11]: Check that the transaction sequence number is not too <b>old</b> (in the past)
    <b>assert</b>(
        txn_sequence_number &gt;= sender_account.sequence_number,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD">PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD</a>)
    );

    // [PCA12]: Check that the transaction's sequence number matches the
    // current sequence number. Otherwise sequence number is too new by [PCA11].
    <b>assert</b>(
        txn_sequence_number == sender_account.sequence_number,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW">PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW</a>)
    );
    // WARNING: No checks should be added here <b>as</b> the sequence number too new check should be the last check run
    // by the prologue.
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> transaction_sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
<b>let</b> max_transaction_fee = txn_gas_price * txn_max_gas_units;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    transaction_sender,
    max_transaction_fee,
};
</code></pre>




<a name="0x1_DiemAccount_PrologueCommonAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    transaction_sender: address;
    txn_sequence_number: u64;
    txn_public_key: vector&lt;u8&gt;;
    chain_id: u8;
    max_transaction_fee: u128;
    txn_expiration_time_seconds: u64;
}
</code></pre>


Only happens if this is called in Genesis. Doesn't need to be handled.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
}
</code></pre>


[PCA1] Covered: L73 (Match 7)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> chain_id != <a href="ChainId.md#0x1_ChainId_spec_get_chain_id">ChainId::spec_get_chain_id</a>() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA2] Covered: L65 (Match 4)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(transaction_sender) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA3] Covered: L57 (Match 0)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> <a href="AccountFreezing.md#0x1_AccountFreezing_spec_account_is_frozen">AccountFreezing::spec_account_is_frozen</a>(transaction_sender) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_STATE">Errors::INVALID_STATE</a>;
}
</code></pre>


[PCA4] Covered: L59 (Match 1)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> <a href="../../../../../../move-stdlib/docs/Hash.md#0x1_Hash_sha3_256">Hash::sha3_256</a>(txn_public_key) != <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(transaction_sender).authentication_key <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA5] Covered: L69 (Match 5)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> max_transaction_fee &gt; <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a> <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA6] Covered: L69 (Match 5)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> max_transaction_fee &gt; 0 && !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">TransactionFee::is_coin_initialized</a>&lt;Token&gt;() <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA7] Covered: L69 (Match 5)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> max_transaction_fee &gt; 0 && !<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(transaction_sender) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA8] Covered: L69 (Match 5)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> max_transaction_fee &gt; 0 && <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;Token&gt;(transaction_sender) &lt; max_transaction_fee <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA9] Covered: L72 (Match 6)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_spec_now_seconds">DiemTimestamp::spec_now_seconds</a>() &gt;= txn_expiration_time_seconds <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA10] Covered: L81 (match 11)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> txn_sequence_number &gt;= <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a> <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_LIMIT_EXCEEDED">Errors::LIMIT_EXCEEDED</a>;
}
</code></pre>


[PCA11] Covered: L61 (Match 2)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> txn_sequence_number &lt; <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(transaction_sender).sequence_number <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>


[PCA12] Covered: L63 (match 3)


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PrologueCommonAbortsIf">PrologueCommonAbortsIf</a>&lt;Token&gt; {
    <b>aborts_if</b> txn_sequence_number &gt; <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(transaction_sender).sequence_number <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_INVALID_ARGUMENT">Errors::INVALID_ARGUMENT</a>;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_epilogue"></a>

## Function `epilogue`

Collects gas and bumps the sequence number for executing a transaction.
The epilogue is invoked at the end of the transaction.
If the exection of the epilogue fails, it is re-invoked with different arguments, and
based on the conditions checked in the prologue, should never fail.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_epilogue">epilogue</a>&lt;Token: store&gt;(account: signer, txn_sequence_number: u64, txn_gas_price: u64, txn_max_gas_units: u64, gas_units_remaining: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_epilogue">epilogue</a>&lt;Token: store&gt;(
    account: signer,
    txn_sequence_number: u64,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    gas_units_remaining: u64
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <a href="DiemAccount.md#0x1_DiemAccount_epilogue_common">epilogue_common</a>&lt;Token&gt;(
        &account,
        txn_sequence_number,
        txn_gas_price,
        txn_max_gas_units,
        gas_units_remaining,
    )
}
</code></pre>



</details>

<a name="0x1_DiemAccount_epilogue_common"></a>

## Function `epilogue_common`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_epilogue_common">epilogue_common</a>&lt;Token: store&gt;(account: &signer, txn_sequence_number: u64, txn_gas_price: u64, txn_max_gas_units: u64, gas_units_remaining: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_epilogue_common">epilogue_common</a>&lt;Token: store&gt;(
    account: &signer,
    txn_sequence_number: u64,
    txn_gas_price: u64,
    txn_max_gas_units: u64,
    gas_units_remaining: u64
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);

    // [EA1; Invariant]: Make sure that the transaction's `max_gas_units` is greater
    // than the number of gas units remaining after execution.
    <b>assert</b>(txn_max_gas_units &gt;= gas_units_remaining, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_EGAS">EGAS</a>));
    <b>let</b> gas_used = txn_max_gas_units - gas_units_remaining;

    // [EA2; Invariant]: Make sure that the transaction fee would not overflow maximum
    // number representable in a u64. Already checked in [PCA5].
    <b>assert</b>(
        (txn_gas_price <b>as</b> u128) * (gas_used <b>as</b> u128) &lt;= <a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a>,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_EGAS">EGAS</a>)
    );
    <b>let</b> transaction_fee_amount = txn_gas_price * gas_used;

    // [EA3; Invariant]: Make sure that account <b>exists</b>, and load the
    // transaction sender's account. Already checked in [PCA2].
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(sender), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="DiemAccount.md#0x1_DiemAccount_EACCOUNT">EACCOUNT</a>));
    <b>let</b> sender_account = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(sender);

    // [EA4; Condition]: Make sure account's sequence number is within the
    // representable range of u64. Already checked in [PCA10].
    <b>assert</b>(
        sender_account.<a href="DiemAccount.md#0x1_DiemAccount_sequence_number">sequence_number</a> &lt; (<a href="DiemAccount.md#0x1_DiemAccount_MAX_U64">MAX_U64</a> <b>as</b> u64),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG">PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG</a>)
    );

    // [EA4; Invariant]: Make sure passed-in `txn_sequence_number` matches
    // the `sender_account`'s `sequence_number`. Already checked in [PCA12].
    <b>assert</b>(
        sender_account.sequence_number == txn_sequence_number,
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW">PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW</a>)
    );

    // The transaction sequence number is passed in <b>to</b> prevent any
    // possibility of the account's sequence number increasing by more than
    // one for any transaction.
    sender_account.sequence_number = txn_sequence_number + 1;

    <b>if</b> (transaction_fee_amount &gt; 0) {
        // [Invariant Use]: <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> for `Token` verified <b>to</b> exist for non-zero transaction fee amounts by [PCA7].
        <b>let</b> sender_balance = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(sender);
        <b>let</b> coin = &<b>mut</b> sender_balance.coin;

        // [EA4; Condition]: Abort <b>if</b> this withdrawal would make the `sender_account`'s balance go negative
        <b>assert</b>(
            transaction_fee_amount &lt;= <a href="Diem.md#0x1_Diem_value">Diem::value</a>(coin),
            <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_ECANT_PAY_GAS_DEPOSIT">PROLOGUE_ECANT_PAY_GAS_DEPOSIT</a>)
        );

        // NB: `withdraw_from_balance` is not used <b>as</b> limits do not <b>apply</b> <b>to</b> this transaction fee
        <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">TransactionFee::pay_fee</a>(<a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(coin, transaction_fee_amount))
    }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_writeset_epilogue"></a>

## Function `writeset_epilogue`

Epilogue for WriteSet trasnaction


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_writeset_epilogue">writeset_epilogue</a>(dr_account: signer, txn_sequence_number: u64, should_trigger_reconfiguration: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_writeset_epilogue">writeset_epilogue</a>(
    dr_account: signer,
    txn_sequence_number: u64,
    should_trigger_reconfiguration: bool,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>, <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
    <b>let</b> dr_account = &dr_account;
    <b>let</b> writeset_events_ref = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">AdminTransactionEvent</a>&gt;(
        &<b>mut</b> writeset_events_ref.upgrade_events,
        <a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">AdminTransactionEvent</a> { committed_timestamp_secs: <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>() },
    );

    // Double check that the sender is the DiemRoot account at the `<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>`
    <b>assert</b>(
        <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(dr_account) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER">PROLOGUE_EINVALID_WRITESET_SENDER</a>)
    );
    <b>assert</b>(<a href="Roles.md#0x1_Roles_has_diem_root_role">Roles::has_diem_root_role</a>(dr_account), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DiemAccount.md#0x1_DiemAccount_PROLOGUE_EINVALID_WRITESET_SENDER">PROLOGUE_EINVALID_WRITESET_SENDER</a>));

    // Currency code don't matter here <b>as</b> it won't be charged anyway.
    <a href="DiemAccount.md#0x1_DiemAccount_epilogue_common">epilogue_common</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;(dr_account, txn_sequence_number, 0, 0, 0);
    <b>if</b> (should_trigger_reconfiguration) <a href="DiemConfig.md#0x1_DiemConfig_reconfigure">DiemConfig::reconfigure</a>(dr_account)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetEpiloguEmits">WritesetEpiloguEmits</a>;
</code></pre>




<a name="0x1_DiemAccount_WritesetEpiloguEmits"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_WritesetEpiloguEmits">WritesetEpiloguEmits</a> {
    <b>let</b> handle = <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()).upgrade_events;
    <b>let</b> msg = <a href="DiemAccount.md#0x1_DiemAccount_AdminTransactionEvent">AdminTransactionEvent</a> {
        committed_timestamp_secs: <a href="DiemTimestamp.md#0x1_DiemTimestamp_spec_now_seconds">DiemTimestamp::spec_now_seconds</a>()
    };
    emits msg <b>to</b> handle;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_validator_account"></a>

## Function `create_validator_account`

NOTE: in 0L this is only used for test harness
Create a Validator account


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account">create_validator_account</a>(dr_account: &signer, new_account_address: address, auth_key_prefix: vector&lt;u8&gt;, human_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account">create_validator_account</a>(
    dr_account: &signer,
    new_account_address: address,
    auth_key_prefix: vector&lt;u8&gt;,
    human_name: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> {
    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    // The dr_account account is verified <b>to</b> have the diem root role in `<a href="Roles.md#0x1_Roles_new_validator_role">Roles::new_validator_role</a>`
    <a href="Roles.md#0x1_Roles_new_validator_role">Roles::new_validator_role</a>(dr_account, &new_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_account);
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_publish">ValidatorConfig::publish</a>(&new_account, dr_account, human_name);
    //////// 0L ////////
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_account, <b>false</b>);

    //////// end 0L ////////
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account, auth_key_prefix);

    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);

    //////// 0L ////////
    <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(&new_account);
    <a href="Jail.md#0x1_Jail_init">Jail::init</a>(&new_account);
    // <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">ValidatorUniverse::add_self</a>(&new_account);
    // <a href="Vouch.md#0x1_Vouch_init">Vouch::init</a>(&new_account);
    //////// end 0L ////////

}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorAccountAbortsIf">CreateValidatorAccountAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorAccountEnsures">CreateValidatorAccountEnsures</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountEmits">MakeAccountEmits</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateValidatorAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorAccountAbortsIf">CreateValidatorAccountAbortsIf</a> {
    dr_account: signer;
    new_account_address: address;
    <b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotDiemRoot">Roles::AbortsIfNotDiemRoot</a>{account: dr_account};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_address};
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>aborts_if</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig_exists_config">ValidatorConfig::exists_config</a>(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_CreateValidatorAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorAccountEnsures">CreateValidatorAccountEnsures</a> {
    new_account_address: address;
    <b>include</b> <a href="Roles.md#0x1_Roles_GrantRole">Roles::GrantRole</a>{addr: new_account_address, role_id: <a href="Roles.md#0x1_Roles_VALIDATOR_ROLE_ID">Roles::VALIDATOR_ROLE_ID</a>};
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address);
    <b>ensures</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig_exists_config">ValidatorConfig::exists_config</a>(new_account_address);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_create_validator_operator_account"></a>

## Function `create_validator_operator_account`

Create a Validator Operator account


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_operator_account">create_validator_operator_account</a>(dr_account: &signer, new_account_address: address, auth_key_prefix: vector&lt;u8&gt;, human_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_create_validator_operator_account">create_validator_operator_account</a>(
    dr_account: &signer,
    new_account_address: address,
    auth_key_prefix: vector&lt;u8&gt;,
    human_name: vector&lt;u8&gt;,
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a> {
    <b>let</b> new_account = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(new_account_address);
    // The dr_account is verified <b>to</b> have the diem root role in `<a href="Roles.md#0x1_Roles_new_validator_operator_role">Roles::new_validator_operator_role</a>`
    <a href="Roles.md#0x1_Roles_new_validator_operator_role">Roles::new_validator_operator_role</a>(dr_account, &new_account);
    <a href="../../../../../../move-stdlib/docs/Event.md#0x1_Event_publish_generator">Event::publish_generator</a>(&new_account);
    <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_publish">ValidatorOperatorConfig::publish</a>(&new_account, dr_account, human_name);
    <a href="DiemAccount.md#0x1_DiemAccount_add_currencies_for_account">add_currencies_for_account</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&new_account, <b>false</b>); /////// 0L /////////
    <a href="DiemAccount.md#0x1_DiemAccount_make_account">make_account</a>(new_account, auth_key_prefix)
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorOperatorAccountAbortsIf">CreateValidatorOperatorAccountAbortsIf</a>;
<b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorOperatorAccountEnsures">CreateValidatorOperatorAccountEnsures</a>;
</code></pre>




<a name="0x1_DiemAccount_CreateValidatorOperatorAccountAbortsIf"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorOperatorAccountAbortsIf">CreateValidatorOperatorAccountAbortsIf</a> {
    dr_account: signer;
    new_account_address: address;
    <b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotDiemRoot">Roles::AbortsIfNotDiemRoot</a>{account: dr_account};
    <b>include</b> <a href="DiemAccount.md#0x1_DiemAccount_MakeAccountAbortsIf">MakeAccountAbortsIf</a>{addr: new_account_address};
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>aborts_if</b> <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_has_validator_operator_config">ValidatorOperatorConfig::has_validator_operator_config</a>(new_account_address) <b>with</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
}
</code></pre>




<a name="0x1_DiemAccount_CreateValidatorOperatorAccountEnsures"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_CreateValidatorOperatorAccountEnsures">CreateValidatorOperatorAccountEnsures</a> {
    new_account_address: address;
    <b>include</b> <a href="Roles.md#0x1_Roles_GrantRole">Roles::GrantRole</a>{addr: new_account_address, role_id: <a href="Roles.md#0x1_Roles_VALIDATOR_OPERATOR_ROLE_ID">Roles::VALIDATOR_OPERATOR_ROLE_ID</a>};
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(new_account_address);
    <b>ensures</b> <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_has_validator_operator_config">ValidatorOperatorConfig::has_validator_operator_config</a>(new_account_address);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_vm_deposit_with_metadata"></a>

## Function `vm_deposit_with_metadata`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">vm_deposit_with_metadata</a>&lt;Token: store&gt;(vm: &signer, payee: address, to_deposit: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;, metadata: vector&lt;u8&gt;, metadata_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">vm_deposit_with_metadata</a>&lt;Token: store&gt;(
    vm: &signer,
    payee: address,
    to_deposit: <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;,
    metadata: vector&lt;u8&gt;,
    metadata_signature: vector&lt;u8&gt;
) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>, <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> { //////// 0L ////////
    <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), 4010);
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">deposit</a>(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
        payee,
        to_deposit,
        metadata,
        metadata_signature
    );
}
</code></pre>



</details>

<a name="0x1_DiemAccount_vm_migrate_slow_wallet"></a>

## Function `vm_migrate_slow_wallet`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_migrate_slow_wallet">vm_migrate_slow_wallet</a>(vm: &signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_migrate_slow_wallet">vm_migrate_slow_wallet</a>(vm: &signer, addr: address) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>{
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>let</b> sig = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(addr);
  <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(&sig);
}
</code></pre>



</details>

<a name="0x1_DiemAccount_init_cumulative_deposits"></a>

## Function `init_cumulative_deposits`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_init_cumulative_deposits">init_cumulative_deposits</a>(sender: &signer, starting_balance: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_init_cumulative_deposits">init_cumulative_deposits</a>(sender: &signer, starting_balance: u64) {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr)) {
    move_to&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(sender, <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> {
      value: starting_balance,
      index: starting_balance,
    })
  };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_maybe_update_deposit"></a>

## Function `maybe_update_deposit`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_maybe_update_deposit">maybe_update_deposit</a>(payee: address, deposit_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_maybe_update_deposit">maybe_update_deposit</a>(payee: address, deposit_value: u64) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> {
    // <b>update</b> cumulative deposits <b>if</b> the account has the <b>struct</b>.
    <b>if</b> (<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(payee)) {
      <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
      <b>let</b> index = <a href="DiemAccount.md#0x1_DiemAccount_deposit_index_curve">deposit_index_curve</a>(epoch, deposit_value);
      <b>let</b> cumu = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(payee);
      cumu.value = cumu.value + deposit_value;
      cumu.index = cumu.index + index;
    };
}
</code></pre>



</details>

<a name="0x1_DiemAccount_deposit_index_curve"></a>

## Function `deposit_index_curve`

adjust the points of the deposits favoring more recent deposits.
inflation by x% per day from the start of network.


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_deposit_index_curve">deposit_index_curve</a>(epoch: u64, value: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_deposit_index_curve">deposit_index_curve</a>(
  epoch: u64,
  value: u64,
): u64 {

  // increment 1/2 percent per day, not compounded.
  (value * (1000 + (epoch * 5))) / 1000
}
</code></pre>



</details>

<a name="0x1_DiemAccount_get_cumulative_deposits"></a>

## Function `get_cumulative_deposits`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_cumulative_deposits">get_cumulative_deposits</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_cumulative_deposits">get_cumulative_deposits</a>(addr: address): u64 <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr)) <b>return</b> 0;

  borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr).value
}
</code></pre>



</details>

<a name="0x1_DiemAccount_get_index_cumu_deposits"></a>

## Function `get_index_cumu_deposits`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_index_cumu_deposits">get_index_cumu_deposits</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_index_cumu_deposits">get_index_cumu_deposits</a>(addr: address): u64 <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr)) <b>return</b> 0;

  borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr).index
}
</code></pre>



</details>

<a name="0x1_DiemAccount_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_is_init">is_init</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_is_init">is_init</a>(addr: address): bool {
  <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_migrate_cumu_deposits"></a>

## Function `migrate_cumu_deposits`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_migrate_cumu_deposits">migrate_cumu_deposits</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_migrate_cumu_deposits">migrate_cumu_deposits</a>(vm: &signer) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">Wallet::get_comm_list</a>();
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&list)) {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_CumulativeDeposits">CumulativeDeposits</a>&gt;(*addr)) {
      <b>let</b> sig = <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(*addr);
      <b>let</b> current_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*addr);

      <a href="DiemAccount.md#0x1_DiemAccount_init_cumulative_deposits">init_cumulative_deposits</a>(&sig, current_bal);
    };
    i = i + 1;
  }

}
</code></pre>



</details>

<a name="0x1_DiemAccount_vm_init_slow"></a>

## Function `vm_init_slow`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_init_slow">vm_init_slow</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_vm_init_slow">vm_init_slow</a>(vm: &signer){
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(@0x0)) {
    move_to&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(vm, <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> {
      list: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
    });
  }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_set_slow"></a>

## Function `set_slow`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_set_slow">set_slow</a>(sig: &signer) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(@0x0)) {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
    <b>let</b> list = <a href="DiemAccount.md#0x1_DiemAccount_get_slow_list">get_slow_list</a>();
    <b>if</b> (!<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&list, &addr)) {
        <b>let</b> s = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(@0x0);
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
    };

    <b>if</b> (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig))) {
      move_to&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(sig, <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {
        unlocked: 0,
        transferred: 0,
      });
    }
  }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_slow_wallet_epoch_drip"></a>

## Function `slow_wallet_epoch_drip`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">slow_wallet_epoch_drip</a>(vm: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">slow_wallet_epoch_drip</a>(vm: &signer, amount: u64) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>{
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> list = <a href="DiemAccount.md#0x1_DiemAccount_get_slow_list">get_slow_list</a>();
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&list)) {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&list, i);
    <b>let</b> s = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(*addr);
    s.unlocked = s.unlocked + amount;
    i = i + 1;
  }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_decrease_unlocked_tracker"></a>

## Function `decrease_unlocked_tracker`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_decrease_unlocked_tracker">decrease_unlocked_tracker</a>(payer: address, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_decrease_unlocked_tracker">decrease_unlocked_tracker</a>(payer: address, amount: u64) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {
  <b>let</b> s = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(payer);
  s.transferred = s.transferred + amount;
  s.unlocked = s.unlocked - amount;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_increase_unlocked_tracker"></a>

## Function `increase_unlocked_tracker`



<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_increase_unlocked_tracker">increase_unlocked_tracker</a>(recipient: address, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_increase_unlocked_tracker">increase_unlocked_tracker</a>(recipient: address, amount: u64) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {
  <b>let</b> s = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(recipient);
  s.unlocked = s.unlocked + amount;
}
</code></pre>



</details>

<a name="0x1_DiemAccount_is_slow"></a>

## Function `is_slow`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_is_slow">is_slow</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_is_slow">is_slow</a>(addr: address): bool {
  <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_unlocked_amount"></a>

## Function `unlocked_amount`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_unlocked_amount">unlocked_amount</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_unlocked_amount">unlocked_amount</a>(addr: address): u64 <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(addr)) {
    <b>let</b> s = borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(addr);
    <b>return</b> s.unlocked
  };
  // this is a normal account, so <b>return</b> the normal balance
  <a href="DiemAccount.md#0x1_DiemAccount_balance">balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_get_slow_list"></a>

## Function `get_slow_list`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_slow_list">get_slow_list</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_get_slow_list">get_slow_list</a>(): vector&lt;address&gt; <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(@0x0)) {
    <b>let</b> s = borrow_global&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(@0x0);
    <b>return</b> *&s.list
  } <b>else</b> {
    <b>return</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_DiemAccount_test_helper_create_signer"></a>

## Function `test_helper_create_signer`



<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_test_helper_create_signer">test_helper_create_signer</a>(vm: &signer, addr: address): signer
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_test_helper_create_signer">test_helper_create_signer</a>(vm: &signer, addr: address): signer {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>assert</b>(is_testnet(), 120102011021);
    <a href="DiemAccount.md#0x1_DiemAccount_create_signer">create_signer</a>(addr)
}
</code></pre>



</details>

<a name="0x1_DiemAccount_test_remove_slow"></a>

## Function `test_remove_slow`

should only by called by testnet, once a slow wallet, always a slow wallet.


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_test_remove_slow">test_remove_slow</a>(vm: &signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_test_remove_slow">test_remove_slow</a>(vm: &signer, addr: address) <b>acquires</b> <a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>, <a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a> {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>assert</b>(is_testnet(), 120102011021);

    <b>let</b> l = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWalletList">SlowWalletList</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
    <b>let</b> (found, i) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&l.list, &addr);
    <b>if</b> (found) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> l.list, i);
    };

    <b>let</b> _ = borrow_global_mut&lt;<a href="DiemAccount.md#0x1_DiemAccount_SlowWallet">SlowWallet</a>&gt;(addr);
}
</code></pre>



</details>

<a name="@Module_Specification_4"></a>

## Module Specification



<a name="0x1_DiemAccount_spec_has_published_account_limits"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_has_published_account_limits">spec_has_published_account_limits</a>&lt;Token&gt;(addr: address): bool {
   <b>if</b> (<a href="VASP.md#0x1_VASP_is_vasp">VASP::is_vasp</a>(addr)) <a href="VASP.md#0x1_VASP_spec_has_account_limits">VASP::spec_has_account_limits</a>&lt;Token&gt;(addr)
   <b>else</b> <a href="AccountLimits.md#0x1_AccountLimits_has_window_published">AccountLimits::has_window_published</a>&lt;Token&gt;(addr)
}
</code></pre>




<a name="@Access_Control_5"></a>

### Access Control


<a name="@Key_Rotation_Capability_6"></a>

#### Key Rotation Capability


the permission "RotateAuthenticationKey(addr)" is granted to the account at addr [[H18]][PERMISSION].
When an account is created, its KeyRotationCapability is granted to the account.


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_EnsuresHasKeyRotationCap">EnsuresHasKeyRotationCap</a>{account: new_account} <b>to</b> make_account;
</code></pre>


Only <code>make_account</code> creates KeyRotationCap [[H18]][PERMISSION][[I18]][PERMISSION]. <code>create_*_account</code> only calls
<code>make_account</code>, and does not pack KeyRotationCap by itself.
<code>restore_key_rotation_capability</code> restores KeyRotationCap, and does not create new one.


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_PreserveKeyRotationCapAbsence">PreserveKeyRotationCapAbsence</a> <b>to</b> * <b>except</b> make_account, create_*_account,
      restore_key_rotation_capability, initialize;
</code></pre>


Every account holds either no key rotation capability (because KeyRotationCapability has been delegated)
or the key rotation capability for addr itself [[H18]][PERMISSION].


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr):
    <a href="DiemAccount.md#0x1_DiemAccount_delegated_key_rotation_capability">delegated_key_rotation_capability</a>(addr) || <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(addr);
</code></pre>




<a name="0x1_DiemAccount_EnsuresHasKeyRotationCap"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_EnsuresHasKeyRotationCap">EnsuresHasKeyRotationCap</a> {
    account: signer;
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(addr);
}
</code></pre>




<a name="0x1_DiemAccount_PreserveKeyRotationCapAbsence"></a>

The absence of KeyRotationCap is preserved.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreserveKeyRotationCapAbsence">PreserveKeyRotationCapAbsence</a> {
    <b>ensures</b> <b>forall</b> addr: address:
        <b>old</b>(!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr) || !<a href="DiemAccount.md#0x1_DiemAccount_spec_has_key_rotation_cap">spec_has_key_rotation_cap</a>(addr)) ==&gt;
            (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr) || !<a href="DiemAccount.md#0x1_DiemAccount_spec_has_key_rotation_cap">spec_has_key_rotation_cap</a>(addr));
}
</code></pre>



<a name="@Withdraw_Capability_7"></a>

#### Withdraw Capability


the permission "WithdrawCapability(addr)" is granted to the account at addr [[H19]][PERMISSION].
When an account is created, its WithdrawCapability is granted to the account.


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_EnsuresWithdrawCap">EnsuresWithdrawCap</a>{account: new_account} <b>to</b> make_account;
</code></pre>


Only <code>make_account</code> creates WithdrawCap [[H19]][PERMISSION][[I19]][PERMISSION]. <code>create_*_account</code> only calls
<code>make_account</code>, and does not pack KeyRotationCap by itself.
<code>restore_withdraw_capability</code> restores WithdrawCap, and does not create new one.


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_PreserveWithdrawCapAbsence">PreserveWithdrawCapAbsence</a> <b>to</b> * <b>except</b> make_account, create_*_account,
        restore_withdraw_capability, initialize;
</code></pre>


Every account holds either no withdraw capability (because withdraw cap has been delegated)
or the withdraw capability for addr itself [[H19]][PERMISSION].


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr):
    <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_delegated_withdraw_capability">spec_holds_delegated_withdraw_capability</a>(addr) || <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(addr);
</code></pre>




<a name="0x1_DiemAccount_EnsuresWithdrawCap"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_EnsuresWithdrawCap">EnsuresWithdrawCap</a> {
    account: signer;
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(account);
    <b>ensures</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(addr);
}
</code></pre>




<a name="0x1_DiemAccount_PreserveWithdrawCapAbsence"></a>

The absence of WithdrawCap is preserved.


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_PreserveWithdrawCapAbsence">PreserveWithdrawCapAbsence</a> {
    <b>ensures</b> <b>forall</b> addr: address:
        <b>old</b>(!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr) || <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).withdraw_capability)) ==&gt;
            (!<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr) || <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).withdraw_capability));
}
</code></pre>



<a name="@Authentication_Key_8"></a>

#### Authentication Key


only <code><a href="DiemAccount.md#0x1_DiemAccount_rotate_authentication_key">Self::rotate_authentication_key</a></code> can rotate authentication_key [[H18]][PERMISSION].


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_AuthenticationKeyRemainsSame">AuthenticationKeyRemainsSame</a> <b>to</b> *, *&lt;T&gt; <b>except</b> rotate_authentication_key;
</code></pre>




<a name="0x1_DiemAccount_AuthenticationKeyRemainsSame"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_AuthenticationKeyRemainsSame">AuthenticationKeyRemainsSame</a> {
    <b>ensures</b> <b>forall</b> addr: address <b>where</b> <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr)):
        <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key == <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).authentication_key);
}
</code></pre>



<a name="@Balance_9"></a>

#### Balance


only <code><a href="DiemAccount.md#0x1_DiemAccount_withdraw_from">Self::withdraw_from</a></code> and its helper and clients can withdraw [[H19]][PERMISSION].


<pre><code><b>apply</b> <a href="DiemAccount.md#0x1_DiemAccount_BalanceNotDecrease">BalanceNotDecrease</a>&lt;Token&gt; <b>to</b> *&lt;Token&gt;
    <b>except</b> withdraw_from, withdraw_from_balance, staple_xdx, unstaple_xdx,
        preburn, pay_from, epilogue_common, epilogue, failure_epilogue, success_epilogue;
</code></pre>




<a name="0x1_DiemAccount_BalanceNotDecrease"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_BalanceNotDecrease">BalanceNotDecrease</a>&lt;Token&gt; {
    <b>ensures</b> <b>forall</b> addr: address <b>where</b> <b>old</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr)):
        <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr).coin.value &gt;= <b>old</b>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;Token&gt;&gt;(addr).coin.value);
}
</code></pre>



<a name="@Persistence_of_Resources_10"></a>

### Persistence of Resources


Accounts are never deleted.


<pre><code><b>invariant</b> <b>update</b> <b>forall</b> addr: address <b>where</b> <b>old</b>(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr)): <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr);
</code></pre>


After genesis, the <code><a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a></code> exists.


<pre><code><b>invariant</b>
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


After genesis, the <code><a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a></code> exists.


<pre><code><b>invariant</b>
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


resource struct <code><a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;CoinType&gt;</code> is persistent


<pre><code><b>invariant</b> <b>update</b> <b>forall</b> coin_type: type, addr: address
    <b>where</b> <b>old</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;coin_type&gt;&gt;(addr)):
        <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;coin_type&gt;&gt;(addr);
</code></pre>


resource struct <code><a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a></code> is persistent


<pre><code><b>invariant</b> <b>update</b> <b>old</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()))
        ==&gt; <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


resource struct <code><a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a></code> is persistent


<pre><code><b>invariant</b> <b>update</b>
    <b>old</b>(<b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()))
        ==&gt; <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_DiemWriteSetManager">DiemWriteSetManager</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>



<a name="@Other_invariants_11"></a>

### Other invariants


Every address that has a published account has a published RoleId


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr): <b>exists</b>&lt;<a href="Roles.md#0x1_Roles_RoleId">Roles::RoleId</a>&gt;(addr);
</code></pre>


If an account has a balance, the role of the account is compatible with having a balance.


<pre><code><b>invariant</b> <b>forall</b> token: type: <b>forall</b> addr: address <b>where</b> <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_Balance">Balance</a>&lt;token&gt;&gt;(addr):
    <a href="Roles.md#0x1_Roles_spec_can_hold_balance_addr">Roles::spec_can_hold_balance_addr</a>(addr);
</code></pre>


If there is a <code><a href="DesignatedDealer.md#0x1_DesignatedDealer_Dealer">DesignatedDealer::Dealer</a></code> resource published at <code>addr</code>, the <code>addr</code> has a
<code>Roles::DesignatedDealer</code> role.


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <b>exists</b>&lt;<a href="DesignatedDealer.md#0x1_DesignatedDealer_Dealer">DesignatedDealer::Dealer</a>&gt;(addr):
    <a href="Roles.md#0x1_Roles_spec_has_designated_dealer_role_addr">Roles::spec_has_designated_dealer_role_addr</a>(addr);
</code></pre>


If there is a DualAttestation credential, account has designated dealer role


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <b>exists</b>&lt;<a href="DualAttestation.md#0x1_DualAttestation_Credential">DualAttestation::Credential</a>&gt;(addr):
    <a href="Roles.md#0x1_Roles_spec_has_designated_dealer_role_addr">Roles::spec_has_designated_dealer_role_addr</a>(addr)
    || <a href="Roles.md#0x1_Roles_spec_has_parent_VASP_role_addr">Roles::spec_has_parent_VASP_role_addr</a>(addr);
</code></pre>


Every address that has a published account has a published FreezingBit


<pre><code><b>invariant</b> <b>forall</b> addr: address <b>where</b> <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr): <b>exists</b>&lt;<a href="AccountFreezing.md#0x1_AccountFreezing_FreezingBit">AccountFreezing::FreezingBit</a>&gt;(addr);
</code></pre>



<a name="@Helper_Functions_and_Schemas_12"></a>

### Helper Functions and Schemas


<a name="@Capabilities_13"></a>

#### Capabilities


Returns field <code>key_rotation_capability</code> of the DiemAccount under <code>addr</code>.


<a name="0x1_DiemAccount_spec_get_key_rotation_cap_field"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_get_key_rotation_cap_field">spec_get_key_rotation_cap_field</a>(addr: address): <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a>&gt; {
    <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).key_rotation_capability
}
</code></pre>


Returns the KeyRotationCapability of the field <code>key_rotation_capability</code>.


<a name="0x1_DiemAccount_spec_get_key_rotation_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_get_key_rotation_cap">spec_get_key_rotation_cap</a>(addr: address): <a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a> {
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(<a href="DiemAccount.md#0x1_DiemAccount_spec_get_key_rotation_cap_field">spec_get_key_rotation_cap_field</a>(addr))
}
<a name="0x1_DiemAccount_spec_has_key_rotation_cap"></a>
<b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_has_key_rotation_cap">spec_has_key_rotation_cap</a>(addr: address): bool {
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(<a href="DiemAccount.md#0x1_DiemAccount_spec_get_key_rotation_cap_field">spec_get_key_rotation_cap_field</a>(addr))
}
</code></pre>


Returns true if the DiemAccount at <code>addr</code> holds
<code><a href="DiemAccount.md#0x1_DiemAccount_KeyRotationCapability">KeyRotationCapability</a></code> for itself.


<a name="0x1_DiemAccount_spec_holds_own_key_rotation_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_key_rotation_cap">spec_holds_own_key_rotation_cap</a>(addr: address): bool {
    <a href="DiemAccount.md#0x1_DiemAccount_spec_has_key_rotation_cap">spec_has_key_rotation_cap</a>(addr)
    && addr == <a href="DiemAccount.md#0x1_DiemAccount_spec_get_key_rotation_cap">spec_get_key_rotation_cap</a>(addr).account_address
}
</code></pre>


Returns true if <code><a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a></code> is published.


<a name="0x1_DiemAccount_spec_has_account_operations_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_has_account_operations_cap">spec_has_account_operations_cap</a>(): bool {
    <b>exists</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount_AccountOperationsCapability">AccountOperationsCapability</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())
}
</code></pre>


Returns field <code>withdraw_capability</code> of DiemAccount under <code>addr</code>.


<a name="0x1_DiemAccount_spec_get_withdraw_cap_field"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap_field">spec_get_withdraw_cap_field</a>(addr: address): <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a>&gt; {
    <b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).withdraw_capability
}
</code></pre>


Returns the WithdrawCapability of the field <code>withdraw_capability</code>.


<a name="0x1_DiemAccount_spec_get_withdraw_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap">spec_get_withdraw_cap</a>(addr: address): <a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a> {
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(<a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap_field">spec_get_withdraw_cap_field</a>(addr))
}
</code></pre>


Returns true if the DiemAccount at <code>addr</code> holds a <code><a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a></code>.


<a name="0x1_DiemAccount_spec_has_withdraw_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_has_withdraw_cap">spec_has_withdraw_cap</a>(addr: address): bool {
    <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(<a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap_field">spec_get_withdraw_cap_field</a>(addr))
}
</code></pre>


Returns true if the DiemAccount at <code>addr</code> holds <code><a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">WithdrawCapability</a></code> for itself.


<a name="0x1_DiemAccount_spec_holds_own_withdraw_cap"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_own_withdraw_cap">spec_holds_own_withdraw_cap</a>(addr: address): bool {
    <a href="DiemAccount.md#0x1_DiemAccount_spec_has_withdraw_cap">spec_has_withdraw_cap</a>(addr)
    && addr == <a href="DiemAccount.md#0x1_DiemAccount_spec_get_withdraw_cap">spec_get_withdraw_cap</a>(addr).account_address
}
</code></pre>


Returns true of the account holds a delegated withdraw capability.


<a name="0x1_DiemAccount_spec_holds_delegated_withdraw_capability"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_spec_holds_delegated_withdraw_capability">spec_holds_delegated_withdraw_capability</a>(addr: address): bool {
    <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr) && <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(<b>global</b>&lt;<a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>&gt;(addr).withdraw_capability)
}
</code></pre>



<a name="@Prologue_14"></a>

#### Prologue



<a name="0x1_DiemAccount_prologue_guarantees"></a>


<pre><code><b>fun</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender: signer) : bool {
   <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_spec_address_of">Signer::spec_address_of</a>(sender);
   <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() && <a href="DiemAccount.md#0x1_DiemAccount_exists_at">exists_at</a>(addr) && !<a href="AccountFreezing.md#0x1_AccountFreezing_account_is_frozen">AccountFreezing::account_is_frozen</a>(addr)
}
</code></pre>


Used in transaction script to specify properties checked by the prologue.


<a name="0x1_DiemAccount_TransactionChecks"></a>


<pre><code><b>schema</b> <a href="DiemAccount.md#0x1_DiemAccount_TransactionChecks">TransactionChecks</a> {
    sender: signer;
    <b>requires</b> <a href="DiemAccount.md#0x1_DiemAccount_prologue_guarantees">prologue_guarantees</a>(sender);
}
</code></pre>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
