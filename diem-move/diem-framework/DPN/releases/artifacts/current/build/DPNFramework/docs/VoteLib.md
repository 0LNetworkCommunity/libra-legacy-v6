
<a name="0x1_VoteLib"></a>

# Module `0x1::VoteLib`



-  [Struct `Vote`](#0x1_VoteLib_Vote)
-  [Struct `Ballot`](#0x1_VoteLib_Ballot)
-  [Constants](#@Constants_0)
-  [Function `new_poll`](#0x1_VoteLib_new_poll)
-  [Function `propose_ballot`](#0x1_VoteLib_propose_ballot)
-  [Function `get_ballot_by_id`](#0x1_VoteLib_get_ballot_by_id)
-  [Function `get_ballot_by_id_mut`](#0x1_VoteLib_get_ballot_by_id_mut)
-  [Function `get_ballot_mut`](#0x1_VoteLib_get_ballot_mut)
-  [Function `get_ballot`](#0x1_VoteLib_get_ballot)
-  [Function `find_anywhere`](#0x1_VoteLib_find_anywhere)
-  [Function `find_anywhere_by_data`](#0x1_VoteLib_find_anywhere_by_data)
-  [Function `find_index_of_ballot`](#0x1_VoteLib_find_index_of_ballot)
-  [Function `find_index_of_ballot_by_data`](#0x1_VoteLib_find_index_of_ballot_by_data)
-  [Function `get_list_ballots_by_enum`](#0x1_VoteLib_get_list_ballots_by_enum)
-  [Function `get_list_ballots_by_enum_mut`](#0x1_VoteLib_get_list_ballots_by_enum_mut)
-  [Function `get_ballot_id`](#0x1_VoteLib_get_ballot_id)
-  [Function `get_ballot_type`](#0x1_VoteLib_get_ballot_type)
-  [Function `get_ballot_type_mut`](#0x1_VoteLib_get_ballot_type_mut)
-  [Function `set_ballot_data`](#0x1_VoteLib_set_ballot_data)
-  [Function `is_completed`](#0x1_VoteLib_is_completed)
-  [Function `complete_ballot`](#0x1_VoteLib_complete_ballot)
-  [Function `extract_ballot`](#0x1_VoteLib_extract_ballot)
-  [Function `move_ballot`](#0x1_VoteLib_move_ballot)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_VoteLib_Vote"></a>

## Struct `Vote`



<pre><code><b>struct</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>ballots_pending: vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_approved: vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_rejected: vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_VoteLib_Ballot"></a>

## Struct `Ballot`



<pre><code><b>struct</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt; <b>has</b> drop, store
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


<a name="0x1_VoteLib_APPROVED"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_VoteLib_EALREADY_VOTED"></a>

Voters cannot vote twice, but they can retract a vote


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 300013;
</code></pre>



<a name="0x1_VoteLib_EBAD_STATUS_ENUM"></a>

Bad status enum


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>: u64 = 300016;
</code></pre>



<a name="0x1_VoteLib_ECOMPLETED"></a>

The ballot has already been completed.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_ECOMPLETED">ECOMPLETED</a>: u64 = 300010;
</code></pre>



<a name="0x1_VoteLib_ENOT_VOTED"></a>

The voter has not voted yet. Cannot retract a vote.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_ENOT_VOTED">ENOT_VOTED</a>: u64 = 300014;
</code></pre>



<a name="0x1_VoteLib_ENO_BALLOT_FOUND"></a>

No ballot found under that GUID


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 300015;
</code></pre>



<a name="0x1_VoteLib_EVOTES_GREATER_THAN_ENROLLMENT"></a>

The number of votes cast cannot be greater than the max number of votes available from enrollment.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_EVOTES_GREATER_THAN_ENROLLMENT">EVOTES_GREATER_THAN_ENROLLMENT</a>: u64 = 300011;
</code></pre>



<a name="0x1_VoteLib_EVOTE_CALC_PARAMS"></a>

The threshold curve parameters are wrong. The curve is not decreasing.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_EVOTE_CALC_PARAMS">EVOTE_CALC_PARAMS</a>: u64 = 300012;
</code></pre>



<a name="0x1_VoteLib_HIGH_TURNOUT_X2"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_HIGH_TURNOUT_X2">HIGH_TURNOUT_X2</a>: u64 = 8750;
</code></pre>



<a name="0x1_VoteLib_LOW_TURNOUT_X1"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>: u64 = 1250;
</code></pre>



<a name="0x1_VoteLib_MINORITY_EXT_MARGIN"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_MINORITY_EXT_MARGIN">MINORITY_EXT_MARGIN</a>: u64 = 500;
</code></pre>



<a name="0x1_VoteLib_PCT_SCALE"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_PCT_SCALE">PCT_SCALE</a>: u64 = 10000;
</code></pre>



<a name="0x1_VoteLib_PENDING"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_VoteLib_REJECTED"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_VoteLib_THRESH_AT_HIGH_TURNOUT_Y2"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>: u64 = 5100;
</code></pre>



<a name="0x1_VoteLib_THRESH_AT_LOW_TURNOUT_Y1"></a>



<pre><code><b>const</b> <a href="VoteLib.md#0x1_VoteLib_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a>: u64 = 10000;
</code></pre>



<a name="0x1_VoteLib_new_poll"></a>

## Function `new_poll`

Developers may simply initialize a poll at the root level of their address, Or they can wrap the poll in another struct. There are different APIs for each. One group of APIs are for standalone polls which require the GUID CreateCapability. The other group of APIs are for polls that are wrapped in another struct, and this one assumes the sender can access a mutable instance of the Vote struct, which may be stored under a key of another Struct.
The poll constructor. Use this to create a poll that you are wrapping in another struct.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_new_poll">new_poll</a>&lt;TallyType: drop, store&gt;(): <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_new_poll">new_poll</a>&lt;TallyType: drop + store&gt;(): <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt; {
  <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a> {
    ballots_pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  }
}
</code></pre>



</details>

<a name="0x1_VoteLib_propose_ballot"></a>

## Function `propose_ballot`

If you have a mutable Vote instance AND you have the GUID Create Capability, you can use this to create a ballot.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_propose_ballot">propose_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, tally_type: TallyType): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_propose_ballot">propose_ballot</a>&lt;TallyType:  drop + store&gt;(
  poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, // whoever is ceating this issue needs access <b>to</b> the <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">GUID</a> creation capability
  // issue: IssueData,
  tally_type: TallyType,
): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;  {
  <b>let</b> ignored_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap); // Note 0L's modification <b>to</b> Std::GUID, <b>to</b> get_capability_address

  <b>let</b> b = <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a> {

    guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_with_capability">GUID::create_with_capability</a>(ignored_addr, guid_cap), // Note 0L's modification <b>to</b> Std::GUID, <b>address</b> is ignored.
    // issue,
    tally_type,
    completed: <b>false</b>,

  };
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&poll.ballots_pending);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> poll.ballots_pending, b);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> poll.ballots_pending, len + 1)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_by_id"></a>

## Function `get_ballot_by_id`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_by_id">get_ballot_by_id</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_by_id">get_ballot_by_id</a>&lt;TallyType: drop + store&gt; (
  poll: & <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): &<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> (found, idx, status_enum, _completed) = <a href="VoteLib.md#0x1_VoteLib_find_anywhere">find_anywhere</a>(poll, guid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="VoteLib.md#0x1_VoteLib_get_ballot">get_ballot</a>&lt;TallyType&gt;(poll, idx, status_enum)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_by_id_mut"></a>

## Function `get_ballot_by_id_mut`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_by_id_mut">get_ballot_by_id_mut</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_by_id_mut">get_ballot_by_id_mut</a>&lt;TallyType: drop + store&gt; (
  poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> (found, idx, status_enum, _completed) = <a href="VoteLib.md#0x1_VoteLib_find_anywhere">find_anywhere</a>(poll, guid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="VoteLib.md#0x1_VoteLib_get_ballot_mut">get_ballot_mut</a>&lt;TallyType&gt;(poll, idx, status_enum)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_mut"></a>

## Function `get_ballot_mut`

function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_mut">get_ballot_mut</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, idx: u64, status_enum: u8): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_mut">get_ballot_mut</a>&lt;TallyType: drop + store&gt; (
  poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  idx: u64,
  status_enum: u8
): &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(poll, status_enum);

  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list) &gt; idx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(list, idx)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot"></a>

## Function `get_ballot`

function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot">get_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, idx: u64, status_enum: u8): &<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot">get_ballot</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  idx: u64,
  status_enum: u8
): &<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType&gt;(poll, status_enum);

  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list) &gt; idx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list, idx)
}
</code></pre>



</details>

<a name="0x1_VoteLib_find_anywhere"></a>

## Function `find_anywhere`

find the ballot wherever it is: pending, approved, rejected.
returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_anywhere">find_anywhere</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_anywhere">find_anywhere</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): (bool, u64, u8, bool) {

 // looking in pending
 <b>let</b> (found, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>(poll, proposal_guid, <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>);
 <b>if</b> (found) {
  <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_pending, idx));
   <b>return</b> (<b>true</b>, idx, <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>, complete)
 };

 // looking in approved
  <b>let</b> (found, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>(poll, proposal_guid, <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_approved, idx));
    <b>return</b> (<b>true</b>, idx, <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>, complete)
  };

 // looking in rejected
  <b>let</b> (found, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>(poll, proposal_guid, <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_rejected, idx));
    <b>return</b> (<b>true</b>, idx, <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>, complete)
  };

  (<b>false</b>, 0, 0, <b>false</b>)
}
</code></pre>



</details>

<a name="0x1_VoteLib_find_anywhere_by_data"></a>

## Function `find_anywhere_by_data`

returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_anywhere_by_data">find_anywhere_by_data</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, tally_type: &TallyType): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_anywhere_by_data">find_anywhere_by_data</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  tally_type: &TallyType,
): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64, u8, bool)  {
 // looking in pending
 <b>let</b> (found, guid, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(poll, tally_type, <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>);
 <b>if</b> (found) {
  <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_pending, idx));
   <b>return</b> (<b>true</b>, guid, idx, <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>, complete)
 };

 // looking in approved
  <b>let</b> (found, guid, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(poll, tally_type, <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_approved, idx));
    <b>return</b> (<b>true</b>, guid, idx, <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>, complete)
  };

 // looking in rejected
  <b>let</b> (found, guid, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(poll, tally_type, <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&poll.ballots_rejected, idx));
    <b>return</b> (<b>true</b>, guid, idx, <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>, complete)
  };

  (<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(@0x0, 0), 0, 0, <b>false</b>)
}
</code></pre>



</details>

<a name="0x1_VoteLib_find_index_of_ballot"></a>

## Function `find_index_of_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, status_enum: u8): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  status_enum: u8,
): (bool, u64) {

 <b>let</b> list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType&gt;(poll, status_enum);

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

<a name="0x1_VoteLib_find_index_of_ballot_by_data"></a>

## Function `find_index_of_ballot_by_data`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, tally_type: &TallyType, status_enum: u8): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  tally_type: &TallyType,
  status_enum: u8,
): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64) {

 <b>let</b> list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType&gt;(poll, status_enum);

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list)) {
    <b>let</b> b = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list, i);

    <b>if</b> (&b.tally_type == tally_type) {
      <b>return</b> (<b>true</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&b.guid), i)
    };
    i = i + 1;
  };

  (<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(@0x0, 0), 0)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_list_ballots_by_enum"></a>

## Function `get_list_ballots_by_enum`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType: drop, store&gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, status_enum: u8): &vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType: drop + store &gt;(poll: &<a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;, status_enum: u8): &vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;&gt; {
 <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>) {
    &poll.ballots_pending
  } <b>else</b> <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>) {
    &poll.ballots_approved
  } <b>else</b> <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>) {
    &poll.ballots_rejected
  } <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>));
    & poll.ballots_rejected // dummy <b>return</b>
  }
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_list_ballots_by_enum_mut"></a>

