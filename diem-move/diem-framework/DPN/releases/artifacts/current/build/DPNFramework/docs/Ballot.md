
<a name="0x1_Ballot"></a>

# Module `0x1::Ballot`

VoteLib is a primitive for creating Ballots, keeping track of them.
This library does not keep or manage any state. The BallotTracker and Ballots will be stored in your external contract.
It's meant to be generic, so you can use it for any kind of voting system, and even multisig type use cases.
There are examples on how to do this in BinaryBallot, and MultiSig.
All methods are restricted by the ability to aquire the BallotTracker and Ballots, and also the Owner's GUID CreateCapability (which can be moved into a struct so that it can be accessed programatically outside of owner transactions, see MultiSig as an example).
The actual logic of what happens when a ballot passes, exists outside of this module. That is, there are no "tally" methods here.
There are no handlers here either, your library needs to handle the result of a transaction and a vote outcome.
Developers may simply initialize a poll struct at the root level of their address, and include a field for BallotTracker (see BinaryBallot as an example).
Design:
VoteLib is only opinionated as to the possible status of Ballots: Pending, Approved, Rejected.
Every Ballot has a minimalist set fields properties: GUID and whether it is completed.
Examples of data include: what fields do you need for polling? Is is a simple counter of approve, reject, or do we need more fields (like a vector of addresses that voted yes). This library is unopinionated.
In that generic for TallyType, one can also nest a separate Struct with, and so on, like russian dolls. But in practice inside a TallyType you may want to add data for this ballots "issue" at hand, so that it can be programattically accessed by a handler. I.e. in a multisig case: You can have TallyType<PaymentInstruction> { addresses_in_favor: vector<address>, issue: PaymentInstruction }. Which in itself is PaymentInstruction { amount: u64, payee: address }.
Note to devs new to Move. Because of how Move language works, you are not able to mutate the Ballot type in a third party module. But there isn't much to do on it anyway, only mark it "completed". And there is a method for that.
What you may initially struggle with is the TallyType cannot be modified in this library, it must be mutated in the Library that defines your TallyType (see BinaryBallot). So you should borrow a mutable reference of the TallyType with get_type_struct_mut(), and then mutate it in your contract.


