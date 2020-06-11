
<a name="0x0_PersistenceTrial"></a>

# Module `0x0::PersistenceTrial`

### Table of Contents

-  [Struct `State`](#0x0_PersistenceTrial_State)
-  [Function `initialize`](#0x0_PersistenceTrial_initialize)
-  [Function `add_stuff`](#0x0_PersistenceTrial_add_stuff)
-  [Function `remove_stuff`](#0x0_PersistenceTrial_remove_stuff)
-  [Function `isEmpty`](#0x0_PersistenceTrial_isEmpty)
-  [Function `length`](#0x0_PersistenceTrial_length)
-  [Function `contains`](#0x0_PersistenceTrial_contains)



<a name="0x0_PersistenceTrial_State"></a>

## Struct `State`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_PersistenceTrial_State">State</a>
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

<a name="0x0_PersistenceTrial_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_initialize">initialize</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_initialize">initialize</a>(){
  // In the actual <b>module</b>, must <b>assert</b> that this is the sender is the association
  move_to_sender&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(<a href="#0x0_PersistenceTrial_State">State</a>{ hist: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>() });
}
</code></pre>



</details>

<a name="0x0_PersistenceTrial_add_stuff"></a>

## Function `add_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_add_stuff">add_stuff</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_add_stuff">add_stuff</a>() <b>acquires</b> <a href="#0x0_PersistenceTrial_State">State</a> {
  <b>let</b> st = borrow_global_mut&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(Transaction::sender());
  <b>let</b> s = &<b>mut</b> st.hist;

  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 1);
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 2);
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(s, 3);
}
</code></pre>



</details>

<a name="0x0_PersistenceTrial_remove_stuff"></a>

## Function `remove_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_remove_stuff">remove_stuff</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_remove_stuff">remove_stuff</a>() <b>acquires</b> <a href="#0x0_PersistenceTrial_State">State</a>{
  <b>let</b> st = borrow_global_mut&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(Transaction::sender());
  <b>let</b> s = &<b>mut</b> st.hist;

  <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(s);
  <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(s);
  <a href="Vector.md#0x0_Vector_remove">Vector::remove</a>&lt;u8&gt;(s, 0);
}
</code></pre>



</details>

<a name="0x0_PersistenceTrial_isEmpty"></a>

## Function `isEmpty`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_isEmpty">isEmpty</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_isEmpty">isEmpty</a>(): bool <b>acquires</b> <a href="#0x0_PersistenceTrial_State">State</a> {
  <b>let</b> st = borrow_global&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(Transaction::sender());
  <a href="Vector.md#0x0_Vector_is_empty">Vector::is_empty</a>(&st.hist)
}
</code></pre>



</details>

<a name="0x0_PersistenceTrial_length"></a>

## Function `length`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_length">length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_length">length</a>(): u64 <b>acquires</b> <a href="#0x0_PersistenceTrial_State">State</a>{
  <b>let</b> st = borrow_global&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(Transaction::sender());
  <a href="Vector.md#0x0_Vector_length">Vector::length</a>(&st.hist)
}
</code></pre>



</details>

<a name="0x0_PersistenceTrial_contains"></a>

## Function `contains`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_contains">contains</a>(num: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_PersistenceTrial_contains">contains</a>(num: u8): bool <b>acquires</b> <a href="#0x0_PersistenceTrial_State">State</a> {
  <b>let</b> st = borrow_global&lt;<a href="#0x0_PersistenceTrial_State">State</a>&gt;(Transaction::sender());
  <a href="Vector.md#0x0_Vector_contains">Vector::contains</a>(&st.hist, &num)
}
</code></pre>



</details>
