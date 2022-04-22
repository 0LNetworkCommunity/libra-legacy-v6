
<a name="0x1_WalletScripts"></a>

# Module `0x1::WalletScripts`



-  [Function `init_struct`](#0x1_WalletScripts_init_struct)
-  [Function `vouch_for`](#0x1_WalletScripts_vouch_for)


<pre><code><b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
</code></pre>



<a name="0x1_WalletScripts_init_struct"></a>

## Function `init_struct`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_WalletScripts_init_struct">init_struct</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_WalletScripts_init_struct">init_struct</a>(sender: signer) {
  <a href="Vouch.md#0x1_Vouch_init">Vouch::init</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_WalletScripts_vouch_for"></a>

## Function `vouch_for`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_WalletScripts_vouch_for">vouch_for</a>(sender: signer, val: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_vouch_for.md#0x1_WalletScripts_vouch_for">vouch_for</a>(sender: signer, val: address) {
  <a href="Vouch.md#0x1_Vouch_vouch_for">Vouch::vouch_for</a>(&sender, val);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
