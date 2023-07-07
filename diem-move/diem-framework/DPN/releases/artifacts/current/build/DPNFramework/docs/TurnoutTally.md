
<a name="0x1_TurnoutTally"></a>

# Module `0x1::TurnoutTally`



-  [Resource `TurnoutTally`](#0x1_TurnoutTally_TurnoutTally)
-  [Constants](#@Constants_0)
-  [Function `new_tally_struct`](#0x1_TurnoutTally_new_tally_struct)
-  [Function `update_enrollment`](#0x1_TurnoutTally_update_enrollment)
-  [Function `vote`](#0x1_TurnoutTally_vote)
-  [Function `maybe_complete`](#0x1_TurnoutTally_maybe_complete)
-  [Function `retract`](#0x1_TurnoutTally_retract)
-  [Function `extend_deadline`](#0x1_TurnoutTally_extend_deadline)
-  [Function `maybe_auto_competitive_extend`](#0x1_TurnoutTally_maybe_auto_competitive_extend)
-  [Function `is_competitive`](#0x1_TurnoutTally_is_competitive)
-  [Function `maybe_tally`](#0x1_TurnoutTally_maybe_tally)
-  [Function `get_threshold_from_turnout`](#0x1_TurnoutTally_get_threshold_from_turnout)
-  [Function `get_tally`](#0x1_TurnoutTally_get_tally)
-  [Function `get_tally_data`](#0x1_TurnoutTally_get_tally_data)
-  [Function `maybe_complete_result`](#0x1_TurnoutTally_maybe_complete_result)


<pre><code><b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="VoteReceipt.md#0x1_VoteReceipt">0x1::VoteReceipt</a>;
</code></pre>



<a name="0x1_TurnoutTally_TurnoutTally"></a>

## Resource `TurnoutTally`

for voting to happen with the VoteLib module, the GUID creation capability must be passed in, and so the signer for the addres (the "sponsor" of the ballot) must move the capability to be accessible by the contract logic.


<pre><code><b>struct</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>data: Data</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_deadline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_max_extensions: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_min_turnout: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_minority_extension: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>completed: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>enrollment: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>max_votes: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>votes_approve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>votes_reject: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>extended_deadline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_epoch_voted: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_epoch_approve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_epoch_reject: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>provisional_pass_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_approve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_turnout: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_pass: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TurnoutTally_APPROVED"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_APPROVED">APPROVED</a>: u8 = 2;
</code></pre>



<a name="0x1_TurnoutTally_EBAD_STATUS_ENUM"></a>

Bad status enum


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_EBAD_STATUS_ENUM">EBAD_STATUS_ENUM</a>: u64 = 300016;
</code></pre>



<a name="0x1_TurnoutTally_ENO_BALLOT_FOUND"></a>

No ballot found under that GUID


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_ENO_BALLOT_FOUND">ENO_BALLOT_FOUND</a>: u64 = 300015;
</code></pre>



<a name="0x1_TurnoutTally_PENDING"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_PENDING">PENDING</a>: u8 = 1;
</code></pre>



<a name="0x1_TurnoutTally_REJECTED"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_REJECTED">REJECTED</a>: u8 = 3;
</code></pre>



<a name="0x1_TurnoutTally_EALREADY_VOTED"></a>

Voters cannot vote twice, but they can retract a vote


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_EALREADY_VOTED">EALREADY_VOTED</a>: u64 = 300013;
</code></pre>



<a name="0x1_TurnoutTally_ECOMPLETED"></a>

The ballot has already been completed.


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_ECOMPLETED">ECOMPLETED</a>: u64 = 300010;
</code></pre>



<a name="0x1_TurnoutTally_ENOT_VOTED"></a>

The voter has not voted yet. Cannot retract a vote.


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_ENOT_VOTED">ENOT_VOTED</a>: u64 = 300014;
</code></pre>



<a name="0x1_TurnoutTally_EVOTES_GREATER_THAN_ENROLLMENT"></a>

The number of votes cast cannot be greater than the max number of votes available from enrollment.


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_EVOTES_GREATER_THAN_ENROLLMENT">EVOTES_GREATER_THAN_ENROLLMENT</a>: u64 = 300011;
</code></pre>



<a name="0x1_TurnoutTally_EVOTE_CALC_PARAMS"></a>

The threshold curve parameters are wrong. The curve is not decreasing.


<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_EVOTE_CALC_PARAMS">EVOTE_CALC_PARAMS</a>: u64 = 300012;
</code></pre>



<a name="0x1_TurnoutTally_HIGH_TURNOUT_X2"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_HIGH_TURNOUT_X2">HIGH_TURNOUT_X2</a>: u64 = 8750;
</code></pre>



<a name="0x1_TurnoutTally_LOW_TURNOUT_X1"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>: u64 = 1250;
</code></pre>



<a name="0x1_TurnoutTally_MINORITY_EXT_MARGIN"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_MINORITY_EXT_MARGIN">MINORITY_EXT_MARGIN</a>: u64 = 500;
</code></pre>



<a name="0x1_TurnoutTally_PCT_SCALE"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>: u64 = 10000;
</code></pre>



<a name="0x1_TurnoutTally_THRESH_AT_HIGH_TURNOUT_Y2"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>: u64 = 5100;
</code></pre>



<a name="0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1"></a>



<pre><code><b>const</b> <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a>: u64 = 10000;
</code></pre>



<a name="0x1_TurnoutTally_new_tally_struct"></a>

## Function `new_tally_struct`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_new_tally_struct">new_tally_struct</a>&lt;Data: drop, store&gt;(data: Data, max_vote_enrollment: u64, deadline: u64, max_extensions: u64): <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_new_tally_struct">new_tally_struct</a>&lt;Data: drop + store&gt;(
  // guid_cap: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a>,
  data: Data,
  max_vote_enrollment: u64,
  deadline: u64,
  max_extensions: u64,
): <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt; {
    <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt; {
      data,
      cfg_deadline: deadline,
      cfg_max_extensions: max_extensions, // 0 means infinite extensions
      cfg_min_turnout: 1250,
      cfg_minority_extension: <b>true</b>,
      completed: <b>false</b>,
      enrollment: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(), // TODO: maybe consider merkle roots, or bloom filters here.
      max_votes: max_vote_enrollment,
      votes_approve: 0,
      votes_reject: 0,
      extended_deadline: deadline,
      last_epoch_voted: 0,
      last_epoch_approve: 0,
      last_epoch_reject: 0,
      provisional_pass_epoch: 0,
      tally_approve: 0,
      tally_turnout: 0,
      tally_pass: <b>false</b>,
    }
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_update_enrollment"></a>

## Function `update_enrollment`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_update_enrollment">update_enrollment</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;, enrollment: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_update_enrollment">update_enrollment</a>&lt;Data: drop + store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;, enrollment: vector&lt;<b>address</b>&gt;) {
  <b>assert</b>!(!<a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete">maybe_complete</a>(ballot), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_ECOMPLETED">ECOMPLETED</a>));
  ballot.enrollment = enrollment;
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_vote">vote</a>&lt;Data: drop, store&gt;(user: &signer, ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, approve_reject: bool, weight: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_vote">vote</a>&lt;Data: drop + store&gt;(
  user: &signer,
  ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  approve_reject: bool,
  weight: u64
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; {
  // voting should not be complete
  <b>assert</b>!(!<a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete">maybe_complete</a>(ballot), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_ECOMPLETED">ECOMPLETED</a>));

  // check <b>if</b> this person voted already.
  // If the vote is the same directionally (approve, reject), exit early.
  // otherwise, need <b>to</b> subtract the <b>old</b> vote and add the new vote.
  <b>let</b> user_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(user);
  <b>let</b> (_, is_found) = <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">VoteReceipt::find_prior_vote_idx</a>(user_addr, uid);

  <b>assert</b>!(!is_found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_EALREADY_VOTED">EALREADY_VOTED</a>));

  // <b>if</b> we are in a new epoch than the previous last voter, then store that epoch data.
  <b>let</b> epoch_now = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  <b>if</b> (epoch_now &gt; ballot.last_epoch_voted) {
    ballot.last_epoch_approve = ballot.votes_approve;
    ballot.last_epoch_reject = ballot.votes_reject;
  };

  // in every case, add the new vote
  ballot.last_epoch_voted = epoch_now;
  <b>if</b> (approve_reject) {
    ballot.votes_approve = ballot.votes_approve + weight;
  } <b>else</b> {
    ballot.votes_reject = ballot.votes_reject + weight;
  };

  // always tally on each vote
  // make sure all extensions happened in previous step.
  <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_tally">maybe_tally</a>(ballot);

  // this will handle the case of updating the receipt in case this is a second vote.
  <a href="VoteReceipt.md#0x1_VoteReceipt_make_receipt">VoteReceipt::make_receipt</a>(user, uid, approve_reject, weight);

  <b>if</b> (ballot.completed) { <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(ballot.tally_pass) };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;() // <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>() <b>if</b> complete, and bool <b>if</b> it passed, so it can be used in a third party contract handler for lazy evaluation.
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_maybe_complete"></a>

## Function `maybe_complete`



<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete">maybe_complete</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete">maybe_complete</a>&lt;Data: drop + store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;): bool {
  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  // <b>if</b> completed, exit early
  <b>if</b> (ballot.completed) { <b>return</b> <b>true</b> }; // this should be checked above anyways.

  // this may be a vote that never expires, until a decision is reached
  <b>if</b> (ballot.cfg_deadline == 0 ) { <b>return</b> <b>false</b> };

  // <b>if</b> original and extended deadline have passed, stop tally
  // <b>while</b> we are here, <b>update</b> <b>to</b> "completed".
  <b>if</b> (
    epoch &gt; ballot.cfg_deadline &&
    epoch &gt; ballot.extended_deadline
  ) {
    ballot.completed = <b>true</b>;
    <b>return</b> <b>true</b>
  };
  ballot.completed
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_retract"></a>

## Function `retract`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_retract">retract</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, user: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_retract">retract</a>&lt;Data: drop + store&gt;(
  ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
  user: &signer
) {
  <b>let</b> user_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(user);

  <b>let</b> (_idx, is_found) = <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">VoteReceipt::find_prior_vote_idx</a>(user_addr, uid);
  <b>assert</b>!(is_found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_ENOT_VOTED">ENOT_VOTED</a>));

  <b>let</b> (approve_reject, weight) = <a href="VoteReceipt.md#0x1_VoteReceipt_get_receipt_data">VoteReceipt::get_receipt_data</a>(user_addr, uid);

  <b>if</b> (approve_reject) {
    ballot.votes_approve = ballot.votes_approve - weight;
  } <b>else</b> {
    ballot.votes_reject = ballot.votes_reject - weight;
  };

  <a href="VoteReceipt.md#0x1_VoteReceipt_remove_vote_receipt">VoteReceipt::remove_vote_receipt</a>(user, uid);
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_extend_deadline"></a>

## Function `extend_deadline`

The handler for a third party contract may wish to extend the ballot deadline.
DANGER: the thirdparty ballot contract needs to know what it is doing. If this ballot object is exposed to end users it's game over.


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_extend_deadline">extend_deadline</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;, new_epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_extend_deadline">extend_deadline</a>&lt;Data: drop + store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;, new_epoch: u64) {

  ballot.extended_deadline = new_epoch;
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_maybe_auto_competitive_extend"></a>

## Function `maybe_auto_competitive_extend`

A third party contract can optionally call this function to extend the deadline to extend ballots in competitive situations.
we may need to extend the ballot if on the last day (TBD a wider window) the vote had a big shift in favor of the minority vote.
All that needs to be done, is on the return of vote(), to then call this function.
It's a useful feature, but it will not be included by default in all votes.


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_auto_competitive_extend">maybe_auto_competitive_extend</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_auto_competitive_extend">maybe_auto_competitive_extend</a>&lt;Data: drop + store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;):u64  {

  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  // TODO: The exension window below of 1 day is not sufficient <b>to</b> make
  // much difference in practice (the threshold is most likely reached at that point).

  // Are we on the last day of voting (extension window)? If not exit
  <b>if</b> (epoch == ballot.extended_deadline || epoch == ballot.cfg_deadline) { <b>return</b> ballot.extended_deadline };

  <b>if</b> (<a href="TurnoutTally.md#0x1_TurnoutTally_is_competitive">is_competitive</a>(ballot)) {
    // we may have extended already, but we don't want <b>to</b> extend more than once per day.
    <b>if</b> (ballot.extended_deadline &gt; epoch) { <b>return</b> ballot.extended_deadline };

    // extend the deadline by 1 day
    ballot.extended_deadline = epoch + 1;
  };


  ballot.extended_deadline
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_is_competitive"></a>

## Function `is_competitive`



<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_is_competitive">is_competitive</a>&lt;Data: drop, store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_is_competitive">is_competitive</a>&lt;Data: drop + store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;): bool {
  <b>let</b> (prev_lead, prev_trail, prev_lead_updated, prev_trail_updated) = <b>if</b> (ballot.last_epoch_approve &gt; ballot.last_epoch_reject) {
    // <b>if</b> the "approve" vote WAS leading.
    (ballot.last_epoch_approve, ballot.last_epoch_reject, ballot.votes_approve, ballot.votes_reject)

  } <b>else</b> {
    (ballot.last_epoch_reject, ballot.last_epoch_approve, ballot.votes_reject, ballot.votes_approve)
  };


  // no votes yet
  <b>if</b> (prev_lead == 0 && prev_trail == 0) { <b>return</b> <b>false</b> };
  <b>if</b> (prev_lead_updated == 0 && prev_trail_updated == 0) { <b>return</b> <b>false</b>};

  <b>let</b> prior_margin = ((prev_lead - prev_trail) * <a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>) / (prev_lead + prev_trail);


  // the current margin may have flipped, so we need <b>to</b> check the direction of the vote.
  // <b>if</b> so then give an automatic extensions
  <b>if</b> (prev_lead_updated &lt; prev_trail_updated) {
    <b>return</b> <b>true</b>
  } <b>else</b> {
    <b>let</b> current_margin = (prev_lead_updated - prev_trail_updated) * <a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a> / (prev_lead_updated + prev_trail_updated);

    <b>if</b> (current_margin - prior_margin &gt; <a href="TurnoutTally.md#0x1_TurnoutTally_MINORITY_EXT_MARGIN">MINORITY_EXT_MARGIN</a>) {
      <b>return</b> <b>true</b>
    }
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_maybe_tally"></a>

## Function `maybe_tally`

stop tallying if the expiration is passed or the threshold has been met.


<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_tally">maybe_tally</a>&lt;Data: drop, store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_tally">maybe_tally</a>&lt;Data: drop + store&gt;(ballot: &<b>mut</b> <a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;) {
  <b>let</b> total_votes = ballot.votes_approve + ballot.votes_reject;

  <b>assert</b>!(ballot.max_votes &gt;= total_votes, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_EVOTES_GREATER_THAN_ENROLLMENT">EVOTES_GREATER_THAN_ENROLLMENT</a>));

  // figure out the turnout
  <b>let</b> m = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(total_votes, ballot.max_votes);

  ballot.tally_turnout = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>, m); // scale up

  // calculate the dynamic threshold needed.
  <b>let</b> thresh = <a href="TurnoutTally.md#0x1_TurnoutTally_get_threshold_from_turnout">get_threshold_from_turnout</a>(total_votes, ballot.max_votes);
  // check the threshold that needs <b>to</b> be met met turnout
  ballot.tally_approve = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(ballot.votes_approve, total_votes));

  // the first vote which crosses the threshold causes the poll <b>to</b> end.
  <b>if</b> (ballot.tally_approve &gt; thresh) {
    // before marking it pass, make sure the minimum quorum was met
    // by default 12.50%
    <b>if</b> (ballot.tally_turnout &gt; ballot.cfg_min_turnout) {
      <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

      // cool off period, <b>to</b> next epoch.
      <b>if</b> (ballot.provisional_pass_epoch == 0) {
        // setting the next epoch in which the tally will be final.
        // NOTE: <b>requires</b> a second vote <b>to</b> be cast <b>to</b> finalize the tally.
        // automatically passing once the threshold is reached disadvantages inactive participants.
        // We propose it takes one vote plus one day once reaching threshold.
        ballot.provisional_pass_epoch = epoch;

      } <b>else</b> <b>if</b> (epoch &gt; ballot.provisional_pass_epoch) {
        // multiple days may have passed since the provisional pass.
        ballot.completed = <b>true</b>;
        ballot.tally_pass = <b>true</b>;
      }
    }
  }
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_get_threshold_from_turnout"></a>

## Function `get_threshold_from_turnout`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_threshold_from_turnout">get_threshold_from_turnout</a>(voters: u64, max_votes: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_threshold_from_turnout">get_threshold_from_turnout</a>(voters: u64, max_votes: u64): u64 {
  // <b>let</b>'s just do a line

  <b>let</b> turnout = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(voters, max_votes);
  <b>let</b> turnout_scaled_x = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>, turnout); // scale <b>to</b> two decimal points.
  // only implemeting the negative slope case. Unsure why the other is needed.

  <b>assert</b>!(<a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a> &gt; <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_EVOTE_CALC_PARAMS">EVOTE_CALC_PARAMS</a>));

  // the minimum passing threshold is the low turnout threshold.
  // same for the maximum turnout threshold.
  <b>if</b> (turnout_scaled_x &lt; <a href="TurnoutTally.md#0x1_TurnoutTally_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>) {
    <b>return</b> <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a>
  } <b>else</b> <b>if</b> (turnout_scaled_x &gt; <a href="TurnoutTally.md#0x1_TurnoutTally_HIGH_TURNOUT_X2">HIGH_TURNOUT_X2</a>) {
    <b>return</b> <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>
  };


  <b>let</b> abs_m = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(
    (<a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a> - <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_HIGH_TURNOUT_Y2">THRESH_AT_HIGH_TURNOUT_Y2</a>), (<a href="TurnoutTally.md#0x1_TurnoutTally_HIGH_TURNOUT_X2">HIGH_TURNOUT_X2</a> - <a href="TurnoutTally.md#0x1_TurnoutTally_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>)
  );

  <b>let</b> abs_mx = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_LOW_TURNOUT_X1">LOW_TURNOUT_X1</a>, *&abs_m);
  <b>let</b> b = <a href="TurnoutTally.md#0x1_TurnoutTally_THRESH_AT_LOW_TURNOUT_Y1">THRESH_AT_LOW_TURNOUT_Y1</a> + abs_mx;
  <b>let</b> y =  b - <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(turnout_scaled_x, *&abs_m);

  <b>return</b> y
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_get_tally"></a>

## Function `get_tally`

get current tally


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_tally">get_tally</a>&lt;Data: <b>copy</b>, store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_tally">get_tally</a>&lt;Data: <b>copy</b> + store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;): u64 {
  <b>let</b> total = ballot.votes_approve + ballot.votes_reject;
  <b>if</b> (ballot.votes_approve + ballot.votes_reject &gt; ballot.max_votes) {
    <b>return</b> 0
  };
  <b>if</b> (ballot.max_votes == 0) {
    <b>return</b> 0
  };
  <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="TurnoutTally.md#0x1_TurnoutTally_PCT_SCALE">PCT_SCALE</a>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(total, ballot.max_votes))
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_get_tally_data"></a>

## Function `get_tally_data`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_tally_data">get_tally_data</a>&lt;Data: store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): &Data
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_get_tally_data">get_tally_data</a>&lt;Data: store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;): &Data {
  &ballot.data
}
</code></pre>



</details>

<a name="0x1_TurnoutTally_maybe_complete_result"></a>

## Function `maybe_complete_result`

is it complete and what's the result


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete_result">maybe_complete_result</a>&lt;Data: <b>copy</b>, store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally_TurnoutTally">TurnoutTally::TurnoutTally</a>&lt;Data&gt;): (bool, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTally.md#0x1_TurnoutTally_maybe_complete_result">maybe_complete_result</a>&lt;Data: <b>copy</b> + store&gt;(ballot: &<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;Data&gt;): (bool, bool) {
  (ballot.completed, ballot.tally_pass)
}
</code></pre>



</details>
