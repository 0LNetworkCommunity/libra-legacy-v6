
<a name="0x1_Poll"></a>

# Module `0x1::Poll`



-  [Resource `Poll`](#0x1_Poll_Poll)
-  [Resource `Ballot`](#0x1_Poll_Ballot)
-  [Constants](#@Constants_0)
-  [Function `new_poll`](#0x1_Poll_new_poll)
-  [Function `propose_ballot`](#0x1_Poll_propose_ballot)
-  [Function `get_ballot_mut`](#0x1_Poll_get_ballot_mut)
-  [Function `find_index_of_ballot`](#0x1_Poll_find_index_of_ballot)
-  [Function `get_list_ballots_by_enum`](#0x1_Poll_get_list_ballots_by_enum)
-  [Function `get_ballot_id`](#0x1_Poll_get_ballot_id)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Poll_Poll"></a>

## Resource `Poll`



<pre><code><b>struct</b> <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>ballots_pending: vector&lt;<a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_approved: vector&lt;<a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_rejected: vector&lt;<a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Poll_Ballot"></a>

## Resource `Ballot`



<pre><code><b>struct</b> <a href="Poll.md#0x1_Poll_Ballot">Ballot</a>&lt;IssueData, TallyType&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_GUID">GUID::GUID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>issue: IssueData</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_type: TallyType</code>
</dt>
<dd>

</dd>
<dt>
<code>completed: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Poll_APPROVED"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_Poll_EALREADY_VOTED"></a>

Voters cannot vote twice, but they can retract a vote


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 300013;
</code></pre>



<a name="0x1_Poll_EBAD_STATUS_ENUM"></a>

Bad status enum


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>: u64 = 300016;
</code></pre>



<a name="0x1_Poll_ECOMPLETED"></a>

The ballot has already been completed.


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_ECOMPLETED">ECOMPLETED</a>: u64 = 300010;
</code></pre>



<a name="0x1_Poll_ENOT_VOTED"></a>

The voter has not voted yet. Cannot retract a vote.


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_ENOT_VOTED">ENOT_VOTED</a>: u64 = 300014;
</code></pre>



<a name="0x1_Poll_ENO_BALLOT_FOUND"></a>

No ballot found under that GUID


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 300015;
</code></pre>



<a name="0x1_Poll_EVOTES_GREATER_THAN_ENROLLMENT"></a>

The number of votes cast cannot be greater than the max number of votes available from enrollment.


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_EVOTES_GREATER_THAN_ENROLLMENT">EVOTES_GREATER_THAN_ENROLLMENT</a>: u64 = 300011;
</code></pre>



<a name="0x1_Poll_EVOTE_CALC_PARAMS"></a>

The threshold curve parameters are wrong. The curve is not decreasing.


<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_EVOTE_CALC_PARAMS">EVOTE_CALC_PARAMS</a>: u64 = 300012;
</code></pre>



<a name="0x1_Poll_HIGH_TURNOUT_X2"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_HIGH_TURNOUT_X2">HIGH_TURNOUT_X2</a>: u64 = 8750;
</code></pre>



<a name="0x1_Poll_LOW_TURNOUT_X1"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>: u64 = 1250;
</code></pre>



<a name="0x1_Poll_MINORITY_EXT_MARGIN"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_MINORITY_EXT_MARGIN">MINORITY_EXT_MARGIN</a>: u64 = 500;
</code></pre>



<a name="0x1_Poll_PCT_SCALE"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_PCT_SCALE">PCT_SCALE</a>: u64 = 10000;
</code></pre>



<a name="0x1_Poll_PENDING"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_Poll_REJECTED"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_Poll_THRESH_AT_HIGH_TURNOUT_Y2"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>: u64 = 5100;
</code></pre>



<a name="0x1_Poll_THRESH_AT_LOW_TURNOUT_Y1"></a>



<pre><code><b>const</b> <a href="Poll.md#0x1_Poll_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a>: u64 = 10000;
</code></pre>



<a name="0x1_Poll_new_poll"></a>

## Function `new_poll`



<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_new_poll">new_poll</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(): <a href="Poll.md#0x1_Poll_Poll">Poll::Poll</a>&lt;IssueData, TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_new_poll">new_poll</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store
&gt;(): <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt; {
  <a href="Poll.md#0x1_Poll">Poll</a> {
    ballots_pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  }
}
</code></pre>



</details>

<a name="0x1_Poll_propose_ballot"></a>

## Function `propose_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_propose_ballot">propose_ballot</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(poll: &<b>mut</b> <a href="Poll.md#0x1_Poll_Poll">Poll::Poll</a>&lt;IssueData, TallyType&gt;, guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, issue: IssueData, tally_type: TallyType): &<b>mut</b> <a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_propose_ballot">propose_ballot</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store
&gt;(
  poll: &<b>mut</b> <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt;,
  guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, // whoever is ceating this issue needs access <b>to</b> the <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">GUID</a> creation capability
  issue: IssueData,
  tally_type: TallyType,
): &<b>mut</b> <a href="Poll.md#0x1_Poll_Ballot">Ballot</a>&lt;IssueData, TallyType&gt;  {
  <b>let</b> b = <a href="Poll.md#0x1_Poll_Ballot">Ballot</a> {

    guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_with_capability">GUID::create_with_capability</a>(@0xDEADBEEF, guid_cap), // <b>address</b> is ignored.
    issue,
    tally_type,
    completed: <b>false</b>,

  };
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&poll.ballots_pending);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> poll.ballots_pending, b);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> poll.ballots_pending, len + 1)
}
</code></pre>



</details>

<a name="0x1_Poll_get_ballot_mut"></a>

## Function `get_ballot_mut`

private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_ballot_mut">get_ballot_mut</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(poll: &<b>mut</b> <a href="Poll.md#0x1_Poll_Poll">Poll::Poll</a>&lt;IssueData, TallyType&gt;, idx: u64, status_enum: u8): &<b>mut</b> <a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_ballot_mut">get_ballot_mut</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store,
&gt; (
  poll: &<b>mut</b> <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt;,
  idx: u64,
  status_enum: u8
): &<b>mut</b> <a href="Poll.md#0x1_Poll_Ballot">Ballot</a>&lt;IssueData, TallyType&gt; {

  <b>let</b> list = <a href="Poll.md#0x1_Poll_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;IssueData, TallyType&gt;(poll, status_enum);

  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list) &gt; idx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Poll.md#0x1_Poll_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(list, idx)
}
</code></pre>



</details>

<a name="0x1_Poll_find_index_of_ballot"></a>

## Function `find_index_of_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_find_index_of_ballot">find_index_of_ballot</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(poll: &<b>mut</b> <a href="Poll.md#0x1_Poll_Poll">Poll::Poll</a>&lt;IssueData, TallyType&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, status_enum: u8): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_find_index_of_ballot">find_index_of_ballot</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store,
&gt; (
  poll: &<b>mut</b> <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt;,
  proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  status_enum: u8
): (bool, u64) {

 <b>let</b> list = <a href="Poll.md#0x1_Poll_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;IssueData, TallyType&gt;(poll, status_enum);

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list)) {
    <b>let</b> b = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list, i);

    <b>if</b> (&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&b.guid) == proposal_guid) {
      <b>return</b> (<b>true</b>, i)
    };
    i = i + 1;
  };

  (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_Poll_get_list_ballots_by_enum"></a>

## Function `get_list_ballots_by_enum`



<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(poll: &<b>mut</b> <a href="Poll.md#0x1_Poll_Poll">Poll::Poll</a>&lt;IssueData, TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store,
&gt;(poll: &<b>mut</b> <a href="Poll.md#0x1_Poll">Poll</a>&lt;IssueData, TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="Poll.md#0x1_Poll_Ballot">Ballot</a>&lt;IssueData, TallyType&gt;&gt; {
 <b>if</b> (status_enum == <a href="Poll.md#0x1_Poll_PENDING">PENDING</a>) {
    &<b>mut</b> poll.ballots_pending
  } <b>else</b> <b>if</b> (status_enum == <a href="Poll.md#0x1_Poll_APPROVED">APPROVED</a>) {
    &<b>mut</b> poll.ballots_approved
  } <b>else</b> <b>if</b> (status_enum == <a href="Poll.md#0x1_Poll_REJECTED">REJECTED</a>) {
    &<b>mut</b> poll.ballots_rejected
  } <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Poll.md#0x1_Poll_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>));
    &<b>mut</b> poll.ballots_rejected // dummy <b>return</b>
  }
}
</code></pre>



</details>

<a name="0x1_Poll_get_ballot_id"></a>

## Function `get_ballot_id`



<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_ballot_id">get_ballot_id</a>&lt;IssueData: <b>copy</b>, drop, store, TallyType: <b>copy</b>, drop, store&gt;(ballot: &<a href="Poll.md#0x1_Poll_Ballot">Poll::Ballot</a>&lt;IssueData, TallyType&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Poll.md#0x1_Poll_get_ballot_id">get_ballot_id</a>&lt;
  IssueData: <b>copy</b> + drop + store,
  TallyType: <b>copy</b> + drop + store,
&gt;(ballot: &<a href="Poll.md#0x1_Poll_Ballot">Ballot</a>&lt;IssueData, TallyType&gt;): ID {
  <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&ballot.guid)
}
</code></pre>



</details>
