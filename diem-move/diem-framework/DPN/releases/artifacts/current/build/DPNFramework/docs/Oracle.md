
<a name="0x1_Oracle"></a>

# Module `0x1::Oracle`



-  [Resource `Oracles`](#0x1_Oracle_Oracles)
-  [Struct `Vote`](#0x1_Oracle_Vote)
-  [Struct `VoteCount`](#0x1_Oracle_VoteCount)
-  [Struct `UpgradeOracle`](#0x1_Oracle_UpgradeOracle)
-  [Resource `VoteDelegation`](#0x1_Oracle_VoteDelegation)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_Oracle_initialize)
-  [Function `handler`](#0x1_Oracle_handler)
-  [Function `upgrade_handler`](#0x1_Oracle_upgrade_handler)
-  [Function `upgrade_handler_hash`](#0x1_Oracle_upgrade_handler_hash)
-  [Function `revoke_my_votes`](#0x1_Oracle_revoke_my_votes)
-  [Function `revoke_vote`](#0x1_Oracle_revoke_vote)
-  [Function `increment_vote_count`](#0x1_Oracle_increment_vote_count)
-  [Function `increment_vote_count_hash`](#0x1_Oracle_increment_vote_count_hash)
-  [Function `check_consensus`](#0x1_Oracle_check_consensus)
-  [Function `enter_new_upgrade_round`](#0x1_Oracle_enter_new_upgrade_round)
-  [Function `vm_expire_upgrade`](#0x1_Oracle_vm_expire_upgrade)
-  [Function `tally_upgrade`](#0x1_Oracle_tally_upgrade)
-  [Function `check_upgrade`](#0x1_Oracle_check_upgrade)
-  [Function `get_weight`](#0x1_Oracle_get_weight)
-  [Function `get_threshold`](#0x1_Oracle_get_threshold)
-  [Function `calculate_proportional_voting_threshold`](#0x1_Oracle_calculate_proportional_voting_threshold)
-  [Function `enable_delegation`](#0x1_Oracle_enable_delegation)
-  [Function `has_delegated`](#0x1_Oracle_has_delegated)
-  [Function `check_number_delegates`](#0x1_Oracle_check_number_delegates)
-  [Function `delegate_vote`](#0x1_Oracle_delegate_vote)
-  [Function `remove_delegate_vote`](#0x1_Oracle_remove_delegate_vote)
-  [Function `delegation_enabled_upgrade`](#0x1_Oracle_delegation_enabled_upgrade)
-  [Function `upgrade_vote_type`](#0x1_Oracle_upgrade_vote_type)
-  [Function `test_helper_query_oracle_votes`](#0x1_Oracle_test_helper_query_oracle_votes)
-  [Function `test_helper_check_upgrade`](#0x1_Oracle_test_helper_check_upgrade)


<pre><code><b>use</b> <a href="DiemBlock.md#0x1_DiemBlock">0x1::DiemBlock</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash">0x1::Hash</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="Upgrade.md#0x1_Upgrade">0x1::Upgrade</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="VectorHelper.md#0x1_VectorHelper">0x1::VectorHelper</a>;
</code></pre>



<a name="0x1_Oracle_Oracles"></a>

## Resource `Oracles`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>upgrade: <a href="Oracle.md#0x1_Oracle_UpgradeOracle">Oracle::UpgradeOracle</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Oracle_Vote"></a>

## Struct `Vote`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_Vote">Vote</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>validator: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>data: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>version_id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>weight: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Oracle_VoteCount"></a>

## Struct `VoteCount`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>data: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>validators: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>hash: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_weight: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Oracle_UpgradeOracle"></a>

## Struct `UpgradeOracle`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>validators_voted: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>vote_counts: vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>votes: vector&lt;<a href="Oracle.md#0x1_Oracle_Vote">Oracle::Vote</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>vote_window: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>version_id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>consensus: <a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Oracle_VoteDelegation"></a>

## Resource `VoteDelegation`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>vote_delegated: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>delegates: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>delegated_to_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Oracle_DELEGATION_ENABLED_UPGRADE"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_DELEGATION_ENABLED_UPGRADE">DELEGATION_ENABLED_UPGRADE</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1_Oracle_DELEGATION_NOT_ENABLED"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_DELEGATION_NOT_ENABLED">DELEGATION_NOT_ENABLED</a>: u64 = 150002;
</code></pre>



<a name="0x1_Oracle_DELEGATION_NOT_PRESENT"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_DELEGATION_NOT_PRESENT">DELEGATION_NOT_PRESENT</a>: u64 = 150004;
</code></pre>



<a name="0x1_Oracle_DUPLICATE_VOTE"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_DUPLICATE_VOTE">DUPLICATE_VOTE</a>: u64 = 150005;
</code></pre>



<a name="0x1_Oracle_VOTE_ALREADY_DELEGATED"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_ALREADY_DELEGATED">VOTE_ALREADY_DELEGATED</a>: u64 = 150003;
</code></pre>



<a name="0x1_Oracle_VOTE_TYPE_INVALID"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_INVALID">VOTE_TYPE_INVALID</a>: u64 = 150001;
</code></pre>



<a name="0x1_Oracle_VOTE_TYPE_MAX"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_MAX">VOTE_TYPE_MAX</a>: u8 = 1;
</code></pre>



<a name="0x1_Oracle_VOTE_TYPE_ONE_FOR_ONE"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_ONE_FOR_ONE">VOTE_TYPE_ONE_FOR_ONE</a>: u8 = 0;
</code></pre>



<a name="0x1_Oracle_VOTE_TYPE_PROPORTIONAL_VOTING_POWER"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_PROPORTIONAL_VOTING_POWER">VOTE_TYPE_PROPORTIONAL_VOTING_POWER</a>: u8 = 1;
</code></pre>



<a name="0x1_Oracle_VOTE_TYPE_UPGRADE"></a>



<pre><code><b>const</b> <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>: u8 = 1;
</code></pre>



<a name="0x1_Oracle_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_initialize">initialize</a>(vm: &signer) {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot) {
    <b>move_to</b>(vm, <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
      upgrade: <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a> {
          id: 1,
          validators_voted: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
          vote_counts: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;(),
          votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(),
          vote_window: 1000, //Every n blocks
          version_id: 0,
          consensus: <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
            data: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
            hash: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
            validators: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
            total_weight: 0,
          },
        }
    },
    // other oracles
  );

  // call initialization of upgrade
  <a href="Upgrade.md#0x1_Upgrade_initialize">Upgrade::initialize</a>(vm);
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_handler"></a>

## Function `handler`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_handler">handler</a>(sender: &signer, id: u64, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_handler">handler</a> (sender: &signer, id: u64, data: vector&lt;u8&gt;) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>, <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a> {
  // receives payload from oracle_tx.<b>move</b>
  // Check the sender is a validator.
  <b>assert</b>!(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(150002));

  <b>if</b> (id == 1) {
    <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), <b>copy</b> data);
    <b>if</b> (<a href="Oracle.md#0x1_Oracle_DELEGATION_ENABLED_UPGRADE">DELEGATION_ENABLED_UPGRADE</a> && <b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender))) {
      <b>let</b> del = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
      <b>let</b> l = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&del.delegates);
      <b>let</b> i = 0;
      <b>let</b> hash = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash_sha2_256">Hash::sha2_256</a>(data);
      <b>while</b> (i &lt; l) {
        <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&del.delegates, i);
        <b>if</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr)) {
          <a href="Oracle.md#0x1_Oracle_upgrade_handler_hash">upgrade_handler_hash</a>(addr, <b>copy</b> hash);
        };
        i = i + 1;
      };
    };
  }
  <b>else</b> <b>if</b> (id == 2) {
    <a href="Oracle.md#0x1_Oracle_upgrade_handler_hash">upgrade_handler_hash</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), <b>copy</b> data);
    <b>if</b> (<a href="Oracle.md#0x1_Oracle_DELEGATION_ENABLED_UPGRADE">DELEGATION_ENABLED_UPGRADE</a> && <b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender))) {
      <b>let</b> del = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
      <b>let</b> l = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&del.delegates);
      <b>let</b> i = 0;
      <b>while</b> (i &lt; l) {
        <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&del.delegates, i);
        <b>if</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr)) {
          <a href="Oracle.md#0x1_Oracle_upgrade_handler_hash">upgrade_handler_hash</a>(addr, <b>copy</b> data);
        };
        i = i + 1;
      };
    };
  };
  // put <b>else</b> <b>if</b> cases for other oracles
}
</code></pre>



</details>

<a name="0x1_Oracle_upgrade_handler"></a>

## Function `upgrade_handler`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a>(sender: <b>address</b>, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a> (sender: <b>address</b>, data: vector&lt;u8&gt;) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>let</b> current_height = <a href="DiemBlock.md#0x1_DiemBlock_get_current_block_height">DiemBlock::get_current_block_height</a>();
  <b>let</b> upgrade_oracle = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@DiemRoot).upgrade;

  // check <b>if</b> qualifies <b>as</b> a new round
  <b>let</b> is_new_round = current_height &gt; upgrade_oracle.vote_window;

  <b>if</b> (is_new_round) {
    <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle, current_height);
  };

  // <b>if</b> the sender <b>has</b> voted, do nothing
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&upgrade_oracle.validators_voted, &sender)) {<b>return</b>};

  <b>let</b> vote_weight = <a href="Oracle.md#0x1_Oracle_get_weight">get_weight</a>(sender, <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>);

  <b>let</b> validator_vote = <a href="Oracle.md#0x1_Oracle_Vote">Vote</a> {
          validator: sender,
          data: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash_sha2_256">Hash::sha2_256</a>(<b>copy</b> data),
          version_id: *&upgrade_oracle.version_id,
          weight: vote_weight,
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.votes, validator_vote);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.validators_voted, sender);
  <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(&<b>mut</b> upgrade_oracle.vote_counts, data, sender, vote_weight);
  <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle, <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>);
}
</code></pre>



</details>

<a name="0x1_Oracle_upgrade_handler_hash"></a>

## Function `upgrade_handler_hash`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler_hash">upgrade_handler_hash</a>(sender: <b>address</b>, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler_hash">upgrade_handler_hash</a> (sender: <b>address</b>, data: vector&lt;u8&gt;) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>let</b> current_height = <a href="DiemBlock.md#0x1_DiemBlock_get_current_block_height">DiemBlock::get_current_block_height</a>();
  <b>let</b> upgrade_oracle = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@DiemRoot).upgrade;

  // check <b>if</b> qualifies <b>as</b> a new round
  <b>let</b> is_new_round = current_height &gt; upgrade_oracle.vote_window;

  <b>if</b> (is_new_round) {
    //If it's a new round, user must submit a data payload, not hash only
    <b>return</b>
  };

  // <b>if</b> the sender <b>has</b> voted, do nothing
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&upgrade_oracle.validators_voted, &sender)) {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Oracle.md#0x1_Oracle_DUPLICATE_VOTE">DUPLICATE_VOTE</a>));
  };

  <b>let</b> vote_weight = <a href="Oracle.md#0x1_Oracle_get_weight">get_weight</a>(sender, <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>);

  <b>let</b> validator_vote = <a href="Oracle.md#0x1_Oracle_Vote">Vote</a> {
          validator: sender,
          data: <b>copy</b> data,
          version_id: *&upgrade_oracle.version_id,
          weight: vote_weight,
  };

  <b>let</b> vote_sent = <a href="Oracle.md#0x1_Oracle_increment_vote_count_hash">increment_vote_count_hash</a>(
    &<b>mut</b> upgrade_oracle.vote_counts, data, sender, vote_weight
  );

  <b>if</b> (vote_sent) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.votes, validator_vote);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.validators_voted, sender);
    <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle, <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>);
  };
}
</code></pre>



