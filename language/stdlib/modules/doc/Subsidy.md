
<a name="0x1_Subsidy"></a>

# Module `0x1::Subsidy`



-  [Resource `FullnodeSubsidy`](#0x1_Subsidy_FullnodeSubsidy)
-  [Constants](#@Constants_0)
-  [Function `process_subsidy`](#0x1_Subsidy_process_subsidy)
-  [Function `calculate_subsidy`](#0x1_Subsidy_calculate_subsidy)
-  [Function `subsidy_curve`](#0x1_Subsidy_subsidy_curve)
-  [Function `genesis`](#0x1_Subsidy_genesis)
-  [Function `process_fees`](#0x1_Subsidy_process_fees)
-  [Function `init_fullnode_sub`](#0x1_Subsidy_init_fullnode_sub)
-  [Function `distribute_onboarding_subsidy`](#0x1_Subsidy_distribute_onboarding_subsidy)
-  [Function `distribute_fullnode_subsidy`](#0x1_Subsidy_distribute_fullnode_subsidy)
-  [Function `fullnode_reconfig`](#0x1_Subsidy_fullnode_reconfig)
-  [Function `set_global_count`](#0x1_Subsidy_set_global_count)
-  [Function `baseline_auction_units`](#0x1_Subsidy_baseline_auction_units)
-  [Function `auctioneer`](#0x1_Subsidy_auctioneer)
-  [Function `calc_auction`](#0x1_Subsidy_calc_auction)
-  [Function `fullnode_subsidy_ceiling`](#0x1_Subsidy_fullnode_subsidy_ceiling)
-  [Function `bootstrap_validator_balance`](#0x1_Subsidy_bootstrap_validator_balance)
-  [Function `refund_operator_tx_fees`](#0x1_Subsidy_refund_operator_tx_fees)
-  [Function `test_set_fullnode_fixtures`](#0x1_Subsidy_test_set_fullnode_fixtures)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="FullnodeState.md#0x1_FullnodeState">0x1::FullnodeState</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="Libra.md#0x1_Libra">0x1::Libra</a>;
<b>use</b> <a href="LibraAccount.md#0x1_LibraAccount">0x1::LibraAccount</a>;
<b>use</b> <a href="LibraSystem.md#0x1_LibraSystem">0x1::LibraSystem</a>;
<b>use</b> <a href="LibraTimestamp.md#0x1_LibraTimestamp">0x1::LibraTimestamp</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Subsidy_FullnodeSubsidy"></a>

## Resource `FullnodeSubsidy`



<pre><code><b>resource</b> <b>struct</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>previous_epoch_proofs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>current_proof_price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>current_cap: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>current_subsidy_distributed: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>current_proofs_verified: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Subsidy_BASELINE_TX_COST"></a>



<pre><code><b>const</b> <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a>: u64 = 4336;
</code></pre>



<a name="0x1_Subsidy_process_subsidy"></a>

## Function `process_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_subsidy">process_subsidy</a>(vm_sig: &signer, subsidy_units: u64, outgoing_set: &vector&lt;address&gt;, _fee_ratio: &vector&lt;<a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_subsidy">process_subsidy</a>(
  vm_sig: &signer,
  subsidy_units: u64,
  outgoing_set: &vector&lt;address&gt;,
  _fee_ratio: &vector&lt;<a href="FixedPoint32.md#0x1_FixedPoint32">FixedPoint32</a>&gt;) {
  <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm_sig);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190101034010);

  // Get the split of payments from <a href="Stats.md#0x1_Stats">Stats</a>.
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(outgoing_set);

  // equal subsidy for all active validators
  <b>let</b> subsidy_granted;
  <b>if</b> (subsidy_units &gt; len && subsidy_units &gt; 0 ) { // arithmetic safety check
    subsidy_granted = subsidy_units/len;
  } <b>else</b> { <b>return</b> };

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {

    <b>let</b> node_address = *(<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(outgoing_set, i));

    // Transfer gas from vm address <b>to</b> validator
    <b>let</b> minted_coins = <a href="Libra.md#0x1_Libra_mint">Libra::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm_sig, subsidy_granted);
    <a href="LibraAccount.md#0x1_LibraAccount_vm_deposit_with_metadata">LibraAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
      vm_sig,
      node_address,
      minted_coins,
      x"",
      x""
    );

    // refund operator tx fees for mining
    <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm_sig, node_address);
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Subsidy_calculate_subsidy"></a>

## Function `calculate_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">calculate_subsidy</a>(vm: &signer, height_start: u64, height_end: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">calculate_subsidy</a>(vm: &signer, height_start: u64, height_end: u64):u64 {

  <b>let</b> sender = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm);
  <b>assert</b>(sender == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190101014010);

  // skip genesis
  <b>assert</b>(!<a href="LibraTimestamp.md#0x1_LibraTimestamp_is_genesis">LibraTimestamp::is_genesis</a>(), 190101021000);

  // Gets the transaction fees in the epoch
  <b>let</b> txn_fee_amount = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);

  // Calculate the split for subsidy and burn
  <b>let</b> subsidy_ceiling_gas = <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">Globals::get_subsidy_ceiling_gas</a>();
  <b>let</b> network_density = <a href="Stats.md#0x1_Stats_network_density">Stats::network_density</a>(vm, height_start, height_end);
  <b>let</b> max_node_count = <a href="Globals.md#0x1_Globals_get_max_node_density">Globals::get_max_node_density</a>();
  <b>let</b> guaranteed_minimum = <a href="Subsidy.md#0x1_Subsidy_subsidy_curve">subsidy_curve</a>(
    subsidy_ceiling_gas,
    network_density,
    max_node_count,
  );

  // deduct transaction fees from guaranteed minimum.
  <b>if</b> (guaranteed_minimum &gt; txn_fee_amount ){
    <b>return</b> guaranteed_minimum - txn_fee_amount
  };
  0u64
}
</code></pre>



</details>

<a name="0x1_Subsidy_subsidy_curve"></a>

## Function `subsidy_curve`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_subsidy_curve">subsidy_curve</a>(subsidy_ceiling_gas: u64, network_density: u64, max_node_count: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_subsidy_curve">subsidy_curve</a>(
  subsidy_ceiling_gas: u64,
  network_density: u64,
  max_node_count: u64
  ): u64 {

  <b>let</b> min_node_count = 4u64;

  // Return early <b>if</b> we know the value is below 4.
  // This applies only <b>to</b> test environments <b>where</b> there is network of 1.
  <b>if</b> (network_density &lt;= min_node_count) {
    <b>return</b> subsidy_ceiling_gas
  };

  <b>let</b> slope = <a href="FixedPoint32.md#0x1_FixedPoint32_divide_u64">FixedPoint32::divide_u64</a>(
    subsidy_ceiling_gas,
    <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(max_node_count - min_node_count, 1)
    );
  //y-intercept
  <b>let</b> intercept = slope * max_node_count;
  //calculating subsidy and burn units
  // NOTE: confirm order of operations here:
  <b>let</b> guaranteed_minimum = intercept - slope * network_density;
  guaranteed_minimum
}
</code></pre>



</details>

<a name="0x1_Subsidy_genesis"></a>

## Function `genesis`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_genesis">genesis</a>(vm_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_genesis">genesis</a>(vm_sig: &signer) <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>{
  //Need <b>to</b> check for association or vm account
  <b>let</b> vm_addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm_sig);
  <b>assert</b>(vm_addr == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190101044010);

  // Get eligible validators list
  <b>let</b> genesis_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>(vm_sig);
  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&genesis_validators);

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {

    <b>let</b> node_address = *(<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&genesis_validators, i));
    <b>let</b> old_validator_bal = <a href="LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(node_address);
    // <b>let</b> count_proofs = 1;

    // <b>if</b> (is_testnet()) {
    //   // start <b>with</b> sufficient gas for expensive tests e.g. upgrade
    //   count_proofs = 10;
    // };

    <b>let</b> subsidy_granted = <a href="Subsidy.md#0x1_Subsidy_distribute_onboarding_subsidy">distribute_onboarding_subsidy</a>(vm_sig, node_address);
    //Confirm the calculations, and that the ending balance is incremented accordingly.

    <b>assert</b>(<a href="LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(node_address) == old_validator_bal + subsidy_granted, 19010105100);

    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Subsidy_process_fees"></a>

## Function `process_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_fees">process_fees</a>(vm: &signer, outgoing_set: &vector&lt;address&gt;, _fee_ratio: &vector&lt;<a href="FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_fees">process_fees</a>(
  vm: &signer,
  outgoing_set: &vector&lt;address&gt;,
  _fee_ratio: &vector&lt;<a href="FixedPoint32.md#0x1_FixedPoint32">FixedPoint32</a>&gt;,
){
  <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) == <a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(), 190103014010);
  <b>let</b> capability_token = <a href="LibraAccount.md#0x1_LibraAccount_extract_withdraw_capability">LibraAccount::extract_withdraw_capability</a>(vm);

  <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(outgoing_set);

  <b>let</b> bal = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
// leave fees in tx_fee <b>if</b> there isn't at least 1 gas coin per validator.
  <b>if</b> (bal &lt; len) {
    <a href="LibraAccount.md#0x1_LibraAccount_restore_withdraw_capability">LibraAccount::restore_withdraw_capability</a>(capability_token);
    <b>return</b>
  };

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> node_address = *(<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(outgoing_set, i));
    // <b>let</b> node_ratio = *(<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="FixedPoint32.md#0x1_FixedPoint32">FixedPoint32</a>&gt;(fee_ratio, i));
    <b>let</b> fees = bal/len;

    <a href="LibraAccount.md#0x1_LibraAccount_vm_deposit_with_metadata">LibraAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        vm,
        node_address,
        <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">TransactionFee::get_transaction_fees_coins_amount</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, fees),
        x"",
        x""
    );
    i = i + 1;
  };
  <a href="LibraAccount.md#0x1_LibraAccount_restore_withdraw_capability">LibraAccount::restore_withdraw_capability</a>(capability_token);
}
</code></pre>



</details>

<a name="0x1_Subsidy_init_fullnode_sub"></a>

## Function `init_fullnode_sub`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_init_fullnode_sub">init_fullnode_sub</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_init_fullnode_sub">init_fullnode_sub</a>(vm: &signer) {
  <b>let</b> genesis_validators = <a href="LibraSystem.md#0x1_LibraSystem_get_val_set_addr">LibraSystem::get_val_set_addr</a>();
  <b>let</b> validator_count = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&genesis_validators);
  <b>if</b> (validator_count &lt; 10) validator_count = 10;
  // baseline_cap: baseline units per epoch times the mininmum <b>as</b> used in tx, times minimum gas per unit.

  <b>let</b> ceiling = <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>() * <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * validator_count;

  <a href="Roles.md#0x1_Roles_assert_libra_root">Roles::assert_libra_root</a>(vm);
  <b>assert</b>(!<b>exists</b>&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm)), 130112011021);
  move_to&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(vm, <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>{
    previous_epoch_proofs: 0u64,
    current_proof_price: <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * 24 * 8 * 3, // number of proof submisisons in 3 initial epochs.
    current_cap: ceiling,
    current_subsidy_distributed: 0u64,
    current_proofs_verified: 0u64,
  });
}
</code></pre>



</details>

<a name="0x1_Subsidy_distribute_onboarding_subsidy"></a>

## Function `distribute_onboarding_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_distribute_onboarding_subsidy">distribute_onboarding_subsidy</a>(vm: &signer, miner: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_distribute_onboarding_subsidy">distribute_onboarding_subsidy</a>(
  vm: &signer,
  miner: address
):u64 <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a> {
  // Bootstrap gas <b>if</b> it's the first payment <b>to</b> a prospective validator. Check no fullnode payments have been made, and is in validator universe.
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_libra_root">CoreAddresses::assert_libra_root</a>(vm);

  <a href="FullnodeState.md#0x1_FullnodeState_is_onboarding">FullnodeState::is_onboarding</a>(miner);

  <b>let</b> state = borrow_global&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>());

  <b>let</b> subsidy = <a href="Subsidy.md#0x1_Subsidy_bootstrap_validator_balance">bootstrap_validator_balance</a>();
  // give max possible subisidy, <b>if</b> auction is higher
  <b>if</b> (state.current_proof_price &gt; subsidy) subsidy = state.current_proof_price;

  <b>let</b> minted_coins = <a href="Libra.md#0x1_Libra_mint">Libra::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, subsidy);
  <a href="LibraAccount.md#0x1_LibraAccount_vm_deposit_with_metadata">LibraAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    vm,
    miner,
    minted_coins,
    b"onboarding_subsidy",
    b""
  );

  subsidy
}
</code></pre>



