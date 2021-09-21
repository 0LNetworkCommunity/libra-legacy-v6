
<a name="0x1_MinerState"></a>

# Module `0x1::MinerState`


<a name="@Summary_0"></a>

## Summary

TODO


-  [Summary](#@Summary_0)
-  [Resource `MinerList`](#0x1_MinerState_MinerList)
-  [Resource `MinerStats`](#0x1_MinerState_MinerStats)
-  [Struct `Proof`](#0x1_MinerState_Proof)
-  [Resource `MinerProofHistory`](#0x1_MinerState_MinerProofHistory)
-  [Constants](#@Constants_1)
-  [Function `increment_stats`](#0x1_MinerState_increment_stats)
-  [Function `epoch_reset`](#0x1_MinerState_epoch_reset)
-  [Function `get_fullnode_proofs`](#0x1_MinerState_get_fullnode_proofs)
-  [Function `init_list`](#0x1_MinerState_init_list)
-  [Function `is_init`](#0x1_MinerState_is_init)
-  [Function `is_onboarding`](#0x1_MinerState_is_onboarding)
-  [Function `create_proof_blob`](#0x1_MinerState_create_proof_blob)
-  [Function `increment_miners_list`](#0x1_MinerState_increment_miners_list)
-  [Function `genesis_helper`](#0x1_MinerState_genesis_helper)
-  [Function `commit_state`](#0x1_MinerState_commit_state)
-  [Function `commit_state_by_operator`](#0x1_MinerState_commit_state_by_operator)
-  [Function `verify_and_update_state`](#0x1_MinerState_verify_and_update_state)
-  [Function `update_metrics`](#0x1_MinerState_update_metrics)
-  [Function `node_above_thresh`](#0x1_MinerState_node_above_thresh)
-  [Function `get_validator_weight`](#0x1_MinerState_get_validator_weight)
-  [Function `reconfig`](#0x1_MinerState_reconfig)
-  [Function `init_miner_state`](#0x1_MinerState_init_miner_state)
-  [Function `first_challenge_includes_address`](#0x1_MinerState_first_challenge_includes_address)
-  [Function `get_miner_latest_epoch`](#0x1_MinerState_get_miner_latest_epoch)
-  [Function `reset_rate_limit`](#0x1_MinerState_reset_rate_limit)
-  [Function `get_miner_list`](#0x1_MinerState_get_miner_list)
-  [Function `get_epochs_mining`](#0x1_MinerState_get_epochs_mining)
-  [Function `get_count_in_epoch`](#0x1_MinerState_get_count_in_epoch)
-  [Function `can_create_val_account`](#0x1_MinerState_can_create_val_account)
-  [Function `test_helper`](#0x1_MinerState_test_helper)
-  [Function `test_helper_operator_submits`](#0x1_MinerState_test_helper_operator_submits)
-  [Function `test_helper_mock_mining`](#0x1_MinerState_test_helper_mock_mining)
-  [Function `test_helper_mock_mining_vm`](#0x1_MinerState_test_helper_mock_mining_vm)
-  [Function `test_helper_mock_reconfig`](#0x1_MinerState_test_helper_mock_reconfig)
-  [Function `test_helper_get_height`](#0x1_MinerState_test_helper_get_height)
-  [Function `test_helper_get_count`](#0x1_MinerState_test_helper_get_count)
-  [Function `test_helper_get_contiguous`](#0x1_MinerState_test_helper_get_contiguous)
-  [Function `test_helper_set_rate_limit`](#0x1_MinerState_test_helper_set_rate_limit)
-  [Function `test_helper_set_epochs_mining`](#0x1_MinerState_test_helper_set_epochs_mining)
-  [Function `test_helper_set_proofs_in_epoch`](#0x1_MinerState_test_helper_set_proofs_in_epoch)
-  [Function `test_helper_hash`](#0x1_MinerState_test_helper_hash)
-  [Function `test_helper_set_weight_vm`](#0x1_MinerState_test_helper_set_weight_vm)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Hash.md#0x1_Hash">0x1::Hash</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="VDF.md#0x1_VDF">0x1::VDF</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MinerState_MinerList"></a>

## Resource `MinerList`

a list of all miners' addresses TODO: When is this list updated? Can people be removed?


<pre><code><b>struct</b> <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MinerState_MinerStats"></a>

## Resource `MinerStats`



<pre><code><b>struct</b> <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>proofs_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>validator_proofs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>fullnode_proofs: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MinerState_Proof"></a>

## Struct `Proof`

Struct to store information about a VDF proof submitted
<code>challenge</code>: the seed for the proof
<code>difficulty</code>: the difficulty for the proof (higher difficulty -> longer proof time)
<code>solution</code>: the solution for the proof (the result)


<pre><code><b>struct</b> <a href="MinerState.md#0x1_MinerState_Proof">Proof</a> has drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>challenge: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>difficulty: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>solution: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MinerState_MinerProofHistory"></a>

## Resource `MinerProofHistory`

Struct to encapsulate information about the state of a miner
<code>previous_proof_hash</code>: the hash of their latest proof (used as seed for next proof)
<code>verified_tower_height</code>: the height of the miner's tower (more proofs -> higher tower)
<code>latest_epoch_mining</code>: the latest epoch the miner submitted sufficient proofs (see GlobalConstants.epoch_mining_thres_lower)
<code>count_proofs_in_epoch</code>: the number of proofs the miner has submitted in the current epoch
<code>epochs_validating_and_mining</code>: the cumulative number of epochs the miner has been mining above threshold TODO does this actually only apply to validators?
<code>contiguous_epochs_validating_and_mining</code>: the number of contiguous epochs the miner has been mining above threshold TODO does this actually only apply to validators?
<code>epochs_since_last_account_creation</code>: the number of epochs since the miner last created a new account


<pre><code><b>struct</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>previous_proof_hash: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>verified_tower_height: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>latest_epoch_mining: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>count_proofs_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epochs_validating_and_mining: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>contiguous_epochs_validating_and_mining: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epochs_since_last_account_creation: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="0x1_MinerState_EPOCHS_UNTIL_ACCOUNT_CREATION"></a>



<pre><code><b>const</b> <a href="MinerState.md#0x1_MinerState_EPOCHS_UNTIL_ACCOUNT_CREATION">EPOCHS_UNTIL_ACCOUNT_CREATION</a>: u64 = 6;
</code></pre>



<a name="0x1_MinerState_increment_stats"></a>

## Function `increment_stats`



<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_increment_stats">increment_stats</a>(miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_increment_stats">increment_stats</a>(miner_addr: address) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  <b>assert</b>(<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>()), 1301001);
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());

  <b>if</b> (<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(miner_addr)) {
    state.validator_proofs = state.validator_proofs + 1;
  } <b>else</b> {
    state.fullnode_proofs = state.fullnode_proofs + 1;
  };

  state.proofs_in_epoch = state.proofs_in_epoch + 1;
  // print(&miner_addr);
  // print(state);

}
</code></pre>



</details>

<a name="0x1_MinerState_epoch_reset"></a>

## Function `epoch_reset`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_epoch_reset">epoch_reset</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_epoch_reset">epoch_reset</a>(vm: &signer) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.proofs_in_epoch = 0;
  state.validator_proofs = 0;
  state.fullnode_proofs = 0;
 }
</code></pre>



</details>

<a name="0x1_MinerState_get_fullnode_proofs"></a>

## Function `get_fullnode_proofs`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_fullnode_proofs">get_fullnode_proofs</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_fullnode_proofs">get_fullnode_proofs</a>(): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>{
  <b>let</b> state = borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.fullnode_proofs
}
</code></pre>



</details>

<a name="0x1_MinerState_init_list"></a>

## Function `init_list`

Create an empty list of miners


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_init_list">init_list</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_init_list">init_list</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  move_to&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(vm, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> {
    list: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  });

  move_to&lt;<a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a>&gt;(vm, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
    proofs_in_epoch: 0u64,
    validator_proofs: 0u64,
    fullnode_proofs: 0u64,
  });
}
</code></pre>



</details>

<a name="0x1_MinerState_is_init"></a>

## Function `is_init`

returns true if miner at <code>addr</code> has been initialized


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_is_init">is_init</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_is_init">is_init</a>(addr: address):bool {
  <b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_MinerState_is_onboarding"></a>

## Function `is_onboarding`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_is_onboarding">is_onboarding</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_is_onboarding">is_onboarding</a>(addr: address): bool <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>{
  <b>let</b> state = borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr);

  state.count_proofs_in_epoch &lt; 2 &&
  state.epochs_since_last_account_creation &lt; 2
}
</code></pre>



</details>

<a name="0x1_MinerState_create_proof_blob"></a>

## Function `create_proof_blob`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_create_proof_blob">create_proof_blob</a>(challenge: vector&lt;u8&gt;, difficulty: u64, solution: vector&lt;u8&gt;): <a href="MinerState.md#0x1_MinerState_Proof">MinerState::Proof</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_create_proof_blob">create_proof_blob</a>(
  challenge: vector&lt;u8&gt;,
  difficulty: u64,
  solution: vector&lt;u8&gt;
): <a href="MinerState.md#0x1_MinerState_Proof">Proof</a> {
   <a href="MinerState.md#0x1_MinerState_Proof">Proof</a> {
     challenge,
     difficulty,
     solution,
  }
}
</code></pre>



</details>

<a name="0x1_MinerState_increment_miners_list"></a>

## Function `increment_miners_list`

Private, can only be called within module
adds <code>miner</code> to list of miners


<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_increment_miners_list">increment_miners_list</a>(miner: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_increment_miners_list">increment_miners_list</a>(miner: address) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0)) {
    <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0);
    <b>if</b> (!<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&<b>mut</b> state.list, &miner)) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.list, miner);
    }
  }
}
</code></pre>



</details>

<a name="0x1_MinerState_genesis_helper"></a>

## Function `genesis_helper`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_genesis_helper">genesis_helper</a>(vm_sig: &signer, miner_sig: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_genesis_helper">genesis_helper</a> (
  vm_sig: &signer,
  miner_sig: &signer,
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;
) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  // In rust the vm_genesis creates a <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a> for the miner. So the SENDER is not the same and the <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a>.

  //TODO: Previously in OLv3 is_genesis() returned <b>true</b>. How <b>to</b> check that this is part of genesis? is_genesis returns <b>false</b> here.
  // <b>assert</b>(<a href="DiemTimestamp.md#0x1_DiemTimestamp_is_genesis">DiemTimestamp::is_genesis</a>(), 130101024010);
  // print(&10001);
  <a href="MinerState.md#0x1_MinerState_init_miner_state">init_miner_state</a>(miner_sig, &challenge, &solution);
  // print(&10002);
  // TODO: Move this elsewhere?
  // Initialize stats for first validator set from rust genesis.
  <b>let</b> node_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig);
  // print(&10003);
  <a href="Stats.md#0x1_Stats_init_address">Stats::init_address</a>(vm_sig, node_addr);
}
</code></pre>



</details>

<a name="0x1_MinerState_commit_state"></a>

## Function `commit_state`

This function is called to submit proofs to the chain
Note, the sender of this transaction can differ from the signer, to facilitate onboarding
Function index: 01
Permissions: PUBLIC, ANYONE


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_commit_state">commit_state</a>(miner_sign: &signer, proof: <a href="MinerState.md#0x1_MinerState_Proof">MinerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_commit_state">commit_state</a>(
  miner_sign: &signer,
  proof: <a href="MinerState.md#0x1_MinerState_Proof">Proof</a>
) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {

  //NOTE: Does not check that the Sender is the <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a>. Which we must skip for the onboarding transaction.

  // Get address, assumes the sender is the signer.
  <b>let</b> miner_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sign);

  // Abort <b>if</b> not initialized.
  <b>assert</b>(<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130101));

  // Get vdf difficulty constant. Will be different in tests than in production.
  <b>let</b> difficulty_constant = <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>();

  // Skip this check on local tests, we need tests <b>to</b> send different difficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){
    <b>assert</b>(&proof.difficulty == &difficulty_constant, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130102));
  };

  // Process the proof
  <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);
}
</code></pre>



</details>

<a name="0x1_MinerState_commit_state_by_operator"></a>

## Function `commit_state_by_operator`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_commit_state_by_operator">commit_state_by_operator</a>(operator_sig: &signer, miner_addr: address, proof: <a href="MinerState.md#0x1_MinerState_Proof">MinerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_commit_state_by_operator">commit_state_by_operator</a>(
  operator_sig: &signer,
  miner_addr: address,
  proof: <a href="MinerState.md#0x1_MinerState_Proof">Proof</a>
) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {

  // Check the signer is in fact an operator delegated by the owner.

  // Get address, assumes the sender is the signer.
  <b>assert</b>(<a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr) == <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(operator_sig), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130103));
  // Abort <b>if</b> not initialized.
  <b>assert</b>(<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130104));

  // Get vdf difficulty constant. Will be different in tests than in production.
  <b>let</b> difficulty_constant = <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>();

  // Skip this check on local tests, we need tests <b>to</b> send different difficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){
    <b>assert</b>(&proof.difficulty == &difficulty_constant, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130105));
  };

  // Process the proof
  <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);

  // TODO: The operator mining needs its own <b>struct</b> <b>to</b> count mining.
  // For now it is implicit there is only 1 operator per validator, and that the fullnode state is the place <b>to</b> count.
  // This will require a breaking change <b>to</b> <a href="MinerState.md#0x1_MinerState">MinerState</a>
  // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
}
</code></pre>



</details>

<a name="0x1_MinerState_verify_and_update_state"></a>

## Function `verify_and_update_state`



<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(miner_addr: address, proof: <a href="MinerState.md#0x1_MinerState_Proof">MinerState::Proof</a>, steady_state: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(
  miner_addr: address,
  proof: <a href="MinerState.md#0x1_MinerState_Proof">Proof</a>,
  steady_state: bool
) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  // Get a mutable ref <b>to</b> the current state
  <b>let</b> miner_history = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);

  // <b>return</b> early <b>if</b> the miner is running too fast, no advantage <b>to</b> asics
  <b>assert</b>(miner_history.count_proofs_in_epoch &lt; <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_upper">Globals::get_epoch_mining_thres_upper</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130106));

  // If not genesis proof, check hash <b>to</b> ensure the proof continues the chain
  <b>if</b> (steady_state) {
    //If not genesis proof, check hash
    <b>assert</b>(&proof.challenge == &miner_history.previous_proof_hash, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130107));
  };

  <b>let</b> valid = <a href="VDF.md#0x1_VDF_verify">VDF::verify</a>(&proof.challenge, &proof.difficulty, &proof.solution);
  <b>assert</b>(valid, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130108));

  // add the miner <b>to</b> the miner list <b>if</b> not present
  <a href="MinerState.md#0x1_MinerState_increment_miners_list">increment_miners_list</a>(miner_addr);

  // <b>update</b> the miner proof history (result is used <b>as</b> seed for next proof)
  miner_history.previous_proof_hash = <a href="../../../../../../move-stdlib/docs/Hash.md#0x1_Hash_sha3_256">Hash::sha3_256</a>(*&proof.solution);

  // Increment the verified_tower_height
  <b>if</b> (steady_state) {
    miner_history.verified_tower_height = miner_history.verified_tower_height + 1;
    miner_history.count_proofs_in_epoch = miner_history.count_proofs_in_epoch + 1;
  } <b>else</b> {
    miner_history.verified_tower_height = 0;
    miner_history.count_proofs_in_epoch = 1
  };

  miner_history.latest_epoch_mining = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  <a href="MinerState.md#0x1_MinerState_increment_stats">increment_stats</a>(miner_addr);
}
</code></pre>



</details>

<a name="0x1_MinerState_update_metrics"></a>

## Function `update_metrics`



<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_update_metrics">update_metrics</a>(account: &signer, miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MinerState.md#0x1_MinerState_update_metrics">update_metrics</a>(account: &signer, miner_addr: address) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  // The goal of update_metrics is <b>to</b> confirm that a miner participated in consensus during
  // an epoch, but also that there were mining proofs submitted in that epoch.
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(account);

  // Miner may not have been initialized. Simply <b>return</b> in this case (don't <b>abort</b>)
  <b>if</b>(!<a href="MinerState.md#0x1_MinerState_is_init">is_init</a>(miner_addr)) { <b>return</b> };


  // Check that there was mining and validating in period.
  // Account may not have any proofs submitted in epoch, since the <b>resource</b> was last emptied.
  <b>let</b> passed = <a href="MinerState.md#0x1_MinerState_node_above_thresh">node_above_thresh</a>(miner_addr);
  <b>let</b> miner_history = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);

  // Update statistics.
  <b>if</b> (passed) {
      <b>let</b> this_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
      miner_history.latest_epoch_mining = this_epoch;

      miner_history.epochs_validating_and_mining = miner_history.epochs_validating_and_mining + 1u64;

      miner_history.contiguous_epochs_validating_and_mining = miner_history.contiguous_epochs_validating_and_mining + 1u64;

      miner_history.epochs_since_last_account_creation = miner_history.epochs_since_last_account_creation + 1u64;
  } <b>else</b> {
    // didn't meet the threshold, reset this count
    miner_history.contiguous_epochs_validating_and_mining = 0;
  };

  // This is the end of the epoch, reset the count of proofs
  miner_history.count_proofs_in_epoch = 0u64;
}
</code></pre>



</details>

<a name="0x1_MinerState_node_above_thresh"></a>

## Function `node_above_thresh`

Checks to see if miner submitted enough proofs to be considered compliant


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_node_above_thresh">node_above_thresh</a>(miner_addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_node_above_thresh">node_above_thresh</a>(miner_addr: address): bool <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>let</b> miner_history = borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);
  miner_history.count_proofs_in_epoch &gt; <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">Globals::get_epoch_mining_thres_lower</a>()
}
</code></pre>



</details>

<a name="0x1_MinerState_get_validator_weight"></a>

## Function `get_validator_weight`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_validator_weight">get_validator_weight</a>(account: &signer, miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_validator_weight">get_validator_weight</a>(account: &signer, miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130109));

// //Get the number of epochs a validator has been validating and mining.
// // Permissions: <b>public</b>, only VM can call this function.
// // Function code: 05
// <b>public</b> <b>fun</b> get_validator_epochs_validating_and_mining(account: &signer, miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
//   <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
//   <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130105));

//   // Miner may not have been initialized. (don't <b>abort</b>, just <b>return</b> 0)
//   <b>if</b>( !<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr)){
//     <b>return</b> 0
//   };

  // Update the statistics.
  <b>let</b> miner_history= borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);
  <b>let</b> this_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  miner_history.latest_epoch_mining = this_epoch;

  // Return its weight
  miner_history.epochs_validating_and_mining
}
</code></pre>



</details>

<a name="0x1_MinerState_reconfig"></a>

## Function `reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_reconfig">reconfig</a>(vm: &signer, migrate_eligible_validators: &vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_reconfig">reconfig</a>(vm: &signer, migrate_eligible_validators: &vector&lt;address&gt;) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> {
  // Check permissions
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  // check minerlist <b>exists</b>, or <b>use</b> eligible_validators <b>to</b> initialize.
  // Migration on hot upgrade
  <b>if</b> (!<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0)) {
    move_to&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(vm, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> {
      list: *migrate_eligible_validators
    });
  };

  <b>let</b> minerlist_state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0);

  // // Get list of validators from <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>
  // <b>let</b> eligible_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>(vm);

  // Iterate through validators and call update_metrics for each validator that had proofs this epoch
  <b>let</b> size = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(& *&minerlist_state.list); //TODO: These references are weird
  <b>let</b> i = 0;
  <b>while</b> (i &lt; size) {
      <b>let</b> val = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&minerlist_state.list, i);

      // For testing: don't call update_metrics unless there is account state for the address.
      <b>if</b> (<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(*val)){
          <a href="MinerState.md#0x1_MinerState_update_metrics">update_metrics</a>(vm, *val);
      };
      i = i + 1;
  };

  //reset miner list
  minerlist_state.list = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();

}
</code></pre>



