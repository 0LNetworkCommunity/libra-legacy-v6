
<a name="0x1_GAS"></a>

# Module `0x1::GAS`


<a name="@Summary_0"></a>

## Summary

Code to instantiate the GAS token
This is uninteresting, you may be looking for Diem.move


-  [Summary](#@Summary_0)
-  [Struct `GAS`](#0x1_GAS_GAS)
-  [Function `initialize`](#0x1_GAS_initialize)


<pre><code><b>use</b> <a href="AccountLimits.md#0x1_AccountLimits">0x1::AccountLimits</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
</code></pre>



<a name="0x1_GAS_GAS"></a>

## Struct `GAS`



<pre><code><b>struct</b> <a href="GAS.md#0x1_GAS">GAS</a> <b>has</b> store
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

Called by root in genesis to initialize the GAS coin


<pre><code><b>public</b> <b>fun</b> <a href="GAS.md#0x1_GAS_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="GAS.md#0x1_GAS_initialize">initialize</a>(
    lr_account: &signer,
    // tc_account: &signer,
) {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(lr_account);
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <a href="Diem.md#0x1_Diem_register_SCS_currency">Diem::register_SCS_currency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        lr_account,
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 1), // exchange rate <b>to</b> <a href="GAS.md#0x1_GAS">GAS</a>
        1000000, // scaling_factor = 10^6
        1000,     // fractional_part = 10^3
        b"<a href="GAS.md#0x1_GAS">GAS</a>"
    );
    <a href="AccountLimits.md#0x1_AccountLimits_publish_unrestricted_limits">AccountLimits::publish_unrestricted_limits</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(lr_account);
}
</code></pre>



</details>
