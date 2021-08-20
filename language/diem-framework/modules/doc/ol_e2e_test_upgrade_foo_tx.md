
<a name="0x1_OracleUpgradeFooTx"></a>

# Module `0x1::OracleUpgradeFooTx`



-  [Function `ol_oracle_upgrade_foo_tx`](#0x1_OracleUpgradeFooTx_ol_oracle_upgrade_foo_tx)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="Upgrade.md#0x1_Upgrade">0x1::Upgrade</a>;
</code></pre>



<a name="0x1_OracleUpgradeFooTx_ol_oracle_upgrade_foo_tx"></a>

## Function `ol_oracle_upgrade_foo_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_e2e_test_upgrade_foo_tx.md#0x1_OracleUpgradeFooTx_ol_oracle_upgrade_foo_tx">ol_oracle_upgrade_foo_tx</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_e2e_test_upgrade_foo_tx.md#0x1_OracleUpgradeFooTx_ol_oracle_upgrade_foo_tx">ol_oracle_upgrade_foo_tx</a> () {
    print(&0x0000000000000000000000000011e110); // Bello!
    <a href="Upgrade.md#0x1_Upgrade_foo">Upgrade::foo</a>();
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