-  [Struct `Ballot`](#0x1_Ballot_Ballot)
-  [Struct `BallotTracker`](#0x1_Ballot_BallotTracker)
-  [Constants](#@Constants_0)
-  [Function `get_pending_enum`](#0x1_Ballot_get_pending_enum)
-  [Function `get_approved_enum`](#0x1_Ballot_get_approved_enum)
-  [Function `get_rejected_enum`](#0x1_Ballot_get_rejected_enum)
-  [Function `new_tracker`](#0x1_Ballot_new_tracker)
-  [Function `propose_ballot`](#0x1_Ballot_propose_ballot)
-  [Function `is_completed`](#0x1_Ballot_is_completed)
-  [Function `get_ballot_by_id`](#0x1_Ballot_get_ballot_by_id)
-  [Function `get_ballot_by_id_mut`](#0x1_Ballot_get_ballot_by_id_mut)
-  [Function `get_ballot`](#0x1_Ballot_get_ballot)
-  [Function `get_ballot_mut`](#0x1_Ballot_get_ballot_mut)
-  [Function `get_type_struct`](#0x1_Ballot_get_type_struct)
-  [Function `get_type_struct_mut`](#0x1_Ballot_get_type_struct_mut)
-  [Function `find_anywhere`](#0x1_Ballot_find_anywhere)
-  [Function `find_index_of_ballot`](#0x1_Ballot_find_index_of_ballot)
-  [Function `get_list_ballots_by_enum`](#0x1_Ballot_get_list_ballots_by_enum)
-  [Function `get_list_ballots_by_enum_mut`](#0x1_Ballot_get_list_ballots_by_enum_mut)
-  [Function `get_ballot_id`](#0x1_Ballot_get_ballot_id)
-  [Function `set_ballot_data`](#0x1_Ballot_set_ballot_data)
-  [Function `complete_ballot`](#0x1_Ballot_complete_ballot)
-  [Function `extract_ballot`](#0x1_Ballot_extract_ballot)
-  [Function `move_ballot`](#0x1_Ballot_move_ballot)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Ballot_Ballot"></a>

## Struct `Ballot`



<pre><code><b>struct</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt; <b>has</b> drop, store
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

<a name="0x1_Ballot_BallotTracker"></a>

## Struct `BallotTracker`



<pre><code><b>struct</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>ballots_pending: vector&lt;<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_approved: vector&lt;<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ballots_rejected: vector&lt;<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Ballot_APPROVED"></a>



<pre><code><b>const</b> <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_Ballot_EBAD_STATUS_ENUM"></a>

Bad status enum


<pre><code><b>const</b> <a href="Ballot.md#0x1_Ballot_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>: u64 = 300011;
</code></pre>



<a name="0x1_Ballot_ENO_BALLOT_FOUND"></a>

No ballot found under that GUID


<pre><code><b>const</b> <a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 300010;
</code></pre>



<a name="0x1_Ballot_PENDING"></a>



<pre><code><b>const</b> <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_Ballot_REJECTED"></a>



<pre><code><b>const</b> <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_Ballot_get_pending_enum"></a>

## Function `get_pending_enum`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_pending_enum">get_pending_enum</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_pending_enum">get_pending_enum</a>(): u8 {
  <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>
}
</code></pre>



</details>

<a name="0x1_Ballot_get_approved_enum"></a>

## Function `get_approved_enum`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_approved_enum">get_approved_enum</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_approved_enum">get_approved_enum</a>(): u8 {
  <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>
}
</code></pre>



</details>

<a name="0x1_Ballot_get_rejected_enum"></a>

## Function `get_rejected_enum`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_rejected_enum">get_rejected_enum</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_rejected_enum">get_rejected_enum</a>(): u8 {
  <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>
}
</code></pre>



</details>

<a name="0x1_Ballot_new_tracker"></a>

## Function `new_tracker`

The poll constructor. Use this to create the tracker for each (generic) TallyType that you are instantiating. You may have multiple polls, each with a different TallyType tracker.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_new_tracker">new_tracker</a>&lt;TallyType: drop, store&gt;(): <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_new_tracker">new_tracker</a>&lt;TallyType: drop + store&gt;(): <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt; {
  <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a> {
    ballots_pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    ballots_rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  }
}
</code></pre>



</details>

<a name="0x1_Ballot_propose_ballot"></a>

## Function `propose_ballot`

If you have a mutable BallotTracker instance AND you have the GUID Create Capability, you can use this to create a ballot.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_propose_ballot">propose_ballot</a>&lt;TallyType: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, tally_type: TallyType): &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_propose_ballot">propose_ballot</a>&lt;TallyType:  drop + store&gt;(
  tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>, // whoever is ceating this issue needs access <b>to</b> the <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">GUID</a> creation capability
  // issue: IssueData,
  tally_type: TallyType,
): &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;  {
  <b>let</b> ignored_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_get_capability_address">GUID::get_capability_address</a>(guid_cap); // Note 0L's modification <b>to</b> Std::GUID, <b>to</b> get_capability_address

  <b>let</b> b = <a href="Ballot.md#0x1_Ballot">Ballot</a> {

    guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_with_capability">GUID::create_with_capability</a>(ignored_addr, guid_cap), // Note 0L's modification <b>to</b> Std::GUID, <b>address</b> is ignored.
    tally_type,
    completed: <b>false</b>,

  };
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&tracker.ballots_pending);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> tracker.ballots_pending, b);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> tracker.ballots_pending, len)
}
</code></pre>



</details>

<a name="0x1_Ballot_is_completed"></a>

## Function `is_completed`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_is_completed">is_completed</a>&lt;TallyType: drop, store&gt;(b: &<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_is_completed">is_completed</a>&lt;TallyType: drop + store&gt;(b: &<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;):bool {
  b.completed
}
</code></pre>



</details>

<a name="0x1_Ballot_get_ballot_by_id"></a>

## Function `get_ballot_by_id`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">get_ballot_by_id</a>&lt;TallyType: drop, store&gt;(poll: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">get_ballot_by_id</a>&lt;TallyType: drop + store&gt; (
  poll: & <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): &<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> (found, idx, status_enum, _completed) = <a href="Ballot.md#0x1_Ballot_find_anywhere">find_anywhere</a>(poll, guid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="Ballot.md#0x1_Ballot_get_ballot">get_ballot</a>&lt;TallyType&gt;(poll, idx, status_enum)
}
</code></pre>



</details>

<a name="0x1_Ballot_get_ballot_by_id_mut"></a>

## Function `get_ballot_by_id_mut`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">get_ballot_by_id_mut</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">get_ballot_by_id_mut</a>&lt;TallyType: drop + store&gt; (
  poll: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> (found, idx, status_enum, _completed) = <a href="Ballot.md#0x1_Ballot_find_anywhere">find_anywhere</a>(poll, guid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="Ballot.md#0x1_Ballot_get_ballot_mut">get_ballot_mut</a>&lt;TallyType&gt;(poll, idx, status_enum)
}
</code></pre>



</details>

<a name="0x1_Ballot_get_ballot"></a>

## Function `get_ballot`

function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot">get_ballot</a>&lt;TallyType: drop, store&gt;(poll: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, idx: u64, status_enum: u8): &<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot">get_ballot</a>&lt;TallyType: drop + store&gt; (
  poll: &<a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  idx: u64,
  status_enum: u8
): &<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType&gt;(poll, status_enum);

  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list) &gt; idx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list, idx)
}
</code></pre>



</details>

<a name="0x1_Ballot_get_ballot_mut"></a>

## Function `get_ballot_mut`

function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_mut">get_ballot_mut</a>&lt;TallyType: drop, store&gt;(poll: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, idx: u64, status_enum: u8): &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_mut">get_ballot_mut</a>&lt;TallyType: drop + store&gt; (
  poll: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  idx: u64,
  status_enum: u8
): &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt; {

  <b>let</b> list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(poll, status_enum);

  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list) &gt; idx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(list, idx)
}
</code></pre>



</details>

<a name="0x1_Ballot_get_type_struct"></a>

## Function `get_type_struct`

For fetching the underlying TallyType struct (which is defined in your third party module)


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_type_struct">get_type_struct</a>&lt;TallyType: drop, store&gt;(ballot: &<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;): &TallyType
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_type_struct">get_type_struct</a>&lt;TallyType: drop + store &gt;(ballot: &<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;): &TallyType {
  <b>return</b> &ballot.tally_type
}
</code></pre>



</details>

<a name="0x1_Ballot_get_type_struct_mut"></a>

## Function `get_type_struct_mut`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">get_type_struct_mut</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;): &<b>mut</b> TallyType
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">get_type_struct_mut</a>&lt;TallyType: drop + store &gt;(ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;): &<b>mut</b> TallyType {
  <b>return</b> &<b>mut</b> ballot.tally_type
}
</code></pre>



</details>

<a name="0x1_Ballot_find_anywhere"></a>

## Function `find_anywhere`

find the ballot wherever it is: pending, approved, rejected.
returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_find_anywhere">find_anywhere</a>&lt;TallyType: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_find_anywhere">find_anywhere</a>&lt;TallyType: drop + store&gt; (
  tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
): (bool, u64, u8, bool) {

 // looking in pending
 <b>let</b> (found, idx) = <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>(tracker, proposal_guid, <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>);
 <b>if</b> (found) {
  <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&tracker.ballots_pending, idx));
   <b>return</b> (<b>true</b>, idx, <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>, complete)
 };

 // looking in approved
  <b>let</b> (found, idx) = <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>(tracker, proposal_guid, <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&tracker.ballots_approved, idx));
    <b>return</b> (<b>true</b>, idx, <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>, complete)
  };

 // looking in rejected
  <b>let</b> (found, idx) = <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>(tracker, proposal_guid, <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>);
  <b>if</b> (found) {
    <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">is_completed</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&tracker.ballots_rejected, idx));
    <b>return</b> (<b>true</b>, idx, <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>, complete)
  };

  (<b>false</b>, 0, 0, <b>false</b>)
}
</code></pre>



</details>

<a name="0x1_Ballot_find_index_of_ballot"></a>

## Function `find_index_of_ballot`

find the index in list, if you know the GUID.
If you need to search for the GUID by data, Ballot cannot do that.
since you may need to look at specific fields to find duplications
you'll need to do the search wherever TallyType is defined.
For example: if we tried to do it here, and there was a field of <code>voted</code> addresses, you would never find a duplicate.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>&lt;TallyType: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, status_enum: u8): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>&lt;TallyType: drop + store&gt; (
  tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  proposal_guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  status_enum: u8,
): (bool, u64) {

 <b>let</b> list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType&gt;(tracker, status_enum);

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

<a name="0x1_Ballot_get_list_ballots_by_enum"></a>

## Function `get_list_ballots_by_enum`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, status_enum: u8): &vector&lt;<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">get_list_ballots_by_enum</a>&lt;TallyType: drop + store &gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;, status_enum: u8): &vector&lt;<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;&gt; {
 <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>) {
    &tracker.ballots_pending
  } <b>else</b> <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>) {
    &tracker.ballots_approved
  } <b>else</b> <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>) {
    &tracker.ballots_rejected
  } <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>));
    & tracker.ballots_rejected // dummy <b>return</b>
  }
}
</code></pre>



