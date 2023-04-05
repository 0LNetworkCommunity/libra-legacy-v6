
<a name="0x1_Jail"></a>

# Module `0x1::Jail`



-  [Resource `Jail`](#0x1_Jail_Jail)
-  [Function `init`](#0x1_Jail_init)
-  [Function `is_jailed`](#0x1_Jail_is_jailed)
-  [Function `jail`](#0x1_Jail_jail)
-  [Function `remove_consecutive_fail`](#0x1_Jail_remove_consecutive_fail)
-  [Function `vouch_unjail`](#0x1_Jail_vouch_unjail)
-  [Function `unjail`](#0x1_Jail_unjail)
-  [Function `sort_by_jail`](#0x1_Jail_sort_by_jail)
-  [Function `inc_voucher_jail`](#0x1_Jail_inc_voucher_jail)
-  [Function `get_failure_to_join`](#0x1_Jail_get_failure_to_join)
-  [Function `get_vouchee_jail`](#0x1_Jail_get_vouchee_jail)
-  [Function `exists_jail`](#0x1_Jail_exists_jail)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
</code></pre>



<a name="0x1_Jail_Jail"></a>

## Resource `Jail`



<pre><code><b>struct</b> <a href="Jail.md#0x1_Jail">Jail</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>is_jailed: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_jailed: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_vouchees_jailed: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>consecutive_failure_to_rejoin: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Jail_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_init">init</a>(val_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_init">init</a>(val_sig: &signer) {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(val_sig);
  <b>if</b> (!<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr)) {
    <b>move_to</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(val_sig, <a href="Jail.md#0x1_Jail">Jail</a> {
      is_jailed: <b>false</b>,
      lifetime_jailed: 0,
      lifetime_vouchees_jailed: 0,
      consecutive_failure_to_rejoin: 0,

    });
  }
}
</code></pre>



</details>

<a name="0x1_Jail_is_jailed"></a>

## Function `is_jailed`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_is_jailed">is_jailed</a>(validator: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_is_jailed">is_jailed</a>(validator: <b>address</b>): bool <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator)) {
    <b>return</b> <b>false</b>
  };
  <b>borrow_global</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator).is_jailed
}
</code></pre>



</details>

<a name="0x1_Jail_jail"></a>

## Function `jail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_jail">jail</a>(vm: &signer, validator: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_jail">jail</a>(vm: &signer, validator: <b>address</b>) <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a>{
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator)) {
    <b>let</b> j = <b>borrow_global_mut</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator);
    j.is_jailed = <b>true</b>;
    j.lifetime_jailed = j.lifetime_jailed + 1;
    j.consecutive_failure_to_rejoin = j.consecutive_failure_to_rejoin + 1;
  };

  <a href="Jail.md#0x1_Jail_inc_voucher_jail">inc_voucher_jail</a>(validator);
}
</code></pre>



</details>

<a name="0x1_Jail_remove_consecutive_fail"></a>

## Function `remove_consecutive_fail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_remove_consecutive_fail">remove_consecutive_fail</a>(vm: &signer, validator: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_remove_consecutive_fail">remove_consecutive_fail</a>(vm: &signer, validator: <b>address</b>) <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator)) {
    <b>let</b> j = <b>borrow_global_mut</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(validator);
    j.consecutive_failure_to_rejoin = 0;
  }
}
</code></pre>



</details>

<a name="0x1_Jail_vouch_unjail"></a>

## Function `vouch_unjail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_vouch_unjail">vouch_unjail</a>(sender: &signer, addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_vouch_unjail">vouch_unjail</a>(sender: &signer, addr: <b>address</b>) <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  // only a validator can un-jail themselves.
  <b>let</b> voucher = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  <b>let</b> buddies = <a href="Vouch.md#0x1_Vouch_buddies_in_set">Vouch::buddies_in_set</a>(addr);
  // // print(&buddies);
  <b>let</b> (is_found, _idx) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&buddies, &voucher);
  <b>assert</b>!(is_found, 100103);

  // // check the node <b>has</b> been mining before unjailing.
  // <b>assert</b>!(<a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr), 100104);
  <a href="Jail.md#0x1_Jail_unjail">unjail</a>(addr);
}
</code></pre>



