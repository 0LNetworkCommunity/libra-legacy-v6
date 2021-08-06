
<a name="0x1_OracleScripts"></a>

# Module `0x1::OracleScripts`



-  [Function `ol_oracle_tx`](#0x1_OracleScripts_ol_oracle_tx)


<pre><code><b>use</b> <a href="Oracle.md#0x1_Oracle">0x1::Oracle</a>;
</code></pre>



<a name="0x1_OracleScripts_ol_oracle_tx"></a>

## Function `ol_oracle_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_oracle_tx">ol_oracle_tx</a>(sender: signer, id: u64, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_oracle_tx">ol_oracle_tx</a>(sender: signer, id: u64, data: vector&lt;u8&gt;) {
    <a href="Oracle.md#0x1_Oracle_handler">Oracle::handler</a>(&sender, id, data);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
