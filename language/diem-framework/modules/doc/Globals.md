
<a name="0x1_Globals"></a>

# Module `0x1::Globals`


<a name="@Summary_0"></a>

## Summary

This module provides global variables and constants that have no specific owner


-  [Summary](#@Summary_0)
-  [Struct `GlobalConstants`](#0x1_Globals_GlobalConstants)
-  [Constants](#@Constants_1)
-  [Function `get_epoch_length`](#0x1_Globals_get_epoch_length)
-  [Function `get_max_validators_per_set`](#0x1_Globals_get_max_validators_per_set)
-  [Function `get_coin_scaling_factor`](#0x1_Globals_get_coin_scaling_factor)
-  [Function `get_subsidy_ceiling_gas`](#0x1_Globals_get_subsidy_ceiling_gas)
-  [Function `get_vdf_difficulty_baseline`](#0x1_Globals_get_vdf_difficulty_baseline)
-  [Function `get_vdf_security_baseline`](#0x1_Globals_get_vdf_security_baseline)
-  [Function `get_epoch_mining_thres_lower`](#0x1_Globals_get_epoch_mining_thres_lower)
-  [Function `get_epoch_mining_thres_upper`](#0x1_Globals_get_epoch_mining_thres_upper)
-  [Function `get_unlock`](#0x1_Globals_get_unlock)
-  [Function `get_min_blocks_epoch`](#0x1_Globals_get_min_blocks_epoch)
-  [Function `get_constants`](#0x1_Globals_get_constants)


<pre><code><b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
</code></pre>



<a name="0x1_Globals_GlobalConstants"></a>

## Struct `GlobalConstants`

Global constants determining validator settings & requirements
Some constants need to be changed based on environment; dev, testing, prod.
epoch_length: The length of an epoch in seconds (~1 day for prod.)
max_validators_per_set: The maximum number of validators that can participate
subsidy_ceiling_gas: TODO I don't really know what this is
vdf_difficulty: The difficulty required for VDF proofs submitting by miners
epoch_mining_thres_lower: The number of proofs that must be submitted each
epoch by a miner to remain compliant


<pre><code><b>struct</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> has drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>epoch_length: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>max_validators_per_set: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidy_ceiling_gas: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>vdf_difficulty_baseline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>vdf_security_baseline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_mining_thres_lower: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_mining_thres_upper: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_slow_wallet_unlock: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>min_blocks_per_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="0x1_Globals_COIN_SCALING_FACTOR"></a>



<pre><code><b>const</b> <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>: u64 = 1000000;
</code></pre>



<a name="0x1_Globals_get_epoch_length"></a>

## Function `get_epoch_length`

Get the epoch length


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_length">get_epoch_length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_length">get_epoch_length</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_length
}
</code></pre>



</details>

<a name="0x1_Globals_get_max_validators_per_set"></a>

## Function `get_max_validators_per_set`

Get max validator per epoch


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_validators_per_set">get_max_validators_per_set</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_validators_per_set">get_max_validators_per_set</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().max_validators_per_set
}
</code></pre>



</details>

<a name="0x1_Globals_get_coin_scaling_factor"></a>

## Function `get_coin_scaling_factor`

Get the epoch length


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">get_coin_scaling_factor</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_coin_scaling_factor">get_coin_scaling_factor</a>(): u64 {
   <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>
}
</code></pre>



</details>

<a name="0x1_Globals_get_subsidy_ceiling_gas"></a>

## Function `get_subsidy_ceiling_gas`

Get max validator per epoch


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">get_subsidy_ceiling_gas</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">get_subsidy_ceiling_gas</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().subsidy_ceiling_gas
}
</code></pre>



</details>

<a name="0x1_Globals_get_vdf_difficulty_baseline"></a>

## Function `get_vdf_difficulty_baseline`

Get the current vdf_difficulty


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">get_vdf_difficulty_baseline</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_vdf_difficulty_baseline">get_vdf_difficulty_baseline</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().vdf_difficulty_baseline
}
</code></pre>



</details>

<a name="0x1_Globals_get_vdf_security_baseline"></a>

## Function `get_vdf_security_baseline`

Get the current vdf_difficulty


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_vdf_security_baseline">get_vdf_security_baseline</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_vdf_security_baseline">get_vdf_security_baseline</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().vdf_security_baseline
}
</code></pre>



</details>

<a name="0x1_Globals_get_epoch_mining_thres_lower"></a>

## Function `get_epoch_mining_thres_lower`

Get the mining threshold


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">get_epoch_mining_thres_lower</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_lower">get_epoch_mining_thres_lower</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_mining_thres_lower
}
</code></pre>



</details>

<a name="0x1_Globals_get_epoch_mining_thres_upper"></a>

## Function `get_epoch_mining_thres_upper`

Get the mining threshold


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_upper">get_epoch_mining_thres_upper</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_mining_thres_upper">get_epoch_mining_thres_upper</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_mining_thres_upper
}
</code></pre>



</details>

<a name="0x1_Globals_get_unlock"></a>

## Function `get_unlock`

Get the mining threshold


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_unlock">get_unlock</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_unlock">get_unlock</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_slow_wallet_unlock
}
</code></pre>



</details>

<a name="0x1_Globals_get_min_blocks_epoch"></a>

## Function `get_min_blocks_epoch`

Get the mining threshold


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_min_blocks_epoch">get_min_blocks_epoch</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_min_blocks_epoch">get_min_blocks_epoch</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().min_blocks_per_epoch
}
</code></pre>



</details>

<a name="0x1_Globals_get_constants"></a>

## Function `get_constants`

Get the constants for the current network


<pre><code><b>fun</b> <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>(): <a href="Globals.md#0x1_Globals_GlobalConstants">Globals::GlobalConstants</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>(): <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
  // <b>let</b> coin_scale = 1000000; // <a href="Diem.md#0x1_Diem_scaling_factor">Diem::scaling_factor</a>&lt;GAS::T&gt;();
  <b>assert</b>(<a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a> == <a href="Diem.md#0x1_Diem_scaling_factor">Diem::scaling_factor</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(070001));

  <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
    <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60, // seconds
      max_validators_per_set: 100,
      subsidy_ceiling_gas: 296 * <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>,
      vdf_difficulty_baseline: 100,
      vdf_security_baseline: 512,
      epoch_mining_thres_lower: 2, //many tests depend on two proofs because the test harness already gives one at genesis <b>to</b> validators
      epoch_mining_thres_upper: 1000, // upper bound unlimited
      epoch_slow_wallet_unlock: 10,
      min_blocks_per_epoch: 0,
    }
  };

  <b>if</b> (<a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()) {
    <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60 * 40, // 40 mins, enough for a hard miner proof.
      max_validators_per_set: 100,
      subsidy_ceiling_gas: 8640000 * <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>,
      vdf_difficulty_baseline: 120000000,
      vdf_security_baseline: 512,
      epoch_mining_thres_lower: 1, // in testnet, staging, we don't want <b>to</b> wait too long between proofs.
      epoch_mining_thres_upper: 72, // upper bound enforced at 20 mins per proof.
      epoch_slow_wallet_unlock: 10000000,
      min_blocks_per_epoch: 1000,
    }
  } <b>else</b> {
    <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60 * 60 * 24, // approx 24 hours at 1.4 vdf_proofs/sec
      max_validators_per_set: 100, // max expected for BFT limits.
      // See <a href="DiemVMConfig.md#0x1_DiemVMConfig">DiemVMConfig</a> for gas constants:
      // Target max gas units per transaction 100000000
      // target max block time: 2 secs
      // target transaction per sec max gas: 20
      // uses "scaled representation", since there are no decimals.
      subsidy_ceiling_gas: 8640000 * <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>, // subsidy amount assumes 24 hour epoch lengths. Also needs <b>to</b> be adjusted for coin_scale the onchain representation of human readable value.
      vdf_difficulty_baseline: 120000000, // FYI approx 30 mins per proof on 2020 macbook pro 2.5 ghz quadcore
      vdf_security_baseline: 512,
      epoch_mining_thres_lower: 7, // NOTE: bootstrapping, allowance for operator error.
      epoch_mining_thres_upper: 72, // upper bound enforced at 20 mins per proof.
      epoch_slow_wallet_unlock: 1000 * <a href="Globals.md#0x1_Globals_COIN_SCALING_FACTOR">COIN_SCALING_FACTOR</a>, // approx 10 years for largest accounts in genesis.
      min_blocks_per_epoch: 10000,
    }
  }
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
