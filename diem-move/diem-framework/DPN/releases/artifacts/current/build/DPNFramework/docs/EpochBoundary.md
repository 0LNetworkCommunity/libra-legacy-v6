
<a name="0x1_EpochBoundary"></a>

# Module `0x1::EpochBoundary`



-  [Constants](#@Constants_0)
-  [Function `reconfigure`](#0x1_EpochBoundary_reconfigure)
-  [Function `process_fullnodes`](#0x1_EpochBoundary_process_fullnodes)
-  [Function `process_validators`](#0x1_EpochBoundary_process_validators)
-  [Function `process_jail`](#0x1_EpochBoundary_process_jail)
-  [Function `propose_new_set`](#0x1_EpochBoundary_propose_new_set)
-  [Function `reset_counters`](#0x1_EpochBoundary_reset_counters)
-  [Function `root_service_billing`](#0x1_EpochBoundary_root_service_billing)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="Burn.md#0x1_Burn">0x1::Burn</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">0x1::FullnodeSubsidy</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="InfraEscrow.md#0x1_InfraEscrow">0x1::InfraEscrow</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment">0x1::MultiSigPayment</a>;
<b>use</b> <a href="MusicalChairs.md#0x1_MusicalChairs">0x1::MusicalChairs</a>;
<b>use</b> <a href="ProofOfFee.md#0x1_ProofOfFee">0x1::ProofOfFee</a>;
<b>use</b> <a href="RecoveryMode.md#0x1_RecoveryMode">0x1::RecoveryMode</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
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


    ///////// SETTLE ACCOUNTS OF PREVIOUS EPOCH /////////
    // Update all slow wallet limits
    <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">DiemAccount::slow_wallet_epoch_drip</a>(vm, <a href="Globals.md#0x1_Globals_get_unlock">Globals::get_unlock</a>()); // todo
    // print(&800100);

    // Check compliance of nodes
    <b>let</b> height_start = <a href="Epoch.md#0x1_Epoch_get_timer_height_start">Epoch::get_timer_height_start</a>();
    // print(&800200);
    <b>let</b> (outgoing_compliant_set, new_set_size) =
        <a href="MusicalChairs.md#0x1_MusicalChairs_stop_the_music">MusicalChairs::stop_the_music</a>(vm, height_start, height_now);

    // print(&800300);

    // get the total fees produced before we start spending them.
    <b>let</b> total_fees = <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">TransactionFee::get_fees_collected</a>();
    // Get the consensus reward established at the beginning of the epoch
    // so we know what <b>to</b> pay people
    <b>let</b> (reward, _, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">ProofOfFee::get_consensus_reward</a>();

    // process the oracles first (previously the identiy reward)
    <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm, reward);
    // print(&800400);

    // print(&800500);

    <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm, reward, &outgoing_compliant_set, total_fees);
    // print(&800600);

    // process the non performing nodes: jail
    <a href="EpochBoundary.md#0x1_EpochBoundary_process_jail">process_jail</a>(vm, &outgoing_compliant_set);
    // print(&800600);
    // EVERYONE SHOULD BE PAID UP AT THIS POINT
    // after everyone is paid from the chain's Fee account
    // we can burn the remainder.
    // Note we <b>assume</b> <a href="Oracle.md#0x1_Oracle">Oracle</a> subsidy was paid prior <b>to</b> this.

    // TODO: implement what happens <b>to</b> the matching donation algo
    // depending on the validator's preferences.
    // TransactionFee::ol_burn_fees(vm);


    <b>let</b> proposed_set = <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm, &outgoing_compliant_set, new_set_size);

    // print(&800700);

    <a href="EpochBoundary.md#0x1_EpochBoundary_root_service_billing">root_service_billing</a>(vm);
    // print(&801000);

    // <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm, proposed_set, outgoing_compliant_set, height_now);
    // print(&801100);
    ///////// PREPARE NEXT EPOCH /////////

    // <b>let</b> proposed_set = <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm, &outgoing_compliant_set, new_set_size);


    // print(&800800);

    // Now we need <b>to</b> collect coins from infrastructure escrow, <b>to</b> temporarily fund the network fee <b>address</b> for the next set.
    // Note in step
    <a href="InfraEscrow.md#0x1_InfraEscrow_epoch_boundary_collection">InfraEscrow::epoch_boundary_collection</a>(vm, reward * <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&proposed_set));

    // <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">TransactionFee::get_fees_collected</a>();
    // print(&fees);

    // print(&800900);



    <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm, &proposed_set, outgoing_compliant_set, height_now);
    // print(&8001000);

    // Reconfig should be the last event.
    // Reconfigure the network
    <a href="DiemSystem.md#0x1_DiemSystem_bulk_update_validators">DiemSystem::bulk_update_validators</a>(vm, proposed_set);

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



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm: &signer, subsidy_units: u64, outgoing_compliant_set: &vector&lt;<b>address</b>&gt;, fees_collected: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(
    vm: &signer,
    subsidy_units: u64,
    outgoing_compliant_set: &vector&lt;<b>address</b>&gt;,
    fees_collected: u64,
) {
    // Process outgoing validators:
    // Distribute Transaction fees and subsidy payments <b>to</b> all outgoing validators

    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>&lt;<b>address</b>&gt;(outgoing_compliant_set)) <b>return</b>;

    // don't pay <b>while</b> we are in recovery mode, since that creates
    // a frontrunning opportunity
    <b>if</b> (subsidy_units &gt; 0 && !<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
        <a href="Subsidy.md#0x1_Subsidy_process_fees">Subsidy::process_fees</a>(vm, outgoing_compliant_set);
    };

    // after everyone is paid from the chain's Fee account
    // we can burn the excess fees from the epoch
    <a href="Burn.md#0x1_Burn_reset_ratios">Burn::reset_ratios</a>(vm);

    <a href="Burn.md#0x1_Burn_epoch_burn_fees">Burn::epoch_burn_fees</a>(vm, fees_collected);

}
</code></pre>



</details>

<a name="0x1_EpochBoundary_process_jail"></a>

## Function `process_jail`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_jail">process_jail</a>(vm: &signer, outgoing_compliant_set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_jail">process_jail</a>(vm: &signer, outgoing_compliant_set: &vector&lt;<b>address</b>&gt;) {
    <b>let</b> all_previous_vals = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&all_previous_vals)) {
        <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&all_previous_vals, i);

        <b>if</b> (

          // <b>if</b> they are compliant, remove the consecutive fail, otherwise jail
          // V6 Note: audit functions are now all contained in
          // <a href="ProofOfFee.md#0x1_ProofOfFee">ProofOfFee</a>.<b>move</b> and exludes validators at auction time.

          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(outgoing_compliant_set, &addr)
        ) {
          // print(&902);
            // also reset the jail counter for any successful unjails
            <a href="Jail.md#0x1_Jail_remove_consecutive_fail">Jail::remove_consecutive_fail</a>(vm, addr);
        } <b>else</b> {
          // print(&903);
          <a href="Jail.md#0x1_Jail_jail">Jail::jail</a>(vm, addr);
        };
        i = i+ 1;
    };
    // print(&904);
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_propose_new_set"></a>

