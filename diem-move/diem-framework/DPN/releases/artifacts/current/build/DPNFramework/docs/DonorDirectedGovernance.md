
<a name="0x1_DonorDirectedGovernance"></a>

# Module `0x1::DonorDirectedGovernance`

DonorDirected wallet governance. See documentation at DonorDirected.move
For each DonorDirected account there are Donors.
We establish who is a Donor through the Receipts module.
The DonorDirected account also has a tracker for the Cumulative amount of funds that have been sent to this account.
We will use the lifetime cumulative amounts sent as the total amount of votes that can be cast (voter enrollment).
The voting on a veto of a transaction or an outright liquidation of the account is done by the Donors.
The voting mechanism is a ParticipationVote. Such votes ajust the threshold for passing a vote based on the actual turnout. I.e. The fewer people that vote, the higher the threshold to reach consensus. But a vote is not scuttled if the turnout is low. See more details in the ParticipationVote.move module.


-  [Resource `Governance`](#0x1_DonorDirectedGovernance_Governance)
-  [Struct `Veto`](#0x1_DonorDirectedGovernance_Veto)
-  [Struct `Liquidate`](#0x1_DonorDirectedGovernance_Liquidate)
-  [Constants](#@Constants_0)
-  [Function `init_donor_governance`](#0x1_DonorDirectedGovernance_init_donor_governance)
-  [Function `get_enrollment`](#0x1_DonorDirectedGovernance_get_enrollment)
-  [Function `check_is_donor`](#0x1_DonorDirectedGovernance_check_is_donor)
-  [Function `assert_authorized`](#0x1_DonorDirectedGovernance_assert_authorized)
-  [Function `get_user_donations`](#0x1_DonorDirectedGovernance_get_user_donations)
-  [Function `propose_veto`](#0x1_DonorDirectedGovernance_propose_veto)
-  [Function `vote_veto`](#0x1_DonorDirectedGovernance_vote_veto)
-  [Function `get_pending_ballot`](#0x1_DonorDirectedGovernance_get_pending_ballot)
-  [Function `veto_by_id`](#0x1_DonorDirectedGovernance_veto_by_id)
-  [Function `sync_ballot_and_tx_expiration`](#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration)
-  [Function `propose_gov`](#0x1_DonorDirectedGovernance_propose_gov)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="VoteLib.md#0x1_ParticipationVote">0x1::ParticipationVote</a>;
<b>use</b> <a href="Receipts.md#0x1_Receipts">0x1::Receipts</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_DonorDirectedGovernance_Governance"></a>

## Resource `Governance`

Data struct to store all the governance Ballots for vetos
allows for a generic type of Governance action, using the Participation Vote Poll type to keep track of ballots


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;GovAction&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>poll: <a href="VoteLib.md#0x1_ParticipationVote_Poll">ParticipationVote::Poll</a>&lt;GovAction&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirectedGovernance_Veto"></a>

## Struct `Veto`

this is a GovAction type for veto


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a> <b>has</b> <b>copy</b>, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>guid: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirectedGovernance_Liquidate"></a>

## Struct `Liquidate`

this is a GovAction type for liquidation


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a> <b>has</b> <b>copy</b>, store
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


<a name="0x1_DonorDirectedGovernance_ENO_BALLOT_FOUND"></a>

No ballot found under that GUID


<pre><code><b>const</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 220001;
</code></pre>



<a name="0x1_DonorDirectedGovernance_ENOT_A_DONOR"></a>

Is not a donor to this account


<pre><code><b>const</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_ENOT_A_DONOR">ENOT_A_DONOR</a>: u64 = 220000;
</code></pre>



<a name="0x1_DonorDirectedGovernance_init_donor_governance"></a>

## Function `init_donor_governance`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_init_donor_governance">init_donor_governance</a>(directed_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_init_donor_governance">init_donor_governance</a>(directed_account: &signer) {
  <b>let</b> veto = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt; {
      poll: <a href="VoteLib.md#0x1_ParticipationVote_new_poll">ParticipationVote::new_poll</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;()
  };

  <b>move_to</b>(directed_account, veto);

  <b>let</b> liquidate = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a>&gt; {
      poll: <a href="VoteLib.md#0x1_ParticipationVote_new_poll">ParticipationVote::new_poll</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a>&gt;()
  };
  <b>move_to</b>(directed_account, liquidate);
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_get_enrollment"></a>

## Function `get_enrollment`

For a DonorDirected account get the total number of votes enrolled from reading the Cumulative tracker.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_enrollment">get_enrollment</a>(directed_account: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_enrollment">get_enrollment</a>(directed_account: <b>address</b>): u64 {
  <a href="DiemAccount.md#0x1_DiemAccount_get_cumulative_deposits">DiemAccount::get_cumulative_deposits</a>(directed_account)
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_check_is_donor"></a>

## Function `check_is_donor`

public function to check that a user account is a Donor for a DonorDirected account.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account: <b>address</b>, user: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account: <b>address</b>, user: <b>address</b>): bool {
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(directed_account, user) &gt; 0
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_assert_authorized"></a>

## Function `assert_authorized`



<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(sig: &signer, directed_account: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(sig: &signer, directed_account: <b>address</b>) {
  <b>let</b> user = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account, user), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_ENOT_A_DONOR">ENOT_A_DONOR</a>));
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_get_user_donations"></a>

## Function `get_user_donations`

For an individual donor, get the amount of votes that they can cast, based on their cumulative donations to the DonorDirected account.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(directed_account: <b>address</b>, user: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(directed_account: <b>address</b>, user: <b>address</b>): u64 {
  <b>let</b> (_, _, cumulative_donations) = <a href="Receipts.md#0x1_Receipts_read_receipt">Receipts::read_receipt</a>(user, directed_account);

  cumulative_donations
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_propose_veto"></a>

## Function `propose_veto`

a private function to propose a ballot for a veto. This is called by a verified donor.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_veto">propose_veto</a>(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, directed_account: <b>address</b>, proposal_guid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_veto">propose_veto</a>(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, directed_account: <b>address</b>, proposal_guid: u64) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> gov_state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt;(directed_account);

  <b>let</b> v = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a> { guid: proposal_guid };

  <a href="VoteLib.md#0x1_ParticipationVote_propose_ballot">ParticipationVote::propose_ballot</a>(
    cap,
    &<b>mut</b> gov_state.poll,
    v,
    <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_enrollment">get_enrollment</a>(directed_account),
    <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + 7, // 7 epochs is about 1 week
    0, // TODO: remove this parameter from the <a href="VoteLib.md#0x1_ParticipationVote">ParticipationVote</a> <b>module</b>
  );
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_vote_veto"></a>

## Function `vote_veto`

private function to vote on a ballot based on a Donor's voting power.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user: &signer, ballot: &<b>mut</b> <a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">DonorDirectedGovernance::Veto</a>&gt;, multisig_address: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user: &signer, ballot: &<b>mut</b> Ballot&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;, multisig_address: <b>address</b>): bool {
  <b>let</b> user_votes = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(multisig_address, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(user));

  <b>let</b> veto_tx = <b>true</b>; // True means  approve the ballot, meaning: "veto transaction". Rejecting the ballot would mean "approve transaction".

  <a href="VoteLib.md#0x1_ParticipationVote_vote">ParticipationVote::vote</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;(ballot, user, veto_tx, user_votes)
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_get_pending_ballot"></a>

## Function `get_pending_ballot`

private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_pending_ballot">get_pending_ballot</a>&lt;GovAction: <b>copy</b>, store&gt;(gov_state: &<b>mut</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">DonorDirectedGovernance::Governance</a>&lt;GovAction&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a>&lt;GovAction&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_pending_ballot">get_pending_ballot</a>&lt;GovAction: <b>copy</b> + store&gt; (gov_state: &<b>mut</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;GovAction&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a>&lt;GovAction&gt; {

  // <b>let</b> (found, idx) = find_index_of_ballot(gov_state, proposal_guid);
  // <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <b>let</b> ballot = <a href="VoteLib.md#0x1_ParticipationVote_get_ballot_mut">ParticipationVote::get_ballot_mut</a>(&<b>mut</b> gov_state.poll, proposal_guid, 0); // 0 enum of pending ballots
  ballot
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_veto_by_id"></a>

## Function `veto_by_id`

Public script transaction to propose a veto, or vote on it if it already exists.
should only be called by the DonorDirected.move so that the handlers can be called on "pass" conditions.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">veto_by_id</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">veto_by_id</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> directed_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(proposal_guid);
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(user, directed_account);

  <b>let</b> vb = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt;(directed_account);
  <b>let</b> ballot = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_pending_ballot">get_pending_ballot</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;(vb, proposal_guid);

  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user, ballot, directed_account)
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration"></a>

## Function `sync_ballot_and_tx_expiration`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration">sync_ballot_and_tx_expiration</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, epoch_deadline: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration">sync_ballot_and_tx_expiration</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, epoch_deadline: u64) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> directed_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(proposal_guid);
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(user, directed_account);

  <b>let</b> vb = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt;(directed_account);
  <b>let</b> ballot = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_pending_ballot">get_pending_ballot</a>(vb, proposal_guid);

  <a href="VoteLib.md#0x1_ParticipationVote_extend_deadline">ParticipationVote::extend_deadline</a>(ballot, epoch_deadline);

}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_propose_gov"></a>

## Function `propose_gov`



<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;GovAction: <b>copy</b>, store&gt;(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, directed_account: <b>address</b>, data: GovAction)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;GovAction: <b>copy</b> + store&gt;(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, directed_account: <b>address</b>, data: GovAction) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> gov_state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;GovAction&gt;&gt;(directed_account);

  <a href="VoteLib.md#0x1_ParticipationVote_propose_ballot">ParticipationVote::propose_ballot</a>(
    cap,
    &<b>mut</b> gov_state.poll,
    data,
    <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_enrollment">get_enrollment</a>(directed_account),
    <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + 7, // 7 epochs is about 1 week
    0, // TODO: remove this parameter from the <a href="VoteLib.md#0x1_ParticipationVote">ParticipationVote</a> <b>module</b>
  );
}
</code></pre>



</details>
