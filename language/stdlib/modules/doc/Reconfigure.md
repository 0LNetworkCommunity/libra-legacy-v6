
<a name="0x1_Reconfigure"></a>

# Module `0x1::Reconfigure`



-  [Function `reconfigure`](#0x1_Reconfigure_reconfigure)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Epoch.md#0x1_Epoch">0x1::Epoch</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="FullnodeState.md#0x1_FullnodeState">0x1::FullnodeState</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="LibraSystem.md#0x1_LibraSystem">0x1::LibraSystem</a>;
<b>use</b> <a href="MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Subsidy.md#0x1_Subsidy">0x1::Subsidy</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Reconfigure_reconfigure"></a>

## Function `reconfigure`



<pre><code><b>public</b> <b>fun</b> <a href="Reconfigure.md#0x1_Reconfigure_reconfigure">reconfigure</a>(vm: &signer, height_now: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Reconfigure.md#0x1_Reconfigure_reconfigure">reconfigure</a>(vm: &signer, height_now: u64) {
    <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 180101014010);

    // Fullnode subsidy
    // <b>loop</b> through validators and pay full node subsidies.
    // Should happen before transactionfees get distributed.
    <b>let</b> miners = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>(vm);
    <b>let</b> global_proofs_count = 0;
    <b>let</b> k = 0;
    <b>while</b> (k &lt; <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&miners)) {
        <b>let</b> addr = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&miners, k);

        <b>let</b> count = <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">FullnodeState::get_address_proof_count</a>(addr);
        <b>if</b> (count &gt; 0) {
            global_proofs_count = global_proofs_count + count;

            <b>let</b> value = <a href="Subsidy.md#0x1_Subsidy_distribute_fullnode_subsidy">Subsidy::distribute_fullnode_subsidy</a>(vm, addr, count, <b>false</b>);
            <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_count">FullnodeState::inc_payment_count</a>(vm, addr, count);
            <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_value">FullnodeState::inc_payment_value</a>(vm, addr, value);
            <a href="FullnodeState.md#0x1_FullnodeState_reconfig">FullnodeState::reconfig</a>(vm, addr);
        };
        k = k + 1;
    };

    // Process outgoing validators:
    // Distribute Transaction fees and subsidy payments <b>to</b> all outgoing validators
    <b>let</b> height_start = <a href="Epoch.md#0x1_Epoch_get_timer_height_start">Epoch::get_timer_height_start</a>(vm);

    <b>let</b> (outgoing_set, fee_ratio) = <a href="LibraSystem.md#0x1_LibraSystem_get_fee_ratio">LibraSystem::get_fee_ratio</a>(vm, height_start, height_now);
    <b>if</b> (<a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&outgoing_set) &gt; 0) {
        <b>let</b> subsidy_units = <a href="Subsidy.md#0x1_Subsidy_calculate_Subsidy">Subsidy::calculate_Subsidy</a>(vm, height_start, height_now);
        <b>if</b> (subsidy_units &gt; 0) {
            <a href="Subsidy.md#0x1_Subsidy_process_subsidy">Subsidy::process_subsidy</a>(vm, subsidy_units, &outgoing_set, &fee_ratio);
        };
        <a href="Subsidy.md#0x1_Subsidy_process_fees">Subsidy::process_fees</a>(vm, &outgoing_set, &fee_ratio);
    };
    // Propose upcoming validator set:
    // Step 1: Sort Top N Elegible validators
    // Step 2: Jail non-performing validators
    // Step 3: Reset counters
    // Step 4: Bulk <b>update</b> validator set (reconfig)

    // prepare_upcoming_validator_set(vm);
    <b>let</b> top_accounts = <a href="NodeWeight.md#0x1_NodeWeight_top_n_accounts">NodeWeight::top_n_accounts</a>(
        vm, <a href="Globals.md#0x1_Globals_get_max_validator_per_epoch">Globals::get_max_validator_per_epoch</a>());
    <b>let</b> jailed_set = <a href="LibraSystem.md#0x1_LibraSystem_get_jailed_set">LibraSystem::get_jailed_set</a>(vm, height_start, height_now);

    <b>let</b> proposed_set = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&top_accounts)) {
        <b>let</b> addr = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&top_accounts, i);
        <b>if</b> (!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>(&jailed_set, &addr)){
            <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> proposed_set, addr);
        };
        i = i+ 1;
    };

    // If the cardinality of validator_set in the next epoch is less than 4, we keep the same validator set.
    <b>if</b> (<a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&proposed_set)&lt;= 3) proposed_set = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>(vm);
    // Usually an issue in staging network for QA only.
    // This is very rare and theoretically impossible for network <b>with</b> at least 6 nodes and 6 rounds. If we reach an epoch boundary <b>with</b> at least 6 rounds, we would have at least 2/3rd of the validator set <b>with</b> at least 66% liveliness.


    // needs <b>to</b> be set before the auctioneer runs in <a href="Subsidy.md#0x1_Subsidy_fullnode_reconfig">Subsidy::fullnode_reconfig</a>
    <a href="Subsidy.md#0x1_Subsidy_set_global_count">Subsidy::set_global_count</a>(vm, global_proofs_count);

    //Reset Counters
    <a href="Stats.md#0x1_Stats_reconfig">Stats::reconfig</a>(vm, &proposed_set);
    <a href="MinerState.md#0x1_MinerState_reconfig">MinerState::reconfig</a>(vm);

    // <a href="Reconfigure.md#0x1_Reconfigure">Reconfigure</a> the network
    <a href="LibraSystem.md#0x1_LibraSystem_bulk_update_validators">LibraSystem::bulk_update_validators</a>(vm, proposed_set);
    // reset clocks
    <a href="Subsidy.md#0x1_Subsidy_fullnode_reconfig">Subsidy::fullnode_reconfig</a>(vm);
    <a href="AutoPay.md#0x1_AutoPay_reconfig_reset_tick">AutoPay::reconfig_reset_tick</a>(vm);
    <a href="Epoch.md#0x1_Epoch_reset_timer">Epoch::reset_timer</a>(vm, height_now);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
