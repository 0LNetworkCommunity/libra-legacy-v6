
<a name="0x1_EpochBoundary"></a>

# Module `0x1::EpochBoundary`



-  [Constants](#@Constants_0)
-  [Function `reconfigure`](#0x1_EpochBoundary_reconfigure)
-  [Function `process_fullnodes`](#0x1_EpochBoundary_process_fullnodes)
-  [Function `process_validators`](#0x1_EpochBoundary_process_validators)
-  [Function `reset_counters`](#0x1_EpochBoundary_reset_counters)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">0x1::FullnodeSubsidy</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="ProofOfFee.md#0x1_ProofOfFee">0x1::ProofOfFee</a>;
<b>use</b> <a href="RecoveryMode.md#0x1_RecoveryMode">0x1::RecoveryMode</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_EpochBoundary_MOCK_VAL_SIZE"></a>



<pre><code><b>const</b> <a href="EpochBoundary.md#0x1_EpochBoundary_MOCK_VAL_SIZE">MOCK_VAL_SIZE</a>: u64 = 21;
</code></pre>



<a name="0x1_EpochBoundary_reconfigure"></a>

## Function `reconfigure`



<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64) {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    <b>let</b> height_start = <a href="Epoch.md#0x1_Epoch_get_timer_height_start">Epoch::get_timer_height_start</a>();
    print(&800100);
    <b>let</b> (outgoing_compliant_set, _) =
        <a href="DiemSystem.md#0x1_DiemSystem_get_fee_ratio">DiemSystem::get_fee_ratio</a>(vm, height_start, height_now);
    print(&800200);

    // NOTE: This is "nominal" because it doesn't check
    <b>let</b> compliant_nodes_count = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&outgoing_compliant_set);
    print(&800300);

    <b>let</b> (subsidy_units, nominal_subsidy_per) =
        <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">Subsidy::calculate_subsidy</a>(vm, compliant_nodes_count);

    print(&800400);

    <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm, nominal_subsidy_per);
    print(&800500);
    <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm, subsidy_units, *&outgoing_compliant_set);
    print(&800600);

    // <b>let</b> proposed_set = propose_new_set(vm, height_start, height_now);
    //// V6 ////
    // CONSENSUS CRITICAL
    // pick the validators based on proof of fee.
    <b>let</b> (proposed_set, _price) = <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">ProofOfFee::fill_seats_and_get_price</a>(<a href="EpochBoundary.md#0x1_EpochBoundary_MOCK_VAL_SIZE">MOCK_VAL_SIZE</a>, <b>copy</b> outgoing_compliant_set);

    print(&800700);
    // Update all slow wallet limits
    <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">DiemAccount::slow_wallet_epoch_drip</a>(vm, <a href="Globals.md#0x1_Globals_get_unlock">Globals::get_unlock</a>()); // todo
    print(&800800);

    // TODO: What <b>to</b> do in recovery mode.
    // <b>if</b> (!<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
    //   elect_validators(vm,nominal_subsidy_per, &proposed_set);
    //   print(&800900);
    // };
    <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm, proposed_set, outgoing_compliant_set, height_now);
    print(&801000);
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
    <b>while</b> (k &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&miners)) {
        <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&miners, k);
        <b>if</b> (<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr)) { // skip validators
          k = k + 1;
          <b>continue</b>
        };

        // TODO: this call is repeated in propose_new_set.
        // Not sure <b>if</b> the performance hit at epoch boundary is worth the refactor.
        <b>if</b> (<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr)) {
          <b>let</b> count = <a href="TowerState.md#0x1_TowerState_get_count_above_thresh_in_epoch">TowerState::get_count_above_thresh_in_epoch</a>(addr);

          <b>let</b> miner_subsidy = count * proof_price;

          // don't pay <b>while</b> we are in recovery mode, since that creates
          // a frontrunning opportunity
          // <b>if</b> (!<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()){
            <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">FullnodeSubsidy::distribute_fullnode_subsidy</a>(vm, addr, miner_subsidy);
          // }
        };

        k = k + 1;
    };
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_process_validators"></a>

## Function `process_validators`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm: &signer, subsidy_units: u64, outgoing_compliant_set: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(
    vm: &signer, subsidy_units: u64, outgoing_compliant_set: vector&lt;<b>address</b>&gt;
) {
    // Process outgoing validators:
    // Distribute Transaction fees and subsidy payments <b>to</b> all outgoing validators

    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>&lt;<b>address</b>&gt;(&outgoing_compliant_set)) <b>return</b>;

    // don't pay <b>while</b> we are in recovery mode, since that creates
    // a frontrunning opportunity
    <b>if</b> (subsidy_units &gt; 0 && !<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
        <a href="Subsidy.md#0x1_Subsidy_process_subsidy">Subsidy::process_subsidy</a>(vm, subsidy_units, &outgoing_compliant_set);
    };

    <a href="Subsidy.md#0x1_Subsidy_process_fees">Subsidy::process_fees</a>(vm, &outgoing_compliant_set);
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_reset_counters"></a>

## Function `reset_counters`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm: &signer, proposed_set: vector&lt;<b>address</b>&gt;, outgoing_compliant: vector&lt;<b>address</b>&gt;, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(
    vm: &signer,
    proposed_set: vector&lt;<b>address</b>&gt;,
    outgoing_compliant: vector&lt;<b>address</b>&gt;,
    height_now: u64
) {
    print(&800900100);
    // Reset <a href="Stats.md#0x1_Stats">Stats</a>
    <a href="Stats.md#0x1_Stats_reconfig">Stats::reconfig</a>(vm, &proposed_set);
    print(&800900101);
    // Migrate <a href="TowerState.md#0x1_TowerState">TowerState</a> list from elegible.
    <a href="TowerState.md#0x1_TowerState_reconfig">TowerState::reconfig</a>(vm, &outgoing_compliant);
    print(&800900102);
    // process community wallets
    <a href="DiemAccount.md#0x1_DiemAccount_process_community_wallets">DiemAccount::process_community_wallets</a>(vm, <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>());
    print(&800900103);
    // reset counters
    <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">AutoPay::reconfig_reset_tick</a>(vm);
    print(&800900104);
    <a href="Epoch.md#0x1_Epoch_reset_timer">Epoch::reset_timer</a>(vm, height_now);
    print(&800900105);
    <a href="RecoveryMode.md#0x1_RecoveryMode_maybe_remove_debug_at_epoch">RecoveryMode::maybe_remove_debug_at_epoch</a>(vm);
    // Reconfig should be the last event.
    // Reconfigure the network
    print(&800900106);
    <a href="DiemSystem.md#0x1_DiemSystem_bulk_update_validators">DiemSystem::bulk_update_validators</a>(vm, proposed_set);
    print(&800900107);
}
</code></pre>



</details>
