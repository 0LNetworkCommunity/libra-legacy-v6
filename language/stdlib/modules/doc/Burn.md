
<a name="0x1_Burn"></a>

# Module `0x1::Burn`



-  [Resource `DepositInfo`](#0x1_Burn_DepositInfo)
-  [Function `set_ratios`](#0x1_Burn_set_ratios)
-  [Function `get_address_list`](#0x1_Burn_get_address_list)
-  [Function `get_ratio`](#0x1_Burn_get_ratio)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Wallet.md#0x1_Wallet">0x1::Wallet</a>;
</code></pre>



<a name="0x1_Burn_DepositInfo"></a>

## Resource `DepositInfo`



<pre><code><b>resource</b> <b>struct</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>addr: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>deposits: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ratio: vector&lt;<a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Burn_set_ratios"></a>

## Function `set_ratios`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_set_ratios">set_ratios</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_set_ratios">set_ratios</a>(vm: &signer) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_libra_root">CoreAddresses::assert_libra_root</a>(vm);

  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">Wallet::get_comm_list</a>();
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>let</b> global_deposits = 0;
  <b>let</b> deposit_vec = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>while</b> (i &lt; len) {
    <b>let</b> addr = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>let</b> cumu = <a href="LibraAccount.md#0x1_LibraAccount_get_cumulative_deposits">LibraAccount::get_cumulative_deposits</a>(addr);
    global_deposits = global_deposits + cumu;
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> deposit_vec, cumu)
  };

  <b>let</b> ratios_vec = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;();
  <b>while</b> (i &lt; len) {
    <b>let</b> cumu = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&deposit_vec, i);
    <b>let</b> ratio = <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(cumu, global_deposits);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ratios_vec, ratio);
  };
  <b>let</b> d = borrow_global_mut&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(0x0);
  d.addr = list;
  d.deposits = deposit_vec;
  d.ratio = ratios_vec;
}
</code></pre>



</details>

<a name="0x1_Burn_get_address_list"></a>

## Function `get_address_list`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_address_list">get_address_list</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_address_list">get_address_list</a>(): vector&lt;address&gt; <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  *&borrow_global&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(0x0).addr
}
</code></pre>



</details>

<a name="0x1_Burn_get_ratio"></a>

## Function `get_ratio`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_ratio">get_ratio</a>(payee: address): <a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_ratio">get_ratio</a>(payee: address): <a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a> <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <b>let</b> d = borrow_global&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(0x0);
  <b>let</b> (_, i) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&d.addr, &payee);
  <b>return</b> *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&d.ratio, i)
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
