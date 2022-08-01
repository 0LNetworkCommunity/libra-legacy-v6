
<a name="0x1_Stats"></a>

# Module `0x1::Stats`



-  [Struct `SetData`](#0x1_Stats_SetData)
-  [Resource `ValStats`](#0x1_Stats_ValStats)
-  [Function `initialize`](#0x1_Stats_initialize)
-  [Function `blank`](#0x1_Stats_blank)
-  [Function `init_address`](#0x1_Stats_init_address)
-  [Function `init_set`](#0x1_Stats_init_set)
-  [Function `process_set_votes`](#0x1_Stats_process_set_votes)
-  [Function `node_current_votes`](#0x1_Stats_node_current_votes)
-  [Function `node_above_thresh`](#0x1_Stats_node_above_thresh)
-  [Function `network_density`](#0x1_Stats_network_density)
-  [Function `node_current_props`](#0x1_Stats_node_current_props)
-  [Function `inc_prop`](#0x1_Stats_inc_prop)
-  [Function `inc_vote`](#0x1_Stats_inc_vote)
-  [Function `reconfig`](#0x1_Stats_reconfig)
-  [Function `get_total_votes`](#0x1_Stats_get_total_votes)
-  [Function `get_total_props`](#0x1_Stats_get_total_props)
-  [Function `get_history`](#0x1_Stats_get_history)
-  [Function `test_helper_inc_vote_addr`](#0x1_Stats_test_helper_inc_vote_addr)
-  [Function `get_sorted_vals_by_props`](#0x1_Stats_get_sorted_vals_by_props)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Stats_SetData"></a>

## Struct `SetData`



<pre><code><b>struct</b> <a href="Stats.md#0x1_Stats_SetData">SetData</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>addr: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>prop_count: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>vote_count: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_votes: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>total_props: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Stats_ValStats"></a>

## Resource `ValStats`



<pre><code><b>struct</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> <b>has</b> <b>copy</b>, drop, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>history: vector&lt;<a href="Stats.md#0x1_Stats_SetData">Stats::SetData</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>current: <a href="Stats.md#0x1_Stats_SetData">Stats::SetData</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Stats_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_initialize">initialize</a>(vm: &signer) {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190001));
  <b>move_to</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(
    vm,
    <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
      history: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      current: <a href="Stats.md#0x1_Stats_blank">blank</a>()
    }
  );
}
</code></pre>



</details>

<a name="0x1_Stats_blank"></a>

## Function `blank`



<pre><code><b>fun</b> <a href="Stats.md#0x1_Stats_blank">blank</a>(): <a href="Stats.md#0x1_Stats_SetData">Stats::SetData</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Stats.md#0x1_Stats_blank">blank</a>():<a href="Stats.md#0x1_Stats_SetData">SetData</a> {
  <a href="Stats.md#0x1_Stats_SetData">SetData</a> {
    addr: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    prop_count: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    vote_count: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    total_votes: 0,
    total_props: 0,
  }
}
</code></pre>



</details>

<a name="0x1_Stats_init_address"></a>

## Function `init_address`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_init_address">init_address</a>(vm: &signer, node_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_init_address">init_address</a>(vm: &signer, node_addr: <b>address</b>) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);

  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190002));

  <b>let</b> stats = <b>borrow_global</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);
  <b>let</b> (is_init, _) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&stats.current.addr, &node_addr);
  <b>if</b> (!is_init) {
    <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.current.addr, node_addr);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.current.prop_count, 0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.current.vote_count, 0);
  }
}
</code></pre>



</details>

<a name="0x1_Stats_init_set"></a>

## Function `init_set`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_init_set">init_set</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_init_set">init_set</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a>{
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190003));
  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(set);
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {
    <b>let</b> node_address = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(set, k));
    <a href="Stats.md#0x1_Stats_init_address">init_address</a>(vm, node_address);
    k = k + 1;
  }
}
</code></pre>



</details>

<a name="0x1_Stats_process_set_votes"></a>

## Function `process_set_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_process_set_votes">process_set_votes</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_process_set_votes">process_set_votes</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a>{
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190004));

  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(set);
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {
    <b>let</b> node_address = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(set, k));
    <a href="Stats.md#0x1_Stats_inc_vote">inc_vote</a>(vm, node_address);
    k = k + 1;
  }
}
</code></pre>



</details>

<a name="0x1_Stats_node_current_votes"></a>

## Function `node_current_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_current_votes">node_current_votes</a>(vm: &signer, node_addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_current_votes">node_current_votes</a>(vm: &signer, node_addr: <b>address</b>): u64 <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190005));
  <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);
  <b>let</b> (is_found, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&<b>mut</b> stats.current.addr, &node_addr);
  <b>if</b> (is_found) <b>return</b> *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&<b>mut</b> stats.current.vote_count, i)
  <b>else</b> 0
}
</code></pre>



