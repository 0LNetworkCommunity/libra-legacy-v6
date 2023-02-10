
<a name="0x1_ProofOfFee"></a>

# Module `0x1::ProofOfFee`



-  [Resource `ProofOfFeeAuction`](#0x1_ProofOfFee_ProofOfFeeAuction)
-  [Resource `ConsensusReward`](#0x1_ProofOfFee_ConsensusReward)
-  [Constants](#@Constants_0)
-  [Function `init_genesis_baseline_reward`](#0x1_ProofOfFee_init_genesis_baseline_reward)
-  [Function `init`](#0x1_ProofOfFee_init)
-  [Function `top_n_accounts`](#0x1_ProofOfFee_top_n_accounts)
-  [Function `get_sorted_vals`](#0x1_ProofOfFee_get_sorted_vals)
-  [Function `fill_seats_and_get_price`](#0x1_ProofOfFee_fill_seats_and_get_price)
-  [Function `reward_thermostat`](#0x1_ProofOfFee_reward_thermostat)
-  [Function `set_history`](#0x1_ProofOfFee_set_history)
-  [Function `get_median`](#0x1_ProofOfFee_get_median)
-  [Function `get_consensus_reward`](#0x1_ProofOfFee_get_consensus_reward)
-  [Function `current_bid`](#0x1_ProofOfFee_current_bid)
-  [Function `set_bid`](#0x1_ProofOfFee_set_bid)
-  [Function `init_bidding`](#0x1_ProofOfFee_init_bidding)
-  [Function `update_pof_bid`](#0x1_ProofOfFee_update_pof_bid)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
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
<code>average_winning_bid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>avg_bid_history: vector&lt;u64&gt;</code>
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
        average_winning_bid: 0,
        avg_bid_history: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
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
        epoch_expiration: 0
      }
    );
  }
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_top_n_accounts"></a>

## Function `top_n_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_top_n_accounts">top_n_accounts</a>(account: &signer, n: u64): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
    <b>assert</b>!(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(140101));

    <b>let</b> eligible_validators = <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>();
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

<a name="0x1_ProofOfFee_get_sorted_vals"></a>

## Function `get_sorted_vals`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  <b>let</b> eligible_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();
  <b>let</b> length = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&eligible_validators);
  // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">Vector</a> <b>to</b> store each <b>address</b>'s node_weight
  <b>let</b> weights = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {

    <b>let</b> cur_address = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&eligible_validators, k);
    // Ensure that this <b>address</b> is an active validator
    <b>let</b> (bid, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(cur_address);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, bid);
    k = k + 1;
  };

  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> i = 0;
  <b>while</b> (i &lt; length){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; length-i-1){

      <b>let</b> value_j = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
      <b>let</b> value_jp1 = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
      <b>if</b>(value_j &gt; value_jp1){
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap">Vector::swap</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators, j, j+1);
      };
      j = j + 1;
    };
    i = i + 1;
  };

  // Reverse <b>to</b> have sorted order - high <b>to</b> low.
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_reverse">Vector::reverse</a>&lt;<b>address</b>&gt;(&<b>mut</b> eligible_validators);

  <b>return</b> eligible_validators
}
</code></pre>



</details>

<a name="0x1_ProofOfFee_fill_seats_and_get_price"></a>

## Function `fill_seats_and_get_price`



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">fill_seats_and_get_price</a>(vm: &signer, set_size: u64, proven_nodes: &vector&lt;<b>address</b>&gt;): (vector&lt;<b>address</b>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_fill_seats_and_get_price">fill_seats_and_get_price</a>(vm: &signer, set_size: u64, proven_nodes: &vector&lt;<b>address</b>&gt;): (vector&lt;<b>address</b>&gt;, u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>, <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @VMReserved) <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(), 0);

  <b>let</b> baseline_reward = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>();

  <b>let</b> seats_to_fill = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  // print(&set_size);
  print(&8006010201);
  <b>let</b> max_unproven = set_size / 3;

  <b>let</b> num_unproven_added = 0;

  print(&8006010202);
  <b>let</b> sorted_vals_by_bid = <a href="ProofOfFee.md#0x1_ProofOfFee_get_sorted_vals">get_sorted_vals</a>();

  <b>let</b> i = 0u64;
  <b>while</b> (
    (i &lt; set_size) &&
    (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&sorted_vals_by_bid))
  ) {
    // print(&i);
    <b>let</b> val = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&sorted_vals_by_bid, i);
    <b>let</b> (bid, expire) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(*val);
    // fail fast <b>if</b> the validator is jailed.
    // NOTE: epoch reconfigure needs <b>to</b> reset the jail
    // before calling the proof of fee.

    // NOTE: I know the multiple i = i+1 is ugly, but debugging
    // is much harder <b>if</b> we have all the checks in one '<b>if</b>' statement.
    print(&8006010203);
    <b>if</b> (<a href="Jail.md#0x1_Jail_is_jailed">Jail::is_jailed</a>(*val)) {
      i = i + 1;
      <b>continue</b>
    };
    print(&8006010204);
    <b>if</b> (!<a href="Vouch.md#0x1_Vouch_unrelated_buddies_above_thresh">Vouch::unrelated_buddies_above_thresh</a>(*val)) {
      i = i + 1;
      <b>continue</b>
    };

    print(&80060102041);
    // skip the user <b>if</b> they don't have sufficient UNLOCKED funds
    // or <b>if</b> the bid expired.

    // belt and suspenders, expiry
    <b>if</b> (<a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() &gt; expire) {
      i = i + 1;
      <b>continue</b>
    };

    <b>let</b> coin_required = bid * baseline_reward;
    <b>if</b> (
      <a href="DiemAccount.md#0x1_DiemAccount_unlocked_amount">DiemAccount::unlocked_amount</a>(*val) &lt; coin_required
    ) {
      i = i + 1;
      <b>continue</b>
    };


    // check <b>if</b> a proven node
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(proven_nodes, val)) {
      print(&8006010205);
      // print(&01);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> seats_to_fill, *val);
    } <b>else</b> {
      print(&8006010206);
      // print(&02);
      // for unproven nodes, push it <b>to</b> list <b>if</b> we haven't hit limit
      <b>if</b> (num_unproven_added &lt; max_unproven ) {
        // print(&03);
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> seats_to_fill, *val);
      };
      // print(&04);
      print(&8006010207);
      num_unproven_added = num_unproven_added + 1;
    };
    i = i + 1;
  };
  // print(&05);
  print(&8006010208);
  print(&seats_to_fill);

  <a href="ProofOfFee.md#0x1_ProofOfFee_set_history">set_history</a>(vm, &seats_to_fill);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&seats_to_fill)) {
    <b>return</b> (seats_to_fill, 0)
  };

  // Find the clearing price which all validators will pay
  <b>let</b> lowest_bidder = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&seats_to_fill, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&seats_to_fill) - 1);

  <b>let</b> (lowest_bid, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_current_bid">current_bid</a>(*lowest_bidder);
  <b>return</b> (seats_to_fill, lowest_bid)
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

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;u64&gt;(&cr.avg_bid_history);
  <b>let</b> i = 0;

  <b>let</b> epochs_above = 0;
  <b>let</b> epochs_below = 0;
  <b>while</b> (i &lt; 10 || i &lt; len) { // max ten days, but may have less in history, filling set should truncate the history at 10 epochs.
    <b>let</b> avg_bid = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&cr.avg_bid_history, i);
    <b>if</b> (avg_bid &gt; bid_upper_bound) {
      epochs_above = epochs_above + 1;
    } <b>else</b> <b>if</b> (avg_bid &lt; bid_lower_bound) {
      epochs_below = epochs_below + 1;
    };

    i = i + 1;
  };

  <b>if</b> (cr.value &gt; 0) {
    // TODO: this is an initial implementation, we need <b>to</b>
    // decide <b>if</b> we want more granularity in the reward adjustment
    // Note: making this readable for now, but we can optimize later
    <b>if</b> (epochs_above &gt; short_window) {
      // check for zeros.
      // TODO: put a better safety check here
      <b>if</b> ((cr.value / 10) &gt; cr.value){
        <b>return</b>
      };
      // If the Validators are bidding near 100% that means
      // the reward is very generous, i.e. their opportunity
      // cost is met at small percentages. This means the
      // implicit bond is very high on validators. E.g.
      // at 1% median bid, the implicit bond is 100x the reward.
      // We need <b>to</b> DECREASE the reward

      <b>if</b> (epochs_above &gt; short_window) {
        // decrease the reward by 10%
        cr.value = cr.value - (cr.value / 10);
        <b>return</b> // <b>return</b> early since we can't increase and decrease simultaneously
      } <b>else</b> <b>if</b> (epochs_above &gt; long_window) {
        // decrease the reward by 5%
        cr.value = cr.value - (cr.value / 20);
        <b>return</b> // <b>return</b> early since we can't increase and decrease simultaneously
      };

      // <b>if</b> validators are bidding low percentages
      // it means the nominal reward is not high enough.
      // That is the validator's opportunity cost is not met within a
      // range <b>where</b> the bond is meaningful.
      // For example: <b>if</b> the bids for the epoch's reward is 50% of the  value, that means the potential profit, is the same <b>as</b> the potential loss.
      // At a 25% bid (potential loss), the profit is thus 75% of the value, which means the implicit bond is 25/75, or 1/3 of the bond, the risk favors the validator. This means among other things, that an attacker can pay for the cost of the attack <b>with</b> the profits. See paper, for more details.

      // we need <b>to</b> INCREASE the reward, so that the bond is more meaningful.
      <b>if</b> (epochs_below &gt; short_window) {
        // decrease the reward by 5%
        cr.value = cr.value + (cr.value / 20);
      } <b>else</b> <b>if</b> (epochs_above &gt; long_window) {
        // decrease the reward by 10%
        cr.value = cr.value + (cr.value / 10);
      };
    };
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

  <b>let</b> median_bid = <a href="ProofOfFee.md#0x1_ProofOfFee_get_median">get_median</a>(seats_to_fill);
  // push <b>to</b> history
  <b>let</b> cr = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&cr.avg_bid_history) &lt; 10) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> cr.avg_bid_history, median_bid);
  } <b>else</b> {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> cr.avg_bid_history, 0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> cr.avg_bid_history, median_bid);
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