</details>

<a name="0x1_Subsidy_distribute_fullnode_subsidy"></a>

## Function `distribute_fullnode_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(vm: &signer, miner: address, count: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(vm: &signer, miner: address, count: u64):u64 <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>{
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_libra_root">CoreAddresses::assert_libra_root</a>(vm);
  // Payment is only for fullnodes, ie. not in current validator set.
  <b>if</b> (<a href="LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(miner)) <b>return</b> 0;

  <b>let</b> state = borrow_global_mut&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
  <b>let</b> subsidy;

  // fail fast, <b>abort</b> <b>if</b> ceiling was met
  <b>if</b> (state.current_subsidy_distributed &gt; state.current_cap) <b>return</b> 0;

  <b>let</b> proposed_subsidy = state.current_proof_price * count;

  <b>if</b> (proposed_subsidy == 0) <b>return</b> 0;
  // check <b>if</b> payments will exceed ceiling.
  <b>if</b> (state.current_subsidy_distributed + proposed_subsidy &gt; state.current_cap) {
    // pay the remainder only
    // TODO: This creates a race. Check ordering of list.
    subsidy = state.current_cap - state.current_subsidy_distributed;
  } <b>else</b> {
    // happy case, the ceiling is not met.
    subsidy = proposed_subsidy;
  };

  <b>if</b> (subsidy == 0) <b>return</b> 0;

  <b>let</b> minted_coins = <a href="Libra.md#0x1_Libra_mint">Libra::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, subsidy);
  <a href="LibraAccount.md#0x1_LibraAccount_vm_deposit_with_metadata">LibraAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    vm,
    miner,
    minted_coins,
    b"fullnode_subsidy",
    b""
  );

  state.current_subsidy_distributed = state.current_subsidy_distributed + subsidy;

  subsidy
}
</code></pre>



