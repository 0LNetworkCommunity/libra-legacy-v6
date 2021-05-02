
<a name="0x1_Epoch"></a>

# Module `0x1::Epoch`



-  [Resource `Timer`](#0x1_Epoch_Timer)
-  [Function `initialize`](#0x1_Epoch_initialize)
-  [Function `epoch_finished`](#0x1_Epoch_epoch_finished)
-  [Function `reset_timer`](#0x1_Epoch_reset_timer)
-  [Function `get_timer_seconds_start`](#0x1_Epoch_get_timer_seconds_start)
-  [Function `get_timer_height_start`](#0x1_Epoch_get_timer_height_start)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="LibraConfig.md#0x1_LibraConfig">0x1::LibraConfig</a>;
<b>use</b> <a href="LibraTimestamp.md#0x1_LibraTimestamp">0x1::LibraTimestamp</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_Epoch_Timer"></a>

## Resource `Timer`



<pre><code><b>resource</b> <b>struct</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a>
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



<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_initialize">initialize</a>(vm: &signer) {
    <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), <a href="Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(050001));
    move_to&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(
    vm,
    <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
        epoch: 0,
        height_start: 0,
        seconds_start: <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_seconds">LibraTimestamp::now_seconds</a>()
        }
    );
}
</code></pre>



</details>

<a name="0x1_Epoch_epoch_finished"></a>

## Function `epoch_finished`



<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_epoch_finished">epoch_finished</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_epoch_finished">epoch_finished</a>(): bool <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <b>let</b> epoch_secs = <a href="Globals.md#0x1_Globals_get_epoch_length">Globals::get_epoch_length</a>();
    <b>let</b> time = borrow_global&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_seconds">LibraTimestamp::now_seconds</a>() &gt; (epoch_secs + time.seconds_start)
}
</code></pre>



</details>

<a name="0x1_Epoch_reset_timer"></a>

## Function `reset_timer`



<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_reset_timer">reset_timer</a>(vm: &signer, height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_reset_timer">reset_timer</a>(vm: &signer, height: u64) <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), <a href="Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(050002));
    <b>let</b> time = borrow_global_mut&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
    time.epoch = <a href="LibraConfig.md#0x1_LibraConfig_get_current_epoch">LibraConfig::get_current_epoch</a>() + 1;
    time.height_start = height;
    time.seconds_start = <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_seconds">LibraTimestamp::now_seconds</a>();
}
</code></pre>



</details>

<a name="0x1_Epoch_get_timer_seconds_start"></a>

## Function `get_timer_seconds_start`



<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_seconds_start">get_timer_seconds_start</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_seconds_start">get_timer_seconds_start</a>(vm: &signer):u64 <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
    <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(),  <a href="Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(050003));
    <b>let</b> time = borrow_global&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
    time.seconds_start
}
</code></pre>



</details>

<a name="0x1_Epoch_get_timer_height_start"></a>

## Function `get_timer_height_start`



<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_height_start">get_timer_height_start</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Epoch.md#0x1_Epoch_get_timer_height_start">get_timer_height_start</a>(vm: &signer):u64 <b>acquires</b> <a href="Epoch.md#0x1_Epoch_Timer">Timer</a> {
  <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(),  <a href="Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(050004));
  <b>let</b> time = borrow_global&lt;<a href="Epoch.md#0x1_Epoch_Timer">Timer</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  time.height_start
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
