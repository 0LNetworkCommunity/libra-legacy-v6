
<a name="0x1_StagingNet"></a>

# Module `0x1::StagingNet`



-  [Resource `IsStagingNet`](#0x1_StagingNet_IsStagingNet)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_StagingNet_initialize)
-  [Function `is_staging_net`](#0x1_StagingNet_is_staging_net)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_StagingNet_IsStagingNet"></a>

## Resource `IsStagingNet`



<pre><code><b>struct</b> <a href="Testnet.md#0x1_StagingNet_IsStagingNet">IsStagingNet</a> <b>has</b> key
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

<a name="@Constants_0"></a>

## Constants


<a name="0x1_StagingNet_EWHY_U_NO_ROOT"></a>



<pre><code><b>const</b> <a href="Testnet.md#0x1_StagingNet_EWHY_U_NO_ROOT">EWHY_U_NO_ROOT</a>: u64 = 667;
</code></pre>



<a name="0x1_StagingNet_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="Testnet.md#0x1_StagingNet_initialize">initialize</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Testnet.md#0x1_StagingNet_initialize">initialize</a>(account: &signer) {
    <b>assert</b>!(
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @DiemRoot,
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="Testnet.md#0x1_StagingNet_EWHY_U_NO_ROOT">EWHY_U_NO_ROOT</a>)
    );
    <b>move_to</b>(account, <a href="Testnet.md#0x1_StagingNet_IsStagingNet">IsStagingNet</a>{})
}
</code></pre>



</details>

<a name="0x1_StagingNet_is_staging_net"></a>

## Function `is_staging_net`



<pre><code><b>public</b> <b>fun</b> <a href="Testnet.md#0x1_StagingNet_is_staging_net">is_staging_net</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Testnet.md#0x1_StagingNet_is_staging_net">is_staging_net</a>(): bool {
    <b>exists</b>&lt;<a href="Testnet.md#0x1_StagingNet_IsStagingNet">IsStagingNet</a>&gt;(@DiemRoot)
}
</code></pre>



</details>
