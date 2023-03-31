
<a name="0x1_TransferScripts"></a>

# Module `0x1::TransferScripts`



-  [Function `balance_transfer`](#0x1_TransferScripts_balance_transfer)
-  [Function `community_transfer`](#0x1_TransferScripts_community_transfer)


<pre><code><b>use</b> <a href="CommunityWallet.md#0x1_CommunityWallet">0x1::CommunityWallet</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_TransferScripts_balance_transfer"></a>

## Function `balance_transfer`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_balance_transfer">balance_transfer</a>(sender: signer, destination: <b>address</b>, unscaled_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_balance_transfer">balance_transfer</a>(
    sender: signer,
    destination: <b>address</b>,
    unscaled_value: u64,
) {
    // IMPORTANT: the human representation of a value is unscaled.
    // The user which expects <b>to</b> send 10 coins, will input that <b>as</b> an
    // unscaled_value. This <b>script</b> converts it <b>to</b> the Move <b>internal</b> scale
    // by multiplying by COIN_SCALING_FACTOR.
    <b>let</b> value = unscaled_value * <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">Globals::get_coin_scaling_factor</a>();
    <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);
    <b>let</b> sender_balance_pre = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr);
    <b>let</b> destination_balance_pre = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(destination);

    <b>let</b> with_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">DiemAccount::extract_withdraw_capability</a>(&sender);
    <a href="DiemAccount.md#0x1_DiemAccount_pay_from">DiemAccount::pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&with_cap, destination, value, b"balance_transfer", b"");
    <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">DiemAccount::restore_withdraw_capability</a>(with_cap);

    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(destination) &gt; destination_balance_pre, 01);
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr) &lt; sender_balance_pre, 02);
}
</code></pre>



</details>

<a name="0x1_TransferScripts_community_transfer"></a>

## Function `community_transfer`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_community_transfer">community_transfer</a>(sender: signer, multisig_address: <b>address</b>, destination: <b>address</b>, unscaled_value: u64, memo: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_community_transfer">community_transfer</a>(
    sender: signer,
    multisig_address: <b>address</b>,
    destination: <b>address</b>,
    unscaled_value: u64,
    memo: vector&lt;u8&gt;,
) {
    // IMPORTANT: the human representation of a value is unscaled.
    // The user which expects <b>to</b> send 10 coins, will input that <b>as</b> an
    // unscaled_value. This <b>script</b> converts it <b>to</b> the Move <b>internal</b> scale
    // by multiplying by COIN_SCALING_FACTOR.
    <b>let</b> value = unscaled_value * <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">Globals::get_coin_scaling_factor</a>();
    <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);
    <b>assert</b>!(<a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">CommunityWallet::is_comm</a>(sender_addr), 30001);

    // confirm the destination account <b>has</b> a slow wallet
    // TODO: this check only happens in this <b>script</b> since there's
    // a circular dependecy issue <b>with</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> and <a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a> which impedes
    // checking in <a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a> <b>module</b>
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(destination), 30002);

    <b>let</b> _uid = <a href="DonorDirected.md#0x1_DonorDirected_propose_payment">DonorDirected::propose_payment</a>(&sender, multisig_address, destination, value, memo);
    // <b>assert</b>!(DonorDirected::transfer_is_proposed(uid, multisig_address), 30003);
}
</code></pre>



</details>
