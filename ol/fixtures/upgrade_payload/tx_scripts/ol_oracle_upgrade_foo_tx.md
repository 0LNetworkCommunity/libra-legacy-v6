
<a name="ol_oracle_upgrade_foo_tx"></a>

# Script `ol_oracle_upgrade_foo_tx`





<pre><code><b>use</b> <a href="../../modules/doc/Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="../../modules/doc/Upgrade.md#0x1_Upgrade">0x1::Upgrade</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_oracle_upgrade_foo_tx.md#ol_oracle_upgrade_foo_tx">ol_oracle_upgrade_foo_tx</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_oracle_upgrade_foo_tx.md#ol_oracle_upgrade_foo_tx">ol_oracle_upgrade_foo_tx</a> () {
    print(&0x000000000000000000000000000be110); // Bello!
    <a href="../../modules/doc/Upgrade.md#0x1_Upgrade_foo">Upgrade::foo</a>();
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
