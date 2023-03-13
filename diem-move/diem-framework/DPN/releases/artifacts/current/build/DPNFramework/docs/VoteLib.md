
<a name="0x1_ParticipationVote"></a>

# Module `0x1::ParticipationVote`



-  [Resource `MyElections`](#0x1_ParticipationVote_MyElections)
-  [Resource `Ballot`](#0x1_ParticipationVote_Ballot)
-  [Constants](#@Constants_0)
-  [Function `maybe_init_elections`](#0x1_ParticipationVote_maybe_init_elections)
-  [Function `user_init_ballot`](#0x1_ParticipationVote_user_init_ballot)
-  [Function `find_index_ballot`](#0x1_ParticipationVote_find_index_ballot)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="VectorHelper.md#0x1_VectorHelper">0x1::VectorHelper</a>;
</code></pre>



<a name="0x1_ParticipationVote_MyElections"></a>

## Resource `MyElections`



<pre><code><b>struct</b> <a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>active: vector&lt;<a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>completed: vector&lt;<a href="VoteLib.md#0x1_ParticipationVote_Ballot">ParticipationVote::Ballot</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ParticipationVote_Ballot"></a>

## Resource `Ballot`



<pre><code><b>struct</b> <a href="VoteLib.md#0x1_ParticipationVote_Ballot">Ballot</a> <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>name: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_min_deadline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_max_deadline: u64</code>
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
<code>in_progress: bool</code>
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
<code>epochs_extended: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tally_turnout: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a></code>
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


<a name="0x1_ParticipationVote_EEXISTS_ACTIVE"></a>

A current active ballot with this name already exists.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_ParticipationVote_EEXISTS_ACTIVE">EEXISTS_ACTIVE</a>: u64 = 200010;
</code></pre>



<a name="0x1_ParticipationVote_EEXISTS_COMPLETED"></a>

A completed ballot with this name already exists.


<pre><code><b>const</b> <a href="VoteLib.md#0x1_ParticipationVote_EEXISTS_COMPLETED">EEXISTS_COMPLETED</a>: u64 = 200011;
</code></pre>



<a name="0x1_ParticipationVote_maybe_init_elections"></a>

## Function `maybe_init_elections`



<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_maybe_init_elections">maybe_init_elections</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_maybe_init_elections">maybe_init_elections</a>(sig: &signer) {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>if</b> (!<b>exists</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(addr)) {
    <b>let</b> elections = <a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a> {
      active: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      completed: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    };
    <b>move_to</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(sig, elections);
  }
}
</code></pre>



</details>

<a name="0x1_ParticipationVote_user_init_ballot"></a>

## Function `user_init_ballot`



<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_user_init_ballot">user_init_ballot</a>(sig: &signer, name: vector&lt;u8&gt;, cfg_min_deadline: u64, cfg_max_deadline: u64, cfg_min_turnout: u64, cfg_minority_extension: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_user_init_ballot">user_init_ballot</a>(
  sig: &signer,
  name: vector&lt;u8&gt;,
  cfg_min_deadline: u64,
  cfg_max_deadline: u64,
  cfg_min_turnout: u64,
  cfg_minority_extension: bool
) <b>acquires</b> <a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a> {
  <a href="VoteLib.md#0x1_ParticipationVote_maybe_init_elections">maybe_init_elections</a>(sig);

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);

  <b>if</b> (!<b>exists</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(addr)) {
    <a href="VoteLib.md#0x1_ParticipationVote_maybe_init_elections">maybe_init_elections</a>(sig);
  };

  <b>let</b> (_, is_found_active) = <a href="VoteLib.md#0x1_ParticipationVote_find_index_ballot">find_index_ballot</a>(addr, &name, <b>false</b>);
  <b>assert</b>!(!is_found_active, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="VoteLib.md#0x1_ParticipationVote_EEXISTS_ACTIVE">EEXISTS_ACTIVE</a>));

  <b>let</b> (_, is_found_completed) = <a href="VoteLib.md#0x1_ParticipationVote_find_index_ballot">find_index_ballot</a>(addr, &name, <b>false</b>);
  <b>assert</b>!(!is_found_completed, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="VoteLib.md#0x1_ParticipationVote_EEXISTS_COMPLETED">EEXISTS_COMPLETED</a>));


  <b>let</b> new_ballot = <a href="VoteLib.md#0x1_ParticipationVote_Ballot">Ballot</a> {
      name: name,
      cfg_min_deadline: cfg_min_deadline,
      cfg_max_deadline: cfg_max_deadline,
      cfg_min_turnout: cfg_min_turnout,
      cfg_minority_extension: cfg_minority_extension,
      in_progress: <b>true</b>,
      max_votes: 0,
      votes_approve: 0,
      votes_reject: 0,
      epochs_extended: 0,
      tally_turnout: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_raw_value">FixedPoint32::create_from_raw_value</a>(0),
      tally_pass: <b>false</b>,
    };
  <b>let</b> elections = <b>borrow_global_mut</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> elections.active, new_ballot);
}
</code></pre>



</details>

<a name="0x1_ParticipationVote_find_index_ballot"></a>

## Function `find_index_ballot`



<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_find_index_ballot">find_index_ballot</a>(election_addr: <b>address</b>, name: &vector&lt;u8&gt;, completed: bool): (u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="VoteLib.md#0x1_ParticipationVote_find_index_ballot">find_index_ballot</a>(election_addr: <b>address</b>, name: &vector&lt;u8&gt;, completed: bool): (u64, bool) <b>acquires</b> <a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(election_addr)) {
    <b>let</b> elections = <b>borrow_global</b>&lt;<a href="VoteLib.md#0x1_ParticipationVote_MyElections">MyElections</a>&gt;(election_addr);
    <b>let</b> list = <b>if</b> (completed) {
      &elections.completed
    } <b>else</b> {
      &elections.active
    };

    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      <b>let</b> ballot = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&elections.active, i);
      <b>if</b> (<a href="VectorHelper.md#0x1_VectorHelper_compare">VectorHelper::compare</a>(&ballot.name, name)) {
        <b>return</b> (i, <b>true</b>)
      };
      i = i + 1;
    };
    (0, <b>false</b>)

  } <b>else</b> {
    (0, <b>false</b>)
  }
}
</code></pre>



</details>