</details>

<a name="0x1_MinerState_init_miner_state"></a>

## Function `init_miner_state`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_init_miner_state">init_miner_state</a>(miner_sig: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_init_miner_state">init_miner_state</a>(miner_sig: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {

  // NOTE Only <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a> can <b>update</b> own state.
  // Should only happen once.
  <b>assert</b>(!<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig)), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130111));
  // <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> calls this.
  // Exception is <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> which can simulate a <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a>.
  // Initialize <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> object and give <b>to</b> miner account
  move_to&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_sig, <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>{
    previous_proof_hash: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    verified_tower_height: 0u64,
    latest_epoch_mining: 0u64,
    count_proofs_in_epoch: 1u64,
    epochs_validating_and_mining: 0u64,
    contiguous_epochs_validating_and_mining: 0u64,
    epochs_since_last_account_creation: 0u64,
  });

  // create the initial proof submission
  <b>let</b> difficulty = <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>();
  <b>let</b> proof = <a href="MinerState.md#0x1_MinerState_Proof">Proof</a> {
    challenge: *challenge,
    difficulty,
    solution: *solution,
  };

  // TODO: should fullnode state happen here?
  // FullnodeState::init(miner_sig);

  //submit the proof
  <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig), proof, <b>false</b>);
}
</code></pre>



