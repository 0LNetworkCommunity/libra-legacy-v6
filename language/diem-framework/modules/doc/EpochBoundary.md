
<a name="0x1_EpochBoundary"></a>

# Module `0x1::EpochBoundary`



-  [Resource `DebugMode`](#0x1_EpochBoundary_DebugMode)
-  [Function `init_debug`](#0x1_EpochBoundary_init_debug)
-  [Function `remove_debug`](#0x1_EpochBoundary_remove_debug)
-  [Function `is_debug`](#0x1_EpochBoundary_is_debug)
-  [Function `get_debug_vals`](#0x1_EpochBoundary_get_debug_vals)
-  [Function `reconfigure`](#0x1_EpochBoundary_reconfigure)
-  [Function `process_fullnodes`](#0x1_EpochBoundary_process_fullnodes)
-  [Function `process_validators`](#0x1_EpochBoundary_process_validators)
-  [Function `propose_new_set`](#0x1_EpochBoundary_propose_new_set)
-  [Function `reset_counters`](#0x1_EpochBoundary_reset_counters)
-  [Function `proof_of_burn`](#0x1_EpochBoundary_proof_of_burn)


<pre><code><b>use</b> <a href="Audit.md#0x1_Audit">0x1::Audit</a>;
<b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="Burn.md#0x1_Burn">0x1::Burn</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">0x1::FullnodeSubsidy</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_EpochBoundary_DebugMode"></a>

## Resource `DebugMode`



<pre><code><b>struct</b> <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>fixed_set: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_EpochBoundary_init_debug"></a>

## Function `init_debug`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_init_debug">init_debug</a>(vm: &signer, vals: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_init_debug">init_debug</a>(vm: &signer, vals: vector&lt;address&gt;) {
  <b>if</b> (!<a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>()) {
    move_to&lt;<a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>&gt;(vm, <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a> {
      fixed_set: vals
    });
  }
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_remove_debug"></a>

## Function `remove_debug`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_remove_debug">remove_debug</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_remove_debug">remove_debug</a>(vm: &signer) <b>acquires</b> <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (<a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>()) {
    _ = move_from&lt;<a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  }
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_is_debug"></a>

## Function `is_debug`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>(): bool {
  <b>exists</b>&lt;<a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_get_debug_vals"></a>

## Function `get_debug_vals`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_get_debug_vals">get_debug_vals</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_get_debug_vals">get_debug_vals</a>(): vector&lt;address&gt; <b>acquires</b> <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>  {
  <b>if</b> (<a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>()) {
    <b>let</b> d = borrow_global&lt;<a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    *&d.fixed_set
  } <b>else</b> {
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_reconfigure"></a>

## Function `reconfigure`



<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64) <b>acquires</b> <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>{
    print(&300300);

    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    <b>let</b> height_start = <a href="Epoch.md#0x1_Epoch_get_timer_height_start">Epoch::get_timer_height_start</a>(vm);
    print(&300310);
    <b>let</b> (outgoing_compliant_set, _) =
        <a href="DiemSystem.md#0x1_DiemSystem_get_fee_ratio">DiemSystem::get_fee_ratio</a>(vm, height_start, height_now);
    print(&300320);

    // NOTE: This is "nominal" because it doesn't check
    <b>let</b> compliant_nodes_count = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&outgoing_compliant_set);
    print(&300330);

    <b>let</b> (subsidy_units, nominal_subsidy_per) =
        <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">Subsidy::calculate_subsidy</a>(vm, compliant_nodes_count);
    print(&300340);
    <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm, nominal_subsidy_per);
    print(&300350);

    <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm, subsidy_units, *&outgoing_compliant_set);
    print(&300360);

    <b>let</b> proposed_set = <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm, height_start, height_now);


    <a href="EpochBoundary.md#0x1_EpochBoundary_proof_of_burn">proof_of_burn</a>(vm, subsidy_units, &proposed_set);

    // release funds <b>to</b> slow wallets
    <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">DiemAccount::slow_wallet_epoch_drip</a>(vm, <a href="Globals.md#0x1_Globals_get_unlock">Globals::get_unlock</a>());

    <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm, proposed_set, outgoing_compliant_set, height_now)
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_process_fullnodes"></a>

## Function `process_fullnodes`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm: &signer, nominal_subsidy_per_node: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm: &signer, nominal_subsidy_per_node: u64) {
    // Fullnode subsidy
    // <b>loop</b> through validators and pay full node subsidies.
    // Should happen before transactionfees get distributed.
    // Note: need <b>to</b> check, there may be new validators which have not mined yet.
    <b>let</b> miners = <a href="TowerState.md#0x1_TowerState_get_miner_list">TowerState::get_miner_list</a>();
    // fullnode subsidy is a fraction of the total subsidy available <b>to</b> validators.
    <b>let</b> proof_price = <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_get_proof_price">FullnodeSubsidy::get_proof_price</a>(nominal_subsidy_per_node);

    <b>let</b> k = 0;
    // Distribute mining subsidy <b>to</b> fullnodes
    <b>while</b> (k &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&miners)) {
        <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&miners, k);
        <b>if</b> (<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr)) { // skip validators
          k = k + 1;
          <b>continue</b>
        };

        // TODO: this call is repeated in propose_new_set.
        // Not sure <b>if</b> the performance hit at epoch boundary is worth the refactor.
        <b>if</b> (<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr)) {
          <b>let</b> count = <a href="TowerState.md#0x1_TowerState_get_count_above_thresh_in_epoch">TowerState::get_count_above_thresh_in_epoch</a>(addr);

          <b>let</b> miner_subsidy = count * proof_price;
          <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">FullnodeSubsidy::distribute_fullnode_subsidy</a>(vm, addr, miner_subsidy);
        };

        k = k + 1;
    };
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_process_validators"></a>

## Function `process_validators`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm: &signer, nominal_subsidy_per: u64, outgoing_compliant_set: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(
    vm: &signer, nominal_subsidy_per: u64, outgoing_compliant_set: vector&lt;address&gt;
) {
    // Process outgoing validators:
    // Distribute Transaction fees and subsidy payments <b>to</b> all outgoing validators

    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>&lt;address&gt;(&outgoing_compliant_set)) <b>return</b>;

    <b>if</b> (nominal_subsidy_per &gt; 0) {
        <a href="Subsidy.md#0x1_Subsidy_process_subsidy">Subsidy::process_subsidy</a>(vm, nominal_subsidy_per, &outgoing_compliant_set);
    };

    <a href="Subsidy.md#0x1_Subsidy_process_fees">Subsidy::process_fees</a>(vm, &outgoing_compliant_set);
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_propose_new_set"></a>

## Function `propose_new_set`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm: &signer, height_start: u64, height_now: u64): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm: &signer, height_start: u64, height_now: u64): vector&lt;address&gt; <b>acquires</b> <a href="EpochBoundary.md#0x1_EpochBoundary_DebugMode">DebugMode</a>{
    // Propose upcoming validator set:

    // in emergency admin roles set the validator set
    <b>if</b> (<a href="EpochBoundary.md#0x1_EpochBoundary_is_debug">is_debug</a>()) {
      <b>return</b> <a href="EpochBoundary.md#0x1_EpochBoundary_get_debug_vals">get_debug_vals</a>()
    };

    // save all the eligible list, before the jailing removes them.
    <b>let</b> proposed_set = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>();

    <b>let</b> top_accounts = <a href="NodeWeight.md#0x1_NodeWeight_top_n_accounts">NodeWeight::top_n_accounts</a>(
        vm, <a href="Globals.md#0x1_Globals_get_max_validators_per_set">Globals::get_max_validators_per_set</a>()
    );

    <b>let</b> jailed_set = <a href="DiemSystem.md#0x1_DiemSystem_get_jailed_set">DiemSystem::get_jailed_set</a>(vm, height_start, height_now);


    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&top_accounts)) {
        <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&top_accounts, i);
        <b>let</b> mined_last_epoch = <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr);
        // TODO: temporary until jailing is enabled.
        <b>if</b> (
            !<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&jailed_set, &addr) &&
            mined_last_epoch &&
            <a href="Audit.md#0x1_Audit_val_audit_passing">Audit::val_audit_passing</a>(addr)
        ) {
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> proposed_set, addr);
        };
        i = i+ 1;
    };


    // If the cardinality of validator_set in the next epoch is less than 4,

    // <b>if</b> we are failing <b>to</b> qualify anyone. Pick top 1/2 of validator set by proposals. They are probably online.

    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&proposed_set) &lt;= 3) proposed_set = <a href="Stats.md#0x1_Stats_get_sorted_vals_by_props">Stats::get_sorted_vals_by_props</a>(vm, <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&proposed_set) / 2);


    // If still failing...in extreme case <b>if</b> we cannot qualify anyone. Don't change the validator set.
    // we keep the same validator set.
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&proposed_set) &lt;= 3) proposed_set = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>(); // Patch for april incident. Make no changes <b>to</b> validator set.

    // Usually an issue in staging network for QA only.
    // This is very rare and theoretically impossible for network <b>with</b>
    // at least 6 nodes and 6 rounds. If we reach an epoch boundary <b>with</b>
    // at least 6 rounds, we would have at least 2/3rd of the validator
    // set <b>with</b> at least 66% liveliness.
    proposed_set
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_reset_counters"></a>

