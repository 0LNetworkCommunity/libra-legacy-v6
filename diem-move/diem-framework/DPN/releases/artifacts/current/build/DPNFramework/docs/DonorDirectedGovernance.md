
<a name="0x1_DonorDirectedGovernance"></a>

# Module `0x1::DonorDirectedGovernance`

DonorDirected wallet governance. See documentation at DonorDirected.move
For each DonorDirected account there are Donors.
We establish who is a Donor through the Receipts module.
The DonorDirected account also has a tracker for the Cumulative amount of funds that have been sent to this account.
We will use the lifetime cumulative amounts sent as the total amount of votes that can be cast (voter enrollment).
The voting on a veto of a transaction or an outright liquidation of the account is done by the Donors.
The voting mechanism is a TurnoutTally. Such votes ajust the threshold for passing a vote based on the actual turnout. I.e. The fewer people that vote, the higher the threshold to reach consensus. But a vote is not scuttled if the turnout is low. See more details in the TurnoutTally.move module.


-  [Resource `Governance`](#0x1_DonorDirectedGovernance_Governance)
-  [Struct `Veto`](#0x1_DonorDirectedGovernance_Veto)
-  [Struct `Liquidate`](#0x1_DonorDirectedGovernance_Liquidate)
-  [Constants](#@Constants_0)
-  [Function `init_donor_governance`](#0x1_DonorDirectedGovernance_init_donor_governance)
-  [Function `get_enrollment`](#0x1_DonorDirectedGovernance_get_enrollment)
-  [Function `check_is_donor`](#0x1_DonorDirectedGovernance_check_is_donor)
-  [Function `assert_authorized`](#0x1_DonorDirectedGovernance_assert_authorized)
-  [Function `is_authorized`](#0x1_DonorDirectedGovernance_is_authorized)
-  [Function `get_user_donations`](#0x1_DonorDirectedGovernance_get_user_donations)
-  [Function `vote_veto`](#0x1_DonorDirectedGovernance_vote_veto)
-  [Function `vote_liquidation`](#0x1_DonorDirectedGovernance_vote_liquidation)
-  [Function `veto_by_id`](#0x1_DonorDirectedGovernance_veto_by_id)
-  [Function `sync_ballot_and_tx_expiration`](#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration)
-  [Function `propose_veto`](#0x1_DonorDirectedGovernance_propose_veto)
-  [Function `propose_liquidate`](#0x1_DonorDirectedGovernance_propose_liquidate)
-  [Function `propose_gov`](#0x1_DonorDirectedGovernance_propose_gov)
-  [Function `is_unique_proposal`](#0x1_DonorDirectedGovernance_is_unique_proposal)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="Receipts.md#0x1_Receipts">0x1::Receipts</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TurnoutTally.md#0x1_TurnoutTally">0x1::TurnoutTally</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_DonorDirectedGovernance_Governance"></a>

## Resource `Governance`

Data struct to store all the governance Ballots for vetos
allows for a generic type of Governance action, using the Participation Vote Poll type to keep track of ballots


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;T&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tracker: <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;T&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirectedGovernance_Veto"></a>

## Struct `Veto`

this is a GovAction type for veto


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirectedGovernance_Liquidate"></a>

## Struct `Liquidate`

this is a GovAction type for liquidation


<pre><code><b>struct</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a> <b>has</b> drop, store
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

  // <b>let</b> t = <a href="TurnoutTally.md#0x1_TurnoutTally_new_tally_struct">TurnoutTally::new_tally_struct</a>();
  <b>let</b> veto = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt; {
      tracker: <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>()
  };

  <b>move_to</b>(directed_account, veto);

  <b>let</b> liquidate = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a>&gt;&gt; {
      tracker: <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>()
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


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account: <b>address</b>, user: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account: <b>address</b>, user: <b>address</b>): bool {
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(directed_account, user) &gt; 0
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_assert_authorized"></a>

## Function `assert_authorized`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(sig: &signer, directed_account: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(sig: &signer, directed_account: <b>address</b>) {
  <b>let</b> user = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account, user), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_ENOT_A_DONOR">ENOT_A_DONOR</a>));
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_is_authorized"></a>

## Function `is_authorized`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_is_authorized">is_authorized</a>(user: <b>address</b>, directed_account: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_is_authorized">is_authorized</a>(user: <b>address</b>, directed_account: <b>address</b>):bool {
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_check_is_donor">check_is_donor</a>(directed_account, user)
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

<a name="0x1_DonorDirectedGovernance_vote_veto"></a>

## Function `vote_veto`

private function to vote on a ballot based on a Donor's voting power.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user: &signer, ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">DonorDirectedGovernance::Veto</a>&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, multisig_address: <b>address</b>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user: &signer, ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, multisig_address: <b>address</b>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; {
  <b>let</b> user_votes = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(multisig_address, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(user));

  <b>let</b> veto_tx = <b>true</b>; // True means  approve the ballot, meaning: "veto transaction". Rejecting the ballot would mean "approve transaction".

  <a href="TurnoutTally.md#0x1_TurnoutTally_vote">TurnoutTally::vote</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;(user, ballot, uid, veto_tx, user_votes)
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_vote_liquidation"></a>

## Function `vote_liquidation`

Liquidation tally only. The handler for liquidation exists in DonorDirected, where a tx script will call it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_liquidation">vote_liquidation</a>(donor: &signer, multisig_address: <b>address</b>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_liquidation">vote_liquidation</a>(donor: &signer, multisig_address: <b>address</b>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>{
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(donor, multisig_address);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a>&gt;&gt;&gt;(multisig_address);

  // for liquidation there is only ever one proposal, which never expires
  // so always taket the first one from pending.
  <b>let</b> pending_list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">Ballot::get_list_ballots_by_enum_mut</a>(&<b>mut</b> state.tracker, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>());
  // print(pending_list);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(pending_list)) {
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;()
  };

  <b>let</b> ballot = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(pending_list, 0);
  <b>let</b> ballot_guid = <a href="Ballot.md#0x1_Ballot_get_ballot_id">Ballot::get_ballot_id</a>(ballot);
  <b>let</b> tally_state = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);
  <b>let</b> user_weight = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_user_donations">get_user_donations</a>(multisig_address, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(donor));

  <a href="TurnoutTally.md#0x1_TurnoutTally_vote">TurnoutTally::vote</a>(donor, tally_state, &ballot_guid, <b>true</b>, user_weight)
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_veto_by_id"></a>

## Function `veto_by_id`

Public script transaction to propose a veto, or vote on it if it already exists.
should only be called by the DonorDirected.move so that the handlers can be called on "pass" conditions.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">veto_by_id</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">veto_by_id</a>(user: &signer, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> directed_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(proposal_guid);
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">assert_authorized</a>(user, directed_account);

  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt;&gt;(directed_account);

  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(&<b>mut</b> state.tracker, proposal_guid);
  <b>let</b> tally_state = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);

  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_veto">vote_veto</a>(user, tally_state, proposal_guid, directed_account)
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

  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;&gt;&gt;(directed_account);

  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(&<b>mut</b> state.tracker, proposal_guid);
  <b>let</b> tally_state = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);

  <a href="TurnoutTally.md#0x1_TurnoutTally_extend_deadline">TurnoutTally::extend_deadline</a>(tally_state, epoch_deadline);

}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_propose_veto"></a>

## Function `propose_veto`

only DonorDirected can call this. The veto and liquidate handlers need
to be located there. So users should not call functions here.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_veto">propose_veto</a>(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, epochs_duration: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_veto">propose_veto</a>(
  cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
  guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, // Id of initiated transaction.
  epochs_duration: u64
) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> data = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a> { guid: *guid };
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Veto">Veto</a>&gt;(cap, data, epochs_duration);
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_propose_liquidate"></a>

## Function `propose_liquidate`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_liquidate">propose_liquidate</a>(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, epochs_duration: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_liquidate">propose_liquidate</a>(
  cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
  epochs_duration: u64
) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> data = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a> { };
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Liquidate">Liquidate</a>&gt;(cap, data, epochs_duration);
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_propose_gov"></a>

## Function `propose_gov`

a private function to propose a ballot for a veto. This is called by a verified donor.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;GovAction: drop, store&gt;(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, data: GovAction, epochs_duration: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_gov">propose_gov</a>&lt;GovAction: drop + store&gt;(cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, data: GovAction, epochs_duration: u64) <b>acquires</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a> {
  <b>let</b> directed_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(cap);
  <b>let</b> gov_state = <b>borrow_global_mut</b>&lt;<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_Governance">Governance</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;GovAction&gt;&gt;&gt;(directed_account);

  <b>if</b> (!<a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_is_unique_proposal">is_unique_proposal</a>(&gov_state.tracker, &data)) <b>return</b>;

  // what's the maximum universe of valid votes.
  <b>let</b> max_votes_enrollment = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_get_enrollment">get_enrollment</a>(directed_account);
  <b>if</b> (epochs_duration &lt; 7) {
    epochs_duration = 7;
  };

  <b>let</b> deadline = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + epochs_duration; // 7 epochs is about 1 week
  <b>let</b> max_extensions = 0; // infinite

  <b>let</b> t = <a href="TurnoutTally.md#0x1_TurnoutTally_new_tally_struct">TurnoutTally::new_tally_struct</a>(
    data,
    max_votes_enrollment,
    deadline,
    max_extensions
  );

  <a href="Ballot.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>(&<b>mut</b> gov_state.tracker, cap, t);
}
</code></pre>



</details>

<a name="0x1_DonorDirectedGovernance_is_unique_proposal"></a>

## Function `is_unique_proposal`

Check if a proposal has already been made for this transaction.


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_is_unique_proposal">is_unique_proposal</a>&lt;GovAction: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;GovAction&gt;&gt;, data: &GovAction): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_is_unique_proposal">is_unique_proposal</a>&lt;GovAction: drop + store&gt;(tracker: &BallotTracker&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;GovAction&gt;&gt;, data: &GovAction): bool {
  // NOTE: <a href="Ballot.md#0x1_Ballot">Ballot</a>.<b>move</b> does not check for duplicates. We need <b>to</b> check here.
  <b>let</b> list_pending = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">Ballot::get_list_ballots_by_enum</a>(tracker, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>());

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list_pending);
  <b>let</b> i = 0;

  <b>while</b> (i &lt; len) {
    <b>let</b> ballot = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list_pending, i);
    <b>let</b> ballot_data = <a href="Ballot.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>(ballot);

    <b>if</b> (<a href="TurnoutTally.md#0x1_TurnoutTally_get_tally_data">TurnoutTally::get_tally_data</a>(ballot_data) == data) <b>return</b> <b>false</b>;

    i = i + 1;
  };
  <b>true</b>
}
</code></pre>



</details>