</details>

<a name="0x1_Oracle_revoke_my_votes"></a>

## Function `revoke_my_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_revoke_my_votes">revoke_my_votes</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_revoke_my_votes">revoke_my_votes</a>(sender: &signer) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>, <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <a href="Oracle.md#0x1_Oracle_revoke_vote">revoke_vote</a>(addr);
  <b>let</b> del = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <b>let</b> l = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&del.delegates);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; l) {
    <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&del.delegates, i);
    <a href="Oracle.md#0x1_Oracle_revoke_vote">revoke_vote</a>(addr);
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Oracle_revoke_vote"></a>

## Function `revoke_vote`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_revoke_vote">revoke_vote</a>(addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_revoke_vote">revoke_vote</a>(addr: <b>address</b>) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>{
  <b>let</b> upgrade_oracle = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@DiemRoot).upgrade;
  <b>let</b> (is_found, idx) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&upgrade_oracle.validators_voted, &addr);
  <b>if</b> (is_found) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> upgrade_oracle.votes, idx);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> upgrade_oracle.validators_voted, idx);
    <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle, <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>);
  };
}
</code></pre>



</details>

<a name="0x1_Oracle_increment_vote_count"></a>

## Function `increment_vote_count`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: <b>address</b>, vote_weight: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: <b>address</b>, vote_weight: u64) {
  <b>let</b> data_hash = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Hash.md#0x1_Hash_sha2_256">Hash::sha2_256</a>(<b>copy</b> data);
  <b>let</b> i = 0;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(vote_counts);
  <b>while</b> (i &lt; len) {
      <b>let</b> entry = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(vote_counts, i);
      <b>if</b> (<a href="VectorHelper.md#0x1_VectorHelper_compare">VectorHelper::compare</a>(&entry.hash, &data_hash)) {
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> entry.validators, validator);
        entry.total_weight = entry.total_weight + vote_weight;
        <b>return</b>
      };
      i = i + 1;
  };
  <b>let</b> validators = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> validators, validator);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(vote_counts, <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{data: <b>copy</b> data, hash: data_hash, validators: validators, total_weight: vote_weight});
}
</code></pre>



