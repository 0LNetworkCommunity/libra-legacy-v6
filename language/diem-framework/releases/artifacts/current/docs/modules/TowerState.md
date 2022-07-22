
<a name="0x1_TowerState"></a>

# Module `0x1::TowerState`



-  [Resource `TowerList`](#0x1_TowerState_TowerList)
-  [Resource `TowerStats`](#0x1_TowerState_TowerStats)
-  [Resource `TowerCounter`](#0x1_TowerState_TowerCounter)
-  [Struct `Proof`](#0x1_TowerState_Proof)
-  [Resource `TowerProofHistory`](#0x1_TowerState_TowerProofHistory)
-  [Resource `VDFDifficulty`](#0x1_TowerState_VDFDifficulty)
-  [Constants](#@Constants_0)
-  [Function `init_difficulty`](#0x1_TowerState_init_difficulty)
-  [Function `init_miner_list`](#0x1_TowerState_init_miner_list)
-  [Function `init_tower_counter`](#0x1_TowerState_init_tower_counter)
-  [Function `init_miner_list_and_stats`](#0x1_TowerState_init_miner_list_and_stats)
-  [Function `is_init`](#0x1_TowerState_is_init)
-  [Function `is_onboarding`](#0x1_TowerState_is_onboarding)
-  [Function `create_proof_blob`](#0x1_TowerState_create_proof_blob)
-  [Function `increment_miners_list`](#0x1_TowerState_increment_miners_list)
-  [Function `genesis_helper`](#0x1_TowerState_genesis_helper)
-  [Function `commit_state`](#0x1_TowerState_commit_state)
-  [Function `commit_state_by_operator`](#0x1_TowerState_commit_state_by_operator)
-  [Function `verify_and_update_state`](#0x1_TowerState_verify_and_update_state)
-  [Function `update_epoch_metrics_vals`](#0x1_TowerState_update_epoch_metrics_vals)
-  [Function `node_above_thresh`](#0x1_TowerState_node_above_thresh)
-  [Function `epoch_param_reset`](#0x1_TowerState_epoch_param_reset)
-  [Function `reconfig`](#0x1_TowerState_reconfig)
-  [Function `init_miner_state`](#0x1_TowerState_init_miner_state)
-  [Function `first_challenge_includes_address`](#0x1_TowerState_first_challenge_includes_address)
-  [Function `get_miner_latest_epoch`](#0x1_TowerState_get_miner_latest_epoch)
-  [Function `reset_rate_limit`](#0x1_TowerState_reset_rate_limit)
-  [Function `increment_stats`](#0x1_TowerState_increment_stats)
-  [Function `epoch_reset`](#0x1_TowerState_epoch_reset)
-  [Function `toy_rng`](#0x1_TowerState_toy_rng)
-  [Function `get_miner_list`](#0x1_TowerState_get_miner_list)
-  [Function `get_tower_height`](#0x1_TowerState_get_tower_height)
-  [Function `get_epochs_compliant`](#0x1_TowerState_get_epochs_compliant)
-  [Function `get_count_in_epoch`](#0x1_TowerState_get_count_in_epoch)
-  [Function `get_count_above_thresh_in_epoch`](#0x1_TowerState_get_count_above_thresh_in_epoch)
-  [Function `lazy_reset_count_in_epoch`](#0x1_TowerState_lazy_reset_count_in_epoch)
-  [Function `can_create_val_account`](#0x1_TowerState_can_create_val_account)
-  [Function `get_validator_proofs_in_epoch`](#0x1_TowerState_get_validator_proofs_in_epoch)
-  [Function `get_fullnode_proofs_in_epoch`](#0x1_TowerState_get_fullnode_proofs_in_epoch)
-  [Function `get_fullnode_proofs_in_epoch_above_thresh`](#0x1_TowerState_get_fullnode_proofs_in_epoch_above_thresh)
-  [Function `get_lifetime_proof_count`](#0x1_TowerState_get_lifetime_proof_count)
-  [Function `danger_migrate_get_lifetime_proof_count`](#0x1_TowerState_danger_migrate_get_lifetime_proof_count)
-  [Function `get_difficulty`](#0x1_TowerState_get_difficulty)
-  [Function `test_helper_init_val`](#0x1_TowerState_test_helper_init_val)
-  [Function `test_epoch_reset_counter`](#0x1_TowerState_test_epoch_reset_counter)
-  [Function `test_helper_operator_submits`](#0x1_TowerState_test_helper_operator_submits)
-  [Function `test_helper_mock_mining`](#0x1_TowerState_test_helper_mock_mining)
-  [Function `test_helper_mock_mining_vm`](#0x1_TowerState_test_helper_mock_mining_vm)
-  [Function `danger_mock_mining`](#0x1_TowerState_danger_mock_mining)
-  [Function `test_helper_mock_reconfig`](#0x1_TowerState_test_helper_mock_reconfig)
-  [Function `test_helper_get_height`](#0x1_TowerState_test_helper_get_height)
-  [Function `test_helper_get_count`](#0x1_TowerState_test_helper_get_count)
-  [Function `test_helper_get_nominal_count`](#0x1_TowerState_test_helper_get_nominal_count)
-  [Function `test_helper_get_contiguous_vm`](#0x1_TowerState_test_helper_get_contiguous_vm)
-  [Function `test_helper_set_rate_limit`](#0x1_TowerState_test_helper_set_rate_limit)
-  [Function `test_helper_set_epochs_mining`](#0x1_TowerState_test_helper_set_epochs_mining)
-  [Function `test_helper_set_proofs_in_epoch`](#0x1_TowerState_test_helper_set_proofs_in_epoch)
-  [Function `test_helper_previous_proof_hash`](#0x1_TowerState_test_helper_previous_proof_hash)
-  [Function `test_helper_set_weight_vm`](#0x1_TowerState_test_helper_set_weight_vm)
-  [Function `test_helper_set_weight`](#0x1_TowerState_test_helper_set_weight)
-  [Function `test_mock_depr_tower_stats`](#0x1_TowerState_test_mock_depr_tower_stats)
-  [Function `test_get_liftime_proofs`](#0x1_TowerState_test_get_liftime_proofs)
-  [Function `test_set_vdf_difficulty`](#0x1_TowerState_test_set_vdf_difficulty)
-  [Function `test_danger_destroy_tower_counter`](#0x1_TowerState_test_danger_destroy_tower_counter)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
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



<a name="0x1_TowerState_TowerList"></a>

## Resource `TowerList`

A list of all miners' addresses


<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a> has key
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

<a name="0x1_TowerState_TowerStats"></a>

## Resource `TowerStats`

To use in migration, and in future upgrade to deprecate.


<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a> has key
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

<a name="0x1_TowerState_TowerCounter"></a>

## Resource `TowerCounter`

The struct to store the global count of proofs in 0x0


<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>lifetime_proofs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_validator_proofs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_fullnode_proofs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>proofs_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>validator_proofs_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>fullnode_proofs_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>validator_proofs_in_epoch_above_thresh: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>fullnode_proofs_in_epoch_above_thresh: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TowerState_Proof"></a>

## Struct `Proof`

Struct to store information about a VDF proof submitted
<code>challenge</code>: the seed for the proof
<code>difficulty</code>: the difficulty for the proof
(higher difficulty -> longer proof time)
<code>solution</code>: the solution for the proof (the result)


<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_Proof">Proof</a> has drop
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
<dt>
<code>security: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TowerState_TowerProofHistory"></a>

## Resource `TowerProofHistory`

Struct to encapsulate information about the state of a miner
<code>previous_proof_hash</code>: the hash of their latest proof
(used as seed for next proof)
<code>verified_tower_height</code>: the height of the miner's tower
(more proofs -> higher tower)
<code>latest_epoch_mining</code>: the latest epoch the miner submitted sufficient
proofs (see GlobalConstants.epoch_mining_thres_lower)
<code>count_proofs_in_epoch</code>: the number of proofs the miner has submitted
in the current epoch
<code>epochs_validating_and_mining</code>: the cumulative number of epochs
the miner has been mining above threshold
TODO does this actually only apply to validators?
<code>contiguous_epochs_validating_and_mining</code>: the number of contiguous
epochs the miner has been mining above threshold
TODO does this actually only apply to validators?
<code>epochs_since_last_account_creation</code>: the number of epochs since
the miner last created a new account


<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> has key
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

<a name="0x1_TowerState_VDFDifficulty"></a>

## Resource `VDFDifficulty`



<pre><code><b>struct</b> <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>difficulty: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>security: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>prev_diff: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>prev_sec: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TowerState_EPOCHS_UNTIL_ACCOUNT_CREATION"></a>



<pre><code><b>const</b> <a href="TowerState.md#0x1_TowerState_EPOCHS_UNTIL_ACCOUNT_CREATION">EPOCHS_UNTIL_ACCOUNT_CREATION</a>: u64 = 14;
</code></pre>



<a name="0x1_TowerState_init_difficulty"></a>

## Function `init_difficulty`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_difficulty">init_difficulty</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_difficulty">init_difficulty</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
      move_to&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(vm, <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
        difficulty: 100,
        security: 512,
        prev_diff: 100,
        prev_sec: 512,
      });
    } <b>else</b> {
      move_to&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(vm, <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
        difficulty: 5000000,
        security: 512,
        prev_diff: 5000000,
        prev_sec: 512,
      });
    }

  }
}
</code></pre>



</details>

<a name="0x1_TowerState_init_miner_list"></a>

## Function `init_miner_list`

Create an empty list of miners


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_list">init_miner_list</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_list">init_miner_list</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  move_to&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(vm, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a> {
    list: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  });
}
</code></pre>



</details>

<a name="0x1_TowerState_init_tower_counter"></a>

## Function `init_tower_counter`

Create an empty miner stats


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_tower_counter">init_tower_counter</a>(vm: &signer, lifetime_proofs: u64, lifetime_validator_proofs: u64, lifetime_fullnode_proofs: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_tower_counter">init_tower_counter</a>(
  vm: &signer,
  lifetime_proofs: u64,
  lifetime_validator_proofs: u64,
  lifetime_fullnode_proofs: u64,
) {
  <b>if</b> (!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    move_to&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(vm, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
      lifetime_proofs,
      lifetime_validator_proofs,
      lifetime_fullnode_proofs,
      proofs_in_epoch: 0,
      validator_proofs_in_epoch: 0,
      fullnode_proofs_in_epoch: 0,
      validator_proofs_in_epoch_above_thresh: 0,
      fullnode_proofs_in_epoch_above_thresh: 0,
    });
  }

}
</code></pre>



</details>

<a name="0x1_TowerState_init_miner_list_and_stats"></a>

## Function `init_miner_list_and_stats`

Create empty miners list and stats


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_list_and_stats">init_miner_list_and_stats</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_list_and_stats">init_miner_list_and_stats</a>(vm: &signer) {
  <a href="TowerState.md#0x1_TowerState_init_miner_list">init_miner_list</a>(vm);

  // Note: for testing migration we need <b>to</b> destroy this <b>struct</b>, see test_danger_destroy_tower_counter
  <a href="TowerState.md#0x1_TowerState_init_tower_counter">init_tower_counter</a>(vm, 0, 0, 0);
}
</code></pre>



</details>

<a name="0x1_TowerState_is_init"></a>

## Function `is_init`

returns true if miner at <code>addr</code> has been initialized


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_is_init">is_init</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_is_init">is_init</a>(addr: address):bool {
  <b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_TowerState_is_onboarding"></a>

## Function `is_onboarding`

is onboarding


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_is_onboarding">is_onboarding</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_is_onboarding">is_onboarding</a>(addr: address): bool <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>let</b> count = <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(addr);
  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);

  count &lt; 2 &&
  state.epochs_since_last_account_creation &lt; 2
}
</code></pre>



</details>

<a name="0x1_TowerState_create_proof_blob"></a>

## Function `create_proof_blob`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_create_proof_blob">create_proof_blob</a>(challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, difficulty: u64, security: u64): <a href="TowerState.md#0x1_TowerState_Proof">TowerState::Proof</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_create_proof_blob">create_proof_blob</a>(
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;,
  difficulty: u64,
  security: u64,
): <a href="TowerState.md#0x1_TowerState_Proof">Proof</a> {
   <a href="TowerState.md#0x1_TowerState_Proof">Proof</a> {
     challenge,
     difficulty,
     solution,
     security,
  }
}
</code></pre>



</details>

<a name="0x1_TowerState_increment_miners_list"></a>

## Function `increment_miners_list`

Private, can only be called within module
adds <code>tower</code> to list of towers


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_increment_miners_list">increment_miners_list</a>(miner: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_increment_miners_list">increment_miners_list</a>(miner: address) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0)) {
    <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0);
    <b>if</b> (!<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&<b>mut</b> state.list, &miner)) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.list, miner);
    }
  }
}
</code></pre>



</details>

<a name="0x1_TowerState_genesis_helper"></a>

## Function `genesis_helper`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_genesis_helper">genesis_helper</a>(vm_sig: &signer, miner_sig: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, difficulty: u64, security: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_genesis_helper">genesis_helper</a>(
  vm_sig: &signer,
  miner_sig: &signer,
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;,
  difficulty: u64,
  security: u64,
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  // TODO: Previously in OLv3 is_genesis() returned <b>true</b>.
  // How <b>to</b> check that this is part of genesis? is_genesis returns <b>false</b> here.

  // In rust the vm_genesis creates a <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a> for the miner.
  // So the SENDER is not the same and the <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a>.

  <a href="TowerState.md#0x1_TowerState_init_miner_state">init_miner_state</a>(miner_sig, &challenge, &solution, difficulty, security);
  // TODO: Move this elsewhere?
  // Initialize stats for first validator set from rust genesis.
  <b>let</b> node_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig);
  <a href="Stats.md#0x1_Stats_init_address">Stats::init_address</a>(vm_sig, node_addr);
}
</code></pre>



</details>

<a name="0x1_TowerState_commit_state"></a>

## Function `commit_state`

This function is called to submit proofs to the chain
Function index: 01
Permissions: PUBLIC, ANYONE


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_commit_state">commit_state</a>(miner_sign: &signer, proof: <a href="TowerState.md#0x1_TowerState_Proof">TowerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_commit_state">commit_state</a>(
  miner_sign: &signer,
  proof: <a href="TowerState.md#0x1_TowerState_Proof">Proof</a>
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>, <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
  // Get address, assumes the sender is the signer.
  <b>let</b> miner_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sign);
  <b>let</b> diff = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());

  // This may be the 0th proof of an end user that hasn't had tower state initialized
  <b>if</b> (!<a href="TowerState.md#0x1_TowerState_is_init">is_init</a>(miner_addr)) {

    <b>assert</b>(&proof.difficulty == &<a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">Globals::get_vdf_difficulty_baseline</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130102));
    <b>assert</b>(&proof.security == &<a href="Globals.md#0x1_Globals_get_vdf_security_baseline">Globals::get_vdf_security_baseline</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(13010202));

    // check proof belongs <b>to</b> user.
    <b>let</b> (addr_in_proof, _) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(&proof.challenge);
    <b>assert</b>(addr_in_proof == <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sign), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130112));

    <a href="TowerState.md#0x1_TowerState_init_miner_state">init_miner_state</a>(miner_sign, &proof.challenge, &proof.solution, proof.difficulty, proof.security);
    <b>return</b>
  };


  // Skip this check on local tests, we need tests <b>to</b> send different difficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){
    // Get vdf difficulty constant. Will be different in tests than in production.

    // need <b>to</b> also give allowance for user's first proof in epoch <b>to</b> be in the last proof.
    <b>if</b> (<a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr) == 0) {
      // first proof in this epoch, can be either the previous difficulty or the current one
      <b>let</b> is_diff = &proof.difficulty == &diff.difficulty ||
      &proof.difficulty == &diff.prev_diff;

      <b>let</b> is_sec = &proof.difficulty == &diff.security ||
      &proof.difficulty == &diff.prev_sec;

      <b>assert</b>(is_diff, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130102));
      <b>assert</b>(is_sec, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(13010202));
    } <b>else</b> {
      <b>assert</b>(&proof.difficulty == &diff.difficulty, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130102));
      <b>assert</b>(&proof.security == &diff.security, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(13010202));
    };
  };
  // Process the proof
  <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);
}
</code></pre>



</details>

<a name="0x1_TowerState_commit_state_by_operator"></a>

## Function `commit_state_by_operator`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_commit_state_by_operator">commit_state_by_operator</a>(operator_sig: &signer, miner_addr: address, proof: <a href="TowerState.md#0x1_TowerState_Proof">TowerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_commit_state_by_operator">commit_state_by_operator</a>(
  operator_sig: &signer,
  miner_addr: address,
  proof: <a href="TowerState.md#0x1_TowerState_Proof">Proof</a>
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {

  // Check the signer is in fact an operator delegated by the owner.

  // Get address, assumes the sender is the signer.
  <b>assert</b>(<a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr) == <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(operator_sig), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130103));
  // Abort <b>if</b> not initialized. Assumes the validator Owner account already has submitted the 0th miner proof in onboarding.
  <b>assert</b>(<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130104));

  // Return early <b>if</b> difficulty and security are not correct.
  // Check vdf difficulty constant. Will be different in tests than in production.
  // Skip this check on local tests, we need tests <b>to</b> send differentdifficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){
    <b>assert</b>(&proof.difficulty == &<a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">Globals::get_vdf_difficulty_baseline</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130105));
    <b>assert</b>(&proof.security == &<a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">Globals::get_vdf_difficulty_baseline</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130106));
  };

  // Process the proof
  <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);

  // TODO: The operator mining needs its own <b>struct</b> <b>to</b> count mining.
  // For now it is implicit there is only 1 operator per validator,
  // and that the fullnode state is the place <b>to</b> count.
  // This will require a breaking change <b>to</b> <a href="TowerState.md#0x1_TowerState">TowerState</a>
  // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
}
</code></pre>



</details>

<a name="0x1_TowerState_verify_and_update_state"></a>

## Function `verify_and_update_state`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(miner_addr: address, proof: <a href="TowerState.md#0x1_TowerState_Proof">TowerState::Proof</a>, steady_state: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(
  miner_addr: address,
  proof: <a href="TowerState.md#0x1_TowerState_Proof">Proof</a>,
  steady_state: bool
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  // instead of looping through all miners at end of epcoh the stats are only reset when the miner submits a new proof.
  <a href="TowerState.md#0x1_TowerState_lazy_reset_count_in_epoch">lazy_reset_count_in_epoch</a>(miner_addr);

  <b>assert</b>(
    <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr) &lt; <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_upper">Globals::get_epoch_mining_thres_upper</a>(),
    <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130108)
  );

  <b>let</b> miner_history = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);

  // If not genesis proof, check hash <b>to</b> ensure the proof continues the chain
  <b>if</b> (steady_state) {
    //If not genesis proof, check hash
    <b>assert</b>(&proof.challenge == &miner_history.previous_proof_hash,
    <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130109));
  };

  <b>let</b> valid = <a href="VDF.md#0x1_VDF_verify">VDF::verify</a>(&proof.challenge, &proof.solution, &proof.difficulty, &proof.security);
  <b>assert</b>(valid, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130110));

  // add the miner <b>to</b> the miner list <b>if</b> not present
  <a href="TowerState.md#0x1_TowerState_increment_miners_list">increment_miners_list</a>(miner_addr);

  // Get a mutable ref <b>to</b> the current state
  <b>let</b> miner_history = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);

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

  <a href="TowerState.md#0x1_TowerState_increment_stats">increment_stats</a>(miner_addr);
}
</code></pre>



</details>

<a name="0x1_TowerState_update_epoch_metrics_vals"></a>

## Function `update_epoch_metrics_vals`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_update_epoch_metrics_vals">update_epoch_metrics_vals</a>(account: &signer, miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_update_epoch_metrics_vals">update_epoch_metrics_vals</a>(account: &signer, miner_addr: address) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  // The goal of update_metrics is <b>to</b> confirm that a miner participated in consensus during
  // an epoch, but also that there were mining proofs submitted in that epoch.
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(account);

  // Tower may not have been initialized.
  // Simply <b>return</b> in this case (don't <b>abort</b>)
  <b>if</b>(!<a href="TowerState.md#0x1_TowerState_is_init">is_init</a>(miner_addr)) { <b>return</b> };

  // Check that there was mining and validating in period.
  // Account may not have any proofs submitted in epoch, since
  // the <b>resource</b> was last emptied.
  <b>let</b> passed = <a href="TowerState.md#0x1_TowerState_node_above_thresh">node_above_thresh</a>(miner_addr);
  <b>let</b> miner_history = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);
  // Update statistics.
  <b>if</b> (passed) {
      // <b>let</b> this_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
      // miner_history.latest_epoch_mining = this_epoch; // TODO: Don't need this
      miner_history.epochs_validating_and_mining
        = miner_history.epochs_validating_and_mining + 1u64;
      miner_history.contiguous_epochs_validating_and_mining
        = miner_history.contiguous_epochs_validating_and_mining + 1u64;
      miner_history.epochs_since_last_account_creation
        = miner_history.epochs_since_last_account_creation + 1u64;
  } <b>else</b> {
    // didn't meet the threshold, reset this count
    miner_history.contiguous_epochs_validating_and_mining = 0;
  };

  // This is the end of the epoch, reset the count of proofs
  miner_history.count_proofs_in_epoch = 0u64;
}
</code></pre>



</details>

<a name="0x1_TowerState_node_above_thresh"></a>

## Function `node_above_thresh`

Checks to see if miner submitted enough proofs to be considered compliant


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_node_above_thresh">node_above_thresh</a>(miner_addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_node_above_thresh">node_above_thresh</a>(miner_addr: address): bool <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr) &gt;= <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">Globals::get_epoch_mining_thres_lower</a>()
}
</code></pre>



</details>

<a name="0x1_TowerState_epoch_param_reset"></a>

## Function `epoch_param_reset`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_epoch_param_reset">epoch_param_reset</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_epoch_param_reset">epoch_param_reset</a>(vm: &signer) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>  {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  <b>let</b> diff = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());

  diff.prev_diff = diff.difficulty;
  diff.prev_sec = diff.security;

  // NOTE: For now we are not changing the vdf security params.
  <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
    // <a href="VDF.md#0x1_VDF">VDF</a> proofs must be even numbers.
    <b>let</b> rng =  <a href="TowerState.md#0x1_TowerState_toy_rng">toy_rng</a>(3, 2);
    <b>if</b> (rng &gt; 0) {
      rng = rng * 2;
    };
    diff.difficulty = <a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">Globals::get_vdf_difficulty_baseline</a>() + rng;

  }
}
</code></pre>



</details>

<a name="0x1_TowerState_reconfig"></a>

## Function `reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_reconfig">reconfig</a>(vm: &signer, outgoing_validators: &vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_reconfig">reconfig</a>(vm: &signer, outgoing_validators: &vector&lt;address&gt;) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>, <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
  // Check permissions
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  // <b>update</b> the vdf parameters
  <a href="TowerState.md#0x1_TowerState_epoch_param_reset">epoch_param_reset</a>(vm);

  // Iterate through validators and call update_metrics for each validator that had proofs this epoch
  <b>let</b> vals_len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(outgoing_validators); //TODO: These references are weird
  <b>let</b> i = 0;
  <b>while</b> (i &lt; vals_len) {
      <b>let</b> val = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(outgoing_validators, i);

      // For testing: don't call update_metrics unless there is account state for the address.
      <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(*val)){
          <a href="TowerState.md#0x1_TowerState_update_epoch_metrics_vals">update_epoch_metrics_vals</a>(vm, *val);
      };
      i = i + 1;
  };

  <a href="TowerState.md#0x1_TowerState_epoch_reset">epoch_reset</a>(vm);
  // safety
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0)) {
    //reset miner list
    <b>let</b> towerlist_state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0);
    towerlist_state.list = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
  };
}
</code></pre>



</details>

<a name="0x1_TowerState_init_miner_state"></a>

## Function `init_miner_state`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_state">init_miner_state</a>(miner_sig: &signer, challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;, difficulty: u64, security: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_init_miner_state">init_miner_state</a>(
  miner_sig: &signer,
  challenge: &vector&lt;u8&gt;,
  solution: &vector&lt;u8&gt;,
  difficulty: u64,
  security: u64
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {

  // NOTE Only <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a> can <b>update</b> own state.
  // Should only happen once.
  <b>assert</b>(!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig)), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(130111));
  // <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> calls this.
  // Exception is <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> which can simulate a <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">Signer</a>.
  // Initialize <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> object and give <b>to</b> miner account
  move_to&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_sig, <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>{
    previous_proof_hash: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    verified_tower_height: 0u64,
    latest_epoch_mining: 0u64,
    count_proofs_in_epoch: 1u64,
    epochs_validating_and_mining: 0u64,
    contiguous_epochs_validating_and_mining: 0u64,
    epochs_since_last_account_creation: 0u64,
  });
  // create the initial proof submission
  <b>let</b> proof = <a href="TowerState.md#0x1_TowerState_Proof">Proof</a> {
    challenge: *challenge,
    difficulty,
    solution: *solution,
    security,
  };

  //submit the proof
  <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig), proof, <b>false</b>);
}
</code></pre>



</details>

<a name="0x1_TowerState_first_challenge_includes_address"></a>

## Function `first_challenge_includes_address`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_first_challenge_includes_address">first_challenge_includes_address</a>(new_account_address: address, challenge: &vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_first_challenge_includes_address">first_challenge_includes_address</a>(new_account_address: address, challenge: &vector&lt;u8&gt;) {
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
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(challenge) &gt;= 32, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(130113));
  <b>let</b> (parsed_address, _auth_key) = <a href="VDF.md#0x1_VDF_extract_address_from_challenge">VDF::extract_address_from_challenge</a>(challenge);
  // Confirm the address is corect and included in challenge
  <b>assert</b>(new_account_address == parsed_address, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(130114));
}
</code></pre>



</details>

<a name="0x1_TowerState_get_miner_latest_epoch"></a>

## Function `get_miner_latest_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_miner_latest_epoch">get_miner_latest_epoch</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_miner_latest_epoch">get_miner_latest_epoch</a>(addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>let</b> addr_state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
  *&addr_state.latest_epoch_mining
}
</code></pre>



</details>

<a name="0x1_TowerState_reset_rate_limit"></a>

## Function `reset_rate_limit`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_reset_rate_limit">reset_rate_limit</a>(miner: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_reset_rate_limit">reset_rate_limit</a>(miner: &signer) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner));
  state.epochs_since_last_account_creation = 0;
}
</code></pre>



</details>

<a name="0x1_TowerState_increment_stats"></a>

## Function `increment_stats`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_increment_stats">increment_stats</a>(miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_increment_stats">increment_stats</a>(miner_addr: address) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  // safety. Don't cause VM <b>to</b> halt
  <b>if</b> (!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) <b>return</b>;

  <b>let</b> above = <a href="TowerState.md#0x1_TowerState_node_above_thresh">node_above_thresh</a>(miner_addr);

  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());

  <b>if</b> (<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(miner_addr)) {
    state.validator_proofs_in_epoch = state.validator_proofs_in_epoch + 1;
    state.lifetime_validator_proofs = state.lifetime_validator_proofs + 1;
    // only proofs above threshold are counted here. The preceding proofs are not counted;
    <b>if</b> (above) { state.validator_proofs_in_epoch_above_thresh = state.validator_proofs_in_epoch_above_thresh + 1; }
  } <b>else</b> {
    state.fullnode_proofs_in_epoch = state.fullnode_proofs_in_epoch + 1;
    state.lifetime_fullnode_proofs = state.lifetime_fullnode_proofs + 1;
    // Preceding proofs before threshold was met are not counted <b>to</b> payment.
    <b>if</b> (above) { state.fullnode_proofs_in_epoch_above_thresh = state.fullnode_proofs_in_epoch_above_thresh + 1; }
  };

  state.proofs_in_epoch = state.proofs_in_epoch + 1;
  state.lifetime_proofs = state.lifetime_proofs + 1;
}
</code></pre>



</details>

<a name="0x1_TowerState_epoch_reset"></a>

## Function `epoch_reset`

Reset the tower counter at the end of epoch.


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_epoch_reset">epoch_reset</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_epoch_reset">epoch_reset</a>(vm: &signer) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) <b>return</b>;

  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.proofs_in_epoch = 0;
  state.validator_proofs_in_epoch = 0;
  state.fullnode_proofs_in_epoch = 0;
  state.validator_proofs_in_epoch_above_thresh = 0;
  state.fullnode_proofs_in_epoch_above_thresh = 0;
}
</code></pre>



</details>

<a name="0x1_TowerState_toy_rng"></a>

## Function `toy_rng`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_toy_rng">toy_rng</a>(seed: u64, iters: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_toy_rng">toy_rng</a>(seed: u64, iters: u64): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  // Get the list of all miners L
  // Pick a tower miner  (M) from the seed position 1/(N) of the list of miners.
  print(&77777777);

  <b>let</b> l = <a href="TowerState.md#0x1_TowerState_get_miner_list">get_miner_list</a>();
  print(&l);
  // the length will keep incrementing through the epoch. The last miner can know what the starting position will be. There could be a race <b>to</b> be the last validator <b>to</b> augment the set and bias the initial shuffle.
  <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&l);
  <b>if</b> (len == 0) <b>return</b> 0;
  print(&5555);

  // start n <b>with</b> the seed index
  <b>let</b> n = seed;

  <b>let</b> i = 0;
  <b>while</b> (i &lt; iters) {
    print(&6666);
    print(&i);
    // make sure we get an n smaller than list of validators
    // <b>abort</b> <b>if</b> loops too much
    <b>let</b> k = 0;
    <b>while</b> (n &gt; len) {
      <b>if</b> (k &gt; 1000) <b>return</b> 0;
      n = n / len;
      k = k + 1;
    };
    print(&n);
    print(&len);
    // double check
    <b>if</b> (len &lt;= n) <b>return</b> 0;

    print(&666602);
    <b>let</b> miner_addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&l, n);

    print(&666603);
    <b>let</b> vec = <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(*miner_addr)) {
      *&borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(*miner_addr).previous_proof_hash
    } <b>else</b> { <b>return</b> 0 };

    print(&vec);

    print(&666604);
    // take the last bit (B) from their last proof hash.

    n = (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(&<b>mut</b> vec) <b>as</b> u64);
    print(&666605);
    i = i + 1;
  };
  print(&8888);

  n
}
</code></pre>



