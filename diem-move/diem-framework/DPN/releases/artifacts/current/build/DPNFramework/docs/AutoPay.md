
<a name="0x1_AutoPay"></a>

# Module `0x1::AutoPay`


<a name="@Summary_0"></a>

## Summary

This module enables automatic payments from accounts to community wallets at epoch boundaries.


-  [Summary](#@Summary_0)
-  [Resource `Tick`](#0x1_AutoPay_Tick)
-  [Resource `AccountLimitsEnable`](#0x1_AutoPay_AccountLimitsEnable)
-  [Resource `Data`](#0x1_AutoPay_Data)
-  [Resource `UserAutoPay`](#0x1_AutoPay_UserAutoPay)
-  [Resource `AccountList`](#0x1_AutoPay_AccountList)
-  [Struct `Payment`](#0x1_AutoPay_Payment)
-  [Constants](#@Constants_1)
-  [Function `tick`](#0x1_AutoPay_tick)
-  [Function `reconfig_reset_tick`](#0x1_AutoPay_reconfig_reset_tick)
-  [Function `initialize`](#0x1_AutoPay_initialize)
-  [Function `enable_account_limits`](#0x1_AutoPay_enable_account_limits)
-  [Function `process_autopay`](#0x1_AutoPay_process_autopay)
-  [Function `process_autopay_account`](#0x1_AutoPay_process_autopay_account)
-  [Function `process_autopay_payment`](#0x1_AutoPay_process_autopay_payment)
-  [Function `enable_autopay`](#0x1_AutoPay_enable_autopay)
-  [Function `disable_autopay`](#0x1_AutoPay_disable_autopay)
-  [Function `create_instruction`](#0x1_AutoPay_create_instruction)
-  [Function `delete_instruction`](#0x1_AutoPay_delete_instruction)
-  [Function `migrate_instructions`](#0x1_AutoPay_migrate_instructions)
-  [Function `is_enabled`](#0x1_AutoPay_is_enabled)
-  [Function `query_instruction`](#0x1_AutoPay_query_instruction)
-  [Function `get_enabled`](#0x1_AutoPay_get_enabled)
-  [Function `find`](#0x1_AutoPay_find)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_AutoPay_Tick"></a>

## Resource `Tick`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>triggered: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_AccountLimitsEnable"></a>

## Resource `AccountLimitsEnable`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>enabled: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_Data"></a>

## Resource `Data`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>payments: vector&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">AutoPay::Payment</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_UserAutoPay"></a>

## Resource `UserAutoPay`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>payments: vector&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">AutoPay::Payment</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>prev_bal: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_AccountList"></a>

## Resource `AccountList`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>accounts: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_Payment"></a>

## Struct `Payment`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>uid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>in_type: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>payee: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>end_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>prev_bal: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>amt: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="0x1_AutoPay_EPAYEE_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_EPAYEE_DOES_NOT_EXIST">EPAYEE_DOES_NOT_EXIST</a>: u64 = 10017;
</code></pre>



<a name="0x1_AutoPay_AUTOPAY_ID_DOES_NOT_EXIST"></a>

Attempting to query a non-existent autpay ID


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_AUTOPAY_ID_DOES_NOT_EXIST">AUTOPAY_ID_DOES_NOT_EXIST</a>: u64 = 10019;
</code></pre>



<a name="0x1_AutoPay_EAUTOPAY_NOT_ENABLED"></a>

The account does not have autopay enabled.


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_EAUTOPAY_NOT_ENABLED">EAUTOPAY_NOT_ENABLED</a>: u64 = 10018;
</code></pre>



<a name="0x1_AutoPay_FIXED_ONCE"></a>

send a certain amount once at the next tick payment type


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_FIXED_ONCE">FIXED_ONCE</a>: u8 = 3;
</code></pre>



<a name="0x1_AutoPay_FIXED_RECURRING"></a>

send a certain amount each tick until end_epoch is reached payment type


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_FIXED_RECURRING">FIXED_RECURRING</a>: u8 = 2;
</code></pre>



<a name="0x1_AutoPay_INVALID_PAYMENT_TYPE"></a>

Invalid payment type given


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_INVALID_PAYMENT_TYPE">INVALID_PAYMENT_TYPE</a>: u64 = 10020;
</code></pre>



<a name="0x1_AutoPay_INVALID_PERCENTAGE"></a>

Attempt to give more than 100.00% to one payee


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_INVALID_PERCENTAGE">INVALID_PERCENTAGE</a>: u64 = 10022;
</code></pre>



<a name="0x1_AutoPay_MAX_NUMBER_OF_INSTRUCTIONS"></a>



<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_MAX_NUMBER_OF_INSTRUCTIONS">MAX_NUMBER_OF_INSTRUCTIONS</a>: u64 = 30;
</code></pre>



<a name="0x1_AutoPay_MAX_PERCENTAGE"></a>



<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_MAX_PERCENTAGE">MAX_PERCENTAGE</a>: u64 = 10000;
</code></pre>



<a name="0x1_AutoPay_MAX_TYPE"></a>

Attempted to send funds to an account that does not exist
Maximum value for the Payment type selection


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_MAX_TYPE">MAX_TYPE</a>: u8 = 3;
</code></pre>



<a name="0x1_AutoPay_PERCENT_OF_BALANCE"></a>

send percent of balance at end of epoch payment type


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_BALANCE">PERCENT_OF_BALANCE</a>: u8 = 0;
</code></pre>



<a name="0x1_AutoPay_PERCENT_OF_CHANGE"></a>

send percent of the change in balance since the last tick payment type


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_CHANGE">PERCENT_OF_CHANGE</a>: u8 = 1;
</code></pre>



<a name="0x1_AutoPay_TOO_MANY_INSTRUCTIONS"></a>

Attempt to add instruction when too many already exist


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_TOO_MANY_INSTRUCTIONS">TOO_MANY_INSTRUCTIONS</a>: u64 = 10021;
</code></pre>



<a name="0x1_AutoPay_UID_TAKEN"></a>

Attempt to use a UID that is already taken


<pre><code><b>const</b> <a href="AutoPay.md#0x1_AutoPay_UID_TAKEN">UID_TAKEN</a>: u64 = 10023;
</code></pre>



<a name="0x1_AutoPay_tick"></a>

## Function `tick`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_tick">tick</a>(vm: &signer): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_tick">tick</a>(vm: &signer): bool <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>if</b> (<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(@DiemRoot)) {
    // The tick is triggered at the beginning of each epoch
    <b>let</b> tick_state = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
    <b>if</b> (!tick_state.triggered) {
      tick_state.triggered = <b>true</b>;
      <b>return</b> <b>true</b>
    };
  } <b>else</b> {
    // initialize is called here, in addition <b>to</b> genesis, in order <b>to</b> facilitate upgrades
    <a href="AutoPay.md#0x1_AutoPay_initialize">initialize</a>(vm);
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_AutoPay_reconfig_reset_tick"></a>

## Function `reconfig_reset_tick`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">reconfig_reset_tick</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">reconfig_reset_tick</a>(vm: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>let</b> tick_state = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
  tick_state.triggered = <b>false</b>;
}
</code></pre>



</details>

<a name="0x1_AutoPay_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_initialize">initialize</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_initialize">initialize</a>(sender: &signer) {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(sender);

  // initialize resources for the <b>module</b>
  <b>move_to</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(
    sender,
    <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> {
      accounts: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      // current_epoch: 0, // todo: unused, delete?
    }
  );
  <b>move_to</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(sender, <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> {triggered: <b>false</b>});
  <b>move_to</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a>&gt;(sender, <a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a> {enabled: <b>false</b>});

  // set this <b>to</b> enable escrow of funds. Not used unless account limits
  // are enabled (i.e. AccoundLimitsEnable set <b>to</b> <b>true</b>)
  <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow_root">DiemAccount::initialize_escrow_root</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender);
}
</code></pre>



</details>

<a name="0x1_AutoPay_enable_account_limits"></a>

## Function `enable_account_limits`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_enable_account_limits">enable_account_limits</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_enable_account_limits">enable_account_limits</a>(sender: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(sender);
  <b>let</b> limits_enable = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  limits_enable.enabled = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_AutoPay_process_autopay"></a>

## Function `process_autopay`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay">process_autopay</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay">process_autopay</a>(
  vm: &signer,
) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>, <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  // Only account 0x0 should be triggering this autopayment each block
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);

  // Go through all accounts in <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>
  // This is the list of accounts which currently have autopay enabled
  <b>let</b> account_list = &<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(
    @DiemRoot
  ).accounts;
  <b>let</b> accounts_length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(account_list);
  <b>let</b> account_idx = 0;
  <b>while</b> (account_idx &lt; accounts_length) {
    <b>let</b> account_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(account_list, account_idx);
    <a href="AutoPay.md#0x1_AutoPay_process_autopay_account">process_autopay_account</a>(vm, account_addr);
    account_idx = account_idx + 1;
  };
}
</code></pre>



</details>

<a name="0x1_AutoPay_process_autopay_account"></a>

## Function `process_autopay_account`



<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay_account">process_autopay_account</a>(vm: &signer, account_addr: &<b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay_account">process_autopay_account</a>(
  vm: &signer,
  account_addr: &<b>address</b>,
) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(*account_addr)) <b>return</b>;

  // Get the payment list from the account
  <b>let</b> my_autopay_state = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(*account_addr);
  <b>let</b> payments = &<b>mut</b> my_autopay_state.payments;
  <b>let</b> payments_len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments);
  <b>let</b> payments_idx = 0;
  <b>let</b> pre_run_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr);

  <b>let</b> bal_change_since_last_run = <b>if</b> (pre_run_bal &gt; my_autopay_state.prev_bal) {
    pre_run_bal - my_autopay_state.prev_bal
  } <b>else</b> { 0 };
  // go through the pledges
  <b>while</b> (payments_idx &lt; payments_len) {
    <b>let</b> payment = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, payments_idx);
    // Make a payment <b>if</b> one is required/allowed
    <b>let</b> delete_payment = <a href="AutoPay.md#0x1_AutoPay_process_autopay_payment">process_autopay_payment</a>(
      vm, account_addr, payment, bal_change_since_last_run
    );
    // Delete any expired payments and increment idx (or decrement list size)
    <b>if</b> (delete_payment == <b>true</b>) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, payments_idx);
      payments_len = payments_len - 1;
    }
    <b>else</b> {
      payments_idx = payments_idx + 1;
    };
  };

  my_autopay_state.prev_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr);
}
</code></pre>



</details>

<a name="0x1_AutoPay_process_autopay_payment"></a>

## Function `process_autopay_payment`



<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay_payment">process_autopay_payment</a>(vm: &signer, account_addr: &<b>address</b>, payment: &<b>mut</b> <a href="AutoPay.md#0x1_AutoPay_Payment">AutoPay::Payment</a>, bal_change_since_last_run: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_process_autopay_payment">process_autopay_payment</a>(
  vm: &signer,
  account_addr: &<b>address</b>,
  payment: &<b>mut</b> <a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>,
  bal_change_since_last_run: u64,
): bool {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  <b>let</b> account_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr);

  // If payment end epoch is greater, it's not an active payment
  // anymore, so delete it, does not <b>apply</b> <b>to</b> fixed once payment
  // (it is deleted once it is sent)
  <b>if</b> (payment.end_epoch &gt;= epoch || payment.in_type == <a href="AutoPay.md#0x1_AutoPay_FIXED_ONCE">FIXED_ONCE</a>) {
    // A payment will happen now
    // Obtain the amount <b>to</b> pay
    // IMPORTANT there are two digits for scaling representation.

    // an autopay instruction of 12.34% is scaled by two orders,
    // and represented in <a href="AutoPay.md#0x1_AutoPay">AutoPay</a> <b>as</b> `1234`.
    <b>let</b> amount = <b>if</b> (payment.in_type == <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_BALANCE">PERCENT_OF_BALANCE</a>) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(
        account_bal,
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(payment.amt, 10000)
      )
    } <b>else</b> <b>if</b> (payment.in_type == <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_CHANGE">PERCENT_OF_CHANGE</a>) {
      <b>if</b> (bal_change_since_last_run &gt; 0 ) {
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(
          bal_change_since_last_run,
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(payment.amt, 10000)
        )
      } <b>else</b> {
        // <b>if</b> account balance hasn't gone up, no value is transferred
        0
      }
    } <b>else</b> {
      // in remaining cases, payment is simple amount given, not a percentage
      payment.amt
    };

    <b>if</b> (amount != 0 && amount &lt;= account_bal) {
       <a href="DiemAccount.md#0x1_DiemAccount_vm_pay_from">DiemAccount::vm_pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
            *account_addr, payment.payee, amount, b"autopay", b"", vm
          );
    };

    // TODO: this would be deprecated.
    payment.prev_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr);
  };

  // <b>if</b> the payment expired or is one-time only, it may be deleted
  payment.in_type == <a href="AutoPay.md#0x1_AutoPay_FIXED_ONCE">FIXED_ONCE</a> || payment.end_epoch &lt;= epoch
}
</code></pre>



</details>

<a name="0x1_AutoPay_enable_autopay"></a>

## Function `enable_autopay`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_enable_autopay">enable_autopay</a>(acc: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_enable_autopay">enable_autopay</a>(acc: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>{
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(acc);
  // append <b>to</b> account list in system state 0x0
  <b>let</b> accounts = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(
    @DiemRoot
  ).accounts;
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(accounts, &addr)) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(accounts, *&addr);
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(*&addr)) {
    // Initialize the instructions <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> on user account state
    <b>move_to</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(acc, <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
      payments: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(),
      prev_bal: <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr),
    });
  };

  // Initialize Escrow data
  <a href="DiemAccount.md#0x1_DiemAccount_initialize_escrow">DiemAccount::initialize_escrow</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(acc);
}
</code></pre>



</details>

<a name="0x1_AutoPay_disable_autopay"></a>

## Function `disable_autopay`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_disable_autopay">disable_autopay</a>(acc: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_disable_autopay">disable_autopay</a>(acc: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>, <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(acc);
  <b>if</b> (!<a href="AutoPay.md#0x1_AutoPay_is_enabled">is_enabled</a>(addr)) <b>return</b>;

  // We destroy the data resource for sender
  <b>let</b> sender_data = <b>move_from</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(addr);
  <b>let</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> { payments: _ , prev_bal: _ } = sender_data;

  // pop that account from <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>
  <b>let</b> accounts = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(
    @DiemRoot
  ).accounts;
  <b>let</b> (status, index) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(accounts, &addr);
  <b>if</b> (status) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<b>address</b>&gt;(accounts, index);
  }
}
</code></pre>



