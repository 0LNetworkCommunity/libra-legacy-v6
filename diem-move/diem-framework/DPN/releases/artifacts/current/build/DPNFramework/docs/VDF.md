
<a name="0x1_VDF"></a>

# Module `0x1::VDF`



-  [Function `verify`](#0x1_VDF_verify)
-  [Function `extract_address_from_challenge`](#0x1_VDF_extract_address_from_challenge)


<pre><code></code></pre>



<a name="0x1_VDF_verify"></a>

## Function `verify`



<pre><code><b>public</b> <b>fun</b> <a href="VDF.md#0x1_VDF_verify">verify</a>(challenge: &vector&lt;u8&gt;, solution: &vector&lt;u8&gt;, difficulty: &u64, security: &u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="VDF.md#0x1_VDF_verify">verify</a>(
  challenge: &vector&lt;u8&gt;,
  solution: &vector&lt;u8&gt;,
  difficulty: &u64,
  security: &u64,
): bool;
</code></pre>



</details>

<a name="0x1_VDF_extract_address_from_challenge"></a>

## Function `extract_address_from_challenge`



<pre><code><b>public</b> <b>fun</b> <a href="VDF.md#0x1_VDF_extract_address_from_challenge">extract_address_from_challenge</a>(challenge: &vector&lt;u8&gt;): (<b>address</b>, vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="VDF.md#0x1_VDF_extract_address_from_challenge">extract_address_from_challenge</a>(challenge: &vector&lt;u8&gt;): (<b>address</b>, vector&lt;u8&gt;);
</code></pre>



</details>
