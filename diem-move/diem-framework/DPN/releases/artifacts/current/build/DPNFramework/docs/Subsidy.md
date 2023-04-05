
<a name="0x1_Subsidy"></a>

# Module `0x1::Subsidy`



-  [Constants](#@Constants_0)
-  [Function `process_subsidy`](#0x1_Subsidy_process_subsidy)
-  [Function `calculate_subsidy`](#0x1_Subsidy_calculate_subsidy)
-  [Function `subsidy_curve`](#0x1_Subsidy_subsidy_curve)
-  [Function `genesis`](#0x1_Subsidy_genesis)
-  [Function `process_fees`](#0x1_Subsidy_process_fees)
-  [Function `refund_operator_tx_fees`](#0x1_Subsidy_refund_operator_tx_fees)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorConfig.md#0x1_ValidatorConfig">0x1::ValidatorConfig</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_Subsidy_BASELINE_TX_COST"></a>



<pre><code><b>const</b> <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a>: u64 = 4336;
</code></pre>



<a name="0x1_Subsidy_process_subsidy"></a>

## Function `process_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_subsidy">process_subsidy</a>(vm: &signer, subsidy_units: u64, outgoing_set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_subsidy">process_subsidy</a>(
  vm: &signer,
  subsidy_units: u64,
  outgoing_set: &vector&lt;<b>address</b>&gt;,
) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  // Get the split of payments from <a href="Stats.md#0x1_Stats">Stats</a>.
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(outgoing_set);
  // equal subsidy for all active validators
  <b>let</b> subsidy_granted;
  // TODO: This calculation is duplicated <b>with</b> get_subsidy
  <b>if</b> (subsidy_units &gt; len && subsidy_units &gt; 0 ) { // arithmetic safety check
    subsidy_granted = subsidy_units/len;
  } <b>else</b> { <b>return</b> };

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> node_address = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(outgoing_set, i));
    // Transfer gas from vm <b>address</b> <b>to</b> validator
    <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, subsidy_granted);
    <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
      vm,
      @VMReserved,
      node_address,
      minted_coins,
      b"validator subsidy",
      b""
    );

    // refund operator tx fees for mining
    <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm, node_address);
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Subsidy_calculate_subsidy"></a>

## Function `calculate_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">calculate_subsidy</a>(vm: &signer, network_density: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_calculate_subsidy">calculate_subsidy</a>(vm: &signer, network_density: u64): (u64, u64) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  // skip genesis
  <b>assert</b>!(!<a href="DiemTimestamp.md#0x1_DiemTimestamp_is_genesis">DiemTimestamp::is_genesis</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(190102));

  // Gets the transaction fees in the epoch
  <b>let</b> txn_fee_amount = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
  // Calculate the split for subsidy and burn
  <b>let</b> subsidy_ceiling_gas = <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">Globals::get_subsidy_ceiling_gas</a>();
  // TODO: This metric network density is different than
  // <a href="DiemSystem.md#0x1_DiemSystem_get_fee_ratio">DiemSystem::get_fee_ratio</a> which actually checks the cases.

  // <b>let</b> network_density = <a href="Stats.md#0x1_Stats_network_density">Stats::network_density</a>(vm, height_start, height_end);
  <b>let</b> max_node_count = <a href="Globals.md#0x1_Globals_get_max_validators_per_set">Globals::get_max_validators_per_set</a>();
  <b>let</b> guaranteed_minimum = <a href="Subsidy.md#0x1_Subsidy_subsidy_curve">subsidy_curve</a>(
    subsidy_ceiling_gas,
    network_density,
    max_node_count,
  );
  <b>let</b> subsidy = 0;
  <b>let</b> subsidy_per_node = 0;
  // deduct transaction fees from guaranteed minimum.
  <b>if</b> (guaranteed_minimum &gt; txn_fee_amount ){
    subsidy = guaranteed_minimum - txn_fee_amount;

    <b>if</b> (subsidy &gt; subsidy_ceiling_gas) {
      subsidy = subsidy_ceiling_gas
    };

    // <b>return</b> <b>global</b> subsidy and subsidy per node.
    // TODO: we are doing this computation twice at reconfigure time.
    <b>if</b> ((subsidy &gt; network_density) && (network_density &gt; 0)) {
      subsidy_per_node = subsidy/network_density;
    };
  };
  (subsidy, subsidy_per_node)
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

  <b>if</b> (network_density &gt;= max_node_count) {
    <b>return</b> 0u64
  };

  <b>let</b> slope = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_divide_u64">FixedPoint32::divide_u64</a>(
    subsidy_ceiling_gas,
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(max_node_count - min_node_count, 1)
  );
  // y-intercept
  <b>let</b> intercept = slope * max_node_count;
  // calculating subsidy and burn units
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


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_genesis">genesis</a>(vm_sig: &signer) { // Todo: rename <b>to</b> "genesis_deposit" ?
  // Need <b>to</b> check for association or vm account
  <b>let</b> vm_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm_sig);
  <b>assert</b>!(vm_addr == @DiemRoot, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(190104));

  // Get eligible validators list
  <b>let</b> genesis_validators = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&genesis_validators);
  // ten coins for validator, sufficient for first epoch of transactions,
  // and an extra which the validator will send <b>to</b> operator.
  <b>let</b> subsidy = 11000000;
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> node_address = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&genesis_validators, i));
    <b>let</b> old_validator_bal = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(node_address);

    <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm_sig, *&subsidy);
    <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
      vm_sig,
      @VMReserved,
      node_address,
      minted_coins,
      b"genesis subsidy",
      b""
    );

    // Confirm the calculations, and that the ending balance is incremented accordingly.
    <b>assert</b>!(
      <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(node_address) == old_validator_bal + subsidy,
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(190104)
    );

    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Subsidy_process_fees"></a>

