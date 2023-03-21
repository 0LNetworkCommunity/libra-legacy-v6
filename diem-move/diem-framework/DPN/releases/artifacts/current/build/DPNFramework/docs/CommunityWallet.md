
<a name="0x1_CommunityWallet"></a>

# Module `0x1::CommunityWallet`

This module is used to dynamically check if an account qualifies for the CommunityWallet flag.
Community Wallet is a flag that can be applied to an account.
These accounts are voluntarily creating a number of restrictions and guarantees for users that interact with it.
In essence, a group of people may set up a wallet with these characteristics to provide funding for a common program.
For example the matching donation game, which validators provide with burns from their account will check that a destination account has a Community Wallet Flag.
The CommunityWallets will have the following properties enabled by their owners.
0. This wallet is initialized as a DonorDirected account. This means that it observes the policies of those accounts: namely, that the donors have Veto rights over the transactions which are proposed by the Owners of the account. Repeated rejections or an outright freeze poll, will prevent the Owners from transferring funds, and may ultimately revert the funds to a different community account (or burn).
!. They have instantiated a MultiSig controller, which means that actions on this wallet can only be done by an n-of-m consensus by the authorities of the account. Plus, the nominal credentials which created the account cannot be used, since the keys will no longer be valid.
2. The Multisig account holders do not have common Ancestry. This is important to prevent an account holder from trivially creating sybil accounts to qualify as a community wallet. Sybils are possibly without common Ancestry, but it is much harder.
3. The multisig account has a minimum of 5 Authorities, and a threshold of 3 signatures. If there are more authorities, a 3/5 ratio or more should be preserved.


-  [Constants](#@Constants_0)
-  [Function `is_community_wallet`](#0x1_CommunityWallet_is_community_wallet)
-  [Function `is_frozen`](#0x1_CommunityWallet_is_frozen)
-  [Function `is_pending_liquidation`](#0x1_CommunityWallet_is_pending_liquidation)
-  [Function `is_comm`](#0x1_CommunityWallet_is_comm)
-  [Function `new_timed_transfer`](#0x1_CommunityWallet_new_timed_transfer)


<pre><code><b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_CommunityWallet_ENOT_AUTHORIZED"></a>



<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>: u64 = 23;
</code></pre>



<a name="0x1_CommunityWallet_is_community_wallet"></a>

## Function `is_community_wallet`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_community_wallet">is_community_wallet</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_community_wallet">is_community_wallet</a>() {

  // <b>has</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> instantiated

  // <b>has</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment">MultiSigPayment</a> instantiated

  // multisig <b>has</b> 3/5 threshold, and minimum 3 and 5.

  // the multisig authorities are unrelated per <a href="Ancestry.md#0x1_Ancestry">Ancestry</a>

}
</code></pre>



</details>

<a name="0x1_CommunityWallet_is_frozen"></a>

## Function `is_frozen`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_frozen">is_frozen</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_frozen">is_frozen</a>() {

}
</code></pre>



</details>

<a name="0x1_CommunityWallet_is_pending_liquidation"></a>

## Function `is_pending_liquidation`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_pending_liquidation">is_pending_liquidation</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_pending_liquidation">is_pending_liquidation</a>() {

}
</code></pre>



</details>

<a name="0x1_CommunityWallet_is_comm"></a>

## Function `is_comm`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">is_comm</a>(_addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">is_comm</a>(_addr: <b>address</b>): bool {
  <b>true</b>
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_new_timed_transfer"></a>

## Function `new_timed_transfer`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_new_timed_transfer">new_timed_transfer</a>(sender: &signer, multisig_wallet: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_new_timed_transfer">new_timed_transfer</a>(
  sender: &signer, multisig_wallet: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;
): u64  {
  // firstly check <b>if</b> payee is a slow wallet
  // TODO: This function should check <b>if</b> the account is a slow wallet before sending
  // but there's a circular dependency <b>with</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> which <b>has</b> the slow wallet <b>struct</b>.
  // curretly we <b>move</b> that check <b>to</b> the transaction <b>script</b> <b>to</b> initialize the payment.
  // <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(payee), EIS_NOT_SLOW_WALLET);

  // <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // <b>let</b> list = get_comm_list();
  <b>assert</b>!(
    <a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">is_comm</a>(multisig_wallet),
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>)
  );

  <a href="DonorDirected.md#0x1_DonorDirected_new_timed_transfer">DonorDirected::new_timed_transfer</a>(sender, payee, value, description)
}
</code></pre>



</details>