</details>

<a name="0x1_Ballot_get_list_ballots_by_enum_mut"></a>

## Function `get_list_ballots_by_enum_mut`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType: drop + store &gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;, status_enum: u8): &<b>mut</b> vector&lt;<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;&gt; {
 <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_PENDING">PENDING</a>) {
    &<b>mut</b> tracker.ballots_pending
  } <b>else</b> <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_APPROVED">APPROVED</a>) {
    &<b>mut</b> tracker.ballots_approved
  } <b>else</b> <b>if</b> (status_enum == <a href="Ballot.md#0x1_Ballot_REJECTED">REJECTED</a>) {
    &<b>mut</b> tracker.ballots_rejected
  } <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>));
    &<b>mut</b> tracker.ballots_rejected // dummy <b>return</b>
  }
}
</code></pre>



</details>

<a name="0x1_Ballot_get_ballot_id"></a>

## Function `get_ballot_id`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_id">get_ballot_id</a>&lt;TallyType: drop, store&gt;(ballot: &<a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_get_ballot_id">get_ballot_id</a>&lt;TallyType: drop + store &gt;(ballot: &<a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;): ID {
  <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&ballot.guid)
}
</code></pre>



</details>

<a name="0x1_Ballot_set_ballot_data"></a>

## Function `set_ballot_data`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_set_ballot_data">set_ballot_data</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;, t: TallyType)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_set_ballot_data">set_ballot_data</a>&lt;TallyType: drop + store &gt;(ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;, t: TallyType) {
  // Devs: FYI need <b>to</b> do this <b>internal</b> <b>to</b> the <b>module</b> that owns <a href="Ballot.md#0x1_Ballot">Ballot</a>
  // you won't be able <b>to</b> do this from outside the <b>module</b>
  ballot.tally_type = t;
}
</code></pre>



