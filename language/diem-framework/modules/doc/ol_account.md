
<a name="0x1_AccountScripts"></a>

# Module `0x1::AccountScripts`



-  [Function `create_acc_user`](#0x1_AccountScripts_create_acc_user)
-  [Function `create_acc_val`](#0x1_AccountScripts_create_acc_val)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>



<a name="0x1_AccountScripts_create_acc_user"></a>

## Function `create_acc_user`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_user">create_acc_user</a>(_sender: signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_user">create_acc_user</a>(
    _sender: signer,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;,
) {
    <b>let</b> new_account_address = <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_proof">DiemAccount::create_user_account_with_proof</a>(
        &challenge,
        &solution,
    );

    // Check the account <b>exists</b> and the balance is 0
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) == 0, 01);
}
</code></pre>



</details>

<a name="0x1_AccountScripts_create_acc_val"></a>

## Function `create_acc_val`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_val">create_acc_val</a>(sender: signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, ow_human_name: vector&lt;u8&gt;, op_address: address, op_auth_key_prefix: vector&lt;u8&gt;, op_consensus_pubkey: vector&lt;u8&gt;, op_validator_network_addresses: vector&lt;u8&gt;, op_fullnode_network_addresses: vector&lt;u8&gt;, op_human_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_val">create_acc_val</a>(
    sender: signer,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;,
    ow_human_name: vector&lt;u8&gt;,
    op_address: address,
    op_auth_key_prefix: vector&lt;u8&gt;,
    op_consensus_pubkey: vector&lt;u8&gt;,
    op_validator_network_addresses: vector&lt;u8&gt;,
    op_fullnode_network_addresses: vector&lt;u8&gt;,
    op_human_name: vector&lt;u8&gt;,
) {
    print(&0x1);
    <b>let</b> new_account_address = <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account_with_proof">DiemAccount::create_validator_account_with_proof</a>(
        &sender,
        &challenge,
        &solution,
        ow_human_name,
        op_address,
        op_auth_key_prefix,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses,
        op_human_name,
    );

    print(&0x2);
    // Check the account has the Validator role
    <b>assert</b>(<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(new_account_address), 03);

    print(&0x3);
    // Check the account <b>exists</b> and the balance is greater than 0
    <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) &gt; 0, 04);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
