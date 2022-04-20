
<a name="0x1_Ancestry"></a>

# Module `0x1::Ancestry`



-  [Resource `Ancestry`](#0x1_Ancestry_Ancestry)
-  [Function `init`](#0x1_Ancestry_init)
-  [Function `set_tree`](#0x1_Ancestry_set_tree)
-  [Function `get_tree`](#0x1_Ancestry_get_tree)
-  [Function `is_family`](#0x1_Ancestry_is_family)
-  [Function `migrate`](#0x1_Ancestry_migrate)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
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
</dl>


</details>

<a name="0x1_Ancestry_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_init">init</a>(new_account_sig: &signer, onboarder_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_init">init</a>(new_account_sig: &signer, onboarder_sig: &signer ) <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a>{
    print(&100100);

    <b>let</b> parent = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(onboarder_sig);
    <a href="Ancestry.md#0x1_Ancestry_set_tree">set_tree</a>(new_account_sig, parent);

}
</code></pre>



</details>

<a name="0x1_Ancestry_set_tree"></a>

## Function `set_tree`



<pre><code><b>fun</b> <a href="Ancestry.md#0x1_Ancestry_set_tree">set_tree</a>(new_account_sig: &signer, parent: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Ancestry.md#0x1_Ancestry_set_tree">set_tree</a>(new_account_sig: &signer, parent: address ) <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
  <b>let</b> child = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(new_account_sig);
    print(&100200);
  <b>let</b> new_tree = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();

  // get the parent's ancestry <b>if</b> initialized.
  // <b>if</b> not then this is an edge case possibly a migration error, and we'll just <b>use</b> the parent.
  <b>if</b> (<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(parent)) {
    <b>let</b> parent_state = borrow_global_mut&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(parent);
    <b>let</b> parent_tree = *&parent_state.tree;
    print(&100210);
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&parent_tree) &gt; 0) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> new_tree, parent_tree);
    };
    print(&100220);
  };

  // add the parent <b>to</b> the tree
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> new_tree, parent);
    print(&100230);

  <b>if</b> (!<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child)) {
    move_to&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(new_account_sig, <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
      tree: new_tree,
    });
    print(&100240);

  } <b>else</b> {
    // this is only for migration cases.
    <b>let</b> child_ancestry = borrow_global_mut&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child);
    child_ancestry.tree = new_tree;
    print(&100250);

  };
  print(&100260);

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
  <b>if</b> (<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(addr)) {
    *&borrow_global&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(addr).tree
  } <b>else</b> {
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>()
  }

}
</code></pre>



</details>

<a name="0x1_Ancestry_is_family"></a>

## Function `is_family`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_is_family">is_family</a>(left: address, right: address): (bool, address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_is_family">is_family</a>(left: address, right: address): (bool, address) <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
  <b>let</b> is_family = <b>false</b>;
  <b>let</b> common_ancestor = @0x0;
  print(&100300);
  print(&<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(left));
  print(&<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(right));

  // <b>if</b> (<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(left) && <b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(right)) {
    // <b>if</b> tree is empty it will still work.
    print(&100310);
    <b>let</b> left_tree = <a href="Ancestry.md#0x1_Ancestry_get_tree">get_tree</a>(left);
    print(&100311);
    <b>let</b> right_tree = <a href="Ancestry.md#0x1_Ancestry_get_tree">get_tree</a>(right);


    print(&100320);

    // check for direct relationship.
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&left_tree, &right)) <b>return</b> (<b>true</b>, right);
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&right_tree, &left)) <b>return</b> (<b>true</b>, left);



    print(&100330);
    <b>let</b> i = 0;
    // check every address on the list <b>if</b> there are overlaps.
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&left_tree)) {
      print(&100341);
      <b>let</b> family_addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&left_tree, i);
      <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&right_tree, family_addr)) {
        is_family = <b>true</b>;
        common_ancestor = *family_addr;
        print(&100342);
        <b>break</b>
      };
      i = i + 1;
    };
    print(&100350);
  // };
  print(&100360);
  (is_family, common_ancestor)
}
</code></pre>



</details>

<a name="0x1_Ancestry_migrate"></a>

## Function `migrate`



<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_migrate">migrate</a>(vm: &signer, child_sig: &signer, migrate_tree: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ancestry.md#0x1_Ancestry_migrate">migrate</a>(vm: &signer, child_sig: &signer, migrate_tree: vector&lt;address&gt;) <b>acquires</b> <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> child = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(child_sig);

  <b>if</b> (!<b>exists</b>&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child)) {
    move_to&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child_sig, <a href="Ancestry.md#0x1_Ancestry">Ancestry</a> {
      tree: migrate_tree,
    });
    print(&100240);

  } <b>else</b> {
    // this is only for migration cases.
    <b>let</b> child_ancestry = borrow_global_mut&lt;<a href="Ancestry.md#0x1_Ancestry">Ancestry</a>&gt;(child);
    child_ancestry.tree = migrate_tree;
    print(&100250);

  };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
