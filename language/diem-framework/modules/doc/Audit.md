
<a name="0x1_Audit"></a>

# Module `0x1::Audit`



-  [Function `val_audit_passing`](#0x1_Audit_val_audit_passing)
-  [Function `test_helper_make_passing`](#0x1_Audit_test_helper_make_passing)


<pre><code><b>use</b> <a href="AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
</code></pre>



<a name="0x1_Audit_val_audit_passing"></a>

## Function `val_audit_passing`



<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_val_audit_passing">val_audit_passing</a>(val: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Audit.md#0x1_Audit_val_audit_passing">val_audit_passing</a>(val: address): bool {
  print(&11111);
  print(&val);

  // has valid configs
  <b>if</b> (!<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(val)) <b>return</b> <b>false</b>;
  // has operator account set <b>to</b> another address
  <b>let</b> oper = <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(val);
  <b>if</b> (oper == val) <b>return</b> <b>false</b>;
  // operator account has balance
  // has mining state
  <b>if</b> (!<a href="TowerState.md#0x1_TowerState_is_init">TowerState::is_init</a>(val)) <b>return</b> <b>false</b>;
  print(&111110003);

  // is a slow wallet
  <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(val)) <b>return</b> <b>false</b>;
  print(&111110004);

  // <b>if</b> (!<a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">Vouch::unrelated_buddies_above_thresh</a>(val)) <b>return</b> <b>false</b>;
  // print(&111110005);

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
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 1905001);
  <a href="AutoPay.md#0x1_AutoPay_enable_autopay">AutoPay::enable_autopay</a>(account);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