</details>

<a name="0x1_TowerState_get_miner_list"></a>

## Function `get_miner_list`

Getters     ///


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_miner_list">get_miner_list</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_miner_list">get_miner_list</a>(): vector&lt;address&gt; <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0)) {
    <b>return</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  };
  *&borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>&gt;(@0x0).list
}
</code></pre>



</details>

<a name="0x1_TowerState_get_tower_height"></a>

## Function `get_tower_height`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_tower_height">get_tower_height</a>(node_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_tower_height">get_tower_height</a>(node_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr)) {
    <b>return</b> borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr).verified_tower_height
  };
  0
}
</code></pre>



</details>

<a name="0x1_TowerState_get_epochs_compliant"></a>

## Function `get_epochs_compliant`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_epochs_compliant">get_epochs_compliant</a>(node_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_epochs_compliant">get_epochs_compliant</a>(node_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr)) {
    <b>return</b> borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr).epochs_validating_and_mining
  };
  0
}
</code></pre>



</details>

<a name="0x1_TowerState_get_count_in_epoch"></a>

## Function `get_count_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(miner_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr)) {
    <b>let</b> s = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);
    <b>if</b> (s.latest_epoch_mining == <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>()) {
      <b>return</b> s.count_proofs_in_epoch
    };
  };
  0
}
</code></pre>



