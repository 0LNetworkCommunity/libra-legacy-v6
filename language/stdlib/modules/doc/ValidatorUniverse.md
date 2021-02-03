
<a name="0x1_ValidatorUniverse"></a>

# Module `0x1::ValidatorUniverse`



-  [Resource `ValidatorUniverse`](#0x1_ValidatorUniverse_ValidatorUniverse)
-  [Function `initialize`](#0x1_ValidatorUniverse_initialize)
-  [Function `add_validator`](#0x1_ValidatorUniverse_add_validator)
-  [Function `get_eligible_validators`](#0x1_ValidatorUniverse_get_eligible_validators)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
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
  <b>let</b> state = borrow_global_mut&lt;<a href="ValidatorUniverse.md#0x1_ValidatorUniverse">ValidatorUniverse</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());
  <b>let</b> (in_set, _) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&state.validators, &addr);
  <b>if</b> (!in_set) {
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> state.validators, addr);
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


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
