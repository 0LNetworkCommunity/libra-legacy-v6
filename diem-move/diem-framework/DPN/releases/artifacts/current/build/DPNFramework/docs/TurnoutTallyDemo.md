
<a name="0x1_TurnoutTallyDemo"></a>

# Module `0x1::TurnoutTallyDemo`



-  [Resource `Vote`](#0x1_TurnoutTallyDemo_Vote)
-  [Struct `EmptyType`](#0x1_TurnoutTallyDemo_EmptyType)
-  [Function `init`](#0x1_TurnoutTallyDemo_init)
-  [Function `propose_ballot_by_owner`](#0x1_TurnoutTallyDemo_propose_ballot_by_owner)
-  [Function `vote`](#0x1_TurnoutTallyDemo_vote)
-  [Function `retract`](#0x1_TurnoutTallyDemo_retract)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TurnoutTally.md#0x1_TurnoutTally">0x1::TurnoutTally</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_TurnoutTallyDemo_Vote"></a>

## Resource `Vote`



<pre><code><b>struct</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a>&lt;D&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tracker: <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;D&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>enrollment: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TurnoutTallyDemo_EmptyType"></a>

## Struct `EmptyType`



<pre><code><b>struct</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a> <b>has</b> drop, store
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

<a name="0x1_TurnoutTallyDemo_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_init">init</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_init">init</a>(
  sig: &signer,

) {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);

  <b>let</b> tracker = <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;();

  <b>move_to</b>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;&gt;(sig, <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a> {
    tracker,
    enrollment: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>()
  });
}
</code></pre>



</details>

<a name="0x1_TurnoutTallyDemo_propose_ballot_by_owner"></a>

## Function `propose_ballot_by_owner`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_propose_ballot_by_owner">propose_ballot_by_owner</a>(sig: &signer, voters: u64, duration: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_propose_ballot_by_owner">propose_ballot_by_owner</a>(sig: &signer, voters: u64, duration: u64) <b>acquires</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);
  <b>let</b> cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);
  <b>let</b> noop = <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a> {};

  <b>let</b> t = <a href="TurnoutTally.md#0x1_TurnoutTally_new_tally_struct">TurnoutTally::new_tally_struct</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;(noop, voters, duration, 0);

  <b>let</b> vote = <b>borrow_global_mut</b>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig));

  <a href="Ballot.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;(&<b>mut</b> vote.tracker, &cap, t);
}
</code></pre>



</details>

<a name="0x1_TurnoutTallyDemo_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_vote">vote</a>(sig: &signer, election_addr: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, weight: u64, approve_reject: bool): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_vote">vote</a>(sig: &signer, election_addr: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, weight: u64, approve_reject: bool): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; <b>acquires</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a> {
 <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);
 <b>let</b> vote = <b>borrow_global_mut</b>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;&gt;(election_addr);
 <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;(&<b>mut</b> vote.tracker, uid);
 <b>let</b> tally = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;(ballot);
 <a href="TurnoutTally.md#0x1_TurnoutTally_vote">TurnoutTally::vote</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;(sig, tally, uid, approve_reject, weight)
}
</code></pre>



</details>

<a name="0x1_TurnoutTallyDemo_retract"></a>

## Function `retract`



<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_retract">retract</a>(sig: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, election_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_retract">retract</a>(sig: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, election_addr: <b>address</b>) <b>acquires</b> <a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);
  <b>let</b> vote = <b>borrow_global_mut</b>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_Vote">Vote</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;&gt;(election_addr);
  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;(&<b>mut</b> vote.tracker, uid);
  <b>let</b> tally = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>&lt;<a href="TurnoutTally.md#0x1_TurnoutTally">TurnoutTally</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;&gt;(ballot);
  <a href="TurnoutTally.md#0x1_TurnoutTally_retract">TurnoutTally::retract</a>&lt;<a href="TurnoutTallyDemo.md#0x1_TurnoutTallyDemo_EmptyType">EmptyType</a>&gt;(tally, uid, sig);
}
</code></pre>



</details>