## Function `propose_new_set`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm: &signer, outgoing_compliant_set: &vector&lt;<b>address</b>&gt;, n_musical_chairs: u64): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm: &signer, outgoing_compliant_set: &vector&lt;<b>address</b>&gt;, n_musical_chairs: u64): vector&lt;<b>address</b>&gt;
{
    <b>let</b> proposed_set = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();

    // If we are in recovery mode, we <b>use</b> the recovery set.
    <b>if</b> (<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
        <b>let</b> recovery_vals = <a href="RecoveryMode.md#0x1_RecoveryMode_get_debug_vals">RecoveryMode::get_debug_vals</a>();
        <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&recovery_vals) &gt; 0) {
          proposed_set = recovery_vals
        }
    } <b>else</b> { // Default case: Proof of Fee
        //// V6 ////
        // CONSENSUS CRITICAL
        // pick the validators based on proof of fee.
        // <b>false</b> because we want the default behavior of the function: filtered by audit
        // print(&60000);
        <b>let</b> sorted_bids = <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">ProofOfFee::get_sorted_vals</a>(<b>false</b>);
        <b>let</b> (auction_winners, price) = <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">ProofOfFee::fill_seats_and_get_price</a>(vm, n_musical_chairs, &sorted_bids, outgoing_compliant_set);
        // print(&800700);

        // charge the validators for the proof of fee in advance of the epoch
        <a href="DiemAccount.md#0x1_DiemAccount_vm_multi_pay_fee">DiemAccount::vm_multi_pay_fee</a>(vm, &auction_winners, price, &b"proof of fee");

        // <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">TransactionFee::get_fees_collected</a>();
        // print(&fees);
        // print(&800800);

        proposed_set = auction_winners
    };

    //////// Failover Rules ////////
    // If the cardinality of validator_set in the next epoch is less than 4,
    // <b>if</b> we are failing <b>to</b> qualify anyone. Pick top 1/2 of outgoing compliant validator set
    // by proposals. They are probably online.
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&proposed_set) &lt;= 3)
        proposed_set =
          <a href="Stats.md#0x1_Stats_get_sorted_vals_by_props">Stats::get_sorted_vals_by_props</a>(vm, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(outgoing_compliant_set) / 2);

    // If still failing...in extreme case <b>if</b> we cannot qualify anyone.
    // Don't change the validator set. we keep the same validator set.
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&proposed_set) &lt;= 3)
        proposed_set = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();
            // Patch for april incident. Make no changes <b>to</b> validator set.

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



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(vm: &signer, proposed_set: &vector&lt;<b>address</b>&gt;, outgoing_compliant: vector&lt;<b>address</b>&gt;, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reset_counters">reset_counters</a>(
    vm: &signer,
    proposed_set: &vector&lt;<b>address</b>&gt;,
    outgoing_compliant: vector&lt;<b>address</b>&gt;,
    height_now: u64
) {
    // print(&800900100);

    // Reset <a href="Stats.md#0x1_Stats">Stats</a>
    <a href="Stats.md#0x1_Stats_reconfig">Stats::reconfig</a>(vm, proposed_set);
    // print(&800900101);

    // Migrate <a href="TowerState.md#0x1_TowerState">TowerState</a> list from elegible.
    <a href="TowerState.md#0x1_TowerState_reconfig">TowerState::reconfig</a>(vm, &outgoing_compliant);
    // print(&800900102);

    // process community wallets
    <a href="DonorDirected.md#0x1_DonorDirected_process_donor_directed_accounts">DonorDirected::process_donor_directed_accounts</a>(vm, <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>());
    // print(&800900103);

    <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">AutoPay::reconfig_reset_tick</a>(vm);
    // print(&800900104);

    <a href="Epoch.md#0x1_Epoch_reset_timer">Epoch::reset_timer</a>(vm, height_now);
    // print(&800900105);

    <a href="RecoveryMode.md#0x1_RecoveryMode_maybe_remove_debug_at_epoch">RecoveryMode::maybe_remove_debug_at_epoch</a>(vm);
    // print(&800900106);

    <a href="TransactionFee.md#0x1_TransactionFee_epoch_reset_fee_maker">TransactionFee::epoch_reset_fee_maker</a>(vm);


    // trigger the thermostat <b>if</b> the reward needs <b>to</b> be adjusted
    <a href="ProofOfFee.md#0x1_ProofOfFee_reward_thermostat">ProofOfFee::reward_thermostat</a>(vm);
    // print(&800900107);

    // print(&800900108);
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_root_service_billing"></a>

## Function `root_service_billing`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_root_service_billing">root_service_billing</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_root_service_billing">root_service_billing</a>(vm: &signer) {
  <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_security_fee_billing">MultiSigPayment::root_security_fee_billing</a>(vm);
}
</code></pre>



</details>