</details>

<a name="0x1_AutoPay_create_instruction"></a>

## Function `create_instruction`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_create_instruction">create_instruction</a>(sender: &signer, uid: u64, in_type: u8, payee: <b>address</b>, end_epoch: u64, amt: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_create_instruction">create_instruction</a>(
  sender: &signer,
  uid: u64,
  in_type: u8,
  payee: <b>address</b>,
  end_epoch: u64,
  amt: u64
) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // Confirm that no payment <b>exists</b> <b>with</b> the same uid
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(addr, uid);
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>&lt;u64&gt;(&index), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="AutoPay.md#0x1_AutoPay_UID_TAKEN">UID_TAKEN</a>));

  // // TODO: This check already <b>exists</b> at the time of execution.
  // <b>if</b> (<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountLimitsEnable">AccountLimitsEnable</a>&gt;(@DiemRoot).enabled) {
  //   <b>assert</b>!(<a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">CommunityWallet::is_comm</a>(payee), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(PAYEE_NOT_COMMUNITY_WALLET));
  // };

  <b>let</b> payments = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(addr).payments;
  <b>assert</b>!(
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments) &lt; <a href="AutoPay.md#0x1_AutoPay_MAX_NUMBER_OF_INSTRUCTIONS">MAX_NUMBER_OF_INSTRUCTIONS</a>,
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(<a href="AutoPay.md#0x1_AutoPay_TOO_MANY_INSTRUCTIONS">TOO_MANY_INSTRUCTIONS</a>)
  );
  // This is not a necessary check at genesis.
  // TODO: the genesis timestamp is not correctly identifying transactions in genesis.
  // <b>if</b> (!<a href="DiemTimestamp.md#0x1_DiemTimestamp_is_genesis">DiemTimestamp::is_genesis</a>()) {
  <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; 1) {
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_exists_at">DiemAccount::exists_at</a>(payee), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="AutoPay.md#0x1_AutoPay_EPAYEE_DOES_NOT_EXIST">EPAYEE_DOES_NOT_EXIST</a>));
  };

  <b>assert</b>!(in_type &lt;= <a href="AutoPay.md#0x1_AutoPay_MAX_TYPE">MAX_TYPE</a>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="AutoPay.md#0x1_AutoPay_INVALID_PAYMENT_TYPE">INVALID_PAYMENT_TYPE</a>));

  <b>if</b> (in_type == <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_BALANCE">PERCENT_OF_BALANCE</a> || in_type == <a href="AutoPay.md#0x1_AutoPay_PERCENT_OF_CHANGE">PERCENT_OF_CHANGE</a>) {
    <b>assert</b>!(amt &lt;= <a href="AutoPay.md#0x1_AutoPay_MAX_PERCENTAGE">MAX_PERCENTAGE</a>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="AutoPay.md#0x1_AutoPay_INVALID_PERCENTAGE">INVALID_PERCENTAGE</a>));
  };
  <b>let</b> account_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(addr);

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, <a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a> {
    uid: uid,
    in_type: in_type,
    payee: payee,
    end_epoch: end_epoch,
    prev_bal: account_bal,
    amt: amt,
  });
}
</code></pre>