</details>

<a name="0x1_Subsidy_fullnode_reconfig"></a>

## Function `fullnode_reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_fullnode_reconfig">fullnode_reconfig</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_fullnode_reconfig">fullnode_reconfig</a>(vm: &signer) <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a> {
  <a href="Roles.md#0x1_Roles_assert_libra_root">Roles::assert_libra_root</a>(vm);

  // <b>update</b> values for the proof auction.
  <a href="Subsidy.md#0x1_Subsidy_auctioneer">auctioneer</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
   // save
  state.previous_epoch_proofs = state.current_proofs_verified;
  // reset counters
  state.current_subsidy_distributed = 0u64;
  state.current_proofs_verified = 0u64;
}
</code></pre>



</details>

<a name="0x1_Subsidy_set_global_count"></a>

## Function `set_global_count`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_set_global_count">set_global_count</a>(vm: &signer, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_set_global_count">set_global_count</a>(vm: &signer, count: u64) <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>{
  <b>let</b> state = borrow_global_mut&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
  state.current_proofs_verified = count;
}
</code></pre>



</details>

<a name="0x1_Subsidy_baseline_auction_units"></a>

## Function `baseline_auction_units`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>():u64 {
  <b>let</b> epoch_length_mins = 24 * 60;
  <b>let</b> steady_state_nodes = 1000;
  <b>let</b> target_delay = 10;
  steady_state_nodes * (epoch_length_mins/target_delay)
}
</code></pre>