</details>

<a name="0x1_MinerState_first_challenge_includes_address"></a>

## Function `first_challenge_includes_address`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_first_challenge_includes_address">first_challenge_includes_address</a>(new_account_address: address, challenge: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_first_challenge_includes_address">first_challenge_includes_address</a>(new_account_address: address, challenge: &vector&lt;u8&gt;) {
  // Checks that the preimage/challenge of the FIRST <a href="VDF.md#0x1_VDF">VDF</a> proof blob contains a given address.
  // This is <b>to</b> ensure that the same proof is not sent repeatedly, since all the minerstate is on a
  // the address of a miner.
  // Note: The bytes of the miner challenge is <b>as</b> follows:
  //         32 // 0L Key
  //         +64 // chain_id
  //         +8 // iterations/difficulty
  //         +1024; // statement

  // Calling <b>native</b> function <b>to</b> do this parsing in rust
  // The auth_key must be at least 32 bytes long
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(challenge) &gt;= 32, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130112));
  <b>let</b> (parsed_address, _auth_key) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(challenge);
  // Confirm the address is corect and included in challenge
  <b>assert</b>(new_account_address == parsed_address, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(130113));
}
</code></pre>



</details>

<a name="0x1_MinerState_get_miner_latest_epoch"></a>

## Function `get_miner_latest_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_miner_latest_epoch">get_miner_latest_epoch</a>(vm: &signer, addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_miner_latest_epoch">get_miner_latest_epoch</a>(vm: &signer, addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>let</b> addr_state = borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr);
  *&addr_state.latest_epoch_mining
}
</code></pre>



