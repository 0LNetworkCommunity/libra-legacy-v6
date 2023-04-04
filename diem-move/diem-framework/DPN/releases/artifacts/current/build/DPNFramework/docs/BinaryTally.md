
<a name="0x1_BinaryTally"></a>

# Module `0x1::BinaryTally`

This is a simple implementation of a simple binary choice poll with a deadline.
It can be used to instantiate very simple referenda, and to programatically initiate actions/events/transactions based on a result.
It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.
Ballot itself does not have any storage. It just creates the ballot box, and the methods to query or mutate the ballot box, and ballots.
So this module is a wrapper around Ballot with simple storage and simple logic.


-  [Struct `BinaryTally`](#0x1_BinaryTally_BinaryTally)
-  [Constants](#@Constants_0)
-  [Function `ballot_constructor`](#0x1_BinaryTally_ballot_constructor)
-  [Function `propose_ballot`](#0x1_BinaryTally_propose_ballot)
-  [Function `update_enrollment`](#0x1_BinaryTally_update_enrollment)
-  [Function `is_enrolled`](#0x1_BinaryTally_is_enrolled)
-  [Function `has_voted`](#0x1_BinaryTally_has_voted)
-  [Function `vote`](#0x1_BinaryTally_vote)
-  [Function `assert_can_vote`](#0x1_BinaryTally_assert_can_vote)
-  [Function `maybe_tally`](#0x1_BinaryTally_maybe_tally)
-  [Function `maybe_complete`](#0x1_BinaryTally_maybe_complete)
-  [Function `complete_and_move`](#0x1_BinaryTally_complete_and_move)
-  [Function `force_update_tally`](#0x1_BinaryTally_force_update_tally)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_BinaryTally_BinaryTally"></a>

## Struct `BinaryTally`

We keep a tracker of all the Polls for a given Issue.
Ballot leverages generics to make ballots have rich data, for custom handlers.
This makes it confusing at first glance, because it creates a russian doll of structs.
In BinaryPoll we have a single place to track every BinaryTally of a given "issue" that can carry IssueData as a payload.
struct Ballot::BallotTracker<
Ballot::Ballot<
BinaryPoll::BinaryTally<
IssueData { whatever: you_decide }
the ability to update tallies is usually restricted to signer
since the signer is the one who can create the GUID::CreateCapability
A third party contract can store that capability to access based on its own vote logic. Danger.
in Ballot a TallyType can have any kind of data to support the vote.
In our case it's a BinaryTally type.
The counter fields are very straightforward.
What may not be straigtforward is the "issue_data" field.
This is a generic field that can be used to store any kind of data.
If for example you want every ballot to just have a description, but on each ballot the description is different (like a referendum "prop"). MyCoolVote { vote_text: ASCII };
If your vote is always a recurring topic, it could be as simple as an empty struct where the definition has some semantics. <code>DoWeForkThisChain {}</code>
or more interestingly, it could be an address for a payment <code>PayThisGuy { user: <b>address</b>, amount: u64 }</code> which then you can handle with a custom payment logic.
The data stored in IssueData can be used to trigger an event lazily when a voter finally crosses the threshold for the count


<pre><code><b>struct</b> <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt; <b>has</b> drop, store
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

<a name="@Constants_0"></a>

## Constants


<a name="0x1_BinaryTally_ENOT_INITIALIZED"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_ENOT_INITIALIZED">ENOT_INITIALIZED</a>: u64 = 0;
</code></pre>



<a name="0x1_BinaryTally_APPROVED"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_BinaryTally_ENO_BALLOT_FOUND"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_BinaryTally_PENDING"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_BinaryTally_REJECTED"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_BinaryTally_EALREADY_VOTED"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 3;
</code></pre>



<a name="0x1_BinaryTally_EINVALID_VOTE"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_EINVALID_VOTE">EINVALID_VOTE</a>: u64 = 4;
</code></pre>



<a name="0x1_BinaryTally_ENOT_ENROLLED"></a>



<pre><code><b>const</b> <a href="BinaryTally.md#0x1_BinaryTally_ENOT_ENROLLED">ENOT_ENROLLED</a>: u64 = 2;
</code></pre>



<a name="0x1_BinaryTally_ballot_constructor"></a>

## Function `ballot_constructor`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_ballot_constructor">ballot_constructor</a>&lt;IssueData: drop, store&gt;(issue_data: IssueData): <a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_ballot_constructor">ballot_constructor</a>&lt;IssueData: drop + store&gt;(issue_data: IssueData): <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt; {
  <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a> {
    votes_for: 0,
    votes_against: 0,
    voted: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    enrollment: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    deadline_epoch: 0,
    tally_result: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;(),
    issue_data,
  }
}
</code></pre>



</details>

<a name="0x1_BinaryTally_propose_ballot"></a>

## Function `propose_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_propose_ballot">propose_ballot</a>&lt;IssueData: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, issue_data: IssueData)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_propose_ballot">propose_ballot</a>&lt;IssueData: drop + store&gt;(
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
  issue_data: IssueData,
) {
  <b>let</b> prop = <a href="BinaryTally.md#0x1_BinaryTally_ballot_constructor">ballot_constructor</a>&lt;IssueData&gt;(issue_data);
  <a href="Ballot.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>(tracker, guid_cap, prop);
}
</code></pre>



</details>

<a name="0x1_BinaryTally_update_enrollment"></a>

## Function `update_enrollment`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_update_enrollment">update_enrollment</a>&lt;IssueData: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, list: vector&lt;<b>address</b>&gt;, add_remove: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_update_enrollment">update_enrollment</a>&lt;IssueData: drop + store&gt;(
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  list: vector&lt;<b>address</b>&gt;,
  add_remove: bool,
) {
  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(tracker, uid);
  <b>let</b> tally_type: &<b>mut</b> <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt; = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);
  <b>if</b> (add_remove) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> tally_type.enrollment, list);
  } <b>else</b> {
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list)) {
      <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
      <b>let</b> (found, idx) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&tally_type.enrollment, addr);
      <b>if</b> (found) {
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> tally_type.enrollment, idx);
      };
      i = i + 1;
    }
  }
}
</code></pre>



</details>

<a name="0x1_BinaryTally_is_enrolled"></a>

## Function `is_enrolled`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_is_enrolled">is_enrolled</a>&lt;IssueData: drop, store&gt;(sig: &signer, tally_type: &<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_is_enrolled">is_enrolled</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tally_type: &<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;,
): bool {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&tally_type.enrollment, &addr)
}
</code></pre>



</details>

<a name="0x1_BinaryTally_has_voted"></a>

## Function `has_voted`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_has_voted">has_voted</a>&lt;IssueData: drop, store&gt;(sig: &signer, tally_type: &<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_has_voted">has_voted</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tally_type: &<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;,
  // uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,

): bool {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&tally_type.voted, &addr)
}
</code></pre>



