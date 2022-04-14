
<a name="0x1_Delegation"></a>

# Module `0x1::Delegation`



-  [Resource `AllTribes`](#0x1_Delegation_AllTribes)
-  [Resource `Tribe`](#0x1_Delegation_Tribe)
-  [Struct `Member`](#0x1_Delegation_Member)
-  [Function `vm_init`](#0x1_Delegation_vm_init)
-  [Function `elder_init`](#0x1_Delegation_elder_init)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Delegation_AllTribes"></a>

## Resource `AllTribes`



<pre><code><b>struct</b> <a href="Delegation.md#0x1_Delegation_AllTribes">AllTribes</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>teams_by_elder: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Delegation_Tribe"></a>

## Resource `Tribe`



<pre><code><b>struct</b> <a href="Delegation.md#0x1_Delegation_Tribe">Tribe</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>elder: address</code>
</dt>
<dd>

</dd>
<dt>
<code>tribe_name: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>members: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>operator_pct_bonus: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tribal_tower_height_this_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Delegation_Member"></a>

## Struct `Member`



<pre><code><b>struct</b> <a href="Delegation.md#0x1_Delegation_Member">Member</a> has <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>my_tribe_elder: address</code>
</dt>
<dd>

</dd>
<dt>
<code>mining_above_threshold: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Delegation_vm_init"></a>

## Function `vm_init`



<pre><code><b>public</b> <b>fun</b> <a href="Delegation.md#0x1_Delegation_vm_init">vm_init</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Delegation.md#0x1_Delegation_vm_init">vm_init</a>(sender: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(sender);
  move_to&lt;<a href="Delegation.md#0x1_Delegation_AllTribes">AllTribes</a>&gt;(
    sender,
    <a href="Delegation.md#0x1_Delegation_AllTribes">AllTribes</a> {
      teams_by_elder: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>()
    }
  );
}
</code></pre>



</details>

<a name="0x1_Delegation_elder_init"></a>

## Function `elder_init`



<pre><code><b>public</b> <b>fun</b> <a href="Delegation.md#0x1_Delegation_elder_init">elder_init</a>(sender: &signer, tribe_name: vector&lt;u8&gt;, operator_pct_bonus: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Delegation.md#0x1_Delegation_elder_init">elder_init</a>(sender: &signer, tribe_name: vector&lt;u8&gt;, operator_pct_bonus: u64) {
  // An Elder, who is already a validator account, stores the <a href="Delegation.md#0x1_Delegation_Tribe">Tribe</a> <b>struct</b> on their account.
  // the AllTeams <b>struct</b> is saved in the 0x0 account, and needs <b>to</b> be initialized before this is called.

  // check vm has initialized the <b>struct</b>, otherwise exit early.
  <b>if</b> (!<b>exists</b>&lt;<a href="Delegation.md#0x1_Delegation_AllTribes">AllTribes</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>return</b>
};

move_to&lt;<a href="Delegation.md#0x1_Delegation_Tribe">Tribe</a>&gt;(
    sender,
    <a href="Delegation.md#0x1_Delegation_Tribe">Tribe</a> {
      elder: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), // A validator account.
      tribe_name, // A validator account.
      members: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
      operator_pct_bonus, // the percentage of the rewards that the captain proposes <b>to</b> go <b>to</b> the validator operator.
      tribal_tower_height_this_epoch: 0,
    }
  );
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