</details>

<a name="0x1_TowerState_get_count_above_thresh_in_epoch"></a>

## Function `get_count_above_thresh_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_count_above_thresh_in_epoch">get_count_above_thresh_in_epoch</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_count_above_thresh_in_epoch">get_count_above_thresh_in_epoch</a>(miner_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr)) {
    <b>if</b> (borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr).count_proofs_in_epoch &gt; <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">Globals::get_epoch_mining_thres_lower</a>()) {
      <b>return</b> borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr).count_proofs_in_epoch - <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">Globals::get_epoch_mining_thres_lower</a>()
    }
  };
  0
}
</code></pre>



</details>

<a name="0x1_TowerState_lazy_reset_count_in_epoch"></a>

## Function `lazy_reset_count_in_epoch`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_lazy_reset_count_in_epoch">lazy_reset_count_in_epoch</a>(miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_lazy_reset_count_in_epoch">lazy_reset_count_in_epoch</a>(miner_addr: address) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>let</b> s = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);
  <b>if</b> (s.latest_epoch_mining &lt; <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>()) {
    s.count_proofs_in_epoch = 0;
  };
}
</code></pre>



</details>

<a name="0x1_TowerState_can_create_val_account"></a>

## Function `can_create_val_account`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_can_create_val_account">can_create_val_account</a>(node_addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_can_create_val_account">can_create_val_account</a>(node_addr: address): bool <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>if</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>() || <a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()) <b>return</b> <b>true</b>;
  // check <b>if</b> rate limited, needs 7 epochs of validating.
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr)) {
    <b>return</b>
      borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr).epochs_since_last_account_creation
      &gt;= <a href="TowerState.md#0x1_TowerState_EPOCHS_UNTIL_ACCOUNT_CREATION">EPOCHS_UNTIL_ACCOUNT_CREATION</a>
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_TowerState_get_validator_proofs_in_epoch"></a>

