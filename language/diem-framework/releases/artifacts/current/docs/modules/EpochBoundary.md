
<a name="0x1_EpochBoundary"></a>

# Module `0x1::EpochBoundary`



-  [Function `reconfigure`](#0x1_EpochBoundary_reconfigure)
-  [Function `process_fullnodes`](#0x1_EpochBoundary_process_fullnodes)
-  [Function `process_validators`](#0x1_EpochBoundary_process_validators)
-  [Function `propose_new_set`](#0x1_EpochBoundary_propose_new_set)
-  [Function `reset_counters`](#0x1_EpochBoundary_reset_counters)
-  [Function `proof_of_burn`](#0x1_EpochBoundary_proof_of_burn)


<pre><code><b>use</b> <a href="Audit.md#0x1_Audit">0x1::Audit</a>;
<b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="Burn.md#0x1_Burn">0x1::Burn</a>;
<b>use</b> <a href="Cases.md#0x1_Cases">0x1::Cases</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">0x1::FullnodeSubsidy</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="RecoveryMode.md#0x1_RecoveryMode">0x1::RecoveryMode</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
</code></pre>



<a name="0x1_EpochBoundary_reconfigure"></a>

## Function `reconfigure`



<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_reconfigure">reconfigure</a>(vm: &signer, height_now: u64) {

    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    <b>let</b> height_start = <a href="Epoch.md#0x1_Epoch_get_timer_height_start">Epoch::get_timer_height_start</a>(vm);
    print(&800100);
    <b>let</b> (outgoing_compliant_set, _) =
        <a href="DiemSystem.md#0x1_DiemSystem_get_fee_ratio">DiemSystem::get_fee_ratio</a>(vm, height_start, height_now);
    print(&800200);

    // NOTE: This is "nominal" because it doesn't check
    <b>let</b> compliant_nodes_count = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&outgoing_compliant_set);
    print(&800300);

    <b>let</b> (subsidy_units, nominal_subsidy_per) =
        <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">Subsidy::calculate_subsidy</a>(vm, compliant_nodes_count);
    print(&800400);
    <a href="EpochBoundary.md#0x1_EpochBoundary_process_fullnodes">process_fullnodes</a>(vm, nominal_subsidy_per);
    print(&800500);

    <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm, subsidy_units, *&outgoing_compliant_set);
    print(&800600);

    <b>let</b> proposed_set = <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm, height_start, height_now);
    print(&800700);

    // Update all slow wallet limits
    <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">DiemAccount::slow_wallet_epoch_drip</a>(vm, <a href="Globals.md#0x1_Globals_get_unlock">Globals::get_unlock</a>());
    print(&800800);

    <b>if</b> (!<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
      <a href="EpochBoundary.md#0x1_EpochBoundary_proof_of_burn">proof_of_burn</a>(vm,nominal_subsidy_per, &proposed_set);
      print(&800900);
    };


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

          // don't pay <b>while</b> we are in recovery mode, since that creates a frontrunning opportunity
          <b>if</b> (!<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()){
            <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">FullnodeSubsidy::distribute_fullnode_subsidy</a>(vm, addr, miner_subsidy);
          }

        };

        k = k + 1;
    };
}
</code></pre>



</details>

<a name="0x1_EpochBoundary_process_validators"></a>

## Function `process_validators`



