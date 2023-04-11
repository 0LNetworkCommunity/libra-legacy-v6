
<a name="0x1_TurnkeyBinaryPoll"></a>

# Module `0x1::TurnkeyBinaryPoll`

See BinaryTally.move for the details docs on developing your own poll.
This is a simple implementation of a simple binary choice poll with a deadline.
It can be used to instantiate very simple referenda, and to programatically initiate actions/events/transactions based on a result.
It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.


-  [Resource `AllPolls`](#0x1_TurnkeyBinaryPoll_AllPolls)
-  [Resource `VoteCapability`](#0x1_TurnkeyBinaryPoll_VoteCapability)
-  [Constants](#@Constants_0)
-  [Function `init_polling_at_address`](#0x1_TurnkeyBinaryPoll_init_polling_at_address)
-  [Function `propose_ballot_by_owner`](#0x1_TurnkeyBinaryPoll_propose_ballot_by_owner)
-  [Function `propose_ballot_with_capability`](#0x1_TurnkeyBinaryPoll_propose_ballot_with_capability)
-  [Function `find_by_address`](#0x1_TurnkeyBinaryPoll_find_by_address)
-  [Function `propose_ballot_owner_script`](#0x1_TurnkeyBinaryPoll_propose_ballot_owner_script)
-  [Function `add_remove_voters`](#0x1_TurnkeyBinaryPoll_add_remove_voters)
-  [Function `vote`](#0x1_TurnkeyBinaryPoll_vote)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="BinaryTally.md#0x1_BinaryTally">0x1::BinaryTally</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_AllPolls"></a>

## Resource `AllPolls`

In BinaryPoll we have a single place to track every BinaryTally of a given "issue" that can carry IssueData as a payload.
The "B" generic is deceptively simple. How the state actually looks in memory is:
struct Ballot::BallotTracker<
Ballot::Ballot<
BinaryPoll::BinaryTally<
IssueData { whatever: you_decide }


<pre><code><b>struct</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;B&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tracker: <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;B&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TurnkeyBinaryPoll_VoteCapability"></a>

## Resource `VoteCapability`

the ability to update tallies is usually restricted to signer
since the signer is the one who can create the GUID::CreateCapability
A third party contract can store that capability to access based on its own vote logic. Danger.


<pre><code><b>struct</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_VoteCapability">VoteCapability</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>guid_cap: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TurnkeyBinaryPoll_ENOT_INITIALIZED"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_ENOT_INITIALIZED">ENOT_INITIALIZED</a>: u64 = 0;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_APPROVED"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_ENO_BALLOT_FOUND"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_PENDING"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_REJECTED"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_EALREADY_VOTED"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 3;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_EINVALID_VOTE"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_EINVALID_VOTE">EINVALID_VOTE</a>: u64 = 4;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_ENOT_ENROLLED"></a>



<pre><code><b>const</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_ENOT_ENROLLED">ENOT_ENROLLED</a>: u64 = 2;
</code></pre>



<a name="0x1_TurnkeyBinaryPoll_init_polling_at_address"></a>

## Function `init_polling_at_address`

Developers who need more flexibility, can instead construct the BallotTracker object and then wrap it in another struct on their third party module.


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_init_polling_at_address">init_polling_at_address</a>&lt;IssueData: drop, store&gt;(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_init_polling_at_address">init_polling_at_address</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
) {
  <b>move_to</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(sig, <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a> {
    tracker: <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>&lt;IssueData&gt;(),
  });

  // store the capability in the account so the functions below can mutate the ballot and ballot box (by sharing the token/capability needed <b>to</b> create GUIDs)
  // If the developer wants <b>to</b> allow other access control <b>to</b> the Create Capability, they can do so by storing the capability in a different <b>module</b> (i.e. the third party <b>module</b> calling this function)
  <b>let</b> guid_cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);
  <b>move_to</b>(sig, <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_VoteCapability">VoteCapability</a> { guid_cap });
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_propose_ballot_by_owner"></a>

## Function `propose_ballot_by_owner`

If the BallotTracker is standalone at root of address, you can use thie function as long as the CreateCapability is available.


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_by_owner">propose_ballot_by_owner</a>&lt;IssueData: drop, store&gt;(sig: &signer, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_by_owner">propose_ballot_by_owner</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tally_type: IssueData,
) <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>, <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_VoteCapability">VoteCapability</a> {
  <b>assert</b>!(<b>exists</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_ENOT_INITIALIZED">ENOT_INITIALIZED</a>));
  <b>let</b> guid_cap = &<b>borrow_global</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_VoteCapability">VoteCapability</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)).guid_cap;
  <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData&gt;(guid_cap, tally_type);
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_propose_ballot_with_capability"></a>

## Function `propose_ballot_with_capability`



<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData: drop, store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData: drop + store&gt;(
 guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
 tally_type: IssueData,
) <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a> {
 <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap);
 <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(addr);
 <a href="Ballot.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>(&<b>mut</b> state.tracker, guid_cap, tally_type);
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_find_by_address"></a>

## Function `find_by_address`

Public helper to get data on an issue without privileges. Returns tuple if the ballot is (found, its index, its status enum, is it completed)


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_find_by_address">find_by_address</a>&lt;IssueData: drop, store&gt;(poll_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_find_by_address">find_by_address</a>&lt;IssueData: drop + store&gt;(poll_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool) <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(poll_address);
  <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(&state.tracker, uid)
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_propose_ballot_owner_script"></a>

## Function `propose_ballot_owner_script`



<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_owner_script">propose_ballot_owner_script</a>&lt;IssueData: drop, store&gt;(sig: &signer, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_owner_script">propose_ballot_owner_script</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tally_type: IssueData,
) <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>, <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_VoteCapability">VoteCapability</a>{
  <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_propose_ballot_by_owner">propose_ballot_by_owner</a>&lt;IssueData&gt;(sig, tally_type);
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_add_remove_voters"></a>

## Function `add_remove_voters`



<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_add_remove_voters">add_remove_voters</a>&lt;IssueData: drop, store&gt;(sig: &signer, voters: vector&lt;<b>address</b>&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, add_remove: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_add_remove_voters">add_remove_voters</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  voters: vector&lt;<b>address</b>&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  add_remove: bool,
) <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;&gt;(addr);
  <a href="BinaryTally.md#0x1_BinaryTally_update_enrollment">BinaryTally::update_enrollment</a>&lt;IssueData&gt;(&<b>mut</b> state.tracker, uid, voters, add_remove);
}
</code></pre>



</details>

<a name="0x1_TurnkeyBinaryPoll_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_vote">vote</a>&lt;IssueData: drop, store&gt;(sig: &signer, vote_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, for_against: bool): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_vote">vote</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  vote_address: <b>address</b>,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  for_against: bool,
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt;  <b>acquires</b> <a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a> { //returns some() <b>if</b> the vote was completed, and <b>true</b>/<b>false</b> <b>if</b> it passed.
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="TurnkeyBinaryPoll.md#0x1_TurnkeyBinaryPoll_AllPolls">AllPolls</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;&gt;(vote_address);
  <a href="BinaryTally.md#0x1_BinaryTally_vote">BinaryTally::vote</a>&lt;IssueData&gt;(sig, &<b>mut</b> state.tracker, uid, for_against)
}
</code></pre>



</details>