## Function `get_list_ballots_by_enum_mut`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType: drop + store &gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;&gt; {
 <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_PENDING">PENDING</a>) {
    &<b>mut</b> poll.ballots_pending
  } <b>else</b> <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_APPROVED">APPROVED</a>) {
    &<b>mut</b> poll.ballots_approved
  } <b>else</b> <b>if</b> (status_enum == <a href="VoteLib.md#0x1_VoteLib_REJECTED">REJECTED</a>) {
    &<b>mut</b> poll.ballots_rejected
  } <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>));
    &<b>mut</b> poll.ballots_rejected // dummy <b>return</b>
  }
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_id"></a>

## Function `get_ballot_id`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_id">get_ballot_id</a>&lt;TallyType: drop, store&gt;(ballot: &<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_id">get_ballot_id</a>&lt;TallyType: drop + store &gt;(ballot: &<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;): ID {
  <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&ballot.guid)
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_type"></a>

## Function `get_ballot_type`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_type">get_ballot_type</a>&lt;TallyType: drop, store&gt;(ballot: &<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;): &TallyType
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_type">get_ballot_type</a>&lt;TallyType: drop + store &gt;(ballot: &<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;): &TallyType {
  <b>return</b> &ballot.tally_type
}
</code></pre>



</details>

<a name="0x1_VoteLib_get_ballot_type_mut"></a>

