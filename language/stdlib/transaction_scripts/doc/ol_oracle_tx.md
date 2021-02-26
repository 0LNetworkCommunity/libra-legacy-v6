
<a name="ol_oracle_tx"></a>

# Script `ol_oracle_tx`





<pre><code><b>use</b> <a href="../../modules/doc/Oracle.md#0x1_Oracle">0x1::Oracle</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_oracle_tx.md#ol_oracle_tx">ol_oracle_tx</a>(sender: &signer, id: u64, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_oracle_tx.md#ol_oracle_tx">ol_oracle_tx</a>(sender: &signer, id: u64, data: vector&lt;u8&gt;) {
    <a href="../../modules/doc/Oracle.md#0x1_Oracle_handler">Oracle::handler</a>(sender, id, data);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
