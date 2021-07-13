
<a name="0x1_FullnodeState"></a>

# Module `0x1::FullnodeState`



-  [Resource `FullnodeCounter`](#0x1_FullnodeState_FullnodeCounter)
-  [Function `init`](#0x1_FullnodeState_init)
-  [Function `reconfig`](#0x1_FullnodeState_reconfig)
-  [Function `inc_payment_count`](#0x1_FullnodeState_inc_payment_count)
-  [Function `inc_payment_value`](#0x1_FullnodeState_inc_payment_value)
-  [Function `is_init`](#0x1_FullnodeState_is_init)
-  [Function `is_onboarding`](#0x1_FullnodeState_is_onboarding)
-  [Function `get_address_proof_count`](#0x1_FullnodeState_get_address_proof_count)
-  [Function `get_cumulative_subsidy`](#0x1_FullnodeState_get_cumulative_subsidy)
-  [Function `test_set_fullnode_fixtures`](#0x1_FullnodeState_test_set_fullnode_fixtures)
-  [Function `mock_proof`](#0x1_FullnodeState_mock_proof)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
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

<a name="0x1_FullnodeState_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_init">init</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_init">init</a>(sender: &signer) {
    <b>assert</b>(!<b>exists</b>&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(060001));
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


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_reconfig">reconfig</a>(vm: &signer, addr: address, proofs_in_epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_reconfig">reconfig</a>(vm: &signer, addr: address, proofs_in_epoch: u64) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
    <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
    <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(060001));
    <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
    state.cumulative_proofs_submitted = state.cumulative_proofs_submitted + proofs_in_epoch;
    state.cumulative_proofs_paid = state.cumulative_proofs_paid + state.proofs_paid_in_epoch;
    state.cumulative_subsidy = state.cumulative_subsidy + state.subsidy_in_epoch;
    // reset
    state.proofs_submitted_in_epoch = proofs_in_epoch;
    state.proofs_paid_in_epoch = 0;
    state.subsidy_in_epoch = 0;
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
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(060004));
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
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(060005));
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.subsidy_in_epoch = state.subsidy_in_epoch + value;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_is_init">is_init</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_is_init">is_init</a>(addr: address): bool {
  <b>exists</b>&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_FullnodeState_is_onboarding"></a>

## Function `is_onboarding`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_is_onboarding">is_onboarding</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_is_onboarding">is_onboarding</a>(addr: address): bool <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>{
  <b>let</b> state = borrow_global&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);

  state.cumulative_proofs_submitted &lt; 2 &&
  state.cumulative_proofs_paid &lt; 2 &&
  state.cumulative_subsidy &lt; 1000000
}
</code></pre>



</details>

<a name="0x1_FullnodeState_get_address_proof_count"></a>

## Function `get_address_proof_count`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">get_address_proof_count</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">get_address_proof_count</a>(addr:address): u64 <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  borrow_global&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr).proofs_submitted_in_epoch
}
</code></pre>



</details>

<a name="0x1_FullnodeState_get_cumulative_subsidy"></a>

## Function `get_cumulative_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_cumulative_subsidy">get_cumulative_subsidy</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_get_cumulative_subsidy">get_cumulative_subsidy</a>(addr: address): u64 <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>{
  <b>let</b> state = borrow_global&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.cumulative_subsidy
}
</code></pre>



</details>

<a name="0x1_FullnodeState_test_set_fullnode_fixtures"></a>

## Function `test_set_fullnode_fixtures`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(vm: &signer, addr: address, proofs_submitted_in_epoch: u64, proofs_paid_in_epoch: u64, subsidy_in_epoch: u64, cumulative_proofs_submitted: u64, cumulative_proofs_paid: u64, cumulative_subsidy: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(
  vm: &signer,
  addr: address,
  proofs_submitted_in_epoch: u64,
  proofs_paid_in_epoch: u64,
  subsidy_in_epoch: u64,
  cumulative_proofs_submitted: u64,
  cumulative_proofs_paid: u64,
  cumulative_subsidy: u64,
) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>assert</b>(is_testnet(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(060006));

  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.proofs_submitted_in_epoch = proofs_submitted_in_epoch;
  state.proofs_paid_in_epoch = proofs_paid_in_epoch;
  state.subsidy_in_epoch = subsidy_in_epoch;
  state.cumulative_proofs_submitted = cumulative_proofs_submitted;
  state.cumulative_proofs_paid = cumulative_proofs_paid;
  state.cumulative_subsidy = cumulative_subsidy;
}
</code></pre>



</details>

<a name="0x1_FullnodeState_mock_proof"></a>

## Function `mock_proof`

Testhelper


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_mock_proof">mock_proof</a>(sender: &signer, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeState.md#0x1_FullnodeState_mock_proof">mock_proof</a>(sender: &signer, count: u64) <b>acquires</b> <a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeState.md#0x1_FullnodeState_FullnodeCounter">FullnodeCounter</a>&gt;(addr);
  state.proofs_submitted_in_epoch = state.proofs_submitted_in_epoch + count;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