## Function `get_ballot_type_mut`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_type_mut">get_ballot_type_mut</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;): &<b>mut</b> TallyType
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_get_ballot_type_mut">get_ballot_type_mut</a>&lt;TallyType: drop + store &gt;(ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;): &<b>mut</b> TallyType {
  <b>return</b> &<b>mut</b> ballot.tally_type
}
</code></pre>



</details>

<a name="0x1_VoteLib_set_ballot_data"></a>

## Function `set_ballot_data`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_set_ballot_data">set_ballot_data</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;, t: TallyType)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_set_ballot_data">set_ballot_data</a>&lt;TallyType: drop + store &gt;(ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;, t: TallyType) {
  // Devs: FYI need <b>to</b> do this <b>internal</b> <b>to</b> the <b>module</b> that owns <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>
  // you won't be able <b>to</b> do this from outside the <b>module</b>
  ballot.tally_type = t;
}
</code></pre>



</details>

<a name="0x1_VoteLib_is_completed"></a>

## Function `is_completed`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>&lt;TallyType: drop, store&gt;(b: &<a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_is_completed">is_completed</a>&lt;TallyType: drop + store&gt;(b: &<a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;):bool {
  b.completed
}
</code></pre>



</details>

<a name="0x1_VoteLib_complete_ballot"></a>