</details>

<a name="0x1_MinerState_reset_rate_limit"></a>

## Function `reset_rate_limit`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_reset_rate_limit">reset_rate_limit</a>(miner: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_reset_rate_limit">reset_rate_limit</a>(miner: &signer) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner));
  state.epochs_since_last_account_creation = 0;
}
</code></pre>



</details>

<a name="0x1_MinerState_get_miner_list"></a>

## Function `get_miner_list`

Public Getters ///


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_miner_list">get_miner_list</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_miner_list">get_miner_list</a>(): vector&lt;address&gt; <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0)) {
    <b>return</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  };
  *&borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>&gt;(@0x0).list
}
</code></pre>



</details>

<a name="0x1_MinerState_get_epochs_mining"></a>

## Function `get_epochs_mining`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_epochs_mining">get_epochs_mining</a>(node_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_epochs_mining">get_epochs_mining</a>(node_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr)) {
    <b>return</b> borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr).epochs_validating_and_mining

  };
  0
}
</code></pre>



</details>

<a name="0x1_MinerState_get_count_in_epoch"></a>

## Function `get_count_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr)) {
    <b>return</b> borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr).count_proofs_in_epoch
  };
  0
}
</code></pre>



</details>

<a name="0x1_MinerState_can_create_val_account"></a>

