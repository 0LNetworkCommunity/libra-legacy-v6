
<a name="0x1_GenesisMigration"></a>

# Module `0x1::GenesisMigration`



-  [Function `migrate_user`](#0x1_GenesisMigration_migrate_user)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
</code></pre>



<a name="0x1_GenesisMigration_migrate_user"></a>

## Function `migrate_user`

Called by root in genesis to initialize the GAS coin


<pre><code><b>public</b> <b>fun</b> <a href="GenesisMigration.md#0x1_GenesisMigration_migrate_user">migrate_user</a>(vm: &signer, user_addr: <b>address</b>, auth_key: vector&lt;u8&gt;, balance: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="GenesisMigration.md#0x1_GenesisMigration_migrate_user">migrate_user</a>(
    vm: &signer,
    user_addr: <b>address</b>,
    auth_key: vector&lt;u8&gt;,
    balance: u64,
) {
  <a href="DiemAccount.md#0x1_DiemAccount_create_user_account_with_coin">DiemAccount::create_user_account_with_coin</a>(
    vm,
    user_addr,
    auth_key,
    balance
  );
}
</code></pre>



</details>
