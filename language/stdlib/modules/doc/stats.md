
<a name="0x0_Stats"></a>

# Module `0x0::Stats`

### Table of Contents

-  [Struct `TreeNode`](#0x0_Stats_TreeNode)
-  [Struct `Validator_Tree`](#0x0_Stats_Validator_Tree)
-  [Struct `Foo`](#0x0_Stats_Foo)
-  [Struct `Bar`](#0x0_Stats_Bar)
-  [Struct `Box`](#0x0_Stats_Box)
-  [Struct `State`](#0x0_Stats_State)
-  [Function `initialize`](#0x0_Stats_initialize)
-  [Function `add_stuff`](#0x0_Stats_add_stuff)
-  [Function `remove_stuff`](#0x0_Stats_remove_stuff)
-  [Function `p_addr`](#0x0_Stats_p_addr)
-  [Function `test`](#0x0_Stats_test)



<a name="0x0_Stats_TreeNode"></a>

## Struct `TreeNode`



<pre><code><b>struct</b> <a href="#0x0_Stats_TreeNode">TreeNode</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>validator: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>start_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>end_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_Validator_Tree"></a>

## Struct `Validator_Tree`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Stats_Validator_Tree">Validator_Tree</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>val_list: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>size: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>root: <a href="#0x0_Stats_TreeNode">Stats::TreeNode</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_Foo"></a>

## Struct `Foo`



<pre><code><b>struct</b> <a href="#0x0_Stats_Foo">Foo</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_Bar"></a>

## Struct `Bar`



<pre><code><b>struct</b> <a href="#0x0_Stats_Bar">Bar</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>x: u128</code>
</dt>
<dd>

</dd>
<dt>

<code>y: <a href="#0x0_Stats_Foo">Stats::Foo</a></code>
</dt>
<dd>

</dd>
<dt>

<code>z: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_Box"></a>

## Struct `Box`



<pre><code><b>struct</b> <a href="#0x0_Stats_Box">Box</a>&lt;T&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>x: T</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_State"></a>

## Struct `State`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Stats_State">State</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>hist: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_initialize">initialize</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_initialize">initialize</a>(  ){
  <b>let</b> a = 0;
  move_to_sender&lt;<a href="#0x0_Stats_State">State</a>&gt;(<a href="#0x0_Stats_State">State</a>{ hist: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>() });
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
}
</code></pre>



</details>

<a name="0x0_Stats_add_stuff"></a>

## Function `add_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_add_stuff">add_stuff</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_add_stuff">add_stuff</a>() <b>acquires</b> <a href="#0x0_Stats_State">State</a> {
  <b>let</b> st = borrow_global_mut&lt;<a href="#0x0_Stats_State">State</a>&gt;(Transaction::sender());
  <b>let</b> s = &<b>mut</b> st.hist;

  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 1);
  <b>let</b> a = 10;
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 2);
  a = 20;
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 3);
  a = 30;
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);

  <b>let</b> b = Transaction::sender();
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&b);
}
</code></pre>



</details>

<a name="0x0_Stats_remove_stuff"></a>

## Function `remove_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_remove_stuff">remove_stuff</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_remove_stuff">remove_stuff</a>() <b>acquires</b> <a href="#0x0_Stats_State">State</a>{
  <b>let</b> st = borrow_global_mut&lt;<a href="#0x0_Stats_State">State</a>&gt;(Transaction::sender());
  <b>let</b> s = *&st.hist;

  <b>let</b> a = <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(&<b>mut</b> s);
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
  a = <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(&<b>mut</b> s);
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
  a = <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(&<b>mut</b> s);
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);

  a = 255;
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);

  <b>let</b> b = Transaction::sender();
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&b);
}
</code></pre>



</details>

<a name="0x0_Stats_p_addr"></a>

## Function `p_addr`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_p_addr">p_addr</a>(a: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_p_addr">p_addr</a>(a: address){
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&a);
}
</code></pre>



</details>

<a name="0x0_Stats_test"></a>

## Function `test`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_test">test</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_test">test</a>()  {
    <b>let</b> x = 42;
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&x);

    <b>let</b> v = <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>();
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> v, 100);
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> v, 200);
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> v, 300);
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&v);

    <b>let</b> foo = <a href="#0x0_Stats_Foo">Foo</a> {};
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&foo);

    <b>let</b> bar = <a href="#0x0_Stats_Bar">Bar</a> { x: 404, y: <a href="#0x0_Stats_Foo">Foo</a> {}, z: <b>true</b> };
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&bar);

    <b>let</b> box = <a href="#0x0_Stats_Box">Box</a> { x: <a href="#0x0_Stats_Foo">Foo</a> {} };
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&box);

    <b>let</b> str = 12;
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&str);
}
</code></pre>



</details>