## Function `can_create_val_account`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_can_create_val_account">can_create_val_account</a>(node_addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_can_create_val_account">can_create_val_account</a>(node_addr: address): bool <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>if</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>() || <a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()) <b>return</b> <b>true</b>;
  // check <b>if</b> rate limited, needs 7 epochs of validating.
  <b>if</b> (<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr)) {
    <b>return</b> borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr).epochs_since_last_account_creation &gt; <a href="MinerState.md#0x1_MinerState_EPOCHS_UNTIL_ACCOUNT_CREATION">EPOCHS_UNTIL_ACCOUNT_CREATION</a>
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper"></a>

## Function `test_helper`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper">test_helper</a>(miner_sig: &signer, difficulty: u64, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper">test_helper</a>(
    miner_sig: &signer,
    difficulty: u64,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;
  ) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
    <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 130102014010);

    move_to&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_sig, <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>{
      previous_proof_hash: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      verified_tower_height: 0u64,
      latest_epoch_mining: 0u64,
      count_proofs_in_epoch: 0u64,
      epochs_validating_and_mining: 1u64,
      contiguous_epochs_validating_and_mining: 0u64,
      epochs_since_last_account_creation: 10u64, // is not rate-limited
    });

    // Needs difficulty <b>to</b> test between easy and hard mode.
    <b>let</b> proof = <a href="MinerState.md#0x1_MinerState_Proof">Proof</a> {
      challenge,
      difficulty,
      solution,
    };

    <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig), proof, <b>false</b>);
    // FullnodeState::init(miner_sig);

}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_operator_submits"></a>

