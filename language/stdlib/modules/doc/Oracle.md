
<a name="0x1_Oracle"></a>

# Module `0x1::Oracle`



-  [Resource `Oracles`](#0x1_Oracle_Oracles)
-  [Struct `Vote`](#0x1_Oracle_Vote)
-  [Struct `VoteCount`](#0x1_Oracle_VoteCount)
-  [Struct `UpgradeOracle`](#0x1_Oracle_UpgradeOracle)
-  [Function `initialize`](#0x1_Oracle_initialize)
-  [Function `handler`](#0x1_Oracle_handler)
-  [Function `upgrade_handler`](#0x1_Oracle_upgrade_handler)
-  [Function `increment_vote_count`](#0x1_Oracle_increment_vote_count)
-  [Function `check_consensus`](#0x1_Oracle_check_consensus)
-  [Function `enter_new_upgrade_round`](#0x1_Oracle_enter_new_upgrade_round)
-  [Function `tally_upgrade`](#0x1_Oracle_tally_upgrade)
-  [Function `check_upgrade`](#0x1_Oracle_check_upgrade)
-  [Function `test_helper_query_oracle_votes`](#0x1_Oracle_test_helper_query_oracle_votes)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="LibraBlock.md#0x1_LibraBlock">0x1::LibraBlock</a>;
<b>use</b> <a href="LibraSystem.md#0x1_LibraSystem">0x1::LibraSystem</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="Upgrade.md#0x1_Upgrade">0x1::Upgrade</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Oracle_Oracles"></a>

## Resource `Oracles`



<pre><code><b>resource</b> <b>struct</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>
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



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_Vote">Vote</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>validator: address</code>
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
</dl>


</details>

<a name="0x1_Oracle_VoteCount"></a>

## Struct `VoteCount`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>
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
<code>validators: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Oracle_UpgradeOracle"></a>

## Struct `UpgradeOracle`



<pre><code><b>struct</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a>
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
<code>validators_voted: vector&lt;address&gt;</code>
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

<a name="0x1_Oracle_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_initialize">initialize</a>(vm: &signer) {
  <b>if</b> (<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()) {
    move_to(vm, <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
      upgrade: <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a> {
          id: 1,
          validators_voted: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
          vote_counts: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;(),
          votes: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(),
          vote_window: 1000, //Every n blocks
          version_id: 0,
          consensus: <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
            data: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
            validators: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
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


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_handler">handler</a> (sender: &signer, id: u64, data: vector&lt;u8&gt;) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  // receives payload from oracle_tx.<b>move</b>
  // Check the sender is a validator.
  <b>assert</b>(<a href="LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), 11111); // TODO: error code

  <b>if</b> (id == 1) {
    <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a>(sender, data);
  }
  // put <b>else</b> <b>if</b> cases for other oracles
}
</code></pre>



</details>

<a name="0x1_Oracle_upgrade_handler"></a>

## Function `upgrade_handler`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a>(sender: &signer, data: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_upgrade_handler">upgrade_handler</a> (sender: &signer, data: vector&lt;u8&gt;) <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>let</b> current_height = <a href="LibraBlock.md#0x1_LibraBlock_get_current_block_height">LibraBlock::get_current_block_height</a>();
  <b>let</b> upgrade_oracle = &<b>mut</b> borrow_global_mut&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).upgrade;

  // check <b>if</b> qualifies <b>as</b> a new round
  <b>let</b> is_new_round = current_height &gt; upgrade_oracle.vote_window;

  <b>if</b> (is_new_round) {
    <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle, current_height);
  };

  // <b>if</b> the sender has voted, do nothing
  <b>if</b> (<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&upgrade_oracle.validators_voted, &<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender))) {<b>return</b>};

  <b>let</b> validator_vote = <a href="Oracle.md#0x1_Oracle_Vote">Vote</a> {
          validator: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender),
          data: <b>copy</b> data,
          version_id: *&upgrade_oracle.version_id,
  };
  <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.votes, validator_vote);
  <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> upgrade_oracle.validators_voted, <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(&<b>mut</b> upgrade_oracle.vote_counts, data, <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));
  <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle);
}
</code></pre>



</details>

<a name="0x1_Oracle_increment_vote_count"></a>

## Function `increment_vote_count`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">Oracle::VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_increment_vote_count">increment_vote_count</a>(vote_counts: &<b>mut</b> vector&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;, data: vector&lt;u8&gt;, validator: address) {
  <b>let</b> i = 0;
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(vote_counts);
  <b>while</b> (i &lt; len) {
      <b>let</b> entry = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(vote_counts, i);
      <b>if</b> (<a href="Vector.md#0x1_Vector_compare">Vector::compare</a>(&entry.data, &data)) {
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> entry.validators, validator);
        <b>return</b>
      };
      i = i + 1;
  };
  <b>let</b> validators = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
  <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> validators, validator);
  <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(vote_counts, <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{data: <b>copy</b> data, validators: validators});
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
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(vote_counts);
  <b>while</b> (i &lt; len) {
      <b>let</b> entry = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(vote_counts, i);
      <b>if</b> (<a href="Vector.md#0x1_Vector_length">Vector::length</a>(&entry.validators) &gt;= threshold) {
        <b>return</b> *entry
      };
      i = i + 1;
  };
  <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
    data: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    validators: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
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
  upgrade_oracle.validators_voted = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
  upgrade_oracle.vote_counts = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>&gt;();
  upgrade_oracle.votes = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;();
  // TODO: change <b>to</b> Epochs instead of height. Could possibly be an argument <b>as</b> well.
  // Setting the window <b>to</b> be approx two 24h periods.
  upgrade_oracle.vote_window = height + 1000000;
  upgrade_oracle.consensus = <a href="Oracle.md#0x1_Oracle_VoteCount">VoteCount</a>{
    data: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(),
    validators: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
  };
}
</code></pre>



</details>

<a name="0x1_Oracle_tally_upgrade"></a>

## Function `tally_upgrade`



<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a>(upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">Oracle::UpgradeOracle</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Oracle.md#0x1_Oracle_tally_upgrade">tally_upgrade</a> (upgrade_oracle: &<b>mut</b> <a href="Oracle.md#0x1_Oracle_UpgradeOracle">UpgradeOracle</a>) {
  <b>let</b> validator_num = <a href="LibraSystem.md#0x1_LibraSystem_validator_set_size">LibraSystem::validator_set_size</a>();
  <b>let</b> threshold = validator_num * 2 / 3;
  <b>let</b> result = <a href="Oracle.md#0x1_Oracle_check_consensus">check_consensus</a>(&upgrade_oracle.vote_counts, threshold);

  <b>if</b> (!<a href="Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&result.data)) {
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
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 11111); // TODO: error code
  <b>let</b> upgrade_oracle = &<b>mut</b> borrow_global_mut&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>()).upgrade;

  <b>let</b> payload = *&upgrade_oracle.consensus.data;
  <b>let</b> validators = *&upgrade_oracle.consensus.validators;

  <b>if</b> (!<a href="Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&payload)) {
    <a href="Upgrade.md#0x1_Upgrade_set_update">Upgrade::set_update</a>(vm, *&payload);
    <b>let</b> current_height = <a href="LibraBlock.md#0x1_LibraBlock_get_current_block_height">LibraBlock::get_current_block_height</a>();
    <a href="Upgrade.md#0x1_Upgrade_record_history">Upgrade::record_history</a>(vm, upgrade_oracle.version_id, payload, validators, current_height);
    <a href="Oracle.md#0x1_Oracle_enter_new_upgrade_round">enter_new_upgrade_round</a>(upgrade_oracle, current_height);
  }
}
</code></pre>



</details>

<a name="0x1_Oracle_test_helper_query_oracle_votes"></a>

## Function `test_helper_query_oracle_votes`



<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_query_oracle_votes">test_helper_query_oracle_votes</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Oracle.md#0x1_Oracle_test_helper_query_oracle_votes">test_helper_query_oracle_votes</a>(): vector&lt;address&gt; <b>acquires</b> <a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 123401011000);
  <b>let</b> s = borrow_global&lt;<a href="Oracle.md#0x1_Oracle_Oracles">Oracles</a>&gt;(0x0);
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(&s.upgrade.votes);

  <b>let</b> voters = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> e = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Oracle.md#0x1_Oracle_Vote">Vote</a>&gt;(&s.upgrade.votes, i);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> voters, e.validator);
    i = i + 1;

  };
  voters
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