</details>

<a name="0x1_Oracle_increment_vote_count_hash"></a>

## Function `increment_vote_count_hash`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count_hash">increment_vote_count_hash</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: <b>address</b>, vote_weight: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count_hash">increment_vote_count_hash</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: <b>address</b>, vote_weight: u64): bool {
  <b>let</b> i = 0;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(vote_counts);
  <b>while</b> (i &lt; len) {
      <b>let</b> entry = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(vote_counts, i);
      <b>if</b> (<a href="VectorHelper.md#0x1_VectorHelper_compare">VectorHelper::compare</a>(&entry.hash, &data)) {
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> entry.validators, validator);
        entry.total_weight = entry.total_weight + vote_weight;
        <b>return</b> <b>true</b>
      };
      i = i + 1;
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_Oracle_check_consensus"></a>

## Function `check_consensus`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_check_consensus">check_consensus</a>(vote_counts: &vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>&gt;, threshold: u64): <a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_check_consensus">check_consensus</a>(vote_counts: &vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;, threshold: u64): <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a> {
  <b>let</b> i = 0;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(vote_counts);
  <b>while</b> (i &lt; len) {
      <b>let</b> entry = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(vote_counts, i);
      <b>if</b> (entry.total_weight &gt;= threshold) {
        <b>return</b> *entry
      };
      i = i + 1;
  };
  <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
    data: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    hash: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    validators: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    total_weight: 0,
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_enter_new_upgrade_round"></a>