## Function `process_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_fees">process_fees</a>(vm: &signer, outgoing_set: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Subsidy.md#0x1_Subsidy_process_fees">process_fees</a>(
  vm: &signer,
  outgoing_set: &vector&lt;<b>address</b>&gt;,
) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(outgoing_set);
  <b>let</b> bal = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
  // leave fees in tx_fee <b>if</b> there isn't at least 1 gas coin per validator.
  <b>if</b> (bal &lt; len) {
    <b>return</b>
  };

  <b>if</b> (bal &lt; 1) {
    <b>return</b>
  };

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> node_address = *(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(outgoing_set, i));
    <b>let</b> fees = bal/len;

    <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        vm,
        @VMReserved,
        node_address,
        <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">TransactionFee::get_transaction_fees_coins_amount</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, fees),
        b"transaction fees",
        b""
    );
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Subsidy_refund_operator_tx_fees"></a>

## Function `refund_operator_tx_fees`



<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm: &signer, miner_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Subsidy.md#0x1_Subsidy_refund_operator_tx_fees">refund_operator_tx_fees</a>(vm: &signer, miner_addr: <b>address</b>) {
    // get operator for validator
    <b>let</b> oper_addr = <a href="ValidatorConfig.md#0x1_ValidatorConfig_get_operator">ValidatorConfig::get_operator</a>(miner_addr);
    // count OWNER's proofs submitted
    <b>let</b> proofs_in_epoch = <a href="TowerState.md#0x1_TowerState_get_count_in_epoch">TowerState::get_count_in_epoch</a>(miner_addr);

    <b>let</b> cost = 0;
    // find cost from baseline
    <b>if</b> (proofs_in_epoch &gt; 0) {
      cost = <a href="Subsidy.md#0x1_Subsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * proofs_in_epoch;
    };

    // deduct from subsidy from Validator
    // send payment <b>to</b> operator
    <b>if</b> (cost &gt; 0) {
      <b>let</b> owner_balance = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(miner_addr);
      <b>if</b> (!(owner_balance &gt; cost)) {
        cost = owner_balance;
      };

      <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">DiemAccount::vm_make_payment_no_limit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
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
