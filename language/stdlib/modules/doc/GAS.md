
<a name="0x1_GAS"></a>

# Module `0x1::GAS`



-  [Struct `GAS`](#0x1_GAS_GAS)
-  [Function `initialize`](#0x1_GAS_initialize)


<pre><code><b>use</b> <a href="AccountLimits.md#0x1_AccountLimits">0x1::AccountLimits</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="Libra.md#0x1_Libra">0x1::Libra</a>;
<b>use</b> <a href="LibraTimestamp.md#0x1_LibraTimestamp">0x1::LibraTimestamp</a>;
</code></pre>



<a name="0x1_GAS_GAS"></a>

## Struct `GAS`



<pre><code><b>struct</b> <a href="GAS.md#0x1_GAS">GAS</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_GAS_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="GAS.md#0x1_GAS_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="GAS.md#0x1_GAS_initialize">initialize</a>(
    lr_account: &signer,
    // tc_account: &signer,
) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();
    <a href="Libra.md#0x1_Libra_register_SCS_currency">Libra::register_SCS_currency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        lr_account,
        <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 1), // exchange rate <b>to</b> <a href="GAS.md#0x1_GAS">GAS</a>
        1000000, // scaling_factor = 10^6
        1000,     // fractional_part = 10^3
        b"<a href="GAS.md#0x1_GAS">GAS</a>"
    );
    <a href="AccountLimits.md#0x1_AccountLimits_publish_unrestricted_limits">AccountLimits::publish_unrestricted_limits</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(lr_account);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
