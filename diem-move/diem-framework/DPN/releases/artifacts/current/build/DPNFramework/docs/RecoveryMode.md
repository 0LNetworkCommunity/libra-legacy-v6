
<a name="0x1_RecoveryMode"></a>

# Module `0x1::RecoveryMode`



-  [Resource `RecoveryMode`](#0x1_RecoveryMode_RecoveryMode)
-  [Function `init_recovery`](#0x1_RecoveryMode_init_recovery)
-  [Function `maybe_remove_debug_at_epoch`](#0x1_RecoveryMode_maybe_remove_debug_at_epoch)
-  [Function `remove_debug`](#0x1_RecoveryMode_remove_debug)
-  [Function `is_recovery`](#0x1_RecoveryMode_is_recovery)
-  [Function `get_debug_vals`](#0x1_RecoveryMode_get_debug_vals)
-  [Function `test_init_recovery`](#0x1_RecoveryMode_test_init_recovery)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_RecoveryMode_RecoveryMode"></a>

## Resource `RecoveryMode`



<pre><code><b>struct</b> <a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>fixed_set: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_ends: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_RecoveryMode_init_recovery"></a>

## Function `init_recovery`



<pre><code><b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_init_recovery">init_recovery</a>(vm: &signer, vals: vector&lt;<b>address</b>&gt;, epoch_ends: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_init_recovery">init_recovery</a>(vm: &signer, vals: vector&lt;<b>address</b>&gt;, epoch_ends: u64) {
  <b>if</b> (!<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">is_recovery</a>()) {
    <b>move_to</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(vm, <a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a> {
      fixed_set: vals,
      epoch_ends,
    });
  }
}
</code></pre>



</details>

<a name="0x1_RecoveryMode_maybe_remove_debug_at_epoch"></a>

## Function `maybe_remove_debug_at_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_maybe_remove_debug_at_epoch">maybe_remove_debug_at_epoch</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_maybe_remove_debug_at_epoch">maybe_remove_debug_at_epoch</a>(vm: &signer) <b>acquires</b> <a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(@VMReserved)) <b>return</b>;

  <b>let</b> enough_vals = <b>if</b> (
    <a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>() ||
    <a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()
  ){ <b>true</b> }
  <b>else</b> { (<a href="DiemSystem.md#0x1_DiemSystem_validator_set_size">DiemSystem::validator_set_size</a>() &gt;= 21) };
  <b>let</b> d = <b>borrow_global</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(@VMReserved);

  <b>let</b> enough_epochs = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt;= d.epoch_ends;


  // In the case that we set a fixed group of validators.
  // Make it expire after enough time <b>has</b> passed.
  <b>if</b> (enough_epochs) {
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&d.fixed_set) &gt; 0) {
      <a href="RecoveryMode.md#0x1_RecoveryMode_remove_debug">remove_debug</a>(vm);
    } <b>else</b> {
      // Otherwise, we are keeping the same validator selection logic.
      // In that case the system needs <b>to</b> pick enough validators for this <b>to</b> disable.
      <b>if</b> (enough_vals){
          <a href="RecoveryMode.md#0x1_RecoveryMode_remove_debug">remove_debug</a>(vm);
        }
      }
    }
  }
</code></pre>



</details>

<a name="0x1_RecoveryMode_remove_debug"></a>

## Function `remove_debug`



<pre><code><b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_remove_debug">remove_debug</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_remove_debug">remove_debug</a>(vm: &signer) <b>acquires</b> <a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">is_recovery</a>()) {
    _ = <b>move_from</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(@VMReserved);
  }
}
</code></pre>



</details>

<a name="0x1_RecoveryMode_is_recovery"></a>

## Function `is_recovery`



<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">is_recovery</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">is_recovery</a>(): bool {
  <b>exists</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(@VMReserved)
}
</code></pre>



</details>

<a name="0x1_RecoveryMode_get_debug_vals"></a>

## Function `get_debug_vals`



<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_get_debug_vals">get_debug_vals</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_get_debug_vals">get_debug_vals</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>  {
  <b>if</b> (<a href="RecoveryMode.md#0x1_RecoveryMode_is_recovery">is_recovery</a>()) {
    <b>let</b> d = <b>borrow_global</b>&lt;<a href="RecoveryMode.md#0x1_RecoveryMode">RecoveryMode</a>&gt;(@VMReserved);
    *&d.fixed_set
  } <b>else</b> {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_RecoveryMode_test_init_recovery"></a>

## Function `test_init_recovery`



<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_test_init_recovery">test_init_recovery</a>(vm: &signer, vals: vector&lt;<b>address</b>&gt;, epoch_ends: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="RecoveryMode.md#0x1_RecoveryMode_test_init_recovery">test_init_recovery</a>(vm: &signer, vals: vector&lt;<b>address</b>&gt;, epoch_ends: u64) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
    <a href="RecoveryMode.md#0x1_RecoveryMode_init_recovery">init_recovery</a>(vm, vals, epoch_ends);
  }
}
</code></pre>



</details>
