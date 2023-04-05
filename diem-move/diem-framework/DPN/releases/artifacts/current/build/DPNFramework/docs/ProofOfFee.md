
<a name="0x1_ProofOfFee"></a>

# Module `0x1::ProofOfFee`



-  [Resource `ProofOfFeeAuction`](#0x1_ProofOfFee_ProofOfFeeAuction)
-  [Resource `ConsensusReward`](#0x1_ProofOfFee_ConsensusReward)
-  [Constants](#@Constants_0)
-  [Function `init_genesis_baseline_reward`](#0x1_ProofOfFee_init_genesis_baseline_reward)
-  [Function `init`](#0x1_ProofOfFee_init)
-  [Function `get_sorted_vals`](#0x1_ProofOfFee_get_sorted_vals)
-  [Function `fill_seats_and_get_price`](#0x1_ProofOfFee_fill_seats_and_get_price)
-  [Function `audit_qualification`](#0x1_ProofOfFee_audit_qualification)
-  [Function `reward_thermostat`](#0x1_ProofOfFee_reward_thermostat)
-  [Function `set_history`](#0x1_ProofOfFee_set_history)
-  [Function `get_median`](#0x1_ProofOfFee_get_median)
-  [Function `get_consensus_reward`](#0x1_ProofOfFee_get_consensus_reward)
-  [Function `current_bid`](#0x1_ProofOfFee_current_bid)
-  [Function `is_already_retracted`](#0x1_ProofOfFee_is_already_retracted)
-  [Function `top_n_accounts`](#0x1_ProofOfFee_top_n_accounts)
-  [Function `set_bid`](#0x1_ProofOfFee_set_bid)
-  [Function `retract_bid`](#0x1_ProofOfFee_retract_bid)
-  [Function `init_bidding`](#0x1_ProofOfFee_init_bidding)
-  [Function `pof_update_bid`](#0x1_ProofOfFee_pof_update_bid)
-  [Function `pof_retract_bid`](#0x1_ProofOfFee_pof_retract_bid)
-  [Function `test_set_val_bids`](#0x1_ProofOfFee_test_set_val_bids)
-  [Function `test_set_one_bid`](#0x1_ProofOfFee_test_set_one_bid)
-  [Function `test_mock_reward`](#0x1_ProofOfFee_test_mock_reward)


<pre><code><b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Vouch.md#0x1_Vouch">0x1::Vouch</a>;
</code></pre>



<a name="0x1_ProofOfFee_ProofOfFeeAuction"></a>

## Resource `ProofOfFeeAuction`



<pre><code><b>struct</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_expiration: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_epoch_retracted: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ProofOfFee_ConsensusReward"></a>

## Resource `ConsensusReward`



<pre><code><b>struct</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>clearing_price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>median_win_bid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>median_history: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_ProofOfFee_ENOT_AN_ACTIVE_VALIDATOR"></a>



<pre><code><b>const</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ENOT_AN_ACTIVE_VALIDATOR">ENOT_AN_ACTIVE_VALIDATOR</a>: u64 = 190001;
</code></pre>



<a name="0x1_ProofOfFee_EABOVE_RETRACT_LIMIT"></a>



<pre><code><b>const</b> <a href="ProofOfFee.md#0x1_ProofOfFee_EABOVE_RETRACT_LIMIT">EABOVE_RETRACT_LIMIT</a>: u64 = 190003;
</code></pre>



<a name="0x1_ProofOfFee_EBID_ABOVE_MAX_PCT"></a>



<pre><code><b>const</b> <a href="ProofOfFee.md#0x1_ProofOfFee_EBID_ABOVE_MAX_PCT">EBID_ABOVE_MAX_PCT</a>: u64 = 190002;
</code></pre>



<a name="0x1_ProofOfFee_GENESIS_BASELINE_REWARD"></a>



<pre><code><b>const</b> <a href="ProofOfFee.md#0x1_ProofOfFee_GENESIS_BASELINE_REWARD">GENESIS_BASELINE_REWARD</a>: u64 = 1000000;
</code></pre>



<a name="0x1_ProofOfFee_init_genesis_baseline_reward"></a>

## Function `init_genesis_baseline_reward`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_genesis_baseline_reward">init_genesis_baseline_reward</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_genesis_baseline_reward">init_genesis_baseline_reward</a>(vm: &signer) {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) <b>return</b>;

  <b>if</b> (!<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved)) {
    <b>move_to</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(
      vm,
      <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
        value: <a href="ProofOfFee.md#0x1_ProofOfFee_GENESIS_BASELINE_REWARD">GENESIS_BASELINE_REWARD</a>,
        clearing_price: 0,
        median_win_bid: 0,
        median_history: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
      }
    );
  }
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig: &signer) {

  <b>let</b> acc = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account_sig);

  <b>assert</b>!(<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(acc), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="ProofOfFee.md#0x1_ProofOfFee_ENOT_AN_ACTIVE_VALIDATOR">ENOT_AN_ACTIVE_VALIDATOR</a>));

  <b>if</b> (!<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc)) {
    <b>move_to</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(
    account_sig,
      <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
        bid: 0,
        epoch_expiration: 0,
        last_epoch_retracted: 0,
      }
    );
  }
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_get_sorted_vals"></a>

## Function `get_sorted_vals`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(unfiltered: bool): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(unfiltered: bool): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>let</b> eligible_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();
  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);
  // print(&length);
  // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> <b>to</b> store each <b>address</b>'s node_weight
  <b>let</b> weights = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> filtered_vals = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {
    // TODO: Ensure that this <b>address</b> is an active validator

    <b>let</b> cur_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&eligible_validators, k);
    <b>let</b> (bid, _expire) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(cur_address);
    // print(&bid);
    // print(&expire);
    <b>if</b> (!unfiltered && !<a href="ProofOfFee.md#0x1_ProofOfFee_audit_qualification">audit_qualification</a>(&cur_address)) {
      k = k + 1;
      <b>continue</b>
    };
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, bid);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> filtered_vals, cur_address);
    k = k + 1;
  };

  // print(&weights);

  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> len_filtered = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&filtered_vals);
  // print(&len_filtered);
  // print(&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&weights));
  <b>if</b> (len_filtered &lt; 2) <b>return</b> filtered_vals;
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len_filtered){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; len_filtered-i-1){
      // print(&8888801);

      <b>let</b> value_j = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
      // print(&8888802);
      <b>let</b> value_jp1 = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
      <b>if</b>(value_j &gt; value_jp1){
        // print(&8888803);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
        // print(&8888804);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;<b>address</b>&gt;(&<b>mut</b> filtered_vals, j, j+1);
      };
      j = j + 1;
      // print(&8888805);
    };
    i = i + 1;
    // print(&8888806);
  };

  // print(&filtered_vals);
  // Reverse <b>to</b> have sorted order - high <b>to</b> low.
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_reverse">Vector::reverse</a>&lt;<b>address</b>&gt;(&<b>mut</b> filtered_vals);

  <b>return</b> filtered_vals
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_fill_seats_and_get_price"></a>

## Function `fill_seats_and_get_price`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">fill_seats_and_get_price</a>(vm: &signer, set_size: u64, sorted_vals_by_bid: &vector&lt;<b>address</b>&gt;, proven_nodes: &vector&lt;<b>address</b>&gt;): (vector&lt;<b>address</b>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">fill_seats_and_get_price</a>(
  vm: &signer,
  set_size: u64,
  sorted_vals_by_bid: &vector&lt;<b>address</b>&gt;,
  proven_nodes: &vector&lt;<b>address</b>&gt;
): (vector&lt;<b>address</b>&gt;, u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(), 0);

  //print(sorted_vals_by_bid);

  // <b>let</b> (baseline_reward, _, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>();

  <b>let</b> seats_to_fill = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();

  // check the max size of the validator set.
  // there may be too few "proven" validators <b>to</b> fill the set <b>with</b> 2/3rds proven nodes of the stated set_size.
  <b>let</b> proven_len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(proven_nodes);

  // check <b>if</b> the proven len plus unproven quota will
  // be greater than the set size. Which is the expected.
  // Otherwise the set will need <b>to</b> be smaller than the
  // declared size, because we will have <b>to</b> fill <b>with</b> more unproven nodes.
  <b>let</b> one_third_of_max = proven_len/2;
  <b>let</b> safe_set_size = proven_len + one_third_of_max;
  // print(&77777777);
  // print(&proven_len);
  // print(&one_third_of_max);
  // print(&safe_set_size);

  <b>let</b> (set_size, max_unproven) = <b>if</b> (safe_set_size &lt; set_size) {
    (safe_set_size, safe_set_size/3)
    // <b>if</b> (safe_set_size &lt; 5) { // safety. mostly for test scenarios given rounding issues
    //   (safe_set_size, 1)
    // } <b>else</b> {

    // }

  } <b>else</b> {
    // happy case, unproven bidders are a smaller minority
    (set_size, set_size/3)
  };
  // print(&set_size);
  // print(&max_unproven);


  // print(&8006010201);

  // Now we can seat the validators based on the algo above:
  // 1. seat the proven nodes of previous epoch
  // 2. seat validators who did not participate in the previous epoch:
  // 2a. seat the vals <b>with</b> jail reputation &lt; 2
  // 2b. seat the remainder of the unproven vals <b>with</b> any jail reputation.

  <b>let</b> num_unproven_added = 0;
  <b>let</b> i = 0u64;
  <b>while</b> (
    (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&seats_to_fill) &lt; set_size) &&
    (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(sorted_vals_by_bid))
  ) {
    // // print(&i);
    <b>let</b> val = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(sorted_vals_by_bid, i);

    // // belt and suspenders, we <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(<b>true</b>) should filter ineligible validators
    // <b>if</b> (!<a href="ProofOfFee.md#0x1_ProofOfFee_audit_qualification">audit_qualification</a>(val, baseline_reward)) {
    //   i = i + 1;
    //   <b>continue</b>
    // };


    // check <b>if</b> a proven node
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(proven_nodes, val)) {
      // print(&8006010205);
      // // print(&01);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> seats_to_fill, *val);
    } <b>else</b> {
      // print(&8006010206);
      // print(&max_unproven);
      // print(&num_unproven_added);
      // // print(&02);
      // for unproven nodes, push it <b>to</b> list <b>if</b> we haven't hit limit
      <b>if</b> (num_unproven_added &lt; max_unproven ) {
        // TODO: check jail reputation
        // // print(&03);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> seats_to_fill, *val);
        // // print(&04);
        // print(&8006010207);
        num_unproven_added = num_unproven_added + 1;
      };
    };
    // don't advance <b>if</b> we havent filled
    i = i + 1;
  };
  // // print(&05);
  // print(&8006010208);
  // print(&seats_to_fill);



  // Set history
  <a href="ProofOfFee.md#0x1_ProofOfFee_set_history">set_history</a>(vm, &seats_to_fill);

  // we failed <b>to</b> seat anyone.
  // <b>let</b> <a href="EpochBoundary.md#0x1_EpochBoundary">EpochBoundary</a> deal <b>with</b> this.
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&seats_to_fill)) {
    // print(&8006010209);

    <b>return</b> (seats_to_fill, 0)
  };

  // Find the clearing price which all validators will pay
  <b>let</b> lowest_bidder = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&seats_to_fill, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&seats_to_fill) - 1);

  <b>let</b> (lowest_bid_pct, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(*lowest_bidder);

  // print(&lowest_bid_pct);

  // <b>update</b> the clearing price
  <b>let</b> cr = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved);
  cr.clearing_price = lowest_bid_pct;

  <b>return</b> (seats_to_fill, lowest_bid_pct)
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_audit_qualification"></a>

## Function `audit_qualification`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_audit_qualification">audit_qualification</a>(val: &<b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_audit_qualification">audit_qualification</a>(val: &<b>address</b>): bool <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {

    // Safety check: node <b>has</b> valid configs
    <b>if</b> (!<a href="ValidatorConfig.md#0x1_ValidatorConfig_is_valid">ValidatorConfig::is_valid</a>(*val)) <b>return</b> <b>false</b>;
    // <b>has</b> operator account set <b>to</b> another <b>address</b>
    <b>let</b> oper = <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(*val);
    <b>if</b> (oper == *val) <b>return</b> <b>false</b>;

    // is a slow wallet
    <b>if</b> (!<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(*val)) <b>return</b> <b>false</b>;

    // print(&8006010203);
    // we can't seat validators that were just jailed
    // NOTE: epoch reconfigure needs <b>to</b> reset the jail
    // before calling the proof of fee.
    <b>if</b> (<a href="Jail.md#0x1_Jail_is_jailed">Jail::is_jailed</a>(*val)) <b>return</b> <b>false</b>;
    // print(&8006010204);
    // we can't seat validators who don't have minimum viable vouches
    <b>if</b> (!<a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">Vouch::unrelated_buddies_above_thresh</a>(*val)) <b>return</b> <b>false</b>;

    // print(&80060102041);

    <b>let</b> (bid, expire) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(*val);
    //print(val);
    // print(&bid);
    // print(&expire);

    // Skip <b>if</b> the bid expired. belt and suspenders, this should have been checked in the sorting above.
    // TODO: make this it's own function so it can be publicly callable, it's useful generally, and for debugging.
    // print(&<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>());
    <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; expire) <b>return</b> <b>false</b>;

    // skip the user <b>if</b> they don't have sufficient UNLOCKED funds
    // or <b>if</b> the bid expired.
    // print(&80060102042);
    <b>let</b> unlocked_coins = <a href="DiemAccount.md#0x1_DiemAccount_unlocked_amount">DiemAccount::unlocked_amount</a>(*val);
    // print(&unlocked_coins);

    <b>let</b> (baseline_reward, _, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>();
    <b>let</b> coin_required = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(baseline_reward, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(bid, 1000));

    // print(&coin_required);
    <b>if</b> (unlocked_coins &lt; coin_required) <b>return</b> <b>false</b>;

    // print(&80060102043);
    <b>true</b>
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_reward_thermostat"></a>

## Function `reward_thermostat`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_reward_thermostat">reward_thermostat</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_reward_thermostat">reward_thermostat</a>(vm: &signer) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) {
    <b>return</b>
  };
  // check the bid history
  // <b>if</b> there are 5 days above 95% adjust the reward up by 5%
  // adjust by more <b>if</b> it <b>has</b> been 10 days then, 10%
  // <b>if</b> there are 5 days below 50% adjust the reward down.
  // adjust by more <b>if</b> it <b>has</b> been 10 days then 10%

  <b>let</b> bid_upper_bound = 0950;
  <b>let</b> bid_lower_bound = 0500;

  <b>let</b> short_window: u64 = 5;
  <b>let</b> long_window: u64 = 10;

  <b>let</b> cr = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved);

  // print(&8006010551);
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;u64&gt;(&cr.median_history);
  <b>let</b> i = 0;

  <b>let</b> epochs_above = 0;
  <b>let</b> epochs_below = 0;
  <b>while</b> (i &lt; 16 && i &lt; len) { // max ten days, but may have less in history, filling set should truncate the history at 15 epochs.
  // print(&8006010552);
    <b>let</b> avg_bid = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&cr.median_history, i);
    // print(&8006010553);
    <b>if</b> (avg_bid &gt; bid_upper_bound) {
      epochs_above = epochs_above + 1;
    } <b>else</b> <b>if</b> (avg_bid &lt; bid_lower_bound) {
      epochs_below = epochs_below + 1;
    };

    i = i + 1;
  };

  // print(&8006010554);
  <b>if</b> (cr.value &gt; 0) {
    // print(&8006010555);
    // print(&epochs_above);
    // print(&epochs_below);


    // TODO: this is an initial implementation, we need <b>to</b>
    // decide <b>if</b> we want more granularity in the reward adjustment
    // Note: making this readable for now, but we can optimize later
    <b>if</b> (epochs_above &gt; epochs_below) {

      // <b>if</b> (epochs_above &gt; short_window) {
      // print(&8006010556);
      // check for zeros.
      // TODO: put a better safety check here

      // If the Validators are bidding near 100% that means
      // the reward is very generous, i.e. their opportunity
      // cost is met at small percentages. This means the
      // implicit bond is very high on validators. E.g.
      // at 1% median bid, the implicit bond is 100x the reward.
      // We need <b>to</b> DECREASE the reward
      // print(&8006010558);

      <b>if</b> (epochs_above &gt; long_window) {

        // decrease the reward by 10%
        // print(&8006010559);


        cr.value = cr.value - (cr.value / 10);
        <b>return</b> // <b>return</b> early since we can't increase and decrease simultaneously
      } <b>else</b> <b>if</b> (epochs_above &gt; short_window) {
        // decrease the reward by 5%
        // print(&80060105510);
        cr.value = cr.value - (cr.value / 20);


        <b>return</b> // <b>return</b> early since we can't increase and decrease simultaneously
      }
    };


      // <b>if</b> validators are bidding low percentages
      // it means the nominal reward is not high enough.
      // That is the validator's opportunity cost is not met within a
      // range <b>where</b> the bond is meaningful.
      // For example: <b>if</b> the bids for the epoch's reward is 50% of the  value, that means the potential profit, is the same <b>as</b> the potential loss.
      // At a 25% bid (potential loss), the profit is thus 75% of the value, which means the implicit bond is 25/75, or 1/3 of the bond, the risk favors the validator. This means among other things, that an attacker can pay for the cost of the attack <b>with</b> the profits. See paper, for more details.

      // we need <b>to</b> INCREASE the reward, so that the bond is more meaningful.
      // print(&80060105511);

      <b>if</b> (epochs_below &gt; long_window) {
        // print(&80060105513);

        // increase the reward by 10%
        cr.value = cr.value + (cr.value / 10);
      } <b>else</b> <b>if</b> (epochs_below &gt; short_window) {
        // print(&80060105512);

        // increase the reward by 5%
        cr.value = cr.value + (cr.value / 20);
      };
    // };
  };
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_set_history"></a>

## Function `set_history`

find the median bid to push to history


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_history">set_history</a>(vm: &signer, seats_to_fill: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_history">set_history</a>(vm: &signer, seats_to_fill: &vector&lt;<b>address</b>&gt;) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) {
    <b>return</b>
  };

  // print(&99901);
  <b>let</b> median_bid = <a href="ProofOfFee.md#0x1_ProofOfFee_get_median">get_median</a>(seats_to_fill);
  // push <b>to</b> history
  <b>let</b> cr = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved);
  cr.median_win_bid = median_bid;
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&cr.median_history) &lt; 10) {
    // print(&99902);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> cr.median_history, median_bid);
  } <b>else</b> {
    // print(&99903);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> cr.median_history, 0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> cr.median_history, median_bid);
  };
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_get_median"></a>