</details>

<a name="0x1_Subsidy_auctioneer"></a>

## Function `auctioneer`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_auctioneer">auctioneer</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_auctioneer">auctioneer</a>(vm: &signer) <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a> {

  <a href="Roles.md#0x1_Roles_assert_libra_root">Roles::assert_libra_root</a>(vm);

  <b>let</b> state = borrow_global_mut&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));

  // The targeted amount of proofs <b>to</b> be submitted network-wide per epoch.
  <b>let</b> baseline_auction_units = <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>();
  // The max subsidy that can be paid out in the next epoch.
  <b>let</b> ceiling = <a href="Subsidy.md#0x1_Subsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm);


  // Failure case
  <b>if</b> (ceiling &lt; 1) ceiling = 1;

  state.current_proof_price = <a href="Subsidy.md#0x1_Subsidy_calc_auction">calc_auction</a>(
    ceiling,
    baseline_auction_units,
    state.current_proofs_verified
  );
  // Set new ceiling
  state.current_cap = ceiling;
}
</code></pre>



</details>

<a name="0x1_Subsidy_calc_auction"></a>

## Function `calc_auction`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calc_auction">calc_auction</a>(ceiling: u64, baseline_auction_units: u64, current_proofs_verified: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calc_auction">calc_auction</a>(
  ceiling: u64,
  baseline_auction_units: u64,
  current_proofs_verified: u64,
): u64 {
  // Calculate price per proof
  // Find the baseline price of a proof, which will be altered based on performance.
  // <b>let</b> baseline_proof_price = <a href="FixedPoint32.md#0x1_FixedPoint32_divide_u64">FixedPoint32::divide_u64</a>(
  //   ceiling,
  //   <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_raw_value">FixedPoint32::create_from_raw_value</a>(baseline_auction_units)
  // );
  <b>let</b> baseline_proof_price = ceiling/baseline_auction_units;
  // print(&baseline_proof_price);

  // print(&<a href="FixedPoint32.md#0x1_FixedPoint32_get_raw_value">FixedPoint32::get_raw_value</a>(<b>copy</b> baseline_proof_price));
  // Calculate the appropriate multiplier.
  <b>let</b> proofs = current_proofs_verified;
  <b>if</b> (proofs &lt; 1) proofs = 1;

  <b>let</b> multiplier = baseline_auction_units/proofs;

  // <b>let</b> multiplier = <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(
  //   baseline_auction_units,
  //   proofs
  // );
  // print(&multiplier);

  // Set the proof price using multiplier.
  // New unit price cannot be more than the ceiling
  // <b>let</b> proposed_price = <a href="FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(
  //   baseline_proof_price,
  //   multiplier
  // );

  <b>let</b> proposed_price = baseline_proof_price * multiplier;

  // print(&proposed_price);

  <b>if</b> (proposed_price &lt; ceiling) {
    <b>return</b> proposed_price
  };
  //Note: in failure case, the next miner gets the full ceiling
  <b>return</b> ceiling
}
</code></pre>