## Function `enter_new_upgrade_round`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">Oracle::UpgradeOracle</a>, height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a>, height: u64) {
  upgrade_oracle.version_id = upgrade_oracle.version_id + 1;
  upgrade_oracle.validators_voted = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  upgrade_oracle.vote_counts = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;();
  upgrade_oracle.votes = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;();
  // TODO: change <b>to</b> Epochs instead of height. Could possibly be an argument <b>as</b> well.
  // Setting the window <b>to</b> be approx two 24h periods.
  upgrade_oracle.vote_window = height + 1000000;
  upgrade_oracle.consensus = <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
    data: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    hash: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    validators: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    total_weight: 0,
  };
}
</code></pre>



</details>

<a name="0x1_Oracle_vm_expire_upgrade"></a>

## Function `vm_expire_upgrade`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_vm_expire_upgrade">vm_expire_upgrade</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_vm_expire_upgrade">vm_expire_upgrade</a>(vm: &signer) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(150003));
  <b>let</b> upgrade_oracle = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@DiemRoot).upgrade;
  <b>let</b> threshold = <a href="Oracle.md#0x1_Oracle_get_threshold">get_threshold</a>(<a href="Oracle.md#0x1_Oracle_VOTE_TYPE_PROPORTIONAL_VOTING_POWER">VOTE_TYPE_PROPORTIONAL_VOTING_POWER</a>);
  <b>let</b> result = <a href="Oracle.md#0x1_Oracle_check_consensus">check_consensus</a>(&upgrade_oracle.vote_counts, threshold);
  upgrade_oracle.consensus = result;
  upgrade_oracle.vote_window = <a href="DiemBlock.md#0x1_DiemBlock_get_current_block_height">DiemBlock::get_current_block_height</a>() - 1;
}
</code></pre>



</details>

<a name="0x1_Oracle_tally_upgrade"></a>

