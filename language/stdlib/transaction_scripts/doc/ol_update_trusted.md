
<a name="update_trusted"></a>

# Script `update_trusted`





<pre><code><b>use</b> <a href="../../modules/doc/TrustedAccounts.md#0x1_TrustedAccounts">0x1::TrustedAccounts</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_update_trusted.md#update_trusted">update_trusted</a>(account: &signer, vec_my: vector&lt;address&gt;, vec_follow: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_update_trusted.md#update_trusted">update_trusted</a> (account: &signer, vec_my: vector&lt;address&gt;, vec_follow: vector&lt;address&gt;) {
    <a href="../../modules/doc/TrustedAccounts.md#0x1_TrustedAccounts_update">TrustedAccounts::update</a>(
        account,
        vec_my, //update_my
        vec_follow, //update_follow
    );
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