</details>

<a name="0x1_Subsidy_fullnode_subsidy_ceiling"></a>

## Function `fullnode_subsidy_ceiling`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm: &signer):u64 {
  //get TX fees from previous epoch.
  <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
  // Recover from failure case <b>where</b> there are no fees
  <b>if</b> (fees &lt; <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>()) <b>return</b> <a href="Subsidy.md#0x1_Subsidy_baseline_auction_units">baseline_auction_units</a>();
  fees
}
</code></pre>



</details>

<a name="0x1_Subsidy_bootstrap_validator_balance"></a>

## Function `bootstrap_validator_balance`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_bootstrap_validator_balance">bootstrap_validator_balance</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_bootstrap_validator_balance">bootstrap_validator_balance</a>():u64 {
  <b>let</b> mins_per_day = 60 * 24;
  <b>let</b> proofs_per_day = mins_per_day / 10; // 10 min proofs
  <b>let</b> proof_cost = 4000; // assumes 1 microgas per gas unit
  <b>let</b> subsidy_value = proofs_per_day * proof_cost;
  subsidy_value
}
</code></pre>



</details>

<a name="0x1_Subsidy_refund_operator_tx_fees"></a>

## Function `refund_operator_tx_fees`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm: &signer, miner_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm: &signer, miner_addr: address) {
    // get operator for validator
    <b>let</b> oper_addr = <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr);
    // count OWNER's proofs submitted
    <b>let</b> proofs_in_epoch = <a href="FullnodeState.md#0x1_FullnodeState_get_address_proof_count">FullnodeState::get_address_proof_count</a>(miner_addr);
    <b>let</b> cost = 0;
    // find cost from baseline
    <b>if</b> (proofs_in_epoch &gt; 0) {
      cost = <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * proofs_in_epoch;
    };
    // deduct from subsidy <b>to</b> miner
    // send payment <b>to</b> operator
    <b>if</b> (cost &gt; 0) {
      <b>let</b> owner_balance = <a href="LibraAccount.md#0x1_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(miner_addr);
      <b>if</b> (!(owner_balance &gt; cost)) {
        cost = owner_balance;
      };

      <a href="LibraAccount.md#0x1_LibraAccount_vm_make_payment">LibraAccount::vm_make_payment</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        miner_addr,
        oper_addr,
        cost,
        b"tx fee refund",
        b"",
        vm
      );
    };
}
</code></pre>



</details>

<a name="0x1_Subsidy_test_set_fullnode_fixtures"></a>

## Function `test_set_fullnode_fixtures`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(vm: &signer, previous_epoch_proofs: u64, current_proof_price: u64, current_cap: u64, current_subsidy_distributed: u64, current_proofs_verified: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(
  vm: &signer,
  previous_epoch_proofs: u64,
  current_proof_price: u64,
  current_cap: u64,
  current_subsidy_distributed: u64,
  current_proofs_verified: u64,
) <b>acquires</b> <a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a> {
  <a href="Roles.md#0x1_Roles_assert_libra_root">Roles::assert_libra_root</a>(vm);
  <b>assert</b>(is_testnet(), 1000);
  <b>let</b> state = borrow_global_mut&lt;<a href="Subsidy.md#0x1_Subsidy_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(0x0);
  state.previous_epoch_proofs = previous_epoch_proofs;
  state.current_proof_price = current_proof_price;
  state.current_cap = current_cap;
  state.current_subsidy_distributed = current_subsidy_distributed;
  state.current_proofs_verified = current_proofs_verified;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
