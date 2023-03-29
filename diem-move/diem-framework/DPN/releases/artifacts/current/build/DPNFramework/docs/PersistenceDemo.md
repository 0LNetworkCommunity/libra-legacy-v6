
<a name="0x1_PersistenceDemo"></a>

# Module `0x1::PersistenceDemo`



-  [Resource `State`](#0x1_PersistenceDemo_State)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_PersistenceDemo_initialize)
-  [Function `add_stuff`](#0x1_PersistenceDemo_add_stuff)
-  [Function `remove_stuff`](#0x1_PersistenceDemo_remove_stuff)
-  [Function `isEmpty`](#0x1_PersistenceDemo_isEmpty)
-  [Function `length`](#0x1_PersistenceDemo_length)
-  [Function `contains`](#0x1_PersistenceDemo_contains)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_PersistenceDemo_State"></a>

## Resource `State`



<pre><code><b>struct</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a> <b>has</b> key
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

<a name="@Constants_0"></a>

## Constants


<a name="0x1_PersistenceDemo_ETESTNET"></a>



<pre><code><b>const</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>: u64 = 4001;
</code></pre>



<a name="0x1_PersistenceDemo_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_initialize">initialize</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_initialize">initialize</a>(sender: &signer){
  // `<b>assert</b> can be used <b>to</b> evaluate a bool and exit the program <b>with</b>
  // an error code, e.g. testing <b>if</b> this is being run in testnet, and
  // throwing error 01.
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));
  // In the actual <b>module</b>, must <b>assert</b> that this is the sender is the association
  <b>move_to</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(sender, <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>{ hist: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>() });
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
<b>let</b> init_size = 0;
<b>ensures</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(<b>global</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(addr).hist) == init_size;
</code></pre>



</details>

<a name="0x1_PersistenceDemo_add_stuff"></a>

## Function `add_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_add_stuff">add_stuff</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_add_stuff">add_stuff</a>(sender: &signer) <b>acquires</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a> {
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));

  // Resource Struct state is always "borrowed" and "moved" and generally
  // cannot be copied. A <b>struct</b> can be mutably borrowed, <b>if</b> it is written <b>to</b>,
  // using `<b>borrow_global_mut</b>`. Note the Type <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>
  <b>let</b> st = <b>borrow_global_mut</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  // the `&` <b>as</b> in Rust makes the assignment <b>to</b> a borrowed value. Each
  // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> operation below <b>with</b> <b>use</b> a st.hist and <b>return</b> it before the
  // next one can execute.
  <b>let</b> s = &<b>mut</b> st.hist;

  // Move <b>has</b> very limited data types. <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> is the most sophisticated
  // and resembles a simplified Rust vector. Can be thought of <b>as</b> an array
  // of a single type.
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(s, 1);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(s, 2);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(s, 3);
}
</code></pre>



</details>

<a name="0x1_PersistenceDemo_remove_stuff"></a>

## Function `remove_stuff`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_remove_stuff">remove_stuff</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_remove_stuff">remove_stuff</a>(sender: &signer) <b>acquires</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>{
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));
  <b>let</b> st = <b>borrow_global_mut</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <b>let</b> s = &<b>mut</b> st.hist;

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(s);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>&lt;u8&gt;(s);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;u8&gt;(s, 0);
}
</code></pre>



</details>

<a name="0x1_PersistenceDemo_isEmpty"></a>

## Function `isEmpty`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_isEmpty">isEmpty</a>(sender: &signer): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_isEmpty">isEmpty</a>(sender: &signer): bool <b>acquires</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a> {
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));

  // Note this is not a mutable borrow. Read only.
  <b>let</b> st = <b>borrow_global</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&st.hist)
}
</code></pre>



</details>

<a name="0x1_PersistenceDemo_length"></a>

## Function `length`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_length">length</a>(sender: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_length">length</a>(sender: &signer): u64 <b>acquires</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>{
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));
  <b>let</b> st = <b>borrow_global</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&st.hist)
}
</code></pre>



</details>

<a name="0x1_PersistenceDemo_contains"></a>

## Function `contains`



<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_contains">contains</a>(sender: &signer, num: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_contains">contains</a>(sender: &signer, num: u8): bool <b>acquires</b> <a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a> {
  <b>assert</b>!(is_testnet(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PersistenceDemo.md#0x1_PersistenceDemo_ETESTNET">ETESTNET</a>));
  <b>let</b> st = <b>borrow_global</b>&lt;<a href="PersistenceDemo.md#0x1_PersistenceDemo_State">State</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&st.hist, &num)
}
</code></pre>



</details>