</details>

<a name="0x1_BinaryTally_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_vote">vote</a>&lt;IssueData: drop, store&gt;(sig: &signer, tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, vote_for: bool): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_vote">vote</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  vote_for: bool,
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; { // Returns some() <b>if</b> the result is complete, and <a href="BinaryTally.md#0x1_BinaryTally_APPROVED">APPROVED</a>==<b>true</b>

<a href="BinaryTally.md#0x1_BinaryTally_assert_can_vote">assert_can_vote</a>&lt;IssueData&gt;(sig, tracker, uid);

<b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(tracker, uid);
<b>let</b> tally_type: &<b>mut</b> <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt; = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);

  <b>if</b> (vote_for) {
    tally_type.votes_for = tally_type.votes_for + 1;
  } <b>else</b> {
    tally_type.votes_against = tally_type.votes_against + 1;
  };

  // add the signer <b>to</b> the list of voters
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> tally_type.voted, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig));

  // <b>update</b> the tally
  <a href="BinaryTally.md#0x1_BinaryTally_maybe_tally">maybe_tally</a>(tally_type);

  <a href="BinaryTally.md#0x1_BinaryTally_maybe_complete">maybe_complete</a>(tracker, uid)
}
</code></pre>



</details>

<a name="0x1_BinaryTally_assert_can_vote"></a>

## Function `assert_can_vote`