</details>

<a name="0x1_AutoPay_delete_instruction"></a>

## Function `delete_instruction`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_delete_instruction">delete_instruction</a>(account: &signer, uid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_delete_instruction">delete_instruction</a>(account: &signer, uid: u64) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(addr, uid);

  // Case when the payment <b>to</b> be deleted doesn't actually exist
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;u64&gt;(&index), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="AutoPay.md#0x1_AutoPay_AUTOPAY_ID_DOES_NOT_EXIST">AUTOPAY_ID_DOES_NOT_EXIST</a>));

  <b>let</b> payments = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(addr).payments;
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>&lt;u64&gt;(&<b>mut</b> index));
}
</code></pre>



</details>

<a name="0x1_AutoPay_migrate_instructions"></a>

## Function `migrate_instructions`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_migrate_instructions">migrate_instructions</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_migrate_instructions">migrate_instructions</a>(account: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>, <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>if</b> (!<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(addr) || !<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(addr)) <b>return</b>;

  <b>let</b> <b>old</b> = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(addr);
  <b>let</b> new = <b>borrow_global_mut</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(addr);
  new.payments = *&<b>old</b>.payments;

  <b>old</b>.payments = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>();
}
</code></pre>



</details>

<a name="0x1_AutoPay_is_enabled"></a>