## Function `test_helper_operator_submits`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_operator_submits">test_helper_operator_submits</a>(operator_addr: address, miner_addr: address, proof: <a href="MinerState.md#0x1_MinerState_Proof">MinerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_operator_submits">test_helper_operator_submits</a>(
  operator_addr: address, // Testrunner does not allow arbitrary accounts <b>to</b> submit txs, need <b>to</b> <b>use</b> address, so this will differ slightly from api
  miner_addr: address,
  proof: <a href="MinerState.md#0x1_MinerState_Proof">Proof</a>
) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerList">MinerList</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 130102014010);

  // Get address, assumes the sender is the signer.
  <b>assert</b>(<a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr) == operator_addr, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(130111));
  // Abort <b>if</b> not initialized.
  <b>assert</b>(<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130116));

  // Get vdf difficulty constant. Will be different in tests than in production.
  <b>let</b> difficulty_constant = <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>();

  // Skip this check on local tests, we need tests <b>to</b> send different difficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){
    <b>assert</b>(&proof.difficulty == &difficulty_constant, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130117));
  };

  <a href="MinerState.md#0x1_MinerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);

  // TODO: The operator mining needs its own <b>struct</b> <b>to</b> count mining.
  // For now it is implicit there is only 1 operator per validator, and that the fullnode state is the place <b>to</b> count.
  // This will require a breaking change <b>to</b> <a href="MinerState.md#0x1_MinerState">MinerState</a>
  // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_mock_mining"></a>