## Function `get_validator_proofs_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_validator_proofs_in_epoch">get_validator_proofs_in_epoch</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_validator_proofs_in_epoch">get_validator_proofs_in_epoch</a>(): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>{
  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.validator_proofs_in_epoch
}
</code></pre>



</details>

<a name="0x1_TowerState_get_fullnode_proofs_in_epoch"></a>

## Function `get_fullnode_proofs_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_fullnode_proofs_in_epoch">get_fullnode_proofs_in_epoch</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_fullnode_proofs_in_epoch">get_fullnode_proofs_in_epoch</a>(): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>{
  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.fullnode_proofs_in_epoch
}
</code></pre>



</details>

<a name="0x1_TowerState_get_fullnode_proofs_in_epoch_above_thresh"></a>

## Function `get_fullnode_proofs_in_epoch_above_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_fullnode_proofs_in_epoch_above_thresh">get_fullnode_proofs_in_epoch_above_thresh</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_fullnode_proofs_in_epoch_above_thresh">get_fullnode_proofs_in_epoch_above_thresh</a>(): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>{
  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.fullnode_proofs_in_epoch_above_thresh
}
</code></pre>



</details>

<a name="0x1_TowerState_get_lifetime_proof_count"></a>

## Function `get_lifetime_proof_count`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_lifetime_proof_count">get_lifetime_proof_count</a>(): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_lifetime_proof_count">get_lifetime_proof_count</a>(): (u64, u64, u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>{
  <b>let</b> s = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  (s.lifetime_proofs, s.lifetime_validator_proofs, s.lifetime_fullnode_proofs)
}
</code></pre>



