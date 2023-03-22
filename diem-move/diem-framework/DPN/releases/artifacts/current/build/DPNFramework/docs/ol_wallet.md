
<a name="0x1_WalletScripts"></a>

# Module `0x1::WalletScripts`



-  [Function `set_wallet_type`](#0x1_WalletScripts_set_wallet_type)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
</code></pre>



<a name="0x1_WalletScripts_set_wallet_type"></a>

## Function `set_wallet_type`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_wallet.md#0x1_WalletScripts_set_wallet_type">set_wallet_type</a>(sender: signer, type_of: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_wallet.md#0x1_WalletScripts_set_wallet_type">set_wallet_type</a>(sender: signer, type_of: u8) {
  <b>if</b> (type_of == 0) {
    <a href="DiemAccount.md#0x1_DiemAccount_set_slow">DiemAccount::set_slow</a>(&sender);
  };

  <b>if</b> (type_of == 1) {
      <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">DonorDirected::set_donor_directed</a>(&sender);
  };
}
</code></pre>



</details>