## Function `get_median`



<pre><code><b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_median">get_median</a>(seats_to_fill: &vector&lt;<b>address</b>&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_median">get_median</a>(seats_to_fill: &vector&lt;<b>address</b>&gt;):u64 <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  // TODO: the list is sorted above, so
  // we <b>assume</b> the median is the middle element
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(seats_to_fill);
  <b>if</b> (len == 0) {
    <b>return</b> 0
  };
  <b>let</b> median_bidder = <b>if</b> (len &gt; 2) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(seats_to_fill, len/2)
  } <b>else</b> {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(seats_to_fill, 0)
  };
  <b>let</b> (median_bid, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(*median_bidder);
  <b>return</b> median_bid
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_get_consensus_reward"></a>

## Function `get_consensus_reward`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>(): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>(): (u64, u64, u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>let</b> b = <b>borrow_global</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved );
  <b>return</b> (b.value, b.clearing_price, b.median_win_bid)
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_current_bid"></a>

## Function `current_bid`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(node_addr: <b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(node_addr: <b>address</b>): (u64, u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr)) {
    <b>let</b> pof = <b>borrow_global</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr);
    <b>let</b> e = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
    // check the expiration of the bid
    // the bid is zero <b>if</b> it expires.
    // The expiration epoch number is inclusive of the epoch.
    // i.e. the bid expires on e + 1.
    <b>if</b> (pof.epoch_expiration &gt;= e || pof.epoch_expiration == 0) {
      <b>return</b> (pof.bid, pof.epoch_expiration)
    };
    <b>return</b> (0, pof.epoch_expiration)
  };
  <b>return</b> (0, 0)
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_is_already_retracted"></a>

