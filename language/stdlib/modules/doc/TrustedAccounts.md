
<a name="0x1_TrustedAccounts"></a>

# Module `0x1::TrustedAccounts`

Functions to initialize, accumulated, and burn transaction fees.


-  [Resource `Trusted`](#0x1_TrustedAccounts_Trusted)
-  [Function `initialize`](#0x1_TrustedAccounts_initialize)
-  [Function `update`](#0x1_TrustedAccounts_update)
-  [Function `get_trusted`](#0x1_TrustedAccounts_get_trusted)


<pre><code><b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_TrustedAccounts_Trusted"></a>

## Resource `Trusted`



<pre><code><b>resource</b> <b>struct</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>my_trusted_accounts: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>follow_operators_trusting_accounts: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TrustedAccounts_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_initialize">initialize</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_initialize">initialize</a>(account: &signer) {
  move_to&lt;<a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>&gt;(account, <a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>{
    my_trusted_accounts: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    follow_operators_trusting_accounts: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>()
  });
}
</code></pre>



</details>

<a name="0x1_TrustedAccounts_update"></a>

## Function `update`



<pre><code><b>public</b> <b>fun</b> <b>update</b>(account: &signer, update_my: vector&lt;address&gt;, update_follow: vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <b>update</b>(account: &signer, update_my: vector&lt;address&gt;, update_follow: vector&lt;address&gt;) <b>acquires</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>{
  // TODO: Check <b>exists</b>
  // exists_at(payee)
  <b>let</b> state = borrow_global_mut&lt;<a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));
  state.my_trusted_accounts = update_my;
  state.follow_operators_trusting_accounts = update_follow;
}
</code></pre>



</details>

<a name="0x1_TrustedAccounts_get_trusted"></a>

## Function `get_trusted`



<pre><code><b>public</b> <b>fun</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_get_trusted">get_trusted</a>(account: address): (vector&lt;address&gt;, vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_get_trusted">get_trusted</a>(account: address): (vector&lt;address&gt;, vector&lt;address&gt;) <b>acquires</b> <a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>{
  <b>assert</b>(<b>exists</b>&lt;<a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>&gt;(account), 220101011000);
  <b>let</b> state = borrow_global&lt;<a href="TrustedAccounts.md#0x1_TrustedAccounts_Trusted">Trusted</a>&gt;(account);
  (*&state.my_trusted_accounts, *&state.follow_operators_trusting_accounts)
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
