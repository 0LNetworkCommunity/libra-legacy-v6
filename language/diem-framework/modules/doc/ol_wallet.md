
<a name="0x1_WalletScripts"></a>

# Module `0x1::WalletScripts`



-  [Function `set_wallet_type`](#0x1_WalletScripts_set_wallet_type)


<pre><code><b>use</b> <a href="Wallet.md#0x1_Wallet">0x1::Wallet</a>;
</code></pre>



<a name="0x1_WalletScripts_set_wallet_type"></a>

## Function `set_wallet_type`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_wallet.md#0x1_WalletScripts_set_wallet_type">set_wallet_type</a>(sender: signer, type_of: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_wallet.md#0x1_WalletScripts_set_wallet_type">set_wallet_type</a>(sender: signer, type_of: u8) {
  <b>if</b> (type_of == 0) {
    <a href="Wallet.md#0x1_Wallet_set_slow">Wallet::set_slow</a>(&sender);
  };

  <b>if</b> (type_of == 1) {
      <a href="Wallet.md#0x1_Wallet_set_comm">Wallet::set_comm</a>(&sender);
  };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
