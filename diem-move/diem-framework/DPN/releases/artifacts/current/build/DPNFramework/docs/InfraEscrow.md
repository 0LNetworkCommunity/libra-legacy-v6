
<a name="0x1_InfraEscrow"></a>

# Module `0x1::InfraEscrow`



-  [Function `initialize_infra_pledge`](#0x1_InfraEscrow_initialize_infra_pledge)
-  [Function `infra_pledge_withdraw`](#0x1_InfraEscrow_infra_pledge_withdraw)
-  [Function `epoch_boundary_collection`](#0x1_InfraEscrow_epoch_boundary_collection)
-  [Function `user_pledge_infra`](#0x1_InfraEscrow_user_pledge_infra)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts">0x1::PledgeAccounts</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
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


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_infra_pledge_withdraw">infra_pledge_withdraw</a>(vm: &signer, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_infra_pledge_withdraw">infra_pledge_withdraw</a>(vm: &signer, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt; {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">PledgeAccounts::withdraw_from_all_pledge_accounts</a>(vm, amount)
}
</code></pre>



</details>

<a name="0x1_InfraEscrow_epoch_boundary_collection"></a>

## Function `epoch_boundary_collection`

Helper for epoch boundaries.
Collects funds from pledge and places temporarily in network account (TransactionFee account)


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_epoch_boundary_collection">epoch_boundary_collection</a>(vm: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_epoch_boundary_collection">epoch_boundary_collection</a>(vm: &signer, amount: u64) {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>let</b> opt = <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">PledgeAccounts::withdraw_from_all_pledge_accounts</a>(vm, amount);
    // print(&opt);
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(&opt)) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(opt);
      <b>return</b>
    };
    <b>let</b> c = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> opt);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(opt);

    <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">TransactionFee::pay_fee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(c);
}
</code></pre>



</details>

<a name="0x1_InfraEscrow_user_pledge_infra"></a>

## Function `user_pledge_infra`



<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_user_pledge_infra">user_pledge_infra</a>(user_sig: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="InfraEscrow.md#0x1_InfraEscrow_user_pledge_infra">user_pledge_infra</a>(user_sig: &signer, amount: u64){

  <a href="PledgeAccounts.md#0x1_PledgeAccounts_user_pledge">PledgeAccounts::user_pledge</a>(user_sig, @VMReserved, amount);
}
</code></pre>



</details>
