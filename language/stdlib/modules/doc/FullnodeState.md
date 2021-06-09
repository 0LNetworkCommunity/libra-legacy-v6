
<a name="0x1_FullnodeState"></a>

# Module `0x1::FullnodeState`



-  [Resource `FullnodeCounter`](#0x1_FullnodeState_FullnodeCounter)
-  [Function `val_init`](#0x1_FullnodeState_val_init)
-  [Function `reconfig`](#0x1_FullnodeState_reconfig)
-  [Function `inc_proof`](#0x1_FullnodeState_inc_proof)
-  [Function `inc_payment_count`](#0x1_FullnodeState_inc_payment_count)
-  [Function `inc_payment_value`](#0x1_FullnodeState_inc_payment_value)
-  [Function `get_address_proof_count`](#0x1_FullnodeState_get_address_proof_count)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_FullnodeState_FullnodeCounter"></a>

## Resource `FullnodeCounter`



<pre><code><b>resource</b> <b>struct</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>proofs_submitted_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>proofs_paid_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidy_in_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cumulative_proofs_submitted: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cumulative_proofs_paid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cumulative_subsidy: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_FullnodeState_val_init"></a>

## Function `val_init`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_val_init">val_init</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_val_init">val_init</a>(sender: &signer) {
    <b>assert</b>(!<b>exists</b>&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), 130112011021);
    move_to&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(
    sender,
    <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
        proofs_submitted_in_epoch: 0,
        proofs_paid_in_epoch: 0, // count
        subsidy_in_epoch: 0, // value
        cumulative_proofs_submitted: 0,
        cumulative_proofs_paid: 0,
        cumulative_subsidy: 0,
      }
    );
}
</code></pre>



</details>

<a name="0x1_FullnodeState_reconfig"></a>

## Function `reconfig`

On recongfiguration events, reset.


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_reconfig">reconfig</a>(vm: &signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_reconfig">reconfig</a>(vm: &signer, addr: address) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
    <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190201014010);
    <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
    state.cumulative_proofs_submitted = state.cumulative_proofs_submitted + state.proofs_submitted_in_epoch;
    state.cumulative_proofs_paid = state.cumulative_proofs_paid + state.proofs_paid_in_epoch;
    state.cumulative_subsidy = state.cumulative_subsidy + state.subsidy_in_epoch;
    // reset
    state.proofs_submitted_in_epoch= 0;
    state.proofs_paid_in_epoch = 0;
    state.subsidy_in_epoch = 0;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_inc_proof"></a>

## Function `inc_proof`

Miner increments proofs by 1


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_proof">inc_proof</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_proof">inc_proof</a>(sender: &signer) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.proofs_submitted_in_epoch = state.proofs_submitted_in_epoch + 1;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_inc_payment_count"></a>

## Function `inc_payment_count`

VM Increments payments in epoch. Increases by <code>count</code>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_count">inc_payment_count</a>(vm: &signer, addr: address, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_count">inc_payment_count</a>(vm: &signer, addr: address, count: u64) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190201014010);
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.proofs_paid_in_epoch = state.proofs_paid_in_epoch + count;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_inc_payment_value"></a>

## Function `inc_payment_value`

VM Increments payments in epoch. Increases by <code>count</code>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_value">inc_payment_value</a>(vm: &signer, addr: address, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_inc_payment_value">inc_payment_value</a>(vm: &signer, addr: address, value: u64) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190201014010);
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.subsidy_in_epoch = state.subsidy_in_epoch + value;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_get_address_proof_count"></a>

## Function `get_address_proof_count`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">get_address_proof_count</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">get_address_proof_count</a>(addr: address):u64 <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <b>let</b> state = borrow_global&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.proofs_submitted_in_epoch
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