## Function `is_already_retracted`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_is_already_retracted">is_already_retracted</a>(node_addr: <b>address</b>): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_is_already_retracted">is_already_retracted</a>(node_addr: <b>address</b>): (bool, u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr)) {
    <b>let</b> when_retract = *&<b>borrow_global</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(node_addr).last_epoch_retracted;
    <b>return</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt;= when_retract,  when_retract)
  };
  <b>return</b> (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_top_n_accounts"></a>

## Function `top_n_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64, unfiltered: bool): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64, unfiltered: bool): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
    <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(140101));

    <b>let</b> eligible_validators = <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(unfiltered);
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);
    <b>if</b>(len &lt;= n) <b>return</b> eligible_validators;

    <b>let</b> diff = len - n;
    <b>while</b>(diff &gt; 0){
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(&<b>mut</b> eligible_validators);
      diff = diff - 1;
    };

    eligible_validators
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_set_bid"></a>

## Function `set_bid`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(account_sig: &signer, bid: u64, expiry_epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(account_sig: &signer, bid: u64, expiry_epoch: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {

  <b>let</b> acc = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account_sig);
  <b>if</b> (!<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc)) {
    <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig);
  };

  // bid must be below 110%
  <b>assert</b>!(bid &lt;= 1100, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_ol_tx">Errors::ol_tx</a>(<a href="ProofOfFee.md#0x1_ProofOfFee_EBID_ABOVE_MAX_PCT">EBID_ABOVE_MAX_PCT</a>));

  <b>let</b> pof = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc);
  pof.epoch_expiration = expiry_epoch;
  pof.bid = bid;
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_retract_bid"></a>