</details>

<a name="0x1_Ballot_complete_ballot"></a>

## Function `complete_ballot`



<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_complete_ballot">complete_ballot</a>&lt;TallyType: drop, store&gt;(ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_complete_ballot">complete_ballot</a>&lt;TallyType: drop + store&gt;(
  ballot: &<b>mut</b> <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;,
) {
  ballot.completed = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_Ballot_extract_ballot"></a>

## Function `extract_ballot`

Pop a ballot off a list and return it. This is owned not mutable.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_extract_ballot">extract_ballot</a>&lt;TallyType: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, from_status_enum: u8): <a href="Ballot.md#0x1_Ballot_Ballot">Ballot::Ballot</a>&lt;TallyType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_extract_ballot">extract_ballot</a>&lt;TallyType: drop + store&gt;(
  tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  from_status_enum: u8,
): <a href="Ballot.md#0x1_Ballot">Ballot</a>&lt;TallyType&gt;{
  <b>let</b> (found, idx) = <a href="Ballot.md#0x1_Ballot_find_index_of_ballot">find_index_of_ballot</a>(tracker, id, from_status_enum);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Ballot.md#0x1_Ballot_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>));
  <b>let</b> from_list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(tracker, from_status_enum);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(from_list, idx)
}
</code></pre>



</details>

<a name="0x1_Ballot_move_ballot"></a>

## Function `move_ballot`

extract a ballot and put on another list.


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_move_ballot">move_ballot</a>&lt;TallyType: drop, store&gt;(tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;TallyType&gt;, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, from_status_enum: u8, to_status_enum: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Ballot.md#0x1_Ballot_move_ballot">move_ballot</a>&lt;TallyType: drop + store&gt;(
  tracker: &<b>mut</b> <a href="Ballot.md#0x1_Ballot_BallotTracker">BallotTracker</a>&lt;TallyType&gt;,
  id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  from_status_enum: u8,
  to_status_enum: u8,
) {
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_extract_ballot">extract_ballot</a>(tracker, id, from_status_enum);
  <b>let</b> to_list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum_mut">get_list_ballots_by_enum_mut</a>&lt;TallyType&gt;(tracker, to_status_enum);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(to_list, b);
}
</code></pre>



</details>