</details>

<a name="0x1_TowerState_danger_migrate_get_lifetime_proof_count"></a>

## Function `danger_migrate_get_lifetime_proof_count`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_danger_migrate_get_lifetime_proof_count">danger_migrate_get_lifetime_proof_count</a>(): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_danger_migrate_get_lifetime_proof_count">danger_migrate_get_lifetime_proof_count</a>(): (u64, u64, u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>let</b> s = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    <b>return</b> (s.proofs_in_epoch, s.validator_proofs, s.fullnode_proofs)
  };
  (0,0,0)
}
</code></pre>



</details>

<a name="0x1_TowerState_get_difficulty"></a>

## Function `get_difficulty`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_difficulty">get_difficulty</a>(): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_get_difficulty">get_difficulty</a>(): (u64, u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>let</b> v = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    <b>return</b> (v.difficulty, v.security)
  } <b>else</b> {
    // we are probably in the middle of a migration
    (5000000, 512)
  }
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_init_val"></a>

## Function `test_helper_init_val`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_init_val">test_helper_init_val</a>(miner_sig: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;, difficulty: u64, security: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_init_val">test_helper_init_val</a>(
    miner_sig: &signer,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;,
    difficulty: u64,
    security: u64,
  ) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
    <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 130102014010);

    move_to&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_sig, <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
      previous_proof_hash: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      verified_tower_height: 0u64,
      latest_epoch_mining: 0u64,
      count_proofs_in_epoch: 0u64,
      epochs_validating_and_mining: 1u64,
      contiguous_epochs_validating_and_mining: 0u64,
      epochs_since_last_account_creation: 10u64, // is not rate-limited
    });

    // Needs difficulty <b>to</b> test between easy and hard mode.
    <b>let</b> proof = <a href="TowerState.md#0x1_TowerState_Proof">Proof</a> {
      challenge,
      difficulty,
      solution,
      security,
    };

    <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig), proof, <b>false</b>);
    // FullnodeState::init(miner_sig);
}
</code></pre>