## Function `retract_bid`

Note that the validator will not be bidding on any future
epochs if they retract their bid. The must set a new bid.


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_retract_bid">retract_bid</a>(account_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_retract_bid">retract_bid</a>(account_sig: &signer) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {

  <b>let</b> acc = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account_sig);
  <b>if</b> (!<b>exists</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc)) {
    <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(account_sig);
  };


  <b>let</b> pof = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc);
  <b>let</b> this_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  //////// LEAVE COMMENTED. Code for a potential upgrade. ////////
  // See above discussion for retracting of bids.
  //
  // already retracted this epoch
  // <b>assert</b>!(this_epoch &gt; pof.last_epoch_retracted, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_ol_tx">Errors::ol_tx</a>(<a href="ProofOfFee.md#0x1_ProofOfFee_EABOVE_RETRACT_LIMIT">EABOVE_RETRACT_LIMIT</a>));
  //////// LEAVE COMMENTED. Code for a potential upgrade. ////////


  pof.epoch_expiration = 0;
  pof.bid = 0;
  pof.last_epoch_retracted = this_epoch;
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_init_bidding"></a>

## Function `init_bidding`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_bidding">init_bidding</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_init_bidding">init_bidding</a>(sender: signer) {
  <a href="ProofOfFee.md#0x1_ProofOfFee_init">init</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_pof_update_bid"></a>

