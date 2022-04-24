
<a name="0x1_EthSignature"></a>

# Module `0x1::EthSignature`



-  [Function `recover`](#0x1_EthSignature_recover)
-  [Function `verify`](#0x1_EthSignature_verify)


<pre><code></code></pre>



<a name="0x1_EthSignature_recover"></a>

## Function `recover`



<pre><code><b>public</b> <b>fun</b> <a href="EthSignature.md#0x1_EthSignature_recover">recover</a>(signature: vector&lt;u8&gt;, message: vector&lt;u8&gt;): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="EthSignature.md#0x1_EthSignature_recover">recover</a>(signature: vector&lt;u8&gt;, message: vector&lt;u8&gt;): vector&lt;u8&gt;;
</code></pre>



</details>

<a name="0x1_EthSignature_verify"></a>

## Function `verify`



<pre><code><b>public</b> <b>fun</b> <a href="EthSignature.md#0x1_EthSignature_verify">verify</a>(signature: vector&lt;u8&gt;, pubkey: vector&lt;u8&gt;, message: vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="EthSignature.md#0x1_EthSignature_verify">verify</a>(signature: vector&lt;u8&gt;, pubkey: vector&lt;u8&gt;, message: vector&lt;u8&gt;): bool;
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
