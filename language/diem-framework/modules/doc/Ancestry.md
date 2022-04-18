
<a name="0x1_Ancestry"></a>

# Module `0x1::Ancestry`



-  [Resource `Ancestry`](#0x1_Ancestry_Ancestry)
-  [Function `init`](#0x1_Ancestry_init)
-  [Function `get_tree`](#0x1_Ancestry_get_tree)
-  [Function `migrate`](#0x1_Ancestry_migrate)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Ancestry_Ancestry"></a>

## Resource `Ancestry`



<pre><code><b>struct</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tree: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>family: address</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Ancestry_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_init">init</a>(onboarder: &signer, new_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_init">init</a>(onboarder: &signer, new_account: &signer ) <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
  <b>let</b> parent = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(onboarder);
  <b>let</b> child = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(new_account);
  print(&1);

  <b>if</b> (!<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(parent)) <b>return</b>;

  <b>let</b> parent_state = borrow_global_mut&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(parent);
  <b>let</b> parent_tree = *&parent_state.tree;
  print(&2);
  <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&parent_tree) == 0) <b>return</b>;

  <b>let</b> earliest = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&parent_tree, 0);
  print(&3);
  // push the onboarder onto the inherited tree.
  // for compression, we don't need the tree <b>to</b> <b>include</b> yourself.
  // but it needs <b>to</b> be extended.

  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> parent_tree, parent);

  <b>if</b> (!<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child)) {
    move_to&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(new_account, <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
      tree: parent_tree,
      family: earliest,
    })
  }

}
</code></pre>



</details>

<a name="0x1_Ancestry_get_tree"></a>

## Function `get_tree`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_get_tree">get_tree</a>(addr: address): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_get_tree">get_tree</a>(addr: address): vector&lt;address&gt; <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
  *&borrow_global&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(addr).tree
}
</code></pre>



</details>

<a name="0x1_Ancestry_migrate"></a>

## Function `migrate`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_migrate">migrate</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_migrate">migrate</a>(sender: &signer) {
  <b>let</b> a = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  print(&a);

}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
