
<a name="0x1_VectorHelper"></a>

# Module `0x1::VectorHelper`



-  [Function `compare`](#0x1_VectorHelper_compare)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_VectorHelper_compare"></a>

## Function `compare`



<pre><code><b>public</b> <b>fun</b> <a href="VectorHelper.md#0x1_VectorHelper_compare">compare</a>&lt;Element&gt;(a: &vector&lt;Element&gt;, b: &vector&lt;Element&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VectorHelper.md#0x1_VectorHelper_compare">compare</a>&lt;Element&gt;(a: &vector&lt;Element&gt;, b: &vector&lt;Element&gt;): bool {
    <b>let</b> i = 0;
    <b>let</b> len_a = length(a);
    <b>let</b> len_b = length(b);
    <b>if</b> (len_a != len_b) { <b>return</b> <b>false</b> };
    <b>while</b> (i &lt; len_a) {
        <b>let</b> num_a = borrow(a, i);
        <b>let</b> num_b = borrow(b, i);
        <b>if</b> (num_a == num_b) {
            i = i + 1;
        } <b>else</b> {
            <b>return</b> <b>false</b>
        }
    };
    <b>true</b>
}
</code></pre>



</details>
