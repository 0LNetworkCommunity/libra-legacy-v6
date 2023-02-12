
<a name="0x1_GenesisMigration"></a>

# Module `0x1::GenesisMigration`



-  [Function `migrate_user`](#0x1_GenesisMigration_migrate_user)


<pre><code><b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
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
  // <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, balance);
  // <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
  //   vm,
  //   @VMReserved,
  //   minted_coins,
  //   b"genesis_migration",
  //   b""
  // );

  <a href="DiemAccount.md#0x1_DiemAccount_vm_create_account_migration">DiemAccount::vm_create_account_migration</a>(
    vm,
    user_addr,
    auth_key,
    // balance
  );

  <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, balance);
  <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    vm,
    user_addr,
    minted_coins,
    b"genesis migration",
    b""
  );
}
</code></pre>



</details>
