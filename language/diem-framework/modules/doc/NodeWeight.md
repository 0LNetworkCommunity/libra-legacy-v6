
<a name="0x1_NodeWeight"></a>

# Module `0x1::NodeWeight`



-  [Function `proof_of_weight`](#0x1_NodeWeight_proof_of_weight)
-  [Function `top_n_accounts`](#0x1_NodeWeight_top_n_accounts)
-  [Function `get_sorted_vals`](#0x1_NodeWeight_get_sorted_vals)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_NodeWeight_proof_of_weight"></a>

## Function `proof_of_weight`



<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">proof_of_weight</a>(node_addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">proof_of_weight</a> (node_addr: address): u64 {
  // Calculate the weight/voting power for the next round.
  // TODO: This assumes that validator passed the validation threshold this epoch, perhaps double check here.
  <a href="TowerState.md#0x1_TowerState_get_tower_height">TowerState::get_tower_height</a>(node_addr)
}
</code></pre>



</details>

<a name="0x1_NodeWeight_top_n_accounts"></a>

## Function `top_n_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;address&gt; {
    <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(140101));

    <b>let</b> eligible_validators = <a href="NodeWeight.md#0x1_NodeWeight_get_sorted_vals">get_sorted_vals</a>();
    <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&eligible_validators);
    <b>if</b>(len &lt;= n) <b>return</b> eligible_validators;

    <b>let</b> diff = len - n;
    <b>while</b>(diff &gt; 0){
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(&<b>mut</b> eligible_validators);
      diff = diff - 1;
    };

    eligible_validators
}
</code></pre>



</details>

<a name="0x1_NodeWeight_get_sorted_vals"></a>

## Function `get_sorted_vals`



<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_get_sorted_vals">get_sorted_vals</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="NodeWeight.md#0x1_NodeWeight_get_sorted_vals">get_sorted_vals</a>(): vector&lt;address&gt; {

  <b>let</b> eligible_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();


  <b>let</b> length = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&eligible_validators);

  // <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">Vector</a> <b>to</b> store each address's node_weight
  <b>let</b> weights = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {

    <b>let</b> cur_address = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&eligible_validators, k);
    // Ensure that this address is an active validator
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">proof_of_weight</a>(cur_address));
    k = k + 1;
  };

  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> i = 0;
  <b>while</b> (i &lt; length){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; length-i-1){

      <b>let</b> value_j = *(<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
      <b>let</b> value_jp1 = *(<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
      <b>if</b>(value_j &gt; value_jp1){
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;address&gt;(&<b>mut</b> eligible_validators, j, j+1);
      };
      j = j + 1;
    };
    i = i + 1;
  };

  // Reverse <b>to</b> have sorted order - high <b>to</b> low.
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_reverse">Vector::reverse</a>&lt;address&gt;(&<b>mut</b> eligible_validators);

  <b>return</b> eligible_validators
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
