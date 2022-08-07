
<a name="0x1_ValidatorUniverse"></a>

# Module `0x1::ValidatorUniverse`



-  [Resource `ValidatorUniverse`](#0x1_ValidatorUniverse_ValidatorUniverse)
-  [Resource `JailedBit`](#0x1_ValidatorUniverse_JailedBit)
-  [Function `initialize`](#0x1_ValidatorUniverse_initialize)
-  [Function `add_self`](#0x1_ValidatorUniverse_add_self)
-  [Function `add`](#0x1_ValidatorUniverse_add)
-  [Function `get_eligible_validators`](#0x1_ValidatorUniverse_get_eligible_validators)
-  [Function `is_in_universe`](#0x1_ValidatorUniverse_is_in_universe)
-  [Function `jail`](#0x1_ValidatorUniverse_jail)
-  [Function `unjail_self`](#0x1_ValidatorUniverse_unjail_self)
-  [Function `unjail`](#0x1_ValidatorUniverse_unjail)
-  [Function `exists_jailedbit`](#0x1_ValidatorUniverse_exists_jailedbit)
-  [Function `is_jailed`](#0x1_ValidatorUniverse_is_jailed)
-  [Function `genesis_helper`](#0x1_ValidatorUniverse_genesis_helper)
-  [Function `test_helper_add_self_onboard`](#0x1_ValidatorUniverse_test_helper_add_self_onboard)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_ValidatorUniverse_ValidatorUniverse"></a>

## Resource `ValidatorUniverse`



<pre><code><b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>validators: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ValidatorUniverse_JailedBit"></a>

## Resource `JailedBit`



<pre><code><b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>is_jailed: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ValidatorUniverse_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_initialize">initialize</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_initialize">initialize</a>(account: &signer){
  // Check for transactions sender is association
  <b>let</b> sender = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(220101));
  move_to&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(account, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
      validators: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  });
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_add_self"></a>

## Function `add_self`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">add_self</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">add_self</a>(sender: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  // Miner can only add self <b>to</b> set <b>if</b> the mining is above a threshold.
  <b>if</b> (<a href="TowerState.md#0x1_TowerState_is_onboarding">TowerState::is_onboarding</a>(addr)) {
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(sender);
  } <b>else</b> {
    <b>assert</b>(<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr), 220102014010);
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(sender);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_add"></a>

## Function `add`



<pre><code><b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(sender: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> state = borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
  <b>let</b> (in_set, _) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&state.validators, &addr);
  <b>if</b> (!in_set) {
    <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.validators, addr);
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail">unjail</a>(sender);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_get_eligible_validators"></a>

## Function `get_eligible_validators`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(): vector&lt;address&gt; <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {

  <b>let</b> state = borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
  *&state.validators
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_is_in_universe"></a>

## Function `is_in_universe`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(addr: address): bool <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>let</b> state = borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&state.validators, &addr)
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_jail"></a>

## Function `jail`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_jail">jail</a>(vm: &signer, validator: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_jail">jail</a>(vm: &signer, validator: address) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>{
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), 220101014010);

  <b>assert</b>(<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator), 220101014011);

  borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed = <b>true</b>;

}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_unjail_self"></a>

## Function `unjail_self`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail_self">unjail_self</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail_self">unjail_self</a>(sender: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  // only a validator can un-jail themselves.
  <b>let</b> validator = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // check the node has been mining before unjailing.
  <b>assert</b>(<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(validator), 220101014013);
  <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail">unjail</a>(sender);
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_unjail"></a>

## Function `unjail`



<pre><code><b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail">unjail</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail">unjail</a>(sender: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>if</b> (!<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr)) {
    move_to&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(sender, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> { is_jailed: <b>false</b> });
    <b>return</b>
  };

  borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr).is_jailed = <b>false</b>;
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_exists_jailedbit"></a>

## Function `exists_jailedbit`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_exists_jailedbit">exists_jailedbit</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_exists_jailedbit">exists_jailedbit</a>(addr: address): bool {
  <b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_is_jailed"></a>

## Function `is_jailed`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_jailed">is_jailed</a>(validator: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_jailed">is_jailed</a>(validator: address): bool <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator)) {
    <b>return</b> <b>false</b>
  };
  borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_genesis_helper"></a>

## Function `genesis_helper`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_genesis_helper">genesis_helper</a>(vm: &signer, validator: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_genesis_helper">genesis_helper</a>(vm: &signer, validator: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), 220101014010);
  <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(validator);
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_test_helper_add_self_onboard"></a>

## Function `test_helper_add_self_onboard`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_test_helper_add_self_onboard">test_helper_add_self_onboard</a>(vm: &signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_test_helper_add_self_onboard">test_helper_add_self_onboard</a>(vm: &signer, addr:address) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 220101014014);
  <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), 220101015010);
  <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.validators, addr);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
