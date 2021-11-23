
<a name="0x1_Migrations"></a>

# Module `0x1::Migrations`


<a name="@Summary_0"></a>

## Summary

This module is used to record migrations from old versions of stdlib to new
versions when a breaking change is introduced (e.g. a resource is altered)
The code for the actual migrations is instantiated in seperate modules.
When running a migration, one must:
1. check it has not been run using the <code>has_run</code> function
2. run the migration
3. record that the migration has run using the <code>push</code> function


-  [Summary](#@Summary_0)
-  [Resource `Migrations`](#0x1_Migrations_Migrations)
-  [Struct `Job`](#0x1_Migrations_Job)
-  [Function `init`](#0x1_Migrations_init)
-  [Function `has_run`](#0x1_Migrations_has_run)
-  [Function `push`](#0x1_Migrations_push)
-  [Function `find`](#0x1_Migrations_find)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Migrations_Migrations"></a>

## Resource `Migrations`

A list of Migrations that have been


<pre><code><b>struct</b> <a href="Migrations.md#0x1_Migrations">Migrations</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;<a href="Migrations.md#0x1_Migrations_Job">Migrations::Job</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Migrations_Job"></a>

## Struct `Job`

A specific Migration (e.g. altering a struct)
<code>uid</code> is a unique identifier for the migration, selected by the vm
<code>name</code> is for reference purposes only and is not used by the module
to distinguish between migrations


<pre><code><b>struct</b> <a href="Migrations.md#0x1_Migrations_Job">Job</a> has <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>uid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>name: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Migrations_init"></a>

## Function `init`

initialize the Migrations structure


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_init">init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_init">init</a>(vm: &signer){
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="Migrations.md#0x1_Migrations">Migrations</a>&gt;(@0x0)) {
    move_to&lt;<a href="Migrations.md#0x1_Migrations">Migrations</a>&gt;(vm, <a href="Migrations.md#0x1_Migrations">Migrations</a> {
      list: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;(),
    })
  }
}
</code></pre>



</details>

<a name="0x1_Migrations_has_run"></a>

## Function `has_run`

Returns true if a migration has been added to the Migrations list


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_has_run">has_run</a>(uid: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_has_run">has_run</a>(uid: u64): bool <b>acquires</b> <a href="Migrations.md#0x1_Migrations">Migrations</a> {
  <b>let</b> opt_job = <a href="Migrations.md#0x1_Migrations_find">find</a>(uid);
  <b>if</b> (<a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;(&opt_job)) {
    <b>true</b>
  }
  <b>else</b> {
    <b>false</b>
  }
}
</code></pre>



</details>

<a name="0x1_Migrations_push"></a>

## Function `push`

Adds a job to the migrations list if it has not been added already
Only the vm can add a job to this list in order to prevent others from
preventing a migration by inserting the migration's UID to this list
before it occurs


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_push">push</a>(vm: &signer, uid: u64, text: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_Migrations_push">push</a>(vm: &signer, uid: u64, text: vector&lt;u8&gt;) <b>acquires</b> <a href="Migrations.md#0x1_Migrations">Migrations</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (<a href="Migrations.md#0x1_Migrations_has_run">has_run</a>(uid)) <b>return</b>;
  <b>let</b> s = borrow_global_mut&lt;<a href="Migrations.md#0x1_Migrations">Migrations</a>&gt;(@0x0);
  <b>let</b> j = <a href="Migrations.md#0x1_Migrations_Job">Job</a> {
    uid: uid,
    name: text,
  };

  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;(&<b>mut</b> s.list, j);
}
</code></pre>



</details>

<a name="0x1_Migrations_find"></a>

## Function `find`

Searches for a job within the Migrations list, returns <code>some</code> if
is found, returns <code>none</code> otherwise


<pre><code><b>fun</b> <a href="Migrations.md#0x1_Migrations_find">find</a>(uid: u64): <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Migrations::Job</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Migrations.md#0x1_Migrations_find">find</a>(uid: u64): <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt; <b>acquires</b> <a href="Migrations.md#0x1_Migrations">Migrations</a> {
  <b>let</b> job_list = &borrow_global&lt;<a href="Migrations.md#0x1_Migrations">Migrations</a>&gt;(@0x0).list;
  <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(job_list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> j = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;(job_list, i);
    <b>if</b> (j.uid == uid) {
      <b>return</b> <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_some">Option::some</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;(j)
    };
    i = i + 1;
  };
  <a href="../../../../../../move-stdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;<a href="Migrations.md#0x1_Migrations_Job">Job</a>&gt;()
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
