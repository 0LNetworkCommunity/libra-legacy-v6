
<a name="0x1_Audit"></a>

# Module `0x1::Audit`



-  [Function `val_audit_passing`](#0x1_Audit_val_audit_passing)
-  [Function `test_helper_make_passing`](#0x1_Audit_test_helper_make_passing)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>



<a name="0x1_Audit_val_audit_passing"></a>

## Function `val_audit_passing`



<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_val_audit_passing">val_audit_passing</a>(val: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_val_audit_passing">val_audit_passing</a>(val: <b>address</b>): bool {
  // <b>has</b> valid configs
  <b>if</b> (!<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(val)) <b>return</b> <b>false</b>;
  // <b>has</b> operator account set <b>to</b> another <b>address</b>
  <b>let</b> oper = <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(val);
  <b>if</b> (oper == val) <b>return</b> <b>false</b>;
  // operator account <b>has</b> balance
  // <b>if</b> (<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(oper) &lt; 50000 && !<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) <b>return</b> <b>false</b>;
  // <b>has</b> autopay enabled
  <b>if</b> (!<a href="AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(val)) <b>return</b> <b>false</b>;
  // <b>has</b> mining state
  <b>if</b> (!<a href="TowerState.md#0x1_TowerState_is_init">TowerState::is_init</a>(val)) <b>return</b> <b>false</b>;
  // is a slow wallet
  <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(val)) <b>return</b> <b>false</b>;

  // TODO: <b>has</b> network settings for validator

  <b>true</b>
}
</code></pre>



</details>

<a name="0x1_Audit_test_helper_make_passing"></a>

## Function `test_helper_make_passing`



<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_test_helper_make_passing">test_helper_make_passing</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_test_helper_make_passing">test_helper_make_passing</a>(account: &signer){
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 1905001);
  <a href="AutoPay.md#0x1_AutoPay_enable_autopay">AutoPay::enable_autopay</a>(account);
}
</code></pre>



</details>
