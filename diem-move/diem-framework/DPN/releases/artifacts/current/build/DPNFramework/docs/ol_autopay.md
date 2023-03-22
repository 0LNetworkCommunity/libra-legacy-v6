
<a name="0x1_AutoPayScripts"></a>

# Module `0x1::AutoPayScripts`



-  [Constants](#@Constants_0)
-  [Function `autopay_enable`](#0x1_AutoPayScripts_autopay_enable)
-  [Function `autopay_disable`](#0x1_AutoPayScripts_autopay_disable)
-  [Function `autopay_create_instruction`](#0x1_AutoPayScripts_autopay_create_instruction)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_AutoPayScripts_EAUTOPAY_NOT_ENABLED"></a>



<pre><code><b>const</b> <a href="ol_autopay.md#0x1_AutoPayScripts_EAUTOPAY_NOT_ENABLED">EAUTOPAY_NOT_ENABLED</a>: u64 = 1001;
</code></pre>



<a name="0x1_AutoPayScripts_autopay_enable"></a>

## Function `autopay_enable`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_enable">autopay_enable</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_enable">autopay_enable</a>(sender: signer) {
    <b>let</b> account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);

    <b>if</b> (!<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account)) {
        <a href="AutoPay.md#0x1_AutoPay_enable_autopay">AutoPay::enable_autopay</a>(&sender);
    };
    <b>assert</b>!(<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account), 0);
}
</code></pre>



</details>

<a name="0x1_AutoPayScripts_autopay_disable"></a>

## Function `autopay_disable`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_disable">autopay_disable</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_disable">autopay_disable</a>(sender: signer) {
    <b>let</b> account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);

    <b>if</b> (<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account)) {
        <a href="AutoPay.md#0x1_AutoPay_disable_autopay">AutoPay::disable_autopay</a>(&sender);
    };
    <b>assert</b>!(!<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account), 010001);
}
</code></pre>



</details>

<a name="0x1_AutoPayScripts_autopay_create_instruction"></a>

## Function `autopay_create_instruction`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_create_instruction">autopay_create_instruction</a>(sender: signer, uid: u64, in_type: u8, payee: <b>address</b>, end_epoch: u64, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_autopay.md#0x1_AutoPayScripts_autopay_create_instruction">autopay_create_instruction</a>(
    sender: signer,
    uid: u64,
    in_type: u8,
    payee: <b>address</b>,
    end_epoch: u64,
    value: u64,
) {
    <b>let</b> account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);
    <b>if</b> (!<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account)) {
        <a href="AutoPay.md#0x1_AutoPay_enable_autopay">AutoPay::enable_autopay</a>(&sender);
        <b>assert</b>!(
            <a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account),
            <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_autopay.md#0x1_AutoPayScripts_EAUTOPAY_NOT_ENABLED">EAUTOPAY_NOT_ENABLED</a>)
        );
    };

    <a href="AutoPay.md#0x1_AutoPay_create_instruction">AutoPay::create_instruction</a>(
        &sender,
        uid,
        in_type,
        payee,
        end_epoch,
        value,
    );
}
</code></pre>



</details>