</details>

<a name="0x1_TowerState_test_epoch_reset_counter"></a>

## Function `test_epoch_reset_counter`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_epoch_reset_counter">test_epoch_reset_counter</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_epoch_reset_counter">test_epoch_reset_counter</a>(vm: &signer) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130118));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  state.lifetime_proofs = 0;
  state.lifetime_validator_proofs = 0;
  state.lifetime_fullnode_proofs = 0;
  state.proofs_in_epoch = 0;
  state.validator_proofs_in_epoch = 0;
  state.fullnode_proofs_in_epoch = 0;
  state.validator_proofs_in_epoch_above_thresh = 0;
  state.fullnode_proofs_in_epoch_above_thresh = 0;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_operator_submits"></a>

## Function `test_helper_operator_submits`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_operator_submits">test_helper_operator_submits</a>(operator_addr: address, miner_addr: address, proof: <a href="TowerState.md#0x1_TowerState_Proof">TowerState::Proof</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_operator_submits">test_helper_operator_submits</a>(
  operator_addr: address, // Testrunner does not allow arbitrary accounts
                          // <b>to</b> submit txs, need <b>to</b> <b>use</b> address, so this will
                          // differ slightly from api
  miner_addr: address,
  proof: <a href="TowerState.md#0x1_TowerState_Proof">Proof</a>
) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerList">TowerList</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 130102014010);

  // Get address, assumes the sender is the signer.
  <b>assert</b>(
    <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr) == operator_addr,
    <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(130111)
  );
  // Abort <b>if</b> not initialized.
  <b>assert</b>(<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130116));

  // Check vdf difficulty constant. Will be different in tests than in production.
  // Skip this check on local tests, we need tests <b>to</b> send different difficulties.
  <b>if</b> (!<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()){ // todo: remove?
    <b>assert</b>(&proof.difficulty == &<a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">Globals::get_vdf_difficulty_baseline</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130117));
  };

  <a href="TowerState.md#0x1_TowerState_verify_and_update_state">verify_and_update_state</a>(miner_addr, proof, <b>true</b>);

  // TODO: The operator mining needs its own <b>struct</b> <b>to</b> count mining.
  // For now it is implicit there is only 1 operator per validator,
  // and that the fullnode state is the place <b>to</b> count.
  // This will require a breaking change <b>to</b> <a href="TowerState.md#0x1_TowerState">TowerState</a>
  // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_mock_mining"></a>

## Function `test_helper_mock_mining`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining">test_helper_mock_mining</a>(sender: &signer, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining">test_helper_mock_mining</a>(sender: &signer,  count: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130118));
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <a href="TowerState.md#0x1_TowerState_danger_mock_mining">danger_mock_mining</a>(addr, count)
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_mock_mining_vm"></a>

## Function `test_helper_mock_mining_vm`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining_vm">test_helper_mock_mining_vm</a>(vm: &signer, addr: address, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining_vm">test_helper_mock_mining_vm</a>(vm: &signer, addr: address, count: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130120));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <a href="TowerState.md#0x1_TowerState_danger_mock_mining">danger_mock_mining</a>(addr, count)
}
</code></pre>



