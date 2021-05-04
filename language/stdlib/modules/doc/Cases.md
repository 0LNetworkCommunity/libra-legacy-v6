
<a name="0x1_Cases"></a>

# Module `0x1::Cases`



-  [Function `get_case`](#0x1_Cases_get_case)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
</code></pre>



<a name="0x1_Cases_get_case"></a>

## Function `get_case`



<pre><code><b>public</b> <b>fun</b> <a href="Cases.md#0x1_Cases_get_case">get_case</a>(vm: &signer, node_addr: address, height_start: u64, height_end: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Cases.md#0x1_Cases_get_case">get_case</a>(vm: &signer, node_addr: address, height_start: u64, height_end: u64): u64 {
    <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), <a href="Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(030001));
    // did the validator sign blocks above threshold?
    <b>let</b> signs = <a href="Stats.md#0x1_Stats_node_above_thresh">Stats::node_above_thresh</a>(vm, node_addr, height_start, height_end);
    <b>let</b> mines = <a href="MinerState.md#0x1_MinerState_node_above_thresh">MinerState::node_above_thresh</a>(vm, node_addr);

    <b>if</b> (signs && mines) <b>return</b> 1; // compliant: in next set, gets paid, weight increments
    <b>if</b> (signs && !mines) <b>return</b> 2; // half compliant: not in next set, does not get paid, weight does not increment.
    <b>if</b> (!signs && mines) <b>return</b> 3; // not compliant: jailed, not in next set, does not get paid, weight increments.
    //<b>if</b> !signs && !mines
    <b>return</b> 4 // not compliant: jailed, not in next set, does not get paid, weight does not increment.
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
