
<a name="0x1_ValidatorUniverse"></a>

# Module `0x1::ValidatorUniverse`



-  [Resource `ValidatorUniverse`](#0x1_ValidatorUniverse_ValidatorUniverse)
-  [Resource `JailedBit`](#0x1_ValidatorUniverse_JailedBit)
-  [Function `initialize`](#0x1_ValidatorUniverse_initialize)
-  [Function `add_validator`](#0x1_ValidatorUniverse_add_validator)
-  [Function `remove_validator`](#0x1_ValidatorUniverse_remove_validator)
-  [Function `get_eligible_validators`](#0x1_ValidatorUniverse_get_eligible_validators)
-  [Function `is_in_universe`](#0x1_ValidatorUniverse_is_in_universe)
-  [Function `jail`](#0x1_ValidatorUniverse_jail)
-  [Function `un_jail`](#0x1_ValidatorUniverse_un_jail)
-  [Function `is_jailed`](#0x1_ValidatorUniverse_is_jailed)
-  [Function `genesis_helper`](#0x1_ValidatorUniverse_genesis_helper)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_ValidatorUniverse_ValidatorUniverse"></a>

## Resource `ValidatorUniverse`



<pre><code><b>resource</b> <b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>
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



<pre><code><b>resource</b> <b>struct</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>
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
  <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 220101014010);
  move_to&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(account, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
      validators: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  });
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_add_validator"></a>

## Function `add_validator`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_validator">add_validator</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_validator">add_validator</a>(sender: &signer) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // Miner can only add self <b>to</b> set <b>if</b> the mining is above a threshold.
  <b>assert</b>(<a href="MinerState.md#0x1_MinerState_node_above_thresh">MinerState::node_above_thresh</a>(sender, addr), 220102014010);
  <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  <b>let</b> (in_set, _) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&state.validators, &addr);
  <b>if</b> (!in_set) {
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.validators, addr);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_remove_validator"></a>

## Function `remove_validator`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_remove_validator">remove_validator</a>(vm: &signer, validator: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_remove_validator">remove_validator</a>(vm: &signer, validator: address) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 220101014010);

  <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  <b>let</b> (in_set, index) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&state.validators, &validator);
  <b>if</b> (in_set) {
    <a href="Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;address&gt;(&<b>mut</b> state.validators, index);
  }
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_get_eligible_validators"></a>

## Function `get_eligible_validators`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(vm: &signer): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">get_eligible_validators</a>(vm: &signer): vector&lt;address&gt; <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 220101014010);
  <b>let</b> state = borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  *&state.validators
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_is_in_universe"></a>

## Function `is_in_universe`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(miner: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">is_in_universe</a>(miner: address): bool <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>let</b> state = borrow_global&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  <a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&state.validators, &miner)
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
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 220101014010);
  borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_un_jail"></a>

## Function `un_jail`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_un_jail">un_jail</a>(sender: &signer, validator: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_un_jail">un_jail</a>(sender: &signer, validator: address) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a> {
  // only a validator can un-jail themselves.
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender) == validator, 220101014010);

  <b>if</b> (!<b>exists</b>&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator)) {
    move_to&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(sender, <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>{
      is_jailed: <b>false</b>
    });
  };
  // check the node has been mining before unjailing.
  <b>assert</b>(<a href="MinerState.md#0x1_MinerState_node_above_thresh">MinerState::node_above_thresh</a>(sender, validator), 220102014010);
  borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed = <b>false</b>;
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
  borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_JailedBit">JailedBit</a>&gt;(validator).is_jailed
}
</code></pre>



</details>

<a name="0x1_ValidatorUniverse_genesis_helper"></a>

## Function `genesis_helper`



<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_genesis_helper">genesis_helper</a>(vm: &signer, validator: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_genesis_helper">genesis_helper</a>(vm: &signer, validator: address) <b>acquires</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a> {
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 220101014010);
  // <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // <a href="MinerState.md#0x1_MinerState_node_above_thresh">MinerState::node_above_thresh</a>(sender, addr);
  <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  <b>let</b> (in_set, _) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&state.validators, &validator);
  <b>if</b> (!in_set) {
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.validators, validator);
  }
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
