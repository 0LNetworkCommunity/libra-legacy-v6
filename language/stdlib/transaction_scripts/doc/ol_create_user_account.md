
<a name="create_user_account"></a>

# Script `create_user_account`





<pre><code><b>use</b> <a href="../../modules/doc/GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_create_user_account.md#create_user_account">create_user_account</a>(_sender: &signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_create_user_account.md#create_user_account">create_user_account</a>(
  _sender: &signer,
  challenge: vector&lt;u8&gt;,
  solution: vector&lt;u8&gt;,
) {

  <b>let</b> new_account_address = <a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount_create_user_account_with_proof">LibraAccount::create_user_account_with_proof</a>(
    &challenge,
    &solution,
  );

  // Check the account <b>exists</b> and the balance is 0
  <b>assert</b>(<a href="../../modules/doc/LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="../../modules/doc/GAS.md#0x1_GAS">GAS</a>&gt;(new_account_address) == 0, 01);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