## Function `pof_update_bid`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_pof_update_bid">pof_update_bid</a>(sender: signer, bid: u64, epoch_expiry: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_pof_update_bid">pof_update_bid</a>(sender: signer, bid: u64, epoch_expiry: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  // <b>update</b> the bid, initializes <b>if</b> not already.
  <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(&sender, bid, epoch_expiry);
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_pof_retract_bid"></a>

## Function `pof_retract_bid`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_pof_retract_bid">pof_retract_bid</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_pof_retract_bid">pof_retract_bid</a>(sender: signer) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  // retract a bid
  <a href="ProofOfFee.md#0x1_ProofOfFee_retract_bid">retract_bid</a>(&sender);
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_test_set_val_bids"></a>

## Function `test_set_val_bids`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_set_val_bids">test_set_val_bids</a>(vm: &signer, vals: &vector&lt;<b>address</b>&gt;, bids: &vector&lt;u64&gt;, expiry: &vector&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_set_val_bids">test_set_val_bids</a>(vm: &signer, vals: &vector&lt;<b>address</b>&gt;, bids: &vector&lt;u64&gt;, expiry: &vector&lt;u64&gt;) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(vals);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> bid = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(bids, i);
    <b>let</b> exp = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(expiry, i);
    <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(vals, i);
    <a href="ProofOfFee.md#0x1_ProofOfFee_test_set_one_bid">test_set_one_bid</a>(vm, addr, *bid, *exp);
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_test_set_one_bid"></a>

## Function `test_set_one_bid`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_set_one_bid">test_set_one_bid</a>(vm: &signer, val: &<b>address</b>, bid: u64, exp: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_set_one_bid">test_set_one_bid</a>(vm: &signer, val: &<b>address</b>, bid:  u64, exp: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);
  <b>let</b> pof = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(*val);
  pof.epoch_expiration = exp;
  pof.bid = bid;
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_test_mock_reward"></a>

## Function `test_mock_reward`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_mock_reward">test_mock_reward</a>(vm: &signer, value: u64, clearing_price: u64, median_win_bid: u64, median_history: vector&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_test_mock_reward">test_mock_reward</a>(
  vm: &signer,
  value: u64,
  clearing_price: u64,
  median_win_bid: u64,
  median_history: vector&lt;u64&gt;,
) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);

  <b>let</b> cr = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved );
  cr.value = value;
  cr.clearing_price = clearing_price;
  cr.median_win_bid = median_win_bid;
  cr.median_history = median_history;

}
</code></pre>



</details>