<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_assert_can_vote">assert_can_vote</a>&lt;IssueData: drop, store&gt;(sig: &signer, tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_assert_can_vote">assert_can_vote</a>&lt;IssueData: drop + store&gt;(
  sig: &signer,
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
) {
  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(tracker, uid);

  <b>let</b> tally_type = <a href="Ballot.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>(ballot);

  <b>assert</b>!(<a href="BinaryTally.md#0x1_BinaryTally_is_enrolled">is_enrolled</a>&lt;IssueData&gt;(sig, tally_type), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_ENOT_ENROLLED">ENOT_ENROLLED</a>));

  <b>assert</b>!(!<a href="BinaryTally.md#0x1_BinaryTally_has_voted">has_voted</a>&lt;IssueData&gt;(sig, tally_type), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_EALREADY_VOTED">EALREADY_VOTED</a>));

  <b>let</b> (found, _idx, status_enum, is_completed) = <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(tracker, uid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_EINVALID_VOTE">EINVALID_VOTE</a>));
  <b>assert</b>!(!is_completed, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_EINVALID_VOTE">EINVALID_VOTE</a>));
  // is a pending ballot
  <b>assert</b>!(status_enum == 0, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_EINVALID_VOTE">EINVALID_VOTE</a>));
}
</code></pre>



</details>

<a name="0x1_BinaryTally_maybe_tally"></a>

## Function `maybe_tally`

Just check the tally and mark the result.
this function doesn't move the ballot to a different list, since it doesn't have the outer struct and data needed.


<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_maybe_tally">maybe_tally</a>&lt;IssueData: drop, store&gt;(t: &<b>mut</b> <a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_maybe_tally">maybe_tally</a>&lt;IssueData: drop + store&gt;(t: &<b>mut</b> <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; {


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

<a name="0x1_BinaryTally_maybe_complete"></a>

## Function `maybe_complete`

With access to the outer struct of the Poll, move completed ballots to their correct location: approved or rejected
returns an Option type for approved or rejected, so that the caller can decide what to do with the result.


<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_maybe_complete">maybe_complete</a>&lt;IssueData: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_maybe_complete">maybe_complete</a>&lt;IssueData: drop + store&gt;(
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; { // returns <b>if</b> it was enum <a href="BinaryTally.md#0x1_BinaryTally_APPROVED">APPROVED</a> == <b>true</b>

  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(tracker, uid);
  <b>let</b> tally_type = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(ballot);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&tally_type.tally_result)) {
      <b>let</b> passed = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&tally_type.tally_result);
      <b>let</b> status_enum = <b>if</b> (passed) {
        <a href="BinaryTally.md#0x1_BinaryTally_APPROVED">APPROVED</a> // approved
      } <b>else</b> {
        <a href="BinaryTally.md#0x1_BinaryTally_REJECTED">REJECTED</a> // rejected
      };
      // since we have a result lets <b>update</b> the <a href="Ballot.md#0x1_Ballot">Ballot</a> state
      <a href="BinaryTally.md#0x1_BinaryTally_complete_and_move">complete_and_move</a>&lt;IssueData&gt;(tracker, uid, *&status_enum);
      <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(passed)
    };

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()
}
</code></pre>



</details>

<a name="0x1_BinaryTally_complete_and_move"></a>

## Function `complete_and_move`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_complete_and_move">complete_and_move</a>&lt;IssueData: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, to_status_enum: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_complete_and_move">complete_and_move</a>&lt;IssueData: drop + store&gt;(
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  to_status_enum: u8
) {
  <b>let</b> (found, _idx, status_enum, _completed) = <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(tracker, uid);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(tracker, uid);
  <a href="Ballot.md#0x1_Ballot_complete_ballot">Ballot::complete_ballot</a>(b);
  <a href="Ballot.md#0x1_Ballot_move_ballot">Ballot::move_ballot</a>(tracker, uid, status_enum, to_status_enum);
}
</code></pre>



</details>

<a name="0x1_BinaryTally_force_update_tally"></a>

## Function `force_update_tally`



<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_force_update_tally">force_update_tally</a>&lt;IssueData: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, new_tally: <a href="BinaryTally.md#0x1_BinaryTally_BinaryTally">BinaryTally::BinaryTally</a>&lt;IssueData&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BinaryTally.md#0x1_BinaryTally_force_update_tally">force_update_tally</a>&lt;IssueData: drop + store&gt; (
  tracker: &<b>mut</b> BallotTracker&lt;<a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  new_tally: <a href="BinaryTally.md#0x1_BinaryTally">BinaryTally</a>&lt;IssueData&gt;,
) {
  <b>let</b> (found, _idx, _status_enum, _completed) = <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(tracker, uid);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="BinaryTally.md#0x1_BinaryTally_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(tracker, uid);
  <a href="Ballot.md#0x1_Ballot_set_ballot_data">Ballot::set_ballot_data</a>(b, new_tally);
}
</code></pre>



</details>