</details>

<a name="0x1_TowerState_danger_mock_mining"></a>

## Function `danger_mock_mining`



<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_danger_mock_mining">danger_mock_mining</a>(addr: address, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TowerState.md#0x1_TowerState_danger_mock_mining">danger_mock_mining</a>(addr: address, count: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  // again for safety
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130118));


  <b>let</b> i = 0;
  <b>while</b> (i &lt; count) {
    <a href="TowerState.md#0x1_TowerState_increment_stats">increment_stats</a>(addr);
    <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
    // mock verify_and_update
    state.verified_tower_height = state.verified_tower_height + 1;
    state.count_proofs_in_epoch = state.count_proofs_in_epoch + 1;
    i = i + 1;
  };

  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
  state.count_proofs_in_epoch = count;
  state.latest_epoch_mining = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_mock_reconfig"></a>

## Function `test_helper_mock_reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_reconfig">test_helper_mock_reconfig</a>(account: &signer, miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_mock_reconfig">test_helper_mock_reconfig</a>(account: &signer, miner_addr: address) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>, <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(account);
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130122));
  // update_metrics(account, miner_addr);
  <a href="TowerState.md#0x1_TowerState_epoch_reset">epoch_reset</a>(account);
  <a href="TowerState.md#0x1_TowerState_update_epoch_metrics_vals">update_epoch_metrics_vals</a>(account, miner_addr);
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_get_height"></a>

