
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
4. CommunityWallets have a high threshold for sybils: all multisig authorities must be unrelated in their permission trees, per Ancestry.


-  [Resource `CommunityWallet`](#0x1_CommunityWallet_CommunityWallet)
-  [Constants](#@Constants_0)
-  [Function `is_init`](#0x1_CommunityWallet_is_init)
-  [Function `set_comm_wallet`](#0x1_CommunityWallet_set_comm_wallet)
-  [Function `is_comm`](#0x1_CommunityWallet_is_comm)
-  [Function `multisig_thresh`](#0x1_CommunityWallet_multisig_thresh)
-  [Function `multisig_common_ancestry`](#0x1_CommunityWallet_multisig_common_ancestry)
-  [Function `init_community_multisig`](#0x1_CommunityWallet_init_community_multisig)
-  [Function `add_signer_community_multisig`](#0x1_CommunityWallet_add_signer_community_multisig)


<pre><code><b>use</b> <a href="Ancestry.md#0x1_Ancestry">0x1::Ancestry</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_CommunityWallet_CommunityWallet"></a>

## Resource `CommunityWallet`



<pre><code><b>struct</b> <a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_CommunityWallet_ENOT_AUTHORIZED"></a>



<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>: u64 = 23;
</code></pre>



<a name="0x1_CommunityWallet_ENOT_DONOR_DIRECTED"></a>

This account needs to be donor directed.


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_DONOR_DIRECTED">ENOT_DONOR_DIRECTED</a>: u64 = 120001;
</code></pre>



<a name="0x1_CommunityWallet_ENOT_MULTISIG"></a>

This account needs a multisig enabled


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_MULTISIG">ENOT_MULTISIG</a>: u64 = 120002;
</code></pre>



<a name="0x1_CommunityWallet_ENOT_QUALIFY_COMMUNITY_WALLET"></a>



<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_QUALIFY_COMMUNITY_WALLET">ENOT_QUALIFY_COMMUNITY_WALLET</a>: u64 = 12000;
</code></pre>



<a name="0x1_CommunityWallet_EPAYEE_NOT_SLOW_WALLET"></a>

Recipient does not have a slow wallet


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_EPAYEE_NOT_SLOW_WALLET">EPAYEE_NOT_SLOW_WALLET</a>: u64 = 120006;
</code></pre>



<a name="0x1_CommunityWallet_ESIGNERS_SYBIL"></a>

Signers may be sybil


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ESIGNERS_SYBIL">ESIGNERS_SYBIL</a>: u64 = 120005;
</code></pre>



<a name="0x1_CommunityWallet_ESIG_THRESHOLD"></a>

The multisig does not have minimum 5 signers and 3 approvals in config


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ESIG_THRESHOLD">ESIG_THRESHOLD</a>: u64 = 120003;
</code></pre>



<a name="0x1_CommunityWallet_ESIG_THRESHOLD_RATIO"></a>

The multisig threshold does not equal 3/5


<pre><code><b>const</b> <a href="CommunityWallet.md#0x1_CommunityWallet_ESIG_THRESHOLD_RATIO">ESIG_THRESHOLD_RATIO</a>: u64 = 120004;
</code></pre>



<a name="0x1_CommunityWallet_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_init">is_init</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_init">is_init</a>(addr: <b>address</b>):bool {
  <b>exists</b>&lt;<a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_set_comm_wallet"></a>

## Function `set_comm_wallet`



<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_set_comm_wallet">set_comm_wallet</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_set_comm_wallet">set_comm_wallet</a>(sender: &signer) {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>assert</b>!(<a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">DonorDirected::is_donor_directed</a>(addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="CommunityWallet.md#0x1_CommunityWallet_ENOT_DONOR_DIRECTED">ENOT_DONOR_DIRECTED</a>));

  <b>if</b> (<a href="CommunityWallet.md#0x1_CommunityWallet_is_init">is_init</a>(addr)) {
    <b>move_to</b>(sender, <a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a>{});
  }
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_is_comm"></a>

## Function `is_comm`

Dynamic check to see if CommunityWallet is qualifying.
if it is not qualifying it wont be part of the burn funds matching.


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">is_comm</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_is_comm">is_comm</a>(addr: <b>address</b>): bool {
  // The <a href="CommunityWallet.md#0x1_CommunityWallet">CommunityWallet</a> flag is set
  <a href="CommunityWallet.md#0x1_CommunityWallet_is_init">is_init</a>(addr) &&
  // <b>has</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> instantiated
  <a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">DonorDirected::is_donor_directed</a>(addr) &&
  // <b>has</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> instantialized
  <a href="MultiSig.md#0x1_MultiSig_is_init">MultiSig::is_init</a>(addr) &&
  // multisig <b>has</b> minimum requirement of 3 signatures, and minimum list of 5 signers, and a minimum of 3/5 threshold. I.e. OK <b>to</b> have 4/5 signatures.
  <a href="CommunityWallet.md#0x1_CommunityWallet_multisig_thresh">multisig_thresh</a>(addr) &&
  // the multisig authorities are unrelated per <a href="Ancestry.md#0x1_Ancestry">Ancestry</a>
  !<a href="CommunityWallet.md#0x1_CommunityWallet_multisig_common_ancestry">multisig_common_ancestry</a>(addr)
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_multisig_thresh"></a>

## Function `multisig_thresh`



<pre><code><b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_multisig_thresh">multisig_thresh</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_multisig_thresh">multisig_thresh</a>(addr: <b>address</b>): bool{
  <b>let</b> (n, m) = <a href="MultiSig.md#0x1_MultiSig_get_n_of_m_cfg">MultiSig::get_n_of_m_cfg</a>(addr);

  // can't have less than three signatures
  <b>if</b> (n &lt; 3) <b>return</b> <b>false</b>;
  // can't have less than five authorities
  <b>if</b> (m &lt; 5) <b>return</b> <b>false</b>;

  <b>let</b> r = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(3, 5);
  <b>let</b> pct_baseline = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(100, r);
  <b>let</b> r = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(n, m);
  <b>let</b> pct = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(100, r);

  pct &gt; pct_baseline
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_multisig_common_ancestry"></a>

## Function `multisig_common_ancestry`



<pre><code><b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_multisig_common_ancestry">multisig_common_ancestry</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_multisig_common_ancestry">multisig_common_ancestry</a>(addr: <b>address</b>): bool {
  <b>let</b> list = <a href="MultiSig.md#0x1_MultiSig_get_authorities">MultiSig::get_authorities</a>(addr);

  <b>let</b> (fam, _, _) = <a href="Ancestry.md#0x1_Ancestry_any_family_in_list">Ancestry::any_family_in_list</a>(list);

  fam
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_init_community_multisig"></a>

## Function `init_community_multisig`

Helper to initialize the PaymentMultisig, but also while confirming that the signers are not related family
These transactions can be sent directly to DonorDirected, but this is a helper to make it easier to initialize the multisig with the acestry requirements.


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_init_community_multisig">init_community_multisig</a>(sig: signer, signer_one: <b>address</b>, signer_two: <b>address</b>, signer_three: <b>address</b>, signer_four: <b>address</b>, signer_five: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_init_community_multisig">init_community_multisig</a>(
  sig: signer,
  signer_one: <b>address</b>,
  signer_two: <b>address</b>,
  signer_three: <b>address</b>,
  signer_four: <b>address</b>,
  signer_five: <b>address</b>,
) {
  <b>let</b> init_signers = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(signer_one);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_two);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_three);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_four);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_five);

  <b>let</b> (fam, _, _) = <a href="Ancestry.md#0x1_Ancestry_any_family_in_list">Ancestry::any_family_in_list</a>(*&init_signers);

  <b>assert</b>!(!fam, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="CommunityWallet.md#0x1_CommunityWallet_ESIGNERS_SYBIL">ESIGNERS_SYBIL</a>));

  <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">DonorDirected::set_donor_directed</a>(&sig);
  <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">DonorDirected::make_multisig</a>(&sig, 3, init_signers);
}
</code></pre>



</details>

<a name="0x1_CommunityWallet_add_signer_community_multisig"></a>

## Function `add_signer_community_multisig`

add signer to multisig, and check if they may be related in Ancestry tree


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_add_signer_community_multisig">add_signer_community_multisig</a>(sig: signer, multisig_address: <b>address</b>, new_signer: <b>address</b>, n_of_m: u64, vote_duration_epochs: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="CommunityWallet.md#0x1_CommunityWallet_add_signer_community_multisig">add_signer_community_multisig</a>(sig: signer, multisig_address: <b>address</b>, new_signer: <b>address</b>, n_of_m: u64, vote_duration_epochs: u64) {
  <b>let</b> current_signers = <a href="MultiSig.md#0x1_MultiSig_get_authorities">MultiSig::get_authorities</a>(multisig_address);
  <b>let</b> (fam, _, _) = <a href="Ancestry.md#0x1_Ancestry_is_family_one_in_list">Ancestry::is_family_one_in_list</a>(new_signer, &current_signers);

  <b>assert</b>!(!fam, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="CommunityWallet.md#0x1_CommunityWallet_ESIGNERS_SYBIL">ESIGNERS_SYBIL</a>));

  <a href="MultiSig.md#0x1_MultiSig_propose_governance">MultiSig::propose_governance</a>(
    &sig,
    multisig_address,
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(new_signer),
    <b>true</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(n_of_m),
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(vote_duration_epochs)
  );

}
</code></pre>



</details>