## Function `is_enabled`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_is_enabled">is_enabled</a>(account: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_is_enabled">is_enabled</a>(account: <b>address</b>): bool <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> {
  <b>let</b> accounts = &<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(
      @DiemRoot
    ).accounts;
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(accounts, &account)
}
</code></pre>



</details>

<a name="0x1_AutoPay_query_instruction"></a>

## Function `query_instruction`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_query_instruction">query_instruction</a>(account: <b>address</b>, uid: u64): (u8, <b>address</b>, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_query_instruction">query_instruction</a>(account: <b>address</b>, uid: u64): (u8, <b>address</b>, u64, u64) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account, uid);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>&lt;u64&gt;(&index)) {
    // Case <b>where</b> payment is not found
    <b>return</b> (0, @0x0, 0, 0)
  } <b>else</b> {
    <b>let</b> payments = &<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(account).payments;
    <b>let</b> payment = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(payments, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>&lt;u64&gt;(&<b>mut</b> index));
    <b>return</b> (payment.in_type, payment.payee, payment.end_epoch, payment.amt)
  }
}
</code></pre>



</details>

<a name="0x1_AutoPay_get_enabled"></a>

## Function `get_enabled`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_get_enabled">get_enabled</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_get_enabled">get_enabled</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> {
 *&<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(@VMReserved).accounts
}
</code></pre>



</details>

<a name="0x1_AutoPay_find"></a>

## Function `find`



<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account: <b>address</b>, uid: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account: <b>address</b>, uid: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt; <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a> {
  <b>let</b> payments = &<b>borrow_global</b>&lt;<a href="AutoPay.md#0x1_AutoPay_UserAutoPay">UserAutoPay</a>&gt;(account).payments;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(payments);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> payment = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, i);
    <b>if</b> (payment.uid == uid) {
      <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>&lt;u64&gt;(i)
    };
    i = i + 1;
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;u64&gt;()
}
</code></pre>



</details>