## Function `reset_counters`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm: &signer, proposed_set: vector&lt;address&gt;, outgoing_compliant: vector&lt;address&gt;, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm: &signer, proposed_set: vector&lt;address&gt;, outgoing_compliant: vector&lt;address&gt;, height_now: u64) {

    // Reset <a href="Stats.md#0x1_Stats">Stats</a>
    <a href="Stats.md#0x1_Stats_reconfig">Stats::reconfig</a>(vm, &proposed_set);
    <a href="TowerState.md#0x1_TowerState_reconfig">TowerState::reconfig</a>(vm, &outgoing_compliant);

    // Reconfigure the network
    <a href="DiemSystem.md#0x1_DiemSystem_bulk_update_validators">DiemSystem::bulk_update_validators</a>(vm, proposed_set);

    // process community wallets
    <a href="DiemAccount.md#0x1_DiemAccount_process_community_wallets">DiemAccount::process_community_wallets</a>(vm, <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>());

    // reset counters
    <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">AutoPay::reconfig_reset_tick</a>(vm);
    <a href="Epoch.md#0x1_Epoch_reset_timer">Epoch::reset_timer</a>(vm, height_now);
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_proof_of_burn"></a>

## Function `proof_of_burn`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_proof_of_burn">proof_of_burn</a>(vm: &signer, nominal_subsidy_per: u64, proposed_set: &vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_proof_of_burn">proof_of_burn</a>(vm: &signer, nominal_subsidy_per: u64, proposed_set: &vector&lt;address&gt;) {
    // print(&222201);
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

    // recaulculate the ratios of the community index.
    <a href="Burn.md#0x1_Burn_reset_ratios">Burn::reset_ratios</a>(vm);

    // get the burn value for next epoch. 50% of this epoch's reward.
    <b>let</b> burn_value = nominal_subsidy_per/2;
    // print(&burn_value);
    // <b>apply</b> the cost-<b>to</b>-exist <b>to</b> all validator candidates
    // TODO: remove proposed_set implementation until after epoch 185
    <b>let</b> all_vals = <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; 185) {
     <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>(vm)
    } <b>else</b> {
      *proposed_set
    };

    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&all_vals)) {
      <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&all_vals, i);
      <a href="Burn.md#0x1_Burn_epoch_start_burn">Burn::epoch_start_burn</a>(vm, addr, burn_value);
      i = i + 1;
    };

  //  print(&222202);

}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