<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">get_consensus_reward</a>(): u64 <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a> {
  <b>let</b> b = <b>borrow_global</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ConsensusReward">ConsensusReward</a>&gt;(@VMReserved );
  <b>return</b> b.value
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

  <b>assert</b>!(bid &lt;= 11000, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_ol_tx">Errors::ol_tx</a>(<a href="ProofOfFee.md#0x1_ProofOfFee_EBID_ABOVE_MAX_PCT">EBID_ABOVE_MAX_PCT</a>));

  <b>let</b> pof = <b>borrow_global_mut</b>&lt;<a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a>&gt;(acc);
  pof.epoch_expiration = expiry_epoch;
  pof.bid = bid;
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

<a name="0x1_ProofOfFee_update_pof_bid"></a>

## Function `update_pof_bid`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_update_pof_bid">update_pof_bid</a>(sender: signer, bid: u64, epoch_expiry: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ProofOfFee.md#0x1_ProofOfFee_update_pof_bid">update_pof_bid</a>(sender: signer, bid: u64, epoch_expiry: u64) <b>acquires</b> <a href="ProofOfFee.md#0x1_ProofOfFee_ProofOfFeeAuction">ProofOfFeeAuction</a> {
  // <b>update</b> the bid, initializes <b>if</b> not already.
  <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">set_bid</a>(&sender, bid, epoch_expiry);
}
</code></pre>



</details>
