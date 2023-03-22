
<a name="0x1_BurnScript"></a>

# Module `0x1::BurnScript`



-  [Function `set_burn_pref`](#0x1_BurnScript_set_burn_pref)


<pre><code><b>use</b> <a href="Burn.md#0x1_Burn">0x1::Burn</a>;
</code></pre>



<a name="0x1_BurnScript_set_burn_pref"></a>

## Function `set_burn_pref`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_burn_pref.md#0x1_BurnScript_set_burn_pref">set_burn_pref</a>(sender: signer, to_community: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_burn_pref.md#0x1_BurnScript_set_burn_pref">set_burn_pref</a>(sender: signer, to_community: bool) {
    <a href="Burn.md#0x1_Burn_set_send_community">Burn::set_send_community</a>(&sender, to_community);
}
</code></pre>



</details>
