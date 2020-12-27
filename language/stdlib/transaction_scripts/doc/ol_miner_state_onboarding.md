
<a name="minerstate_onboarding"></a>

# Script `minerstate_onboarding`





<pre><code><b>use</b> <a href="../../modules/doc/GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
<b>use</b> <a href="../../modules/doc/ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_miner_state_onboarding.md#minerstate_onboarding">minerstate_onboarding</a>(sender: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, ow_human_name: vector&lt;u8&gt;, op_address: address, op_auth_key_prefix: vector&lt;u8&gt;, op_consensus_pubkey: vector&lt;u8&gt;, op_validator_network_addresses: vector&lt;u8&gt;, op_fullnode_network_addresses: vector&lt;u8&gt;, op_human_name: vector&lt;u8&gt;, my_trusted_accounts: vector&lt;address&gt;, voter_trusted_accounts: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_miner_state_onboarding.md#minerstate_onboarding">minerstate_onboarding</a>(

  sender: &signer,
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;,
  ow_human_name: vector&lt;u8&gt;,
  op_address: address,
  op_auth_key_prefix: vector&lt;u8&gt;,
  op_consensus_pubkey: vector&lt;u8&gt;,
  op_validator_network_addresses: vector&lt;u8&gt;,
  op_fullnode_network_addresses: vector&lt;u8&gt;,
  op_human_name: vector&lt;u8&gt;,
  my_trusted_accounts: vector&lt;address&gt;,
  voter_trusted_accounts: vector&lt;address&gt;,
) {

  <b>let</b> new_account_address = <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount_create_validator_account_with_proof">LibraAccount::create_validator_account_with_proof</a>(
  sender,
  &challenge,
  &solution,
  ow_human_name,
  op_address,
  op_auth_key_prefix,
  op_consensus_pubkey,
  op_validator_network_addresses,
  op_fullnode_network_addresses,
  op_human_name,
  my_trusted_accounts,
  voter_trusted_accounts,
  );

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
