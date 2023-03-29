
<a name="0x1_BinaryPoll"></a>

# Module `0x1::BinaryPoll`

This is a simple implementation of a simple binary choice poll with a deadline.
It can be used to instantiate very simple referenda, and to programatically initiate actions/events/transactions based on a result.
It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.
Ballot itself does not have any storage. It just creates the ballot box, and the methods to query or mutate the ballot box, and ballots.
So this module is a wrapper around Ballot with simple storage and simple logic.


-  [Resource `AllPolls`](#0x1_BinaryPoll_AllPolls)
-  [Struct `BinaryCounter`](#0x1_BinaryPoll_BinaryCounter)
-  [Resource `VoteCapability`](#0x1_BinaryPoll_VoteCapability)
-  [Constants](#@Constants_0)
-  [Function `init_polling_at_address`](#0x1_BinaryPoll_init_polling_at_address)
-  [Function `propose_ballot_by_owner`](#0x1_BinaryPoll_propose_ballot_by_owner)
-  [Function `propose_ballot_with_capability`](#0x1_BinaryPoll_propose_ballot_with_capability)
-  [Function `force_update_tally`](#0x1_BinaryPoll_force_update_tally)
-  [Function `is_enrolled`](#0x1_BinaryPoll_is_enrolled)
-  [Function `has_voted`](#0x1_BinaryPoll_has_voted)
-  [Function `find_with_cap`](#0x1_BinaryPoll_find_with_cap)
-  [Function `find_by_address`](#0x1_BinaryPoll_find_by_address)
-  [Function `vote`](#0x1_BinaryPoll_vote)
-  [Function `complete_and_move`](#0x1_BinaryPoll_complete_and_move)
-  [Function `maybe_tally`](#0x1_BinaryPoll_maybe_tally)
-  [Function `maybe_complete`](#0x1_BinaryPoll_maybe_complete)


<pre><code><b>use</b> <a href="VoteLib.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_BinaryPoll_AllPolls"></a>

## Resource `AllPolls`

We keep a tracker of all the Polls for a given Issue.
Ballot leverages generics to make ballots have rich data, for custom handlers.
This makes it confusing at first glance, because it creates a russian doll of structs.
In BinaryPoll we have a single place to track every BinaryCounter of a given "issue" that can carry IssueData as a payload.
The "B" generic is deceptively simple. How the state actually looks in memory is:
struct Ballot::BallotTracker<
Ballot::Ballot<
BinaryPoll::BinaryCounter<
IssueData { whatever: you_decide }


<pre><code><b>struct</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;B&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tracker: <a href="VoteLib.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;B&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_BinaryPoll_BinaryCounter"></a>

## Struct `BinaryCounter`

in Ballot a TallyType can have any kind of data to support the vote.
In our case it's a BinaryCounter type.
The counter fields are very straightforward.
What may not be straigtforward is the "issue_data" field.
This is a generic field that can be used to store any kind of data.
If for example you want every ballot to just have a description, but on each ballot the description is different (like a referendum "prop"). MyCoolVote { vote_text: ASCII };
If your vote is always a recurring topic, it could be as simple as an empty struct where the definition has some semantics. <code>DoWeForkThisChain {}</code>
or more interestingly, it could be an address for a payment <code>PayThisGuy { user: <b>address</b>, amount: u64 }</code> which then you can handle with a custom payment logic.
The data stored in IssueData can be used to trigger an event lazily when a voter finally crosses the threshold for the count


<pre><code><b>struct</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>votes_for: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>votes_against: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>voted: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>enrollment: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>deadline_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_result: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>issue_data: IssueData</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_BinaryPoll_VoteCapability"></a>

## Resource `VoteCapability`

the ability to update tallies is usually restricted to signer
since the signer is the one who can create the GUID::CreateCapability
A third party contract can store that capability to access based on its own vote logic. Danger.


<pre><code><b>struct</b> <a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a> <b>has</b> key
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


<a name="0x1_BinaryPoll_ENOT_INITIALIZED"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_ENOT_INITIALIZED">ENOT_INITIALIZED</a>: u64 = 0;
</code></pre>



<a name="0x1_BinaryPoll_APPROVED"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_BinaryPoll_ENO_BALLOT_FOUND"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_BinaryPoll_PENDING"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_BinaryPoll_REJECTED"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_BinaryPoll_EALREADY_VOTED"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 3;
</code></pre>



<a name="0x1_BinaryPoll_EINVALID_VOTE"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_EINVALID_VOTE">EINVALID_VOTE</a>: u64 = 4;
</code></pre>



<a name="0x1_BinaryPoll_ENOT_ENROLLED"></a>



<pre><code><b>const</b> <a href="BinaryPoll.md#0x1_BinaryPoll_ENOT_ENROLLED">ENOT_ENROLLED</a>: u64 = 2;
</code></pre>



<a name="0x1_BinaryPoll_init_polling_at_address"></a>

## Function `init_polling_at_address`

Initialize poll struct which will be stored as-is on the account under BallotTracker<IssueData>.
What is actually happening is a bit of a russian doll. For every "issue y
Developers who need more flexibility, can instead construct the BallotTracker object and then wrap it in another struct on their third party module.


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_init_polling_at_address">init_polling_at_address</a>&lt;IssueData: drop, store&gt;(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_init_polling_at_address">init_polling_at_address</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
) {
  <b>move_to</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(sig, <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
    tracker: <a href="VoteLib.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>&lt;IssueData&gt;(),
  });

  // store the capability in the account so the functions below can mutate the ballot and ballot box (by sharing the token/capability needed <b>to</b> create GUIDs)
  // If the developer wants <b>to</b> allow other access control <b>to</b> the Create Capability, they can do so by storing the capability in a different <b>module</b> (i.e. the third party <b>module</b> calling this function)
  <b>let</b> guid_cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);
  <b>move_to</b>(sig, <a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a> { guid_cap });
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_propose_ballot_by_owner"></a>

## Function `propose_ballot_by_owner`

If the BallotTracker is standalone at root of address, you can use thie function as long as the CreateCapability is available.


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_propose_ballot_by_owner">propose_ballot_by_owner</a>&lt;IssueData: drop, store&gt;(sig: &signer, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_propose_ballot_by_owner">propose_ballot_by_owner</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tally_type: IssueData,
) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>, <a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a> {
  <b>assert</b>!(<b>exists</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_ENOT_INITIALIZED">ENOT_INITIALIZED</a>));
  <b>let</b> guid_cap = &<b>borrow_global</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)).guid_cap;
  <a href="BinaryPoll.md#0x1_BinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData&gt;(guid_cap, tally_type);
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_propose_ballot_with_capability"></a>

## Function `propose_ballot_with_capability`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData: drop, store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_propose_ballot_with_capability">propose_ballot_with_capability</a>&lt;IssueData: drop + store&gt;(
 guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
 tally_type: IssueData,
) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
 <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap);
 <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(addr);
 <a href="VoteLib.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>(&<b>mut</b> state.tracker, guid_cap, tally_type);
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_force_update_tally"></a>

## Function `force_update_tally`

Convenience function to overwrite the tally data of a ballot.


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_force_update_tally">force_update_tally</a>&lt;IssueData: drop, store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, tally_type: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_force_update_tally">force_update_tally</a>&lt;IssueData: drop + store&gt; (
  guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  tally_type: IssueData,
) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {

  <b>let</b> (found, idx, status_enum, _completed) = <a href="BinaryPoll.md#0x1_BinaryPoll_find_with_cap">find_with_cap</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(guid_cap, uid);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(addr);

  <b>let</b> b = <a href="VoteLib.md#0x1_Ballot_get_ballot_mut">Ballot::get_ballot_mut</a>(&<b>mut</b> state.tracker, idx, status_enum);
  <a href="VoteLib.md#0x1_Ballot_set_ballot_data">Ballot::set_ballot_data</a>(b, tally_type);
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_is_enrolled"></a>

## Function `is_enrolled`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_is_enrolled">is_enrolled</a>&lt;IssueData: drop, store&gt;(sig: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_is_enrolled">is_enrolled</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,

): bool <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;&gt;&gt;(addr);
  <b>let</b> ballot = <a href="VoteLib.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(&state.tracker, uid);
  <b>let</b> tally_type: &<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;  = <a href="VoteLib.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>(ballot);
   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&tally_type.enrollment, &addr)
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_has_voted"></a>

## Function `has_voted`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_has_voted">has_voted</a>&lt;IssueData: drop, store&gt;(sig: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_has_voted">has_voted</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,

): bool <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;&gt;&gt;(addr);
  <b>let</b> ballot = <a href="VoteLib.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(&state.tracker, uid);
  <b>let</b> tally_type: &<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;  = <a href="VoteLib.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>(ballot);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&tally_type.voted, &addr)
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_find_with_cap"></a>

## Function `find_with_cap`

Helper to get data from capability, prevent boilerplate. Returns tuple if the ballot is (found, its index, its status enum, is it completed)


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_find_with_cap">find_with_cap</a>&lt;IssueData: drop, store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_find_with_cap">find_with_cap</a>&lt;IssueData: drop + store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap);
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(addr);
  <a href="VoteLib.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(&state.tracker, uid)
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_find_by_address"></a>

## Function `find_by_address`

Public helper to get data on an issue without privileges. Returns tuple if the ballot is (found, its index, its status enum, is it completed)


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_find_by_address">find_by_address</a>&lt;IssueData: drop, store&gt;(poll_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_find_by_address">find_by_address</a>&lt;IssueData: drop + store&gt;(poll_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(poll_address);
  <a href="VoteLib.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(&state.tracker, uid)
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_vote">vote</a>&lt;IssueData: drop, store&gt;(sig: &signer, vote_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, vote_for: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_vote">vote</a>&lt;IssueData: drop + store&gt;(sig: &signer, vote_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, vote_for: bool) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a>, <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {

  // moving asserts into own scope <b>to</b> drop borrows after checks are complete.
  {

  // expensive calls since we are getting <b>mut</b> data below have the state above, but this is a demo

  <b>assert</b>!(<a href="BinaryPoll.md#0x1_BinaryPoll_is_enrolled">is_enrolled</a>&lt;IssueData&gt;(sig, uid), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_ENOT_ENROLLED">ENOT_ENROLLED</a>));

  <b>assert</b>!(!<a href="BinaryPoll.md#0x1_BinaryPoll_has_voted">has_voted</a>&lt;IssueData&gt;(sig, uid), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_EALREADY_VOTED">EALREADY_VOTED</a>));

  // get the <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">GUID</a> capability stored here
  <b>let</b> cap = &<b>borrow_global</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_VoteCapability">VoteCapability</a>&gt;(vote_address).guid_cap;


  <b>let</b> (found, _idx, status_enum, is_completed) = <a href="BinaryPoll.md#0x1_BinaryPoll_find_with_cap">find_with_cap</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;&gt;(cap, uid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_EINVALID_VOTE">EINVALID_VOTE</a>));
  <b>assert</b>!(!is_completed, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_EINVALID_VOTE">EINVALID_VOTE</a>));
  // is a pending ballot
  <b>assert</b>!(status_enum == 0, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_EINVALID_VOTE">EINVALID_VOTE</a>));

  };

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;&gt;&gt;(addr);
  <b>let</b> ballot = <a href="VoteLib.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(&<b>mut</b> state.tracker, uid);
  <b>let</b> tally_type: &<b>mut</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt; = <a href="VoteLib.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);

  <b>if</b> (vote_for) {
    tally_type.votes_for = tally_type.votes_for + 1;
  } <b>else</b> {
    tally_type.votes_against = tally_type.votes_against + 1;
  };

  // add the signer <b>to</b> the list of voters
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> tally_type.voted, addr);


  // <b>update</b> the tally
  <a href="BinaryPoll.md#0x1_BinaryPoll_maybe_tally">maybe_tally</a>(tally_type);
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_complete_and_move"></a>

## Function `complete_and_move`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_complete_and_move">complete_and_move</a>&lt;IssueData: drop, store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, to_status_enum: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_complete_and_move">complete_and_move</a>&lt;IssueData: drop + store&gt;(guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, to_status_enum: u8) <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
  <b>let</b> (found, _idx, status_enum, _completed) = <a href="BinaryPoll.md#0x1_BinaryPoll_find_with_cap">find_with_cap</a>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(guid_cap, uid);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryPoll.md#0x1_BinaryPoll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a>&lt;IssueData&gt;&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap));
  <b>let</b> b = <a href="VoteLib.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(&<b>mut</b> state.tracker, uid);
  <a href="VoteLib.md#0x1_Ballot_complete_ballot">Ballot::complete_ballot</a>(b);
  <a href="VoteLib.md#0x1_Ballot_move_ballot">Ballot::move_ballot</a>(&<b>mut</b> state.tracker, uid, status_enum, to_status_enum);

}
</code></pre>



</details>

<a name="0x1_BinaryPoll_maybe_tally"></a>

## Function `maybe_tally`

Just check the tally and mark the result.
this function doesn't move the ballot to a different list, since it doesn't have the outer struct and data needed.


<pre><code><b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_maybe_tally">maybe_tally</a>&lt;IssueData: drop, store&gt;(t: &<b>mut</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryPoll::BinaryCounter</a>&lt;IssueData&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_maybe_tally">maybe_tally</a>&lt;IssueData: drop + store&gt;(t: &<b>mut</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; {


  <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; t.deadline_epoch) {

    <b>if</b> (t.votes_for &gt; t.votes_against) {
      t.tally_result = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(<b>true</b>);
    } <b>else</b> {
      t.tally_result = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(<b>false</b>);
    }

  };

  *&t.tally_result
}
</code></pre>



</details>

<a name="0x1_BinaryPoll_maybe_complete"></a>

## Function `maybe_complete`

With access to the outer struct of the Poll, move completed ballots to their correct location: approved or rejected
returns an Option type for approved or rejected, so that the caller can decide what to do with the result.


<pre><code><b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_maybe_complete">maybe_complete</a>&lt;IssueData: drop, store&gt;(tally_type: &<b>mut</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryPoll::BinaryCounter</a>&lt;IssueData&gt;, cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BinaryPoll.md#0x1_BinaryPoll_maybe_complete">maybe_complete</a>&lt;IssueData: drop + store&gt;(tally_type: &<b>mut</b> <a href="BinaryPoll.md#0x1_BinaryPoll_BinaryCounter">BinaryCounter</a>&lt;IssueData&gt;, cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u8&gt; <b>acquires</b> <a href="BinaryPoll.md#0x1_BinaryPoll_AllPolls">AllPolls</a> {
<b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&tally_type.tally_result)) {
    <b>let</b> passed = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&tally_type.tally_result);
    <b>let</b> status_enum = <b>if</b> (passed) {
      <a href="BinaryPoll.md#0x1_BinaryPoll_APPROVED">APPROVED</a> // approved
    } <b>else</b> {
      <a href="BinaryPoll.md#0x1_BinaryPoll_REJECTED">REJECTED</a> // rejected
    };
    // since we have a result lets <b>update</b> the <a href="VoteLib.md#0x1_Ballot">Ballot</a> state
    <a href="BinaryPoll.md#0x1_BinaryPoll_complete_and_move">complete_and_move</a>&lt;IssueData&gt;(cap, uid, *&status_enum);
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(status_enum)
  };

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()

}
</code></pre>



</details>
