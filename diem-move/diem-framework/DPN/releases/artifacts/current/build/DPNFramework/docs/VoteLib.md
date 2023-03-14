
<a name="0x1_DummyTestVote"></a>

# Module `0x1::DummyTestVote`



-  [Resource `Vote`](#0x1_DummyTestVote_Vote)
-  [Function `init`](#0x1_DummyTestVote_init)
-  [Function `vote`](#0x1_DummyTestVote_vote)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="VoteLib.md#0x1_ParticipationVote">0x1::ParticipationVote</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
</code></pre>



<a name="0x1_DummyTestVote_Vote"></a>

## Resource `Vote`



<pre><code><b>struct</b> <a href="VoteLib.md#0x1_DummyTestVote_Vote">Vote</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>ballot: <a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DummyTestVote_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_DummyTestVote_init">init</a>(sig: &signer): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_DummyTestVote_init">init</a>(sig: &signer): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);
  <b>let</b> ballot = <a href="VoteLib.md#0x1_ParticipationVote_new">ParticipationVote::new</a>(sig, b"please vote");
  <b>let</b> id = <a href="VoteLib.md#0x1_ParticipationVote_get_ballot_id">ParticipationVote::get_ballot_id</a>(&ballot);
  <b>move_to</b>(sig, <a href="VoteLib.md#0x1_DummyTestVote_Vote">Vote</a> { ballot });
  id
}
</code></pre>



</details>

<a name="0x1_DummyTestVote_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_DummyTestVote_vote">vote</a>(sig: &signer, election_addr: <b>address</b>, weight: u64, approve_reject: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteLib.md#0x1_DummyTestVote_vote">vote</a>(sig: &signer, election_addr: <b>address</b>, weight: u64, approve_reject: bool) <b>acquires</b> <a href="VoteLib.md#0x1_DummyTestVote_Vote">Vote</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 0);
  <b>let</b> vote = <b>borrow_global_mut</b>&lt;<a href="VoteLib.md#0x1_DummyTestVote_Vote">Vote</a>&gt;(election_addr);
  <a href="VoteLib.md#0x1_ParticipationVote_vote">ParticipationVote::vote</a>(&<b>mut</b> vote.ballot, sig, approve_reject, weight);
}
</code></pre>



</details>
