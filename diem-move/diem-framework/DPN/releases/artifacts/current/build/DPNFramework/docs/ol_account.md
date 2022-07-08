
<a name="0x1_AccountScripts"></a>

# Module `0x1::AccountScripts`



-  [Constants](#@Constants_0)
-  [Function `create_user_by_coin_tx`](#0x1_AccountScripts_create_user_by_coin_tx)
-  [Function `create_acc_user`](#0x1_AccountScripts_create_acc_user)
-  [Function `create_acc_val`](#0x1_AccountScripts_create_acc_val)
-  [Function `claim_make_whole`](#0x1_AccountScripts_claim_make_whole)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="MakeWhole.md#0x1_MakeWhole">0x1::MakeWhole</a>;
<b>use</b> <a href="VDF.md#0x1_VDF">0x1::VDF</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_AccountScripts_ACCOUNT_ALREADY_EXISTS"></a>



<pre><code><b>const</b> <a href="ol_account.md#0x1_AccountScripts_ACCOUNT_ALREADY_EXISTS">ACCOUNT_ALREADY_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0x1_AccountScripts_create_user_by_coin_tx"></a>

## Function `create_user_by_coin_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_user_by_coin_tx">create_user_by_coin_tx</a>(sender: signer, account: <b>address</b>, authkey_prefix: vector&lt;u8&gt;, unscaled_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_user_by_coin_tx">create_user_by_coin_tx</a>(
    sender: signer,
    account: <b>address</b>,
    authkey_prefix: vector&lt;u8&gt;,
    unscaled_value: u64,
) {
    // check <b>if</b> the account already <b>exists</b>.
    <b>assert</b>!(!<a href="DiemAccount.md#0x1_DiemAccount_exists_at">DiemAccount::exists_at</a>(account), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_account.md#0x1_AccountScripts_ACCOUNT_ALREADY_EXISTS">ACCOUNT_ALREADY_EXISTS</a>));

    // IMPORTANT: the human representation of a value is unscaled.
    // The user which expects <b>to</b> send 10 coins, will input that <b>as</b> an unscaled_value.
    // This <b>script</b> converts it <b>to</b> the Move <b>internal</b> scale by multiplying
    // by COIN_SCALING_FACTOR.
    <b>let</b> value = unscaled_value * <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">Globals::get_coin_scaling_factor</a>();
    <b>let</b> new_account_address = <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_coin">DiemAccount::create_user_account_with_coin</a>(
        &sender,
        account,
        authkey_prefix,
        value,
    );

    // Check the account <b>exists</b> and the balance is 0
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) &gt; 0, 01);
}
</code></pre>



</details>

<a name="0x1_AccountScripts_create_acc_user"></a>

## Function `create_acc_user`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_user">create_acc_user</a>(sender: signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, difficulty: u64, security: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_user">create_acc_user</a>(
    sender: signer,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
) {
    <b>let</b> new_account_address = <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_proof">DiemAccount::create_user_account_with_proof</a>(
        &sender,
        &challenge,
        &solution,
        difficulty,
        security
    );

    // Check the account <b>exists</b> and the balance is 0
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) &gt; 0, 01);
}
</code></pre>



</details>

<a name="0x1_AccountScripts_create_acc_val"></a>

## Function `create_acc_val`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_val">create_acc_val</a>(sender: signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, difficulty: u64, security: u64, ow_human_name: vector&lt;u8&gt;, op_address: <b>address</b>, op_auth_key_prefix: vector&lt;u8&gt;, op_consensus_pubkey: vector&lt;u8&gt;, op_validator_network_addresses: vector&lt;u8&gt;, op_fullnode_network_addresses: vector&lt;u8&gt;, op_human_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_create_acc_val">create_acc_val</a>(
    sender: signer,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
    ow_human_name: vector&lt;u8&gt;,
    op_address: <b>address</b>,
    op_auth_key_prefix: vector&lt;u8&gt;,
    op_consensus_pubkey: vector&lt;u8&gt;,
    op_validator_network_addresses: vector&lt;u8&gt;,
    op_fullnode_network_addresses: vector&lt;u8&gt;,
    op_human_name: vector&lt;u8&gt;,
) {

  // check <b>if</b> this account <b>exists</b>
  <b>let</b> (new_account_address, _) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(&challenge);
  // <b>assert</b>!(
  //     !<a href="DiemAccount.md#0x1_DiemAccount_exists_at">DiemAccount::exists_at</a>(new_account_address),
  //     <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_account.md#0x1_AccountScripts_ACCOUNT_ALREADY_EXISTS">ACCOUNT_ALREADY_EXISTS</a>)
  // );

  <a href="DiemAccount.md#0x1_DiemAccount_create_validator_account_with_proof">DiemAccount::create_validator_account_with_proof</a>(
        &sender,
        &challenge,
        &solution,
        difficulty,
        security,
        ow_human_name,
        op_address,
        op_auth_key_prefix,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses,
        op_human_name,
    );

    // Check the account <b>has</b> the Validator role
    <b>assert</b>!(<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(new_account_address), 03);

    // Check the account <b>exists</b> and the balance is greater than 0
    <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) &gt; 0, 04);
}
</code></pre>



</details>

<a name="0x1_AccountScripts_claim_make_whole"></a>

## Function `claim_make_whole`

claim a make whole payment, requires the index of the payment
in the MakeWhole module, which can be found using the
query_make_whole_payment, which should not be run as part of
the tx as it is relatively resource intensive (linear search)


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_claim_make_whole">claim_make_whole</a>(sender: signer, index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_account.md#0x1_AccountScripts_claim_make_whole">claim_make_whole</a>(sender: signer, index: u64) {
    <b>let</b> _ = <a href="MakeWhole.md#0x1_MakeWhole_claim_make_whole_payment">MakeWhole::claim_make_whole_payment</a>(&sender, index);
}
</code></pre>



</details>
