
<a name="0x1_OracleScripts"></a>

# Module `0x1::OracleScripts`



-  [Function `ol_oracle_tx`](#0x1_OracleScripts_ol_oracle_tx)
-  [Function `ol_revoke_vote`](#0x1_OracleScripts_ol_revoke_vote)
-  [Function `ol_delegate_vote`](#0x1_OracleScripts_ol_delegate_vote)
-  [Function `ol_enable_delegation`](#0x1_OracleScripts_ol_enable_delegation)
-  [Function `ol_remove_delegation`](#0x1_OracleScripts_ol_remove_delegation)


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

<a name="0x1_OracleScripts_ol_revoke_vote"></a>

## Function `ol_revoke_vote`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_revoke_vote">ol_revoke_vote</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_revoke_vote">ol_revoke_vote</a>(sender: signer) {
    <a href="Oracle.md#0x1_Oracle_revoke_my_votes">Oracle::revoke_my_votes</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_OracleScripts_ol_delegate_vote"></a>

## Function `ol_delegate_vote`

A validator (Alice) can delegate the authority for the operation of an upgrade to another validator (Bob). When Oracle delegation happens, effectively the consensus voting power of Alice, is added to Bob only for the effect of calculating the preference on electing a stdlib binary. Whatever binary Bob proposes, Alice will also propose without needing to be submitting transactions.


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_delegate_vote">ol_delegate_vote</a>(sender: signer, dest: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_delegate_vote">ol_delegate_vote</a>(sender: signer, dest: address) {
    // <b>if</b> for some reason not delegated
    <a href="Oracle.md#0x1_Oracle_enable_delegation">Oracle::enable_delegation</a>(&sender);

    <a href="Oracle.md#0x1_Oracle_delegate_vote">Oracle::delegate_vote</a>(&sender, dest);
}
</code></pre>



</details>

<a name="0x1_OracleScripts_ol_enable_delegation"></a>

## Function `ol_enable_delegation`

First Bob must have delegation enabled, which can be done with:


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_enable_delegation">ol_enable_delegation</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_enable_delegation">ol_enable_delegation</a>(sender: signer) {
    <a href="Oracle.md#0x1_Oracle_enable_delegation">Oracle::enable_delegation</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_OracleScripts_ol_remove_delegation"></a>

## Function `ol_remove_delegation`

Alice can remove Bob as the delegate with this function.


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_remove_delegation">ol_remove_delegation</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_oracle.md#0x1_OracleScripts_ol_remove_delegation">ol_remove_delegation</a>(sender: signer) {
    <a href="Oracle.md#0x1_Oracle_remove_delegate_vote">Oracle::remove_delegate_vote</a>(&sender);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
