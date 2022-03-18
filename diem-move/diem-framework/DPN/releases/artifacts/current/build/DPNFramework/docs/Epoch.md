
<a name="0x1_Epoch"></a>

# Module `0x1::Epoch`


<a name="@Summary_0"></a>

## Summary

This module allows the root to determine epoch boundaries, triggering
epoch change operations (e.g. updating the validator set)


-  [Summary](#@Summary_0)
-  [Resource `Timer`](#0x1_Epoch_Timer)
-  [Function `initialize`](#0x1_Epoch_initialize)
-  [Function `epoch_finished`](#0x1_Epoch_epoch_finished)
-  [Function `reset_timer`](#0x1_Epoch_reset_timer)
-  [Function `get_timer_seconds_start`](#0x1_Epoch_get_timer_seconds_start)
-  [Function `get_timer_height_start`](#0x1_Epoch_get_timer_height_start)


<pre><code><b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
</code></pre>



<a name="0x1_Epoch_Timer"></a>

## Resource `Timer`

Contains timing info for the current epoch
epoch: the epoch number
height_start: the block height the epoch started at
seconds_start: the start time of the epoch


<pre><code><b>struct</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>height_start: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>seconds_start: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Epoch_initialize"></a>

## Function `initialize`

Called in genesis to initialize timer


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_initialize">initialize</a>(vm: &signer) {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
    <b>move_to</b>&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(
        vm,
        <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
            epoch: 0,
            height_start: 0,
            seconds_start: <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>()
        }
    );
}
</code></pre>



</details>

<a name="0x1_Epoch_epoch_finished"></a>

## Function `epoch_finished`

Check to see if epoch is finished
Simply checks if the elapsed time is greater than the epoch time


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_epoch_finished">epoch_finished</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_epoch_finished">epoch_finished</a>(): bool <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <b>let</b> epoch_secs = <a href="Globals.md#0x1_Globals_get_epoch_length">Globals::get_epoch_length</a>();
    <b>let</b> time = <b>borrow_global</b>&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(@DiemRoot);
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>() &gt; (epoch_secs + time.seconds_start)
}
</code></pre>



</details>

<a name="0x1_Epoch_reset_timer"></a>

## Function `reset_timer`

Reset the timer to start the next epoch
Called by root in the reconfiguration process


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_reset_timer">reset_timer</a>(vm: &signer, height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_reset_timer">reset_timer</a>(vm: &signer, height: u64) <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
    <b>let</b> time = <b>borrow_global_mut</b>&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(@DiemRoot);
    time.epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + 1;
    time.height_start = height;
    time.seconds_start = <a href="DiemTimestamp.md#0x1_DiemTimestamp_now_seconds">DiemTimestamp::now_seconds</a>();
}
</code></pre>



</details>

<a name="0x1_Epoch_get_timer_seconds_start"></a>

## Function `get_timer_seconds_start`

Accessor Function, returns the time (in seconds) of the start of the current epoch


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_seconds_start">get_timer_seconds_start</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_seconds_start">get_timer_seconds_start</a>(vm: &signer):u64 <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
    <b>let</b> time = <b>borrow_global</b>&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(@DiemRoot);
    time.seconds_start
}
</code></pre>



</details>

<a name="0x1_Epoch_get_timer_height_start"></a>

## Function `get_timer_height_start`

Accessor Function, returns the block height of the start of the current epoch


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_height_start">get_timer_height_start</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_height_start">get_timer_height_start</a>(vm: &signer):u64 <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
    <b>let</b> time = <b>borrow_global</b>&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(@DiemRoot);
    time.height_start
}
</code></pre>



</details>
