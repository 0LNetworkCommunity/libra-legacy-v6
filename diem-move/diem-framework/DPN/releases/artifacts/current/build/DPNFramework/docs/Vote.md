
<a name="0x1_ExampleStandalonePoll"></a>

# Module `0x1::ExampleStandalonePoll`

This is an example of how to use VoteLib, to create a standalone poll.
In this example we are making a naive DAO payment approval system.
whenever the deadline passes, the next vote will trigger a tally
and if the tally is successful, the payment will be made.
If the tally is not successful, the payment will be rejected.


-  [Struct `DummyTally`](#0x1_ExampleStandalonePoll_DummyTally)
-  [Struct `UsefulTally`](#0x1_ExampleStandalonePoll_UsefulTally)
-  [Struct `ExampleIssueData`](#0x1_ExampleStandalonePoll_ExampleIssueData)
-  [Resource `VoteCapability`](#0x1_ExampleStandalonePoll_VoteCapability)
-  [Constants](#@Constants_0)
-  [Function `init_empty_tally`](#0x1_ExampleStandalonePoll_init_empty_tally)
-  [Function `init_useful_tally`](#0x1_ExampleStandalonePoll_init_useful_tally)
-  [Function `vote`](#0x1_ExampleStandalonePoll_vote)
-  [Function `payment_handler`](#0x1_ExampleStandalonePoll_payment_handler)
-  [Function `maybe_tally`](#0x1_ExampleStandalonePoll_maybe_tally)


<pre><code><b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Vote.md#0x1_VoteLib">0x1::VoteLib</a>;
</code></pre>



<a name="0x1_ExampleStandalonePoll_DummyTally"></a>

## Struct `DummyTally`



<pre><code><b>struct</b> <a href="Vote.md#0x1_ExampleStandalonePoll_DummyTally">DummyTally</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x1_ExampleStandalonePoll_UsefulTally"></a>

## Struct `UsefulTally`

a tally can have any kind of data to support the vote.
this is an example of a binary count.
A dev should also insert data into the tally, to be used in an
action that is triggered on completion.


<pre><code><b>struct</b> <a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;IssueData&gt; <b>has</b> <b>copy</b>, drop, store
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
<code>voters: vector&lt;<b>address</b>&gt;</code>
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

<a name="0x1_ExampleStandalonePoll_ExampleIssueData"></a>

## Struct `ExampleIssueData`

a tally can have some arbitrary data payload.


<pre><code><b>struct</b> <a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>pay_this_person: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>description: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ExampleStandalonePoll_VoteCapability"></a>

## Resource `VoteCapability`

the ability to update tallies is usually restricted to signer
since the signer is the one who can create the GUID::CreateCapability
A third party contract can store that capability to access based on its own vote logic. Danger.


<pre><code><b>struct</b> <a href="Vote.md#0x1_ExampleStandalonePoll_VoteCapability">VoteCapability</a> <b>has</b> key
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


<a name="0x1_ExampleStandalonePoll_EINVALID_VOTE"></a>



<pre><code><b>const</b> <a href="Vote.md#0x1_ExampleStandalonePoll_EINVALID_VOTE">EINVALID_VOTE</a>: u64 = 0;
</code></pre>



<a name="0x1_ExampleStandalonePoll_init_empty_tally"></a>

## Function `init_empty_tally`

The signer can always access a new GUID::CreateCapability
On a multisig type account, will need to store the CreateCapability
wherever the multisig authorities can access it. Be careful ou there!


<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_init_empty_tally">init_empty_tally</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_init_empty_tally">init_empty_tally</a>(sig: &signer) {
  <b>let</b> poll = <a href="Vote.md#0x1_VoteLib_new_poll">VoteLib::new_poll</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_DummyTally">DummyTally</a>&gt;();


  <b>let</b> guid_cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);

  <a href="Vote.md#0x1_VoteLib_standalone_init_poll_at_address">VoteLib::standalone_init_poll_at_address</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_DummyTally">DummyTally</a>&gt;(sig, poll);

  <a href="Vote.md#0x1_VoteLib_standalone_propose_ballot">VoteLib::standalone_propose_ballot</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_DummyTally">DummyTally</a>&gt;(&guid_cap, <a href="Vote.md#0x1_ExampleStandalonePoll_DummyTally">DummyTally</a> {})

}
</code></pre>



</details>

<a name="0x1_ExampleStandalonePoll_init_useful_tally"></a>

## Function `init_useful_tally`



<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_init_useful_tally">init_useful_tally</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_init_useful_tally">init_useful_tally</a>(sig: &signer) {
  <b>let</b> poll = <a href="Vote.md#0x1_VoteLib_new_poll">VoteLib::new_poll</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;();


  <b>let</b> guid_cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);

  <a href="Vote.md#0x1_VoteLib_standalone_init_poll_at_address">VoteLib::standalone_init_poll_at_address</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(sig, poll);

  <b>let</b> t = <a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a> {
    votes_for: 0,
    votes_against: 0,
    voters: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    deadline_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + 7,
    tally_result: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;(),
    issue_data: <a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a> {
      pay_this_person: @0xDEADBEEF,
      amount: 0,
      description: b"hello world",
    }
  };

  <a href="Vote.md#0x1_VoteLib_standalone_propose_ballot">VoteLib::standalone_propose_ballot</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(&guid_cap, t);

  // store the capability in the account so it can be used later by someone other than the owner of the account. (e.g. a voter.)
  <b>move_to</b>(sig, <a href="Vote.md#0x1_ExampleStandalonePoll_VoteCapability">VoteCapability</a> { guid_cap });
}
</code></pre>



</details>

<a name="0x1_ExampleStandalonePoll_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_vote">vote</a>(sig: &signer, vote_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, vote_for: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_vote">vote</a>(sig: &signer, vote_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, vote_for: bool) <b>acquires</b> <a href="Vote.md#0x1_ExampleStandalonePoll_VoteCapability">VoteCapability</a> {

  // get the <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">GUID</a> capability stored here
  <b>let</b> cap = &<b>borrow_global</b>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_VoteCapability">VoteCapability</a>&gt;(vote_address).guid_cap;

  <b>let</b> (found, _idx, status_enum, is_completed) = <a href="Vote.md#0x1_VoteLib_standalone_find_anywhere">VoteLib::standalone_find_anywhere</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(cap, id);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Vote.md#0x1_ExampleStandalonePoll_EINVALID_VOTE">EINVALID_VOTE</a>));
  <b>assert</b>!(!is_completed, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Vote.md#0x1_ExampleStandalonePoll_EINVALID_VOTE">EINVALID_VOTE</a>));
  // is a pending ballot
  <b>assert</b>!(status_enum == 0, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Vote.md#0x1_ExampleStandalonePoll_EINVALID_VOTE">EINVALID_VOTE</a>));



  // check signer did not already vote
  <b>let</b> t = <a href="Vote.md#0x1_VoteLib_standalone_get_tally_copy">VoteLib::standalone_get_tally_copy</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(cap, id);

  // check <b>if</b> the signer <b>has</b> already voted
  <b>let</b> signer_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> found = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&t.voters, &signer_addr);
  <b>assert</b>!(!found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(0));

  <b>if</b> (vote_for) {
    t.votes_for = t.votes_for + 1;
  } <b>else</b> {
    t.votes_against = t.votes_against + 1;
  };


  // add the signer <b>to</b> the list of voters
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> t.voters, signer_addr);


  // <b>update</b> the tally

  <a href="Vote.md#0x1_ExampleStandalonePoll_maybe_tally">maybe_tally</a>(&<b>mut</b> t);

  // <b>update</b> the ballot
  <a href="Vote.md#0x1_VoteLib_standalone_update_tally">VoteLib::standalone_update_tally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(cap, id,  <b>copy</b> t);


  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&t.tally_result)) {
    <b>let</b> passed = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&t.tally_result);
    <b>let</b> status_enum = <b>if</b> (passed) {
      // run the payment handler
      <a href="Vote.md#0x1_ExampleStandalonePoll_payment_handler">payment_handler</a>(&t);
      1 // approved
    } <b>else</b> {

      2 // rejected
    };
    // since we have a result lets <b>update</b> the <a href="Vote.md#0x1_VoteLib">VoteLib</a> state
    <a href="Vote.md#0x1_VoteLib_standalone_complete_and_move">VoteLib::standalone_complete_and_move</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;&gt;(cap, id, status_enum);

  }




}
</code></pre>



</details>

<a name="0x1_ExampleStandalonePoll_payment_handler"></a>

## Function `payment_handler`



<pre><code><b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_payment_handler">payment_handler</a>(t: &<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">ExampleStandalonePoll::UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleStandalonePoll::ExampleIssueData</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_payment_handler">payment_handler</a>(t: &<a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;) {

      // do the action
      // pay the person


    <b>let</b> _payee = t.issue_data.pay_this_person;
    <b>let</b> _amount = t.issue_data.amount;
    <b>let</b> _description = *&t.issue_data.description;
    // MAKE THE PAYMENT.
}
</code></pre>



</details>

<a name="0x1_ExampleStandalonePoll_maybe_tally"></a>

## Function `maybe_tally`



<pre><code><b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_maybe_tally">maybe_tally</a>(t: &<b>mut</b> <a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">ExampleStandalonePoll::UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleStandalonePoll::ExampleIssueData</a>&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vote.md#0x1_ExampleStandalonePoll_maybe_tally">maybe_tally</a>(t: &<b>mut</b> <a href="Vote.md#0x1_ExampleStandalonePoll_UsefulTally">UsefulTally</a>&lt;<a href="Vote.md#0x1_ExampleStandalonePoll_ExampleIssueData">ExampleIssueData</a>&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;bool&gt; {
  // check <b>if</b> the tally is complete
  // <b>if</b> so, <b>move</b> the tally <b>to</b> the completed list
  // <b>if</b> not, do nothing

  <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; t.deadline_epoch) {
    // tally is complete
    // <b>move</b> the tally <b>to</b> the completed list
    // call the action
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