## Function `test_helper_mock_mining`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_mining">test_helper_mock_mining</a>(sender: &signer, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_mining">test_helper_mock_mining</a>(sender: &signer,  count: u64) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130118));
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr);
  state.count_proofs_in_epoch = count;
  <b>let</b> i = 0;
  <b>while</b> (i &lt; count) {
    <a href="MinerState.md#0x1_MinerState_increment_stats">increment_stats</a>(addr);
    i = i + 1;
  }

  // FullnodeState::mock_proof(sender, count);
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_mock_mining_vm"></a>

## Function `test_helper_mock_mining_vm`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_mining_vm">test_helper_mock_mining_vm</a>(vm: &signer, addr: address, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_mining_vm">test_helper_mock_mining_vm</a>(vm: &signer, addr: address, count: u64) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>, <a href="MinerState.md#0x1_MinerState_MinerStats">MinerStats</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130120));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr);
  state.count_proofs_in_epoch = count;

  <b>let</b> i = 0;
  <b>while</b> (i &lt; count) {
    <a href="MinerState.md#0x1_MinerState_increment_stats">increment_stats</a>(addr);
    i = i + 1;
  }
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_mock_reconfig"></a>

## Function `test_helper_mock_reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_reconfig">test_helper_mock_reconfig</a>(account: &signer, miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_mock_reconfig">test_helper_mock_reconfig</a>(account: &signer, miner_addr: address) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>{
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(account);
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130122));
  <a href="MinerState.md#0x1_MinerState_update_metrics">update_metrics</a>(account, miner_addr);
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_get_height"></a>

