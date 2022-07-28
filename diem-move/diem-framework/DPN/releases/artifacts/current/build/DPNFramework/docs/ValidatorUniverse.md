
<a name="0x1_ValidatorUniverse"></a>

# Module `0x1::ValidatorUniverse`



-  [Resource `ValidatorUniverse`](#0x1_ValidatorUniverse_ValidatorUniverse)
-  [Resource `JailedBit`](#0x1_ValidatorUniverse_JailedBit)
-  [Function `initialize`](#0x1_ValidatorUniverse_initialize)
-  [Function `add_self`](#0x1_ValidatorUniverse_add_self)
-  [Function `add`](#0x1_ValidatorUniverse_add)
-  [Function `remove_self`](#0x1_ValidatorUniverse_remove_self)
-  [Function `get_eligible_validators`](#0x1_ValidatorUniverse_get_eligible_validators)
-  [Function `is_in_universe`](#0x1_ValidatorUniverse_is_in_universe)
-  [Function `jail`](#0x1_ValidatorUniverse_jail)
-  [Function `unjail_self`](#0x1_ValidatorUniverse_unjail_self)
-  [Function `unjail`](#0x1_ValidatorUniverse_unjail)
-  [Function `exists_jailedbit`](#0x1_ValidatorUniverse_exists_jailedbit)
-  [Function `is_jailed`](#0x1_ValidatorUniverse_is_jailed)
-  [Function `genesis_helper`](#0x1_ValidatorUniverse_genesis_helper)
-  [Function `test_helper_add_self_onboard`](#0x1_ValidatorUniverse_test_helper_add_self_onboard)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_ValidatorUniverse_ValidatorUniverse"></a>

## Resource `ValidatorUniverse`



<pre><code><b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>validators: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ValidatorUniverse_JailedBit"></a>

## Resource `JailedBit`



<pre><code><b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> <b>has</b> key
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
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(220101));
  <b>move_to</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(account, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
      validators: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
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
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  // Miner can only add self <b>to</b> set <b>if</b> the mining is above a threshold.
  <b>if</b> (<a href="TowerState.md#0x1_TowerState_is_onboarding">TowerState::is_onboarding</a>(addr)) {
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(sender);
  } <b>else</b> {
    <b>assert</b>!(<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr), 220102014010);
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
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
  <b>let</b> (in_set, _) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&state.validators, &addr);
  <b>if</b> (!in_set) {
    <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> state.validators, addr);
    <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_unjail">unjail</a>(sender);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_remove_self"></a>

## Function `remove_self`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_remove_self">remove_self</a>(validator: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_remove_self">remove_self</a>(validator: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>let</b> val = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(validator);
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
  <b>let</b> (in_set, index) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&state.validators, &val);
  <b>if</b> (in_set) {
     <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<b>address</b>&gt;(&<b>mut</b> state.validators, index);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_get_eligible_validators"></a>

## Function `get_eligible_validators`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(vm: &signer): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(vm: &signer): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(220103));
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
  *&state.validators
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_is_in_universe"></a>

## Function `is_in_universe`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(miner: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(miner: <b>address</b>): bool <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&state.validators, &miner)
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_jail"></a>

## Function `jail`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_jail">jail</a>(vm: &signer, validator: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_jail">jail</a>(vm: &signer, validator: <b>address</b>) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>{
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, 220101014010);

  <b>borrow_global_mut</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed = <b>true</b>;
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
  <b>let</b> validator = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // check the node <b>has</b> been mining before unjailing.
  <b>assert</b>!(<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(validator), 220102014010);
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
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>if</b> (!<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr)) {
    <b>move_to</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(sender, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> { is_jailed: <b>false</b> });
    <b>return</b>
  };

  <b>borrow_global_mut</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr).is_jailed = <b>false</b>;
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_exists_jailedbit"></a>

## Function `exists_jailedbit`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_exists_jailedbit">exists_jailedbit</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_exists_jailedbit">exists_jailedbit</a>(addr: <b>address</b>): bool {
  <b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_is_jailed"></a>

## Function `is_jailed`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_jailed">is_jailed</a>(validator: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_jailed">is_jailed</a>(validator: <b>address</b>): bool <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator)) {
    <b>return</b> <b>false</b>
  };
  <b>borrow_global</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed
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
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, 220101014010);
  <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add">add</a>(validator);
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_test_helper_add_self_onboard"></a>

## Function `test_helper_add_self_onboard`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_test_helper_add_self_onboard">test_helper_add_self_onboard</a>(vm: &signer, addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_test_helper_add_self_onboard">test_helper_add_self_onboard</a>(vm: &signer, addr:<b>address</b>) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 220116014011);
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, 220101015010);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(@DiemRoot);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> state.validators, addr);
}
</code></pre>



</details>