</details>

<a name="0x1_Jail_unjail"></a>

## Function `unjail`



<pre><code><b>fun</b> <a href="Jail.md#0x1_Jail_unjail">unjail</a>(addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Jail.md#0x1_Jail_unjail">unjail</a>(addr: <b>address</b>) <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr)) {
    <b>borrow_global_mut</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr).is_jailed = <b>false</b>;
  };
}
</code></pre>



</details>

<a name="0x1_Jail_sort_by_jail"></a>

## Function `sort_by_jail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_sort_by_jail">sort_by_jail</a>(vec_address: vector&lt;<b>address</b>&gt;): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_sort_by_jail">sort_by_jail</a>(vec_address: vector&lt;<b>address</b>&gt;): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {

  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&vec_address);

  <b>let</b> i = 0;
  <b>while</b> (i &lt; length){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; length-i-1){

      <b>let</b> value_j = <a href="Jail.md#0x1_Jail_get_failure_to_join">get_failure_to_join</a>(*<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&vec_address, j));
      <b>let</b> value_jp1 = <a href="Jail.md#0x1_Jail_get_failure_to_join">get_failure_to_join</a>(*<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&vec_address, j + 1));

      <b>if</b>(value_j &gt; value_jp1){
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;<b>address</b>&gt;(&<b>mut</b> vec_address, j, j+1);
      };
      j = j + 1;
    };
    i = i + 1;
  };

  vec_address
}
</code></pre>



</details>

<a name="0x1_Jail_inc_voucher_jail"></a>

## Function `inc_voucher_jail`



<pre><code><b>fun</b> <a href="Jail.md#0x1_Jail_inc_voucher_jail">inc_voucher_jail</a>(addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Jail.md#0x1_Jail_inc_voucher_jail">inc_voucher_jail</a>(addr: <b>address</b>) <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <b>let</b> buddies = <a href="Vouch.md#0x1_Vouch_get_buddies">Vouch::get_buddies</a>(addr);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&buddies)) {
    <b>let</b> voucher = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&buddies, i);
    <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(voucher)) {
      <b>let</b> v = <b>borrow_global_mut</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(voucher);
      v.lifetime_vouchees_jailed = v.lifetime_vouchees_jailed + 1;
    };
    i = i + 1;
  }
}
</code></pre>



</details>

<a name="0x1_Jail_get_failure_to_join"></a>

## Function `get_failure_to_join`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_get_failure_to_join">get_failure_to_join</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_get_failure_to_join">get_failure_to_join</a>(addr: <b>address</b>): u64 <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr)) {
    <b>return</b> <b>borrow_global</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr).consecutive_failure_to_rejoin
  };
  0
}
</code></pre>



</details>

<a name="0x1_Jail_get_vouchee_jail"></a>

## Function `get_vouchee_jail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_get_vouchee_jail">get_vouchee_jail</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_get_vouchee_jail">get_vouchee_jail</a>(addr: <b>address</b>): u64 <b>acquires</b> <a href="Jail.md#0x1_Jail">Jail</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr)) {
    <b>return</b> <b>borrow_global</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr).lifetime_vouchees_jailed
  };
  0
}
</code></pre>



</details>

<a name="0x1_Jail_exists_jail"></a>

## Function `exists_jail`



<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_exists_jail">exists_jail</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Jail.md#0x1_Jail_exists_jail">exists_jail</a>(addr: <b>address</b>): bool {
  <b>exists</b>&lt;<a href="Jail.md#0x1_Jail">Jail</a>&gt;(addr)
}
</code></pre>



</details>
