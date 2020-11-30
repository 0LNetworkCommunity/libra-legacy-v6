
<a name="0x1_AutoPay"></a>

# Module `0x1::AutoPay`



-  [Resource `Tick`](#0x1_AutoPay_Tick)
-  [Resource `Data`](#0x1_AutoPay_Data)
-  [Resource `AccountList`](#0x1_AutoPay_AccountList)
-  [Struct `Payment`](#0x1_AutoPay_Payment)
-  [Function `tick`](#0x1_AutoPay_tick)
-  [Function `reconfig_reset_tick`](#0x1_AutoPay_reconfig_reset_tick)
-  [Function `initialize`](#0x1_AutoPay_initialize)
-  [Function `process_autopay`](#0x1_AutoPay_process_autopay)
-  [Function `enable_autopay`](#0x1_AutoPay_enable_autopay)
-  [Function `disable_autopay`](#0x1_AutoPay_disable_autopay)
-  [Function `create_instruction`](#0x1_AutoPay_create_instruction)
-  [Function `delete_instruction`](#0x1_AutoPay_delete_instruction)
-  [Function `is_enabled`](#0x1_AutoPay_is_enabled)
-  [Function `query_instruction`](#0x1_AutoPay_query_instruction)
-  [Function `find`](#0x1_AutoPay_find)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
<b>use</b> <a href="LibraConfig.md#0x1_LibraConfig">0x1::LibraConfig</a>;
<b>use</b> <a href="LibraTimestamp.md#0x1_LibraTimestamp">0x1::LibraTimestamp</a>;
<b>use</b> <a href="Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_AutoPay_Tick"></a>

## Resource `Tick`



<pre><code><b>resource</b> <b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>
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

<a name="0x1_AutoPay_Data"></a>

## Resource `Data`



<pre><code><b>resource</b> <b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a>
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

<a name="0x1_AutoPay_AccountList"></a>

## Resource `AccountList`



<pre><code><b>resource</b> <b>struct</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>accounts: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>current_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_Payment"></a>

## Struct `Payment`



<pre><code><b>struct</b> <a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>
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
<code>payee: address</code>
</dt>
<dd>

</dd>
<dt>
<code>end_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>percentage: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AutoPay_tick"></a>

## Function `tick`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_tick">tick</a>(vm: &signer): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_tick">tick</a>(vm: &signer): bool <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 0101014010);
  <b>assert</b>(<b>exists</b>&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()), 0101024010);

  <b>let</b> tick_state = borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));

  <b>if</b> (!tick_state.triggered) {
    <b>let</b> timer = <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_seconds">LibraTimestamp::now_seconds</a>() - <a href="Epoch.md#0x1_Epoch_get_timer_seconds_start">Epoch::get_timer_seconds_start</a>(vm);
    <b>let</b> tick_interval = <a href="Globals.md#0x1_Globals_get_epoch_length">Globals::get_epoch_length</a>();
    <b>if</b> (timer &gt; tick_interval/2) {
      tick_state.triggered = <b>true</b>;
      <b>return</b> <b>true</b>
    }
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


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">reconfig_reset_tick</a>(vm: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>{
  <b>let</b> tick_state = borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
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
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 0101014010);
  move_to&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(sender, <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> { accounts: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(), current_epoch: 0, });
  move_to&lt;<a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a>&gt;(sender, <a href="AutoPay.md#0x1_AutoPay_Tick">Tick</a> {triggered: <b>false</b>})
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
) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>, <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {
  // Only account 0x0 should be triggering this autopayment each block
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 0101064010);

  <b>let</b> epoch = <a href="LibraConfig.md#0x1_LibraConfig_get_current_epoch">LibraConfig::get_current_epoch</a>();

  // Go through all accounts in <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>
  // This is the list of accounts which currently have autopay enabled
  <b>let</b> account_list = &borrow_global&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).accounts;
  <b>let</b> accounts_length = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(account_list);
  <b>let</b> account_idx = 0;

  <b>while</b> (account_idx &lt; accounts_length) {

    <b>let</b> account_addr = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(account_list, account_idx);

    // Obtain the account balance
    <b>let</b> account_bal = <a href="LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr);

    // Go through all payments for this account and pay
    <b>let</b> payments = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(*account_addr).payments;
    <b>let</b> payments_len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments);
    <b>let</b> payments_idx = 0;

    <b>while</b> (payments_idx &lt; payments_len) {
      <b>let</b> payment = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, payments_idx);
      // If payment end epoch is greater, it's not an active payment anymore, so delete it
      <b>if</b> (payment.end_epoch &gt;= epoch) {
        // A payment will happen now
        // Obtain the amount <b>to</b> pay from percentage and balance
        <b>let</b> amount = <a href="FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(account_bal , <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(payment.percentage, 100));
        <a href="LibraAccount.md#0x1_LibraAccount_make_payment">LibraAccount::make_payment</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*account_addr, payment.payee, amount, x"", x"", vm);
      };
      // ToDo: might want <b>to</b> delete inactive instructions <b>to</b> save memory
      payments_idx = payments_idx + 1;
    };
    account_idx = account_idx + 1;
  };
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
  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(acc);
  // append <b>to</b> account list
  <b>let</b> accounts = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).accounts;
  <b>if</b> (!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(accounts, &addr)) {
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(accounts, addr);
  };
  // Initialize the instructions <a href="AutoPay.md#0x1_AutoPay_Data">Data</a>
  move_to&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(acc, <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> { payments: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;()});
}
</code></pre>



</details>

<a name="0x1_AutoPay_disable_autopay"></a>

## Function `disable_autopay`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_disable_autopay">disable_autopay</a>(acc: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_disable_autopay">disable_autopay</a>(acc: &signer) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>, <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {

  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(acc);

  // We destroy the data <b>resource</b> for sender
  <b>let</b> sender_data = move_from&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(addr);
  <b>let</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> { payments: _ } = sender_data;

  // pop that account from <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>
  <b>let</b> accounts = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).accounts;
  <b>let</b> (status, index) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(accounts, &addr);
  <b>if</b> (status) {
    <a href="Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;address&gt;(accounts, index);
  }
}
</code></pre>



</details>

<a name="0x1_AutoPay_create_instruction"></a>

## Function `create_instruction`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_create_instruction">create_instruction</a>(sender: &signer, uid: u64, payee: address, end_epoch: u64, percentage: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_create_instruction">create_instruction</a>(
  sender: &signer,
  uid: u64,
  payee: address,
  end_epoch: u64,
  percentage: u64
) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {

  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // Confirm that no payment <b>exists</b> <b>with</b> the same uid
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(addr, uid);
  <b>if</b> (<a href="Option.md#0x1_Option_is_some">Option::is_some</a>&lt;u64&gt;(&index)) {
    // This is the case <b>where</b> the payment uid already <b>exists</b> in the vector
    <b>assert</b>(<b>false</b>, 010104011021);
  };
  <b>let</b> payments = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(addr).payments;
  <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, <a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a> {
    // name: name,
    uid: uid,
    payee: payee,
    end_epoch: end_epoch,
    percentage: percentage,
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


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_delete_instruction">delete_instruction</a>(account: &signer, uid: u64) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {
  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(addr, uid);
  <b>if</b> (<a href="Option.md#0x1_Option_is_none">Option::is_none</a>&lt;u64&gt;(&index)) {
    // Case when the payment <b>to</b> be deleted doesn't actually exist
    <b>assert</b>(<b>false</b>, 010105012040);
  };
  <b>let</b> payments = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(addr).payments;
  <a href="Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, <a href="Option.md#0x1_Option_extract">Option::extract</a>&lt;u64&gt;(&<b>mut</b> index));
}
</code></pre>



</details>

<a name="0x1_AutoPay_is_enabled"></a>

## Function `is_enabled`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_is_enabled">is_enabled</a>(account: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_is_enabled">is_enabled</a>(account: address): bool <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a> {
  <b>let</b> accounts = &<b>mut</b> borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_AccountList">AccountList</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).accounts;
  <b>if</b> (<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(accounts, &account)) {
    <b>return</b> <b>true</b>
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_AutoPay_query_instruction"></a>

## Function `query_instruction`



<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_query_instruction">query_instruction</a>(account: address, uid: u64): (address, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="AutoPay.md#0x1_AutoPay_query_instruction">query_instruction</a>(account: address, uid: u64): (address, u64, u64) <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {
  // TODO: This can be made faster <b>if</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a>.payments is stored <b>as</b> a BST sorted by
  <b>let</b> index = <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account, uid);
  <b>if</b> (<a href="Option.md#0x1_Option_is_none">Option::is_none</a>&lt;u64&gt;(&index)) {
    // Case <b>where</b> payment is not found
    <b>return</b> (0x0, 0, 0)
  } <b>else</b> {
    <b>let</b> payments = &borrow_global_mut&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(account).payments;
    <b>let</b> payment = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(payments, <a href="Option.md#0x1_Option_extract">Option::extract</a>&lt;u64&gt;(&<b>mut</b> index));
    <b>return</b> (payment.payee, payment.end_epoch, payment.percentage)
  }
}
</code></pre>



</details>

<a name="0x1_AutoPay_find"></a>

## Function `find`



<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account: address, uid: u64): <a href="Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="AutoPay.md#0x1_AutoPay_find">find</a>(account: address, uid: u64): <a href="Option.md#0x1_Option">Option</a>&lt;u64&gt; <b>acquires</b> <a href="AutoPay.md#0x1_AutoPay_Data">Data</a> {
  <b>let</b> payments = &borrow_global&lt;<a href="AutoPay.md#0x1_AutoPay_Data">Data</a>&gt;(account).payments;
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(payments);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> payment = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="AutoPay.md#0x1_AutoPay_Payment">Payment</a>&gt;(payments, i);
    <b>if</b> (payment.uid == uid) {
      <b>return</b> <a href="Option.md#0x1_Option_some">Option::some</a>&lt;u64&gt;(i)
    };
    i = i + 1;
  };
  <a href="Option.md#0x1_Option_none">Option::none</a>&lt;u64&gt;()
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
