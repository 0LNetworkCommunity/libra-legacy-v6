
<a name="0x1_Cases"></a>

# Module `0x1::Cases`


<a name="@Summary_0"></a>

## Summary

This module can be used by root to determine whether a validator is compliant
Validators who are no longer compliant may be kicked out of the validator
set and/or jailed. To be compliant, validators must be BOTH validating and mining.


-  [Summary](#@Summary_0)
-  [Constants](#@Constants_1)
-  [Function `get_case`](#0x1_Cases_get_case)


<pre><code><b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="0x1_Cases_INVALID_DATA"></a>



<pre><code><b>const</b> <a href="Cases.md#0x1_Cases_INVALID_DATA">INVALID_DATA</a>: u64 = 0;
</code></pre>



<a name="0x1_Cases_VALIDATOR_COMPLIANT"></a>



<pre><code><b>const</b> <a href="Cases.md#0x1_Cases_VALIDATOR_COMPLIANT">VALIDATOR_COMPLIANT</a>: u64 = 1;
</code></pre>



<a name="0x1_Cases_VALIDATOR_DOUBLY_NOT_COMPLIANT"></a>



<pre><code><b>const</b> <a href="Cases.md#0x1_Cases_VALIDATOR_DOUBLY_NOT_COMPLIANT">VALIDATOR_DOUBLY_NOT_COMPLIANT</a>: u64 = 4;
</code></pre>



<a name="0x1_Cases_get_case"></a>

## Function `get_case`



<pre><code><b>public</b> <b>fun</b> <a href="Cases.md#0x1_Cases_get_case">get_case</a>(vm: &signer, node_addr: <b>address</b>, height_start: u64, height_end: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Cases.md#0x1_Cases_get_case">get_case</a>(
    vm: &signer, node_addr: <b>address</b>, height_start: u64, height_end: u64
): u64 {

    // this is a failure mode. Only usually seen in rescue missions,
    // <b>where</b> epoch counters are reconfigured by writeset offline.
    <b>if</b> (height_end &lt; height_start) <b>return</b> <a href="Cases.md#0x1_Cases_INVALID_DATA">INVALID_DATA</a>;

    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
    // did the validator sign blocks above threshold?
    <b>let</b> signs = <a href="Stats.md#0x1_Stats_node_above_thresh">Stats::node_above_thresh</a>(vm, node_addr, height_start, height_end);

    // <b>let</b> mines = <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(node_addr);

    <b>if</b> (signs) {
        // compliant: in next set, gets paid, weight increments
        <a href="Cases.md#0x1_Cases_VALIDATOR_COMPLIANT">VALIDATOR_COMPLIANT</a>
    }
    // V6: Simplify compliance cases by removing mining.

    // }
    // <b>else</b> <b>if</b> (signs && !mines) {
    //     // half compliant: not in next set, does not get paid, weight
    //     // does not increment.
    //     VALIDATOR_HALF_COMPLIANT
    // }
    // <b>else</b> <b>if</b> (!signs && mines) {
    //     // not compliant: jailed, not in next set, does not get paid,
    //     // weight increments.
    //     VALIDATOR_NOT_COMPLIANT
    // }
    <b>else</b> {
        // not compliant: jailed, not in next set, does not get paid,
        // weight does not increment.
        <a href="Cases.md#0x1_Cases_VALIDATOR_DOUBLY_NOT_COMPLIANT">VALIDATOR_DOUBLY_NOT_COMPLIANT</a>
    }
}
</code></pre>



</details>
