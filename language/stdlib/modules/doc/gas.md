
<a name="0x0_GAS"></a>

# Module `0x0::GAS`

### Table of Contents

-  [Struct `T`](#0x0_GAS_T)
-  [Struct `Reserve`](#0x0_GAS_Reserve)
-  [Function `initialize`](#0x0_GAS_initialize)



<a name="0x0_GAS_T"></a>

## Struct `T`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_GAS_T">T</a>
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

<a name="0x0_GAS_Reserve"></a>

## Struct `Reserve`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_GAS_Reserve">Reserve</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>mint_cap: <a href="Libra.md#0x0_Libra_MintCapability">Libra::MintCapability</a>&lt;<a href="#0x0_GAS_T">GAS::T</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>burn_cap: <a href="Libra.md#0x0_Libra_BurnCapability">Libra::BurnCapability</a>&lt;<a href="#0x0_GAS_T">GAS::T</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>preburn_cap: <a href="Libra.md#0x0_Libra_Preburn">Libra::Preburn</a>&lt;<a href="#0x0_GAS_T">GAS::T</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_GAS_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_GAS_initialize">initialize</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_GAS_initialize">initialize</a>(account: &signer) {
    // Register the <a href="LBR.md#0x0_LBR">LBR</a> currency.
    <b>let</b> (mint_cap, burn_cap) = <a href="Libra.md#0x0_Libra_register_currency">Libra::register_currency</a>&lt;<a href="#0x0_GAS_T">T</a>&gt;(
        account,
        <a href="FixedPoint32.md#0x0_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 1), // exchange rate <b>to</b> <a href="LBR.md#0x0_LBR">LBR</a>
        <b>false</b>,    // is_synthetic
        1000000, // scaling_factor = 10^6
        1000,    // fractional_part = 10^3
        b"<a href="#0x0_GAS">GAS</a>"
    );
    <b>let</b> preburn_cap = <a href="Libra.md#0x0_Libra_new_preburn_with_capability">Libra::new_preburn_with_capability</a>(&burn_cap);
    move_to(account, <a href="#0x0_GAS_Reserve">Reserve</a> { mint_cap, burn_cap, preburn_cap });
}
</code></pre>



</details>