</details>

<a name="0x1_Stats_node_above_thresh"></a>

## Function `node_above_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_above_thresh">node_above_thresh</a>(vm: &signer, node_addr: <b>address</b>, height_start: u64, height_end: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_above_thresh">node_above_thresh</a>(vm: &signer, node_addr: <b>address</b>, height_start: u64, height_end: u64): bool <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a>{
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190006));
  <b>let</b> range = height_end-height_start;
  <b>let</b> threshold_signing = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(range, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 100));
  <b>if</b> (<a href="Stats.md#0x1_Stats_node_current_votes">node_current_votes</a>(vm, node_addr) &gt;  threshold_signing) { <b>return</b> <b>true</b> };
  <b>return</b> <b>false</b>
}
</code></pre>



</details>

<a name="0x1_Stats_network_density"></a>

## Function `network_density`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_network_density">network_density</a>(vm: &signer, height_start: u64, height_end: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_network_density">network_density</a>(vm: &signer, height_start: u64, height_end: u64): u64 <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190007));
  <b>let</b> density = 0u64;
  <b>let</b> nodes = *&(<b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender).current.addr);
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&nodes);
  <b>let</b> k = 0;
  <b>while</b> (k &lt; len) {
    <b>let</b> addr = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&nodes, k));
    <b>if</b> (<a href="Stats.md#0x1_Stats_node_above_thresh">node_above_thresh</a>(vm, addr, height_start, height_end)) {
      density = density + 1;
    };
    k = k + 1;
  };
  <b>return</b> density
}
</code></pre>



</details>

<a name="0x1_Stats_node_current_props"></a>

## Function `node_current_props`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_current_props">node_current_props</a>(vm: &signer, node_addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_node_current_props">node_current_props</a>(vm: &signer, node_addr: <b>address</b>): u64 <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190008));
  <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);
  <b>let</b> (is_found, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&<b>mut</b> stats.current.addr, &node_addr);
  <b>if</b> (is_found) <b>return</b> *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&<b>mut</b> stats.current.prop_count, i)
  <b>else</b> 0
}
</code></pre>



</details>

<a name="0x1_Stats_inc_prop"></a>

## Function `inc_prop`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_inc_prop">inc_prop</a>(vm: &signer, node_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_inc_prop">inc_prop</a>(vm: &signer, node_addr: <b>address</b>) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190009));
  <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(@DiemRoot);
  <b>let</b> (is_true, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&<b>mut</b> stats.current.addr, &node_addr);
  // don't try <b>to</b> increment <b>if</b> no state. This <b>has</b> caused issues in the past
  // in emergency recovery.

  <b>if</b> (is_true) {
    <b>let</b> current_count = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&<b>mut</b> stats.current.prop_count, i);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.current.prop_count, current_count + 1);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> stats.current.prop_count, i);
  };

  stats.current.total_props = stats.current.total_props + 1;
}
</code></pre>



</details>

<a name="0x1_Stats_inc_vote"></a>

## Function `inc_vote`



<pre><code><b>fun</b> <a href="Stats.md#0x1_Stats_inc_vote">inc_vote</a>(vm: &signer, node_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Stats.md#0x1_Stats_inc_vote">inc_vote</a>(vm: &signer, node_addr: <b>address</b>) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190010));
  <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);
  <b>let</b> (is_true, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&<b>mut</b> stats.current.addr, &node_addr);
  <b>if</b> (is_true) {
    <b>let</b> test = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&<b>mut</b> stats.current.vote_count, i);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.current.vote_count, test + 1);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> stats.current.vote_count, i);
  } <b>else</b> {
    // debugging rescue mission. Remove after network stabilizes Apr 2022.
    // something bad happened and we can't find this node in our list.
    // print(&666);
    // print(&node_addr);
  };
  // <b>update</b> total vote count anyways even <b>if</b> we can't find this person.
  stats.current.total_votes = stats.current.total_votes + 1;
  // print(&stats.current);
}
</code></pre>



</details>

<a name="0x1_Stats_reconfig"></a>

