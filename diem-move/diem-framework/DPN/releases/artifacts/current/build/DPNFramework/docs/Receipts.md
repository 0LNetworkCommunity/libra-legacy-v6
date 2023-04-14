
<a name="0x1_Receipts"></a>

# Module `0x1::Receipts`



-  [Resource `UserReceipts`](#0x1_Receipts_UserReceipts)
-  [Function `init`](#0x1_Receipts_init)
-  [Function `fork_migrate`](#0x1_Receipts_fork_migrate)
-  [Function `is_init`](#0x1_Receipts_is_init)
-  [Function `write_receipt_vm`](#0x1_Receipts_write_receipt_vm)
-  [Function `write_receipt`](#0x1_Receipts_write_receipt)
-  [Function `read_receipt`](#0x1_Receipts_read_receipt)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Receipts_UserReceipts"></a>

## Resource `UserReceipts`



<pre><code><b>struct</b> <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>destination: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>cumulative: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>last_payment_timestamp: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>last_payment_value: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Receipts_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_init">init</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_init">init</a>(account: &signer) {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>if</b> (!<b>exists</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(addr)) {
    <b>move_to</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(
      account,
      <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
        destination: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
        last_payment_timestamp: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
        last_payment_value: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
        cumulative: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
      }
    )
  };
}
</code></pre>



</details>

<a name="0x1_Receipts_fork_migrate"></a>

## Function `fork_migrate`



<pre><code><b>fun</b> <a href="Receipts.md#0x1_Receipts_fork_migrate">fork_migrate</a>(vm: &signer, account: &signer, destination: <b>address</b>, cumulative: u64, last_payment_timestamp: u64, last_payment_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Receipts.md#0x1_Receipts_fork_migrate">fork_migrate</a>(
  vm: &signer,
  account: &signer,
  destination: <b>address</b>,
  cumulative: u64,
  last_payment_timestamp: u64,
  last_payment_value: u64,
) <b>acquires</b> <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> {

  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>assert</b>!(<a href="Receipts.md#0x1_Receipts_is_init">is_init</a>(addr), 0);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.destination, destination);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.cumulative, cumulative * <a href="Globals.md#0x1_Globals_get_coin_split_factor">Globals::get_coin_split_factor</a>());
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.last_payment_timestamp, last_payment_timestamp);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.last_payment_value, last_payment_value * <a href="Globals.md#0x1_Globals_get_coin_split_factor">Globals::get_coin_split_factor</a>());
}
</code></pre>



</details>

<a name="0x1_Receipts_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_is_init">is_init</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_is_init">is_init</a>(addr: <b>address</b>):bool {
  <b>exists</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_Receipts_write_receipt_vm"></a>

## Function `write_receipt_vm`



<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_write_receipt_vm">write_receipt_vm</a>(sender: &signer, payer: <b>address</b>, destination: <b>address</b>, value: u64): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_write_receipt_vm">write_receipt_vm</a>(sender: &signer, payer: <b>address</b>, destination: <b>address</b>, value: u64):(u64, u64, u64) <b>acquires</b> <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
    // TODO: make a function for user <b>to</b> write own receipt.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(sender);
    <a href="Receipts.md#0x1_Receipts_write_receipt">write_receipt</a>(payer, destination, value)
}
</code></pre>



</details>

<a name="0x1_Receipts_write_receipt"></a>

## Function `write_receipt`

Restricted to DiemAccount, we need to write receipts for certain users, like to DonorDirected Accounts.
Core Devs: Danger: only DiemAccount can use this.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Receipts.md#0x1_Receipts_write_receipt">write_receipt</a>(payer: <b>address</b>, destination: <b>address</b>, value: u64): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Receipts.md#0x1_Receipts_write_receipt">write_receipt</a>(payer: <b>address</b>, destination: <b>address</b>, value: u64):(u64, u64, u64) <b>acquires</b> <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
    // TODO: make a function for user <b>to</b> write own receipt.
    <b>if</b> (!<b>exists</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(payer)) {
      <b>return</b> (0, 0, 0)
    };

    <b>let</b> r = <b>borrow_global_mut</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(payer);
    <b>let</b> (found_it, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&r.destination, &destination);

    <b>let</b> cumu = 0;
    <b>if</b> (found_it) {
      cumu = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&r.cumulative, i);
    };
    cumu = cumu + value;
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.cumulative, *&cumu);

    <b>let</b> timestamp = <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>();
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.last_payment_timestamp, *&timestamp);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.last_payment_value, *&value);

    <b>if</b> (found_it) { // put in same index <b>if</b> the account was already there.
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.last_payment_timestamp, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.last_payment_value, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.cumulative, i);
    } <b>else</b> {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.destination, destination);
    };

    (timestamp, value, cumu)
}
</code></pre>



</details>

<a name="0x1_Receipts_read_receipt"></a>

## Function `read_receipt`



<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_read_receipt">read_receipt</a>(account: <b>address</b>, destination: <b>address</b>): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipts.md#0x1_Receipts_read_receipt">read_receipt</a>(account: <b>address</b>, destination: <b>address</b>):(u64, u64, u64) <b>acquires</b> <a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(account)) {
    <b>return</b> (0, 0, 0)
  };

  <b>let</b> receipt = <b>borrow_global</b>&lt;<a href="Receipts.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(account);
  <b>let</b> (found_it, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&receipt.destination, &destination);
  <b>if</b> (!found_it) <b>return</b> (0, 0, 0);

  <b>let</b> time = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&receipt.last_payment_timestamp, i);
  <b>let</b> value = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&receipt.last_payment_value, i);
  <b>let</b> cumu = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&receipt.cumulative, i);

  (*time, *value, *cumu)
}
</code></pre>



</details>
