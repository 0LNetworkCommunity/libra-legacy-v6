
<a name="0x1_ZKP"></a>

# Module `0x1::ZKP`



-  [Function `verify`](#0x1_ZKP_verify)


<pre><code></code></pre>



<a name="0x1_ZKP_verify"></a>

## Function `verify`



<pre><code><b>public</b> <b>fun</b> <a href="ZKP.md#0x1_ZKP_verify">verify</a>(proof_hex: &vector&lt;u8&gt;, public_input_json: &vector&lt;u8&gt;, parameters_json: &vector&lt;u8&gt;, annotation_file_name: &vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="ZKP.md#0x1_ZKP_verify">verify</a>(
  proof_hex:            &vector&lt;u8&gt;,
  public_input_json:    &vector&lt;u8&gt;,
  parameters_json:      &vector&lt;u8&gt;,
  annotation_file_name: &vector&lt;u8&gt;
) : bool;
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
