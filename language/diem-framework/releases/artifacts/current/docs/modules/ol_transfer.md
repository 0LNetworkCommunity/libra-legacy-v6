
<a name="0x1_TransferScripts"></a>

# Module `0x1::TransferScripts`



-  [Function `balance_transfer`](#0x1_TransferScripts_balance_transfer)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_TransferScripts_balance_transfer"></a>

## Function `balance_transfer`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_balance_transfer">balance_transfer</a>(sender: signer, destination: address, unscaled_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_transfer.md#0x1_TransferScripts_balance_transfer">balance_transfer</a>(
    sender: signer,
    destination: address,
    unscaled_value: u64,
) {
    // IMPORTANT: the human representation of a value is unscaled. The user which expects <b>to</b> send 10 coins, will input that <b>as</b> an unscaled_value. This <b>script</b> converts it <b>to</b> the Move internal scale by multiplying by COIN_SCALING_FACTOR.
    <b>let</b> value = unscaled_value * <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">Globals::get_coin_scaling_factor</a>();
    <b>let</b> sender_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sender);
    <b>let</b> sender_balance_pre = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr);
    <b>let</b> destination_balance_pre = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(destination);

    <b>let</b> with_cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">DiemAccount::extract_withdraw_capability</a>(&sender);
    <a href="DiemAccount.md#0x1_DiemAccount_pay_from">DiemAccount::pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&with_cap, destination, value, b"balance_transfer", b"");
    <a href="DiemAccount.md#0x1_DiemAccount_restore_withdraw_capability">DiemAccount::restore_withdraw_capability</a>(with_cap);

    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(destination) &gt; destination_balance_pre, 01);
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(sender_addr) &lt; sender_balance_pre, 02);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
