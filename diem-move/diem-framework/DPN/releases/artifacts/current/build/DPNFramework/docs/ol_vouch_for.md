
<a name="0x1_VouchScripts"></a>

# Module `0x1::VouchScripts`



-  [Function `init_vouch`](#0x1_VouchScripts_init_vouch)
-  [Function `vouch_for`](#0x1_VouchScripts_vouch_for)
-  [Function `revoke_vouch`](#0x1_VouchScripts_revoke_vouch)


<pre><code><b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
</code></pre>



<a name="0x1_VouchScripts_init_vouch"></a>

## Function `init_vouch`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_init_vouch">init_vouch</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_init_vouch">init_vouch</a>(sender: signer) {
  <a href="Vouch.md#0x1_Vouch_init">Vouch::init</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_VouchScripts_vouch_for"></a>

## Function `vouch_for`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_vouch_for">vouch_for</a>(sender: signer, val: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_vouch_for">vouch_for</a>(sender: signer, val: <b>address</b>) {
  <a href="Vouch.md#0x1_Vouch_vouch_for">Vouch::vouch_for</a>(&sender, val);
}
</code></pre>



</details>

<a name="0x1_VouchScripts_revoke_vouch"></a>

## Function `revoke_vouch`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_revoke_vouch">revoke_vouch</a>(sender: signer, val: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_VouchScripts_revoke_vouch">revoke_vouch</a>(sender: signer, val: <b>address</b>) {
  <a href="Vouch.md#0x1_Vouch_revoke">Vouch::revoke</a>(&sender, val);
}
</code></pre>



</details>