## Function `test_helper_get_height`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_height">test_helper_get_height</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_height">test_helper_get_height</a>(miner_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130123));
  <b>assert</b>(<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130124));

  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);
  *&state.verified_tower_height
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_get_count"></a>

## Function `test_helper_get_count`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_count">test_helper_get_count</a>(account: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_count">test_helper_get_count</a>(account: &signer): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
    <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 130115014011);
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">get_count_in_epoch</a>(addr)
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_get_nominal_count"></a>

## Function `test_helper_get_nominal_count`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_nominal_count">test_helper_get_nominal_count</a>(miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_nominal_count">test_helper_get_nominal_count</a>(miner_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130123));
  <b>assert</b>(<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(130124));

  <b>let</b> state = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr);
  *&state.count_proofs_in_epoch
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_get_contiguous_vm"></a>

## Function `test_helper_get_contiguous_vm`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_contiguous_vm">test_helper_get_contiguous_vm</a>(vm: &signer, miner_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_get_contiguous_vm">test_helper_get_contiguous_vm</a>(vm: &signer, miner_addr: address): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130125));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(miner_addr).contiguous_epochs_validating_and_mining
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_set_rate_limit"></a>

## Function `test_helper_set_rate_limit`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_rate_limit">test_helper_set_rate_limit</a>(account: &signer, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_rate_limit">test_helper_set_rate_limit</a>(account: &signer, value: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
  state.epochs_since_last_account_creation = value;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_set_epochs_mining"></a>

## Function `test_helper_set_epochs_mining`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_epochs_mining">test_helper_set_epochs_mining</a>(node_addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_epochs_mining">test_helper_set_epochs_mining</a>(node_addr: address, value: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));

  <b>let</b> s = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr);
  s.epochs_validating_and_mining = value;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_set_proofs_in_epoch"></a>

## Function `test_helper_set_proofs_in_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_proofs_in_epoch">test_helper_set_proofs_in_epoch</a>(node_addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_proofs_in_epoch">test_helper_set_proofs_in_epoch</a>(node_addr: address, value: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130126));

  <b>let</b> s = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(node_addr);
  s.count_proofs_in_epoch = value;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_previous_proof_hash"></a>

## Function `test_helper_previous_proof_hash`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_previous_proof_hash">test_helper_previous_proof_hash</a>(account: &signer): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_previous_proof_hash">test_helper_previous_proof_hash</a>(
  account: &signer
): vector&lt;u8&gt; <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()== <b>true</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130128));
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  *&borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr).previous_proof_hash
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_set_weight_vm"></a>

## Function `test_helper_set_weight_vm`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_weight_vm">test_helper_set_weight_vm</a>(vm: &signer, addr: address, weight: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_weight_vm">test_helper_set_weight_vm</a>(vm: &signer, addr: address, weight: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
  state.verified_tower_height = weight;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_helper_set_weight"></a>

## Function `test_helper_set_weight`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_weight">test_helper_set_weight</a>(account: &signer, weight: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_helper_set_weight">test_helper_set_weight</a>(account: &signer, weight: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>let</b> state = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_TowerProofHistory">TowerProofHistory</a>&gt;(addr);
  state.verified_tower_height = weight;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_mock_depr_tower_stats"></a>

## Function `test_mock_depr_tower_stats`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_mock_depr_tower_stats">test_mock_depr_tower_stats</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_mock_depr_tower_stats">test_mock_depr_tower_stats</a>(vm: &signer) {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  move_to&lt;<a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a>&gt;(vm, <a href="TowerState.md#0x1_TowerState_TowerStats">TowerStats</a>{
    proofs_in_epoch: 111,
    validator_proofs: 222,
    fullnode_proofs: 333,
  });
}
</code></pre>



</details>

<a name="0x1_TowerState_test_get_liftime_proofs"></a>

## Function `test_get_liftime_proofs`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_get_liftime_proofs">test_get_liftime_proofs</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_get_liftime_proofs">test_get_liftime_proofs</a>(): u64 <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));

  <b>let</b> s = borrow_global&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  s.lifetime_proofs
}
</code></pre>



</details>

<a name="0x1_TowerState_test_set_vdf_difficulty"></a>

## Function `test_set_vdf_difficulty`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_set_vdf_difficulty">test_set_vdf_difficulty</a>(vm: &signer, diff: u64, sec: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_set_vdf_difficulty">test_set_vdf_difficulty</a>(vm: &signer, diff: u64, sec: u64) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> s = borrow_global_mut&lt;<a href="TowerState.md#0x1_TowerState_VDFDifficulty">VDFDifficulty</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  s.difficulty = diff;
  s.security = sec;
}
</code></pre>



</details>

<a name="0x1_TowerState_test_danger_destroy_tower_counter"></a>

## Function `test_danger_destroy_tower_counter`



<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_danger_destroy_tower_counter">test_danger_destroy_tower_counter</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TowerState.md#0x1_TowerState_test_danger_destroy_tower_counter">test_danger_destroy_tower_counter</a>(vm: &signer) <b>acquires</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130113));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>assert</b>(<b>exists</b>&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>()), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130115));

    // We destroy the data <b>resource</b> for sender
    // move_from and then destructure

    <b>let</b> <a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a> {
      lifetime_proofs: _,
      lifetime_validator_proofs: _,
      lifetime_fullnode_proofs: _,
      proofs_in_epoch: _,
      validator_proofs_in_epoch: _,
      fullnode_proofs_in_epoch: _,
      validator_proofs_in_epoch_above_thresh: _,
      fullnode_proofs_in_epoch_above_thresh: _,
   } = move_from&lt;<a href="TowerState.md#0x1_TowerState_TowerCounter">TowerCounter</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