## Function `test_helper_get_height`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_height">test_helper_get_height</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_height">test_helper_get_height</a>(miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130123));

  <b>assert</b>(<b>exists</b>&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130124));

  <b>let</b> state = borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);
  *&state.verified_tower_height
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_get_count"></a>

## Function `test_helper_get_count`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_count">test_helper_get_count</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_count">test_helper_get_count</a>(miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
    <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, 130115014011);
    borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr).count_proofs_in_epoch
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_get_contiguous"></a>

## Function `test_helper_get_contiguous`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_contiguous">test_helper_get_contiguous</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_get_contiguous">test_helper_get_contiguous</a>(miner_addr: address): u64 <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130125));
  borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr).contiguous_epochs_validating_and_mining
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_set_rate_limit"></a>

## Function `test_helper_set_rate_limit`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_rate_limit">test_helper_set_rate_limit</a>(miner_addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_rate_limit">test_helper_set_rate_limit</a>(miner_addr: address, value: u64) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr);
  state.epochs_since_last_account_creation = value;
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_set_epochs_mining"></a>

## Function `test_helper_set_epochs_mining`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_epochs_mining">test_helper_set_epochs_mining</a>(node_addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_epochs_mining">test_helper_set_epochs_mining</a>(node_addr: address, value: u64)<b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));

  <b>let</b> s = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr);
  s.epochs_validating_and_mining = value;
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_set_proofs_in_epoch"></a>

## Function `test_helper_set_proofs_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_proofs_in_epoch">test_helper_set_proofs_in_epoch</a>(node_addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_proofs_in_epoch">test_helper_set_proofs_in_epoch</a>(node_addr: address, value: u64)<b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));

  <b>let</b> s = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(node_addr);
  s.count_proofs_in_epoch = value;
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_hash"></a>

## Function `test_helper_hash`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_hash">test_helper_hash</a>(miner_addr: address): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_hash">test_helper_hash</a>(miner_addr: address): vector&lt;u8&gt; <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130128));
  *&borrow_global&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(miner_addr).previous_proof_hash
}
</code></pre>



</details>

<a name="0x1_MinerState_test_helper_set_weight_vm"></a>

## Function `test_helper_set_weight_vm`



<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_weight_vm">test_helper_set_weight_vm</a>(_vm: &signer, addr: address, weight: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MinerState.md#0x1_MinerState_test_helper_set_weight_vm">test_helper_set_weight_vm</a>(_vm: &signer, addr: address, weight: u64) <b>acquires</b> <a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <b>let</b> state = borrow_global_mut&lt;<a href="MinerState.md#0x1_MinerState_MinerProofHistory">MinerProofHistory</a>&gt;(addr);
  state.epochs_validating_and_mining = weight;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
