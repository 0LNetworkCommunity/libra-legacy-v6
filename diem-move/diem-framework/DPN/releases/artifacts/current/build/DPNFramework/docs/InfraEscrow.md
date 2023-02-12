
<a name="0x1_InfraEscrow"></a>

# Module `0x1::InfraEscrow`



-  [Function `initialize_infra_pledge`](#0x1_InfraEscrow_initialize_infra_pledge)
-  [Function `infra_pledge_withdraw`](#0x1_InfraEscrow_infra_pledge_withdraw)
-  [Function `user_pledge_tx`](#0x1_InfraEscrow_user_pledge_tx)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts">0x1::PledgeAccounts</a>;
</code></pre>



<a name="0x1_InfraEscrow_initialize_infra_pledge"></a>

## Function `initialize_infra_pledge`

for use on genesis, creates the infra escrow pledge policy struct


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_initialize_infra_pledge">initialize_infra_pledge</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_initialize_infra_pledge">initialize_infra_pledge</a>(vm: &signer) {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    // TODO: perhaps this policy needs <b>to</b> be published <b>to</b> a different <b>address</b>?
    <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">PledgeAccounts::publish_beneficiary_policy</a>(
      vm, // only VM calls at genesis
      b"infra escrow",
      90,
      <b>true</b>
    );
}
</code></pre>



</details>

<a name="0x1_InfraEscrow_infra_pledge_withdraw"></a>

## Function `infra_pledge_withdraw`

VM can call down pledged funds.


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_infra_pledge_withdraw">infra_pledge_withdraw</a>(vm: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_infra_pledge_withdraw">infra_pledge_withdraw</a>(vm: &signer, amount: u64) {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">PledgeAccounts::withdraw_from_all_pledge_accounts</a>(vm, amount);
}
</code></pre>



</details>

<a name="0x1_InfraEscrow_user_pledge_tx"></a>

## Function `user_pledge_tx`

for end users to pledge to the infra escrow


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_user_pledge_tx">user_pledge_tx</a>(user_sig: signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_user_pledge_tx">user_pledge_tx</a>(user_sig: signer, amount: u64) {
  <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">PledgeAccounts::create_pledge_account</a>(&user_sig, @VMReserved, amount);
}
</code></pre>



</details>