<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(vm: &signer, subsidy_units: u64, outgoing_compliant_set: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_process_validators">process_validators</a>(
    vm: &signer, subsidy_units: u64, outgoing_compliant_set: vector&lt;address&gt;
) {
    // Process outgoing validators:
    // Distribute Transaction fees and subsidy payments <b>to</b> all outgoing validators

    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>&lt;address&gt;(&outgoing_compliant_set)) <b>return</b>;

    // don't pay <b>while</b> we are in recovery mode, since that creates a frontrunning opportunity
    <b>if</b> (subsidy_units &gt; 0 && !<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
        <a href="Subsidy.md#0x1_Subsidy_process_subsidy">Subsidy::process_subsidy</a>(vm, subsidy_units, &outgoing_compliant_set);
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


<pre><code><b>fun</b> <a href="EpochBoundary.md#0x1_EpochBoundary_propose_new_set">propose_new_set</a>(vm: &signer, height_start: u64, height_now: u64): vector&lt;address&gt; {
    print(&9999);

    // Propose upcoming validator set:
    // Get validators we know <b>to</b> be in consensus correctly: Case1 and Case2
    // Only expand the amount of seats so that the new set has a max of 25% unproven nodes. I.e. nodes that were not in the previous epoch and we have stats on.

    // in emergency admin roles set the validator set
    // there may be a recovery set <b>to</b> be used.
    // <b>if</b> there is no rescue mission validators, just do usual procedure.

    <b>if</b> (<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">RecoveryMode::is_recovery</a>()) {
      <b>let</b> recovery_vals = <a href="RecoveryMode.md#0x1_RecoveryMode_get_debug_vals">RecoveryMode::get_debug_vals</a>();
      <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&recovery_vals) &gt; 0) <b>return</b> recovery_vals;
    };

    // Process all the jail terms of the previous validator set
    <b>let</b> previous_set = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();

    // Take advantage of this <b>loop</b> <b>to</b> get the expected size of the validator set that the new set doesn't have
    // 25% of nodes that we don't know their current performance.
    <b>let</b> len_proven_nodes = 0;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&previous_set)) {
        <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&previous_set, i);
        <b>let</b> case = <a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, height_start, height_now);
        <b>if</b> (
          // we care about nodes that are performing consensus correctly, case 1 and 2.
          case &lt; 3 &&
          <a href="Audit.md#0x1_Audit_val_audit_passing">Audit::val_audit_passing</a>(addr)
        ) {
            len_proven_nodes = len_proven_nodes + 1;
            // also reset the jail counter for any successful unjails
            <a href="Jail.md#0x1_Jail_remove_consecutive_fail">Jail::remove_consecutive_fail</a>(vm, addr);
        } <b>else</b> {
          <a href="Jail.md#0x1_Jail_jail">Jail::jail</a>(vm, addr);
        };
        i = i+ 1;
    };

    // <b>let</b> len_proven_nodes = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&proven_nodes);
    <b>let</b> max_unproven_nodes = len_proven_nodes / 6;
    print(&len_proven_nodes);
    print(&max_unproven_nodes);
    // start from the proven nodes

    // get all validators by consensus weight
    <b>let</b> sorted_val_universe = <a href="NodeWeight.md#0x1_NodeWeight_get_sorted_vals">NodeWeight::get_sorted_vals</a>();

    // sort by jail index, prioritizes nodes joining that aren't currently struggling <b>to</b> stay in the validator set.
    <b>let</b> top_accounts = <a href="Jail.md#0x1_Jail_sort_by_jail">Jail::sort_by_jail</a>(sorted_val_universe);
    print(&top_accounts);

    // <b>loop</b> through all accounts, sorted by jail status, and then by consensus power
    <b>let</b> proposed_set = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();

    <b>let</b> i = 0;
    <b>while</b> (
      // can't be more than index of accounts
      i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&top_accounts) &&
      // the new proposed set can only only expand by 15%
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&proposed_set) &lt; len_proven_nodes + max_unproven_nodes &&
      // Validator set can only be <b>as</b> big <b>as</b> the maximum set size
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&proposed_set) &lt; <a href="Globals.md#0x1_Globals_get_max_validators_per_set">Globals::get_max_validators_per_set</a>()
    ) {
        <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&top_accounts, i);
        <b>let</b> mined_last_epoch = <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr);
        <b>let</b> case = <a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, height_start, height_now);
        print(&addr);
        print(&case);

        <b>if</b> (
            // ignore proven nodes already on list
            !<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&proposed_set, &addr) &&
            // jail the current validators which did not perform.
            !<a href="Jail.md#0x1_Jail_is_jailed">Jail::is_jailed</a>(addr) &&
            // <b>if</b> they are not a current case 1 or 2, then they are rejoining and need <b>to</b> have mining proofs.
            // case 2 get grace
            (case &lt; 3 || mined_last_epoch) &&
            // do the remaining configuration checks, incl vouching
            <a href="Audit.md#0x1_Audit_val_audit_passing">Audit::val_audit_passing</a>(addr) &&
            // when being onboarded or being un-jailed check <b>if</b> the vouches are sufficient. I.e. don't do this check <b>if</b> the validator has proven themselves in the previous round. If your vouchers fall out of the set, you may also fall out, and this chain reaction would cause instability in the network.
            <a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">Vouch::unrelated_buddies_above_thresh</a>(addr)
        ) {
            print(&99990901);
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> proposed_set, addr);
        };
        i = i + 1;
    };

    print(&proposed_set);

    //////// Failover Rules ////////
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

    // Migrate <a href="TowerState.md#0x1_TowerState">TowerState</a> list from elegible.
    <a href="TowerState.md#0x1_TowerState_reconfig">TowerState::reconfig</a>(vm, &outgoing_compliant);


    // process community wallets
    <a href="DiemAccount.md#0x1_DiemAccount_process_community_wallets">DiemAccount::process_community_wallets</a>(vm, <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>());

    // reset counters
    <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">AutoPay::reconfig_reset_tick</a>(vm);

    <a href="Epoch.md#0x1_Epoch_reset_timer">Epoch::reset_timer</a>(vm, height_now);

    <a href="RecoveryMode.md#0x1_RecoveryMode_maybe_remove_debug_at_epoch">RecoveryMode::maybe_remove_debug_at_epoch</a>(vm);
    // Reconfig should be the last event.
    // Reconfigure the network
    <a href="DiemSystem.md#0x1_DiemSystem_bulk_update_validators">DiemSystem::bulk_update_validators</a>(vm, proposed_set);


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
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    <a href="DiemAccount.md#0x1_DiemAccount_migrate_cumu_deposits">DiemAccount::migrate_cumu_deposits</a>(vm); // may need <b>to</b> populate data on a migration.

    <a href="Burn.md#0x1_Burn_reset_ratios">Burn::reset_ratios</a>(vm);

    <b>let</b> burn_value = nominal_subsidy_per / 2; // 50% of the current per validator reward

    <b>let</b> vals_to_burn = <b>if</b> (
      !<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>() &&
      !<a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>() &&
      <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; 290 && // bump up <b>to</b> epoch 290 so people can discuss.
      // only implement this burn at a steady state <b>with</b> 90/100 validator positions full. Will make the burn amount much smaller over time.
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(proposed_set) &gt; 90
    ) {
      &<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>()
    } <b>else</b> {
      proposed_set
    };

    // print(vals_to_burn);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(vals_to_burn)) {
      <b>let</b> addr = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(vals_to_burn, i);
      // print(&addr);

      <a href="Burn.md#0x1_Burn_epoch_start_burn">Burn::epoch_start_burn</a>(vm, addr, burn_value);
      i = i + 1;
    };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