## Function `tally_upgrade`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">Oracle::UpgradeOracle</a>, type: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a>, type: u8) {
  <b>let</b> threshold = <a href="Oracle.md#0x1_Oracle_get_threshold">get_threshold</a>(type);
  <b>let</b> result = <a href="Oracle.md#0x1_Oracle_check_consensus">check_consensus</a>(&upgrade_oracle.vote_counts, threshold);

  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&result.data)) {
    upgrade_oracle.consensus = result;
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_check_upgrade"></a>

## Function `check_upgrade`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_check_upgrade">check_upgrade</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_check_upgrade">check_upgrade</a>(vm: &signer) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(150003));
  <b>let</b> upgrade_oracle = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@DiemRoot).upgrade;

  <b>let</b> payload = *&upgrade_oracle.consensus.data;
  <b>let</b> validators = *&upgrade_oracle.consensus.validators;

  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&payload)) {
    <a href="Upgrade.md#0x1_Upgrade_set_update">Upgrade::set_update</a>(vm, *&payload);
    <b>let</b> current_height = <a href="DiemBlock.md#0x1_DiemBlock_get_current_block_height">DiemBlock::get_current_block_height</a>();
    <a href="Upgrade.md#0x1_Upgrade_record_history">Upgrade::record_history</a>(vm, upgrade_oracle.version_id, payload, validators, current_height);
    <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle, current_height);
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_get_weight"></a>

## Function `get_weight`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_get_weight">get_weight</a>(voter: <b>address</b>, type: u8): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_get_weight">get_weight</a> (voter: <b>address</b>, type: u8): u64 {

  <b>if</b> (type == <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_ONE_FOR_ONE">VOTE_TYPE_ONE_FOR_ONE</a>) {
    1
  }
  <b>else</b> <b>if</b> (type == <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_PROPORTIONAL_VOTING_POWER">VOTE_TYPE_PROPORTIONAL_VOTING_POWER</a>) {
    <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">NodeWeight::proof_of_weight</a>(voter)
  }
  <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Oracle.md#0x1_Oracle_VOTE_TYPE_INVALID">VOTE_TYPE_INVALID</a>));
    1
  }

}
</code></pre>



</details>

<a name="0x1_Oracle_get_threshold"></a>

## Function `get_threshold`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_get_threshold">get_threshold</a>(type: u8): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_get_threshold">get_threshold</a> (type: u8): u64 {
  <b>if</b> (type == <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_ONE_FOR_ONE">VOTE_TYPE_ONE_FOR_ONE</a>) {
    <b>let</b> validator_num = <a href="DiemSystem.md#0x1_DiemSystem_validator_set_size">DiemSystem::validator_set_size</a>();
    <b>let</b> threshold = validator_num * 2 / 3;
    threshold
  }
  <b>else</b> <b>if</b> (type == <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_PROPORTIONAL_VOTING_POWER">VOTE_TYPE_PROPORTIONAL_VOTING_POWER</a>) {
    <a href="Oracle.md#0x1_Oracle_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>()
  }
  <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="Oracle.md#0x1_Oracle_VOTE_TYPE_INVALID">VOTE_TYPE_INVALID</a>));
    1
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_calculate_proportional_voting_threshold"></a>

## Function `calculate_proportional_voting_threshold`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64 {
  <b>let</b> val_set_size = <a href="DiemSystem.md#0x1_DiemSystem_validator_set_size">DiemSystem::validator_set_size</a>();
  <b>let</b> i = 0;
  <b>let</b> voting_power = 0;
  <b>while</b> (i &lt; val_set_size) {
    <b>let</b> addr = <a href="DiemSystem.md#0x1_DiemSystem_get_ith_validator_address">DiemSystem::get_ith_validator_address</a>(i);
    voting_power = voting_power + <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">NodeWeight::proof_of_weight</a>(addr);
    i = i + 1;
  };
  <b>let</b> threshold = voting_power * 2 / 3;
  threshold
}
</code></pre>



</details>

<a name="0x1_Oracle_enable_delegation"></a>

## Function `enable_delegation`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_enable_delegation">enable_delegation</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_enable_delegation">enable_delegation</a> (sender: &signer) {
  <b>if</b> (!<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender))) {
    <b>move_to</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(sender, <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>{
      vote_delegated: <b>false</b>,
      delegates: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      delegated_to_address: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender),
    });
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_has_delegated"></a>

## Function `has_delegated`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_has_delegated">has_delegated</a>(account: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_has_delegated">has_delegated</a> (account: <b>address</b>): bool <b>acquires</b> <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(account)) {
    <b>let</b> del = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(account);
    <b>return</b> del.vote_delegated
  };
  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_Oracle_check_number_delegates"></a>