## Function `reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_reconfig">reconfig</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_reconfig">reconfig</a>(vm: &signer, set: &vector&lt;<b>address</b>&gt;) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190011));
  <b>let</b> stats = <b>borrow_global_mut</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(sender);

  // Keep only the most recent epoch stats
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&stats.history) &gt; 7) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>&lt;<a href="Stats.md#0x1_Stats_SetData">SetData</a>&gt;(&<b>mut</b> stats.history); // just drop last record
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> stats.history, *&stats.current);
  stats.current = <a href="Stats.md#0x1_Stats_blank">blank</a>();
  <a href="Stats.md#0x1_Stats_init_set">init_set</a>(vm, set);
}
</code></pre>



</details>

<a name="0x1_Stats_get_total_votes"></a>

## Function `get_total_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_total_votes">get_total_votes</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_total_votes">get_total_votes</a>(vm: &signer): u64 <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190012));
  *&<b>borrow_global</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(@DiemRoot).current.total_votes
}
</code></pre>



</details>

<a name="0x1_Stats_get_total_props"></a>

## Function `get_total_props`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_total_props">get_total_props</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_total_props">get_total_props</a>(vm: &signer): u64 <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190013));
  *&<b>borrow_global</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(@DiemRoot).current.total_props
}
</code></pre>



</details>

<a name="0x1_Stats_get_history"></a>

## Function `get_history`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_history">get_history</a>(): vector&lt;<a href="Stats.md#0x1_Stats_SetData">Stats::SetData</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_history">get_history</a>(): vector&lt;<a href="Stats.md#0x1_Stats_SetData">SetData</a>&gt; <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  *&<b>borrow_global</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(@DiemRoot).history
}
</code></pre>



</details>

<a name="0x1_Stats_test_helper_inc_vote_addr"></a>

## Function `test_helper_inc_vote_addr`

TEST HELPERS


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_test_helper_inc_vote_addr">test_helper_inc_vote_addr</a>(vm: &signer, node_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_test_helper_inc_vote_addr">test_helper_inc_vote_addr</a>(vm: &signer, node_addr: <b>address</b>) <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
  <b>let</b> sender = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>!(sender == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190015));
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(190015));

  <a href="Stats.md#0x1_Stats_inc_vote">inc_vote</a>(vm, node_addr);
}
</code></pre>



</details>

<a name="0x1_Stats_get_sorted_vals_by_props"></a>

## Function `get_sorted_vals_by_props`



<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_sorted_vals_by_props">get_sorted_vals_by_props</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Stats.md#0x1_Stats_get_sorted_vals_by_props">get_sorted_vals_by_props</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="Stats.md#0x1_Stats_ValStats">ValStats</a> {
    <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(140101));

    //Get all validators from Validator Universe and then find the eligible validators
    <b>let</b> eligible_validators =
    *&<b>borrow_global</b>&lt;<a href="Stats.md#0x1_Stats_ValStats">ValStats</a>&gt;(@DiemRoot).current.addr;

    <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);

    // Scenario: The universe of validators is under the limit of the BFT consensus.
    // If n is greater than or equal <b>to</b> accounts vector length - <b>return</b> the vector.
    <b>if</b>(length &lt;= n) <b>return</b> eligible_validators;

    // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> <b>to</b> store each <b>address</b>'s node_weight
    <b>let</b> weights = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
    <b>let</b> k = 0;
    <b>while</b> (k &lt; length) {

      <b>let</b> cur_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&eligible_validators, k);
      // Ensure that this <b>address</b> is an active validator
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, <a href="Stats.md#0x1_Stats_node_current_props">node_current_props</a>(account, cur_address));
      k = k + 1;
    };

    // Sorting the accounts vector based on value (weights).
    // Bubble sort algorithm
    <b>let</b> i = 0;
    <b>while</b> (i &lt; length){
      <b>let</b> j = 0;
      <b>while</b>(j &lt; length-i-1){
        <b>let</b> value_j = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
        <b>let</b> value_jp1 = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
        <b>if</b>(value_j &gt; value_jp1){
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators, j, j+1);
        };
        j = j + 1;
      };
      i = i + 1;
    };

    // Reverse <b>to</b> have sorted order - high <b>to</b> low.
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_reverse">Vector::reverse</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators);

    <b>let</b> diff = length - n;
    <b>while</b>(diff&gt;0){
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(&<b>mut</b> eligible_validators);
      diff =  diff - 1;
    };

    <b>return</b> eligible_validators
  }
</code></pre>



</details>
