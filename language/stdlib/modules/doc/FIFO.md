
<a name="0x1_FIFO"></a>

# Module `0x1::FIFO`



-  [Struct `FIFO`](#0x1_FIFO_FIFO)
-  [Function `empty`](#0x1_FIFO_empty)
-  [Function `push`](#0x1_FIFO_push)
-  [Function `push_LIFO`](#0x1_FIFO_push_LIFO)
-  [Function `pop`](#0x1_FIFO_pop)
-  [Function `peek`](#0x1_FIFO_peek)
-  [Function `peek_mut`](#0x1_FIFO_peek_mut)
-  [Function `len`](#0x1_FIFO_len)
-  [Function `perform_swap`](#0x1_FIFO_perform_swap)


<pre><code><b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_FIFO_FIFO"></a>

## Struct `FIFO`



<pre><code><b>struct</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>incoming: vector&lt;Element&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>outgoing: vector&lt;Element&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_FIFO_empty"></a>

## Function `empty`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_empty">empty</a>&lt;Element&gt;(): <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_empty">empty</a>&lt;Element&gt;(): <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;{
    <b>let</b> incoming = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;Element&gt;();
    <b>let</b> outgoing = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;Element&gt;();
    <a href="FIFO.md#0x1_FIFO">FIFO</a> {
        incoming:incoming,
        outgoing:outgoing,
    }
}
</code></pre>



</details>

<a name="0x1_FIFO_push"></a>

## Function `push`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_push">push</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;, new_item: Element)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_push">push</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;, new_item: Element){
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;Element&gt;(&<b>mut</b> v.incoming, new_item);
}
</code></pre>



</details>

<a name="0x1_FIFO_push_LIFO"></a>

## Function `push_LIFO`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_push_LIFO">push_LIFO</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;, new_item: Element)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_push_LIFO">push_LIFO</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;, new_item: Element){
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;Element&gt;(&<b>mut</b> v.outgoing, new_item);
}
</code></pre>



</details>

<a name="0x1_FIFO_pop"></a>

## Function `pop`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_pop">pop</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;): Element
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_pop">pop</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;): Element{
    <a href="FIFO.md#0x1_FIFO_perform_swap">perform_swap</a>&lt;Element&gt;(v);
    //now pop from the outgoing queue
    <a href="Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>&lt;Element&gt;(&<b>mut</b> v.outgoing)
}
</code></pre>



</details>

<a name="0x1_FIFO_peek"></a>

## Function `peek`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_peek">peek</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;): &Element
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_peek">peek</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;): & Element{
    <a href="FIFO.md#0x1_FIFO_perform_swap">perform_swap</a>&lt;Element&gt;(v);

    <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(& v.outgoing);
    <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;Element&gt;(& v.outgoing, len - 1)
}
</code></pre>



</details>

<a name="0x1_FIFO_peek_mut"></a>

## Function `peek_mut`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_peek_mut">peek_mut</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;): &<b>mut</b> Element
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_peek_mut">peek_mut</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;): &<b>mut</b> Element{
    <a href="FIFO.md#0x1_FIFO_perform_swap">perform_swap</a>&lt;Element&gt;(v);

    <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(& v.outgoing);
    <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;Element&gt;(&<b>mut</b> v.outgoing, len - 1)
}
</code></pre>



</details>

<a name="0x1_FIFO_len"></a>

## Function `len`



<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_len">len</a>&lt;Element&gt;(v: &<a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FIFO.md#0x1_FIFO_len">len</a>&lt;Element&gt;(v: & <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;): u64{
    <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(& v.outgoing) + <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(& v.incoming)
}
</code></pre>



</details>

<a name="0x1_FIFO_perform_swap"></a>

## Function `perform_swap`



<pre><code><b>fun</b> <a href="FIFO.md#0x1_FIFO_perform_swap">perform_swap</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO_FIFO">FIFO::FIFO</a>&lt;Element&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="FIFO.md#0x1_FIFO_perform_swap">perform_swap</a>&lt;Element&gt;(v: &<b>mut</b> <a href="FIFO.md#0x1_FIFO">FIFO</a>&lt;Element&gt;) {
    <b>if</b> (<a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(& v.outgoing) == 0) {
        //TODO: Add a proper error here, can't pop from an empty <a href="FIFO.md#0x1_FIFO">FIFO</a>
        <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;Element&gt;(&v.incoming);
        <b>assert</b>(len &gt; 0, 1);
        //If outgoing is empty, pop all of incoming into outgoing
        <b>while</b> (len &gt; 0) {
            <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;Element&gt;(&<b>mut</b> v.outgoing,
                <a href="Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>&lt;Element&gt;(&<b>mut</b> v.incoming));
            len = len - 1;
        }
    };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
