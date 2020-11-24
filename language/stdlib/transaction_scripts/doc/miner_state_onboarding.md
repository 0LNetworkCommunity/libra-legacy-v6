
<a name="minerstate_onboarding"></a>

# Script `minerstate_onboarding`





<pre><code><b>use</b> <a href="../../modules/doc/GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
<b>use</b> <a href="../../modules/doc/ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="miner_state_onboarding.md#minerstate_onboarding">minerstate_onboarding</a>(sender: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, consensus_pubkey: vector&lt;u8&gt;, validator_network_address: vector&lt;u8&gt;, full_node_network_address: vector&lt;u8&gt;, human_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="miner_state_onboarding.md#minerstate_onboarding">minerstate_onboarding</a>(
  sender: &signer,
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;,
  consensus_pubkey: vector&lt;u8&gt;,
  validator_network_address: vector&lt;u8&gt;,
  full_node_network_address: vector&lt;u8&gt;,
  human_name: vector&lt;u8&gt;, // Todo: rename <b>to</b> address
) {

  <b>let</b> new_account_address = <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount_create_validator_account_with_proof">LibraAccount::create_validator_account_with_proof</a>(
    sender,
    &challenge,
    &solution,
    consensus_pubkey,
    validator_network_address,
    full_node_network_address,
    human_name // todo human_name == address
  );

  // add optional trusted accounts info

  // add optional autopay info
  // enable autopay
  // <b>update</b> tx


  // Check the account has the Validator role
  <b>assert</b>(<a href="../../modules/doc/ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(new_account_address), 03);

  // Check the account <b>exists</b> and the balance is 0
  <b>assert</b>(<a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="../../modules/doc/GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) == 0, 04);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
