
<a name="0x1_Receipts"></a>

# Module `0x1::Receipts`



-  [Resource `UserReceipts`](#0x1_Receipts_UserReceipts)
-  [Function `init`](#0x1_Receipts_init)
-  [Function `write_receipt`](#0x1_Receipts_write_receipt)
-  [Function `read_receipt`](#0x1_Receipts_read_receipt)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Receipts_UserReceipts"></a>

## Resource `UserReceipts`



<pre><code><b>struct</b> <a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>destination: vector&lt;address&gt;</code>
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



<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_init">init</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_init">init</a>(account: &signer) {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>if</b> (!<b>exists</b>&lt;<a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(addr)) {
    move_to&lt;<a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(
      account,
      <a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
        destination: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
        last_payment_timestamp: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
        last_payment_value: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
        cumulative: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
      }
    )
  };
}
</code></pre>



</details>

<a name="0x1_Receipts_write_receipt"></a>

## Function `write_receipt`



<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_write_receipt">write_receipt</a>(vm: &signer, payer: address, destination: address, value: u64): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_write_receipt">write_receipt</a>(vm: &signer, payer: address, destination: address, value: u64):(u64, u64, u64) <b>acquires</b> <a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    // <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> r = borrow_global_mut&lt;<a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(payer);
    <b>let</b> (_, i) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&r.destination, &destination);

    <b>let</b> timestamp = <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>();

    <b>let</b> cumu = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&r.cumulative, i);
    cumu = cumu + value;

    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.last_payment_timestamp, *&timestamp);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.last_payment_timestamp, i);

    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.last_payment_value, *&value);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.last_payment_value, i);

    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> r.cumulative, *&cumu);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> r.cumulative, i);
    (timestamp, value, cumu)
}
</code></pre>



</details>

<a name="0x1_Receipts_read_receipt"></a>

## Function `read_receipt`



<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_read_receipt">read_receipt</a>(account: address, destination: address): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Receipt.md#0x1_Receipts_read_receipt">read_receipt</a>(account: address, destination: address):(u64, u64, u64) <b>acquires</b> <a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a> {
  <b>let</b> r = borrow_global&lt;<a href="Receipt.md#0x1_Receipts_UserReceipts">UserReceipts</a>&gt;(account);
  <b>let</b> (_, i) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&r.destination, &destination);

  <b>let</b> time = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&r.last_payment_timestamp, i);
  <b>let</b> value = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&r.last_payment_value, i);
  <b>let</b> cumu = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&r.cumulative, i);

  (*time, *value, *cumu)
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
