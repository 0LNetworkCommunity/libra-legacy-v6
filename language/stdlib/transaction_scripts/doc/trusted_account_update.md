
<a name="trusted_account_update_tx"></a>

# Script `trusted_account_update_tx`





<pre><code><b>use</b> <a href="../../modules/doc/Debug.md#0x1_Debug">0x1::Debug</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="trusted_account_update.md#trusted_account_update_tx">trusted_account_update_tx</a>(world: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trusted_account_update.md#trusted_account_update_tx">trusted_account_update_tx</a>(world: u64) {
    print(&0x0000000000000000000000000011e110); // Hello!
    print(&world); // World!
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