## Function `complete_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_complete_ballot">complete_ballot</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_complete_ballot">complete_ballot</a>&lt;TallyType: drop + store&gt;(
  ballot: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;,
) {
  ballot.completed = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_VoteLib_extract_ballot"></a>

## Function `extract_ballot`

Pop a ballot off a list and return it. This is owned not mutable.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_extract_ballot">extract_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, from_status_enum: u8): <a href="VoteLib.md#0x1_VoteLib_Ballot">VoteLib::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_extract_ballot">extract_ballot</a>&lt;TallyType: drop + store&gt;(
  poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  from_status_enum: u8,
): <a href="VoteLib.md#0x1_VoteLib_Ballot">Ballot</a>&lt;TallyType&gt;{
  <b>let</b> (found, idx) = <a href="VoteLib.md#0x1_VoteLib_find_index_of_ballot">find_index_of_ballot</a>(poll, id, from_status_enum);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="VoteLib.md#0x1_VoteLib_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));
  <b>let</b> from_list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(poll, from_status_enum);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(from_list, idx)
}
</code></pre>



</details>

<a name="0x1_VoteLib_move_ballot"></a>

## Function `move_ballot`

extract a ballot and put on another list.


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_move_ballot">move_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">VoteLib::Vote</a>&lt;TallyType&gt;, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, from_status_enum: u8, to_status_enum: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_VoteLib_move_ballot">move_ballot</a>&lt;TallyType: drop + store&gt;(
  poll: &<b>mut</b> <a href="VoteLib.md#0x1_VoteLib_Vote">Vote</a>&lt;TallyType&gt;,
  id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  from_status_enum: u8,
  to_status_enum: u8,
) {
  <b>let</b> b = <a href="VoteLib.md#0x1_VoteLib_extract_ballot">extract_ballot</a>(poll, id, from_status_enum);
  <b>let</b> to_list = <a href="VoteLib.md#0x1_VoteLib_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(poll, to_status_enum);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(to_list, b);
}
</code></pre>



</details>
