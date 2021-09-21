
<a name="0x1_FullnodeSubsidy"></a>

# Module `0x1::FullnodeSubsidy`



-  [Resource `FullnodeSubsidy`](#0x1_FullnodeSubsidy_FullnodeSubsidy)
-  [Constants](#@Constants_0)
-  [Function `init_fullnode_sub`](#0x1_FullnodeSubsidy_init_fullnode_sub)
-  [Function `get_proof_price`](#0x1_FullnodeSubsidy_get_proof_price)
-  [Function `distribute_fullnode_subsidy`](#0x1_FullnodeSubsidy_distribute_fullnode_subsidy)
-  [Function `fullnode_reconfig`](#0x1_FullnodeSubsidy_fullnode_reconfig)
-  [Function `set_global_count`](#0x1_FullnodeSubsidy_set_global_count)
-  [Function `baseline_auction_units`](#0x1_FullnodeSubsidy_baseline_auction_units)
-  [Function `auctioneer`](#0x1_FullnodeSubsidy_auctioneer)
-  [Function `calc_auction`](#0x1_FullnodeSubsidy_calc_auction)
-  [Function `fullnode_subsidy_ceiling`](#0x1_FullnodeSubsidy_fullnode_subsidy_ceiling)
-  [Function `test_set_fullnode_fixtures`](#0x1_FullnodeSubsidy_test_set_fullnode_fixtures)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_FullnodeSubsidy_FullnodeSubsidy"></a>

## Resource `FullnodeSubsidy`



<pre><code><b>struct</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a> has key
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


<a name="0x1_FullnodeSubsidy_BASELINE_TX_COST"></a>



<pre><code><b>const</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_BASELINE_TX_COST">BASELINE_TX_COST</a>: u64 = 4336;
</code></pre>



<a name="0x1_FullnodeSubsidy_init_fullnode_sub"></a>

## Function `init_fullnode_sub`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_init_fullnode_sub">init_fullnode_sub</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_init_fullnode_sub">init_fullnode_sub</a>(vm: &signer) {
  <b>let</b> genesis_validators = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();
  <b>let</b> validator_count = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&genesis_validators);
  <b>if</b> (validator_count &lt; 10) validator_count = 10;

  // baseline_cap: baseline units per epoch times the mininmum <b>as</b> used in tx, times minimum gas per unit.

  <b>let</b> ceiling = <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>() * <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * validator_count;

  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>assert</b>(!<b>exists</b>&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm)), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(190106));
  move_to&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(vm, <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>{
    previous_epoch_proofs: 0u64,
    current_proof_price: <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_BASELINE_TX_COST">BASELINE_TX_COST</a> * 24 * 8 * 3, // number of proof submisisons in 3 initial epochs.
    current_cap: ceiling,
    current_subsidy_distributed: 0u64,
    current_proofs_verified: 0u64,
  });
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_get_proof_price"></a>

## Function `get_proof_price`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_get_proof_price">get_proof_price</a>(subsidy: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_get_proof_price">get_proof_price</a>(subsidy: u64): u64 {
  // TODO: Check this exclude proofs submitted by validator nodes, or the total reward paid will not equal the pool for fullnodes.

  <b>let</b> global_proofs = <a href="MinerState.md#0x1_MinerState_get_fullnode_proofs">MinerState::get_fullnode_proofs</a>();
  subsidy/global_proofs
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_distribute_fullnode_subsidy"></a>

## Function `distribute_fullnode_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(vm: &signer, miner: address, subsidy: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(vm: &signer, miner: address, subsidy: u64):u64 {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  // Payment is only for fullnodes, ie. not in current validator set.
  <b>if</b> (<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(miner)) <b>return</b> 0; // TODO: this check is duplicated in reconfigure
  <b>if</b> (subsidy == 0) <b>return</b> 0;

  <b>let</b> minted_coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, subsidy);
  <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    vm,
    miner,
    minted_coins,
    b"fullnode_subsidy",
    b""
  );

  subsidy
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_fullnode_reconfig"></a>

## Function `fullnode_reconfig`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_fullnode_reconfig">fullnode_reconfig</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_fullnode_reconfig">fullnode_reconfig</a>(vm: &signer) <b>acquires</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);

  // <b>update</b> values for the proof auction.
  <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_auctioneer">auctioneer</a>(vm);
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
   // save
  state.previous_epoch_proofs = state.current_proofs_verified;
  // reset counters
  state.current_subsidy_distributed = 0u64;
  state.current_proofs_verified = 0u64;
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_set_global_count"></a>

## Function `set_global_count`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_set_global_count">set_global_count</a>(vm: &signer, count: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_set_global_count">set_global_count</a>(vm: &signer, count: u64) <b>acquires</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>{
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));
  state.current_proofs_verified = count;
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_baseline_auction_units"></a>

## Function `baseline_auction_units`



<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>():u64 {
  <b>let</b> epoch_length_mins = 24 * 60;
  <b>let</b> steady_state_nodes = 1000;
  <b>let</b> target_delay_mins = 10;
  steady_state_nodes * (epoch_length_mins/target_delay_mins)
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_auctioneer"></a>

## Function `auctioneer`



<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_auctioneer">auctioneer</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_auctioneer">auctioneer</a>(vm: &signer) <b>acquires</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a> {

  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);

  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm));

  // The targeted amount of proofs <b>to</b> be submitted network-wide per epoch.
  <b>let</b> baseline_auction_units = <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>();
  // The max subsidy that can be paid out in the next epoch.
  <b>let</b> ceiling = <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm);


  // Failure case
  <b>if</b> (ceiling &lt; 1) ceiling = 1;

  state.current_proof_price = <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_calc_auction">calc_auction</a>(
    ceiling,
    baseline_auction_units,
    state.current_proofs_verified
  );
  // Set new ceiling
  state.current_cap = ceiling;
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_calc_auction"></a>

## Function `calc_auction`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_calc_auction">calc_auction</a>(ceiling: u64, baseline_auction_units: u64, current_proofs_verified: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_calc_auction">calc_auction</a>(
  ceiling: u64,
  baseline_auction_units: u64,
  current_proofs_verified: u64,
): u64 {
  // Calculate price per proof
  // Find the baseline price of a proof, which will be altered based on performance.
  // <b>let</b> baseline_proof_price = <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_divide_u64">FixedPoint32::divide_u64</a>(
  //   ceiling,
  //   <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_raw_value">FixedPoint32::create_from_raw_value</a>(baseline_auction_units)
  // );
  <b>let</b> baseline_proof_price = ceiling/baseline_auction_units;

  // print(&<a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_get_raw_value">FixedPoint32::get_raw_value</a>(<b>copy</b> baseline_proof_price));
  // Calculate the appropriate multiplier.
  <b>let</b> proofs = current_proofs_verified;
  <b>if</b> (proofs &lt; 1) proofs = 1;

  <b>let</b> multiplier = baseline_auction_units/proofs;

  // <b>let</b> multiplier = <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(
  //   baseline_auction_units,
  //   proofs
  // );
  // print(&multiplier);

  // Set the proof price using multiplier.
  // New unit price cannot be more than the ceiling
  // <b>let</b> proposed_price = <a href="../../../../../../move-stdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(
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

<a name="0x1_FullnodeSubsidy_fullnode_subsidy_ceiling"></a>

## Function `fullnode_subsidy_ceiling`



<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_fullnode_subsidy_ceiling">fullnode_subsidy_ceiling</a>(vm: &signer):u64 {
  //get TX fees from previous epoch.
  <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
  // Recover from failure case <b>where</b> there are no fees
  <b>if</b> (fees &lt; <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>()) <b>return</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_baseline_auction_units">baseline_auction_units</a>();
  fees
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_test_set_fullnode_fixtures"></a>

## Function `test_set_fullnode_fixtures`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(vm: &signer, previous_epoch_proofs: u64, current_proof_price: u64, current_cap: u64, current_subsidy_distributed: u64, current_proofs_verified: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_test_set_fullnode_fixtures">test_set_fullnode_fixtures</a>(
  vm: &signer,
  previous_epoch_proofs: u64,
  current_proof_price: u64,
  current_cap: u64,
  current_subsidy_distributed: u64,
  current_proofs_verified: u64,
) <b>acquires</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a> {
  <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(vm);
  <b>assert</b>(is_testnet(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(190108));
  <b>let</b> state = borrow_global_mut&lt;<a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy">FullnodeSubsidy</a>&gt;(@0x0);
  state.previous_epoch_proofs = previous_epoch_proofs;
  state.current_proof_price = current_proof_price;
  state.current_cap = current_cap;
  state.current_subsidy_distributed = current_subsidy_distributed;
  state.current_proofs_verified = current_proofs_verified;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