## Function `check_number_delegates`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_check_number_delegates">check_number_delegates</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_check_number_delegates">check_number_delegates</a> (addr: <b>address</b>): u64 <b>acquires</b> <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a> {
  <b>let</b> del = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(& del.delegates)

}
</code></pre>



</details>

<a name="0x1_Oracle_delegate_vote"></a>

## Function `delegate_vote`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_delegate_vote">delegate_vote</a>(sender: &signer, vote_dest: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_delegate_vote">delegate_vote</a> (sender: &signer, vote_dest: <b>address</b>) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>{
  <b>assert</b>!(<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="Oracle.md#0x1_Oracle_DELEGATION_NOT_ENABLED">DELEGATION_NOT_ENABLED</a>));

  // check <b>if</b> the receipient/destination <b>has</b> enabled delegation.
  <b>assert</b>!(<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(vote_dest), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="Oracle.md#0x1_Oracle_DELEGATION_NOT_ENABLED">DELEGATION_NOT_ENABLED</a>));

  <b>let</b> del = <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <b>assert</b>!(del.vote_delegated == <b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="Oracle.md#0x1_Oracle_VOTE_ALREADY_DELEGATED">VOTE_ALREADY_DELEGATED</a>));

  del.vote_delegated = <b>true</b>;
  del.delegated_to_address = vote_dest;

  <b>let</b> del = <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(vote_dest);

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> del.delegates, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));

}
</code></pre>



</details>

<a name="0x1_Oracle_remove_delegate_vote"></a>

## Function `remove_delegate_vote`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_remove_delegate_vote">remove_delegate_vote</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_remove_delegate_vote">remove_delegate_vote</a> (sender: &signer) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>{
  <b>assert</b>!(<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="Oracle.md#0x1_Oracle_DELEGATION_NOT_ENABLED">DELEGATION_NOT_ENABLED</a>));

  <b>let</b> del = <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));

  del.vote_delegated = <b>false</b>;
  <b>let</b> vote_dest = del.delegated_to_address;
  del.delegated_to_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  //don't want <b>to</b> end up in a situation <b>where</b> delegation cannot be removed
  <b>if</b> (<b>exists</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(vote_dest)) {
    <b>let</b> del = <b>borrow_global_mut</b>&lt;<a href="Oracle.md#0x1_Oracle_VoteDelegation">VoteDelegation</a>&gt;(vote_dest);

    <b>let</b> (b, loc) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&del.delegates, &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
    <b>if</b> (b) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<b>address</b>&gt;(&<b>mut</b> del.delegates, loc);
    };
  };

}
</code></pre>



</details>

<a name="0x1_Oracle_delegation_enabled_upgrade"></a>

## Function `delegation_enabled_upgrade`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_delegation_enabled_upgrade">delegation_enabled_upgrade</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_delegation_enabled_upgrade">delegation_enabled_upgrade</a>(): bool {
  <a href="Oracle.md#0x1_Oracle_DELEGATION_ENABLED_UPGRADE">DELEGATION_ENABLED_UPGRADE</a>
}
</code></pre>



</details>

<a name="0x1_Oracle_upgrade_vote_type"></a>

## Function `upgrade_vote_type`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_vote_type">upgrade_vote_type</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_vote_type">upgrade_vote_type</a>(): u8 {
  <a href="Oracle.md#0x1_Oracle_VOTE_TYPE_UPGRADE">VOTE_TYPE_UPGRADE</a>
}
</code></pre>



</details>

<a name="0x1_Oracle_test_helper_query_oracle_votes"></a>

## Function `test_helper_query_oracle_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_query_oracle_votes">test_helper_query_oracle_votes</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_query_oracle_votes">test_helper_query_oracle_votes</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(150004));
  <b>let</b> s = <b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(@0x0);
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(&s.upgrade.votes);

  <b>let</b> voters = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> e = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(&s.upgrade.votes, i);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> voters, e.validator);
    i = i + 1;

  };
  voters
}
</code></pre>



</details>

<a name="0x1_Oracle_test_helper_check_upgrade"></a>

## Function `test_helper_check_upgrade`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_check_upgrade">test_helper_check_upgrade</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_check_upgrade">test_helper_check_upgrade</a>(): bool <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>assert</b>!(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(150004));
  <b>let</b> upgrade_oracle = &<b>borrow_global</b>&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(
    @DiemRoot
  ).upgrade;
  <b>let</b> payload = *&upgrade_oracle.consensus.data;

  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&payload)) {
    <b>true</b>
  }
  <b>else</b> {
    <b>false</b>
  }
}
</code></pre>



</details>
