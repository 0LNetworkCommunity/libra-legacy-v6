
<a name="0x1_GenesisMigration"></a>

# Module `0x1::GenesisMigration`



-  [Function `migrate_user`](#0x1_GenesisMigration_migrate_user)
-  [Function `are_you_a_val_or_oper`](#0x1_GenesisMigration_are_you_a_val_or_oper)


<pre><code><b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig">0x1::ValidatorOperatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
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
  // <b>if</b> not a validator OR operator of a validator, create a new account
  // previously at genesis validator and oper accounts were already created
  <b>if</b> (!<a href="GenesisMigration.md#0x1_GenesisMigration_are_you_a_val_or_oper">are_you_a_val_or_oper</a>(user_addr)) {
    <a href="DiemAccount.md#0x1_DiemAccount_vm_create_account_migration">DiemAccount::vm_create_account_migration</a>(
      vm,
      user_addr,
      auth_key,
    );
  };


  // mint coins again <b>to</b> migrate balance, and all
  // system tracking of balances
  <b>if</b> (balance &lt; 1) {
    <b>return</b>
  };
  <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, balance);
  <b>let</b> value_coin = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&minted_coins);
  <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    vm,
    user_addr,
    minted_coins,
    b"genesis migration",
    b""
  );

  <b>let</b> balance = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(user_addr);
  <b>assert</b>!(balance == value_coin, 0);
}
</code></pre>



</details>

<a name="0x1_GenesisMigration_are_you_a_val_or_oper"></a>

## Function `are_you_a_val_or_oper`



<pre><code><b>fun</b> <a href="GenesisMigration.md#0x1_GenesisMigration_are_you_a_val_or_oper">are_you_a_val_or_oper</a>(user_addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="GenesisMigration.md#0x1_GenesisMigration_are_you_a_val_or_oper">are_you_a_val_or_oper</a>(user_addr: <b>address</b>): bool {
  <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(user_addr) ||
  <a href="ValidatorOperatorConfig.md#0x1_ValidatorOperatorConfig_has_validator_operator_config">ValidatorOperatorConfig::has_validator_operator_config</a>(user_addr)
}
</code></pre>



</details>
