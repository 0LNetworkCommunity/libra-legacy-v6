
<a name="0x1_Vouch"></a>

# Module `0x1::Vouch`



-  [Resource `Vouch`](#0x1_Vouch_Vouch)
-  [Function `init`](#0x1_Vouch_init)
-  [Function `is_init`](#0x1_Vouch_is_init)
-  [Function `vouch_for`](#0x1_Vouch_vouch_for)
-  [Function `vm_migrate`](#0x1_Vouch_vm_migrate)
-  [Function `get_buddies`](#0x1_Vouch_get_buddies)
-  [Function `buddies_in_set`](#0x1_Vouch_buddies_in_set)
-  [Function `unrelated_buddies`](#0x1_Vouch_unrelated_buddies)
-  [Function `unrelated_buddies_above_thresh`](#0x1_Vouch_unrelated_buddies_above_thresh)


<pre><code><b>use</b> <a href="Ancestry.md#0x1_Ancestry">0x1::Ancestry</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Vouch_Vouch"></a>

## Resource `Vouch`



<pre><code><b>struct</b> <a href="Vouch.md#0x1_Vouch">Vouch</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>vals: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Vouch_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_init">init</a>(new_account_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_init">init</a>(new_account_sig: &signer ) {
  <b>let</b> acc = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(new_account_sig);

  <b>if</b> (<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(acc) && !<a href="Vouch.md#0x1_Vouch_is_init">is_init</a>(acc)) {
    move_to&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(new_account_sig, <a href="Vouch.md#0x1_Vouch">Vouch</a> {
        vals: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      });
  }
}
</code></pre>



</details>

<a name="0x1_Vouch_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_is_init">is_init</a>(acc: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_is_init">is_init</a>(acc: address ):bool {
  <b>exists</b>&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(acc)
}
</code></pre>



</details>

<a name="0x1_Vouch_vouch_for"></a>

## Function `vouch_for`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_vouch_for">vouch_for</a>(buddy: &signer, val: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_vouch_for">vouch_for</a>(buddy: &signer, val: address) <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a> {
  <b>let</b> buddy_acc = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(buddy);
  <b>assert</b>(buddy_acc!=val, 12345); // TODO: Error code.

  <b>if</b> (!<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(buddy_acc)) <b>return</b>;
  <b>if</b> (!<b>exists</b>&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val)) <b>return</b>;

  <b>let</b> v = borrow_global_mut&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val);
  <b>if</b> (!<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&v.vals, &buddy_acc)) { // prevent duplicates
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> v.vals, buddy_acc);
  }
}
</code></pre>



</details>

<a name="0x1_Vouch_vm_migrate"></a>

## Function `vm_migrate`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_vm_migrate">vm_migrate</a>(vm: &signer, val: address, buddy_list: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_vm_migrate">vm_migrate</a>(vm: &signer, val: address, buddy_list: vector&lt;address&gt;) <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>if</b> (!<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(val)) <b>return</b>;
  <b>if</b> (!<b>exists</b>&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val)) <b>return</b>;

  <b>let</b> v = borrow_global_mut&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val);

  // take self out of list
  <b>let</b> (is_found, i) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&buddy_list, &val);

  <b>if</b> (is_found) {
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>&lt;address&gt;(&<b>mut</b> buddy_list, i);
  };

  v.vals = buddy_list;

}
</code></pre>



</details>

<a name="0x1_Vouch_get_buddies"></a>

## Function `get_buddies`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_get_buddies">get_buddies</a>(val: address): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_get_buddies">get_buddies</a>(val: address): vector&lt;address&gt; <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a>{
  <b>if</b> (<a href="Vouch.md#0x1_Vouch_is_init">is_init</a>(val)) {
    <b>return</b> *&borrow_global&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val).vals
  };
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
}
</code></pre>



</details>

<a name="0x1_Vouch_buddies_in_set"></a>

## Function `buddies_in_set`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_buddies_in_set">buddies_in_set</a>(val: address): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_buddies_in_set">buddies_in_set</a>(val: address): vector&lt;address&gt; <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a> {
  <b>let</b> current_set = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();
  <b>if</b> (!<b>exists</b>&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val)) <b>return</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();

  <b>let</b> v = borrow_global&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val);

  <b>let</b> buddies_in_set = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
  <b>let</b>  i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&v.vals)) {
    <b>let</b> a = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&v.vals, i);
    <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&current_set, a)) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> buddies_in_set, *a);
    };
    i = i + 1;
  };

  buddies_in_set
}
</code></pre>



</details>

<a name="0x1_Vouch_unrelated_buddies"></a>

## Function `unrelated_buddies`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_unrelated_buddies">unrelated_buddies</a>(val: address): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_unrelated_buddies">unrelated_buddies</a>(val: address): vector&lt;address&gt; <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a> {
  // start our list empty
  <b>let</b> unrelated_buddies = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();

  // find all our buddies in this validator set
  <b>let</b> buddies_in_set = <a href="Vouch.md#0x1_Vouch_buddies_in_set">buddies_in_set</a>(val);
  <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&buddies_in_set);
  <b>let</b>  i = 0;
  <b>while</b> (i &lt; len) {

    <b>let</b> target_acc = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&buddies_in_set, i);

    // now <b>loop</b> through all the accounts again, and check <b>if</b> this target account is related <b>to</b> anyone.
    <b>let</b>  k = 0;
    <b>while</b> (k &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&buddies_in_set)) {
      <b>let</b> comparison_acc = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&buddies_in_set, k);
      // skip <b>if</b> you're the same person
      <b>if</b> (comparison_acc != target_acc) {
        // check ancestry algo
        <b>let</b> (is_fam, _) = <a href="Ancestry.md#0x1_Ancestry_is_family">Ancestry::is_family</a>(*comparison_acc, *target_acc);
        <b>if</b> (!is_fam) {
          <b>if</b> (!<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&unrelated_buddies, target_acc)) {
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> unrelated_buddies, *target_acc)
          }
        }
      };
      k = k + 1;
    };

    // <b>if</b> (<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&current_set, a)) {
    //   <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> buddies_in_set, *a);
    // };
    i = i + 1;
  };

  unrelated_buddies
}
</code></pre>



</details>

<a name="0x1_Vouch_unrelated_buddies_above_thresh"></a>

## Function `unrelated_buddies_above_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">unrelated_buddies_above_thresh</a>(val: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">unrelated_buddies_above_thresh</a>(val: address): bool <b>acquires</b> <a href="Vouch.md#0x1_Vouch">Vouch</a>{
  print(&222222);
  <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>() || <a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()) {
    <b>return</b> <b>true</b>
  };
  print(&22222200001);

  <b>if</b> (!<b>exists</b>&lt;<a href="Vouch.md#0x1_Vouch">Vouch</a>&gt;(val)) <b>return</b> <b>false</b>;
  print(&22222200002);

  <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&<a href="Vouch.md#0x1_Vouch_unrelated_buddies">unrelated_buddies</a>(val));
  print(&22222200003);

  (len &gt;= 4) // TODO: <b>move</b> <b>to</b> <a href="Globals.md#0x1_Globals">Globals</a>
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
