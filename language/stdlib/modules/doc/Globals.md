
<a name="0x1_Globals"></a>

# Module `0x1::Globals`



-  [Struct `GlobalConstants`](#0x1_Globals_GlobalConstants)
-  [Function `get_epoch_length`](#0x1_Globals_get_epoch_length)
-  [Function `get_max_validator_per_epoch`](#0x1_Globals_get_max_validator_per_epoch)
-  [Function `get_subsidy_ceiling_gas`](#0x1_Globals_get_subsidy_ceiling_gas)
-  [Function `get_max_node_density`](#0x1_Globals_get_max_node_density)
-  [Function `get_burn_accounts`](#0x1_Globals_get_burn_accounts)
-  [Function `get_difficulty`](#0x1_Globals_get_difficulty)
-  [Function `get_mining_threshold`](#0x1_Globals_get_mining_threshold)
-  [Function `get_constants`](#0x1_Globals_get_constants)


<pre><code><b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="Testnet.md#0x1_StagingNet">0x1::StagingNet</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Globals_GlobalConstants"></a>

## Struct `GlobalConstants`



<pre><code><b>struct</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a>
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
<code>max_validator_per_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidy_ceiling_gas: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>min_node_density: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>max_node_density: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_accounts: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>difficulty: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_mining_threshold: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Globals_get_epoch_length"></a>

## Function `get_epoch_length`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_length">get_epoch_length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_epoch_length">get_epoch_length</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_length
}
</code></pre>



</details>

<a name="0x1_Globals_get_max_validator_per_epoch"></a>

## Function `get_max_validator_per_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_validator_per_epoch">get_max_validator_per_epoch</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_validator_per_epoch">get_max_validator_per_epoch</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().max_validator_per_epoch
}
</code></pre>



</details>

<a name="0x1_Globals_get_subsidy_ceiling_gas"></a>

## Function `get_subsidy_ceiling_gas`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">get_subsidy_ceiling_gas</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_subsidy_ceiling_gas">get_subsidy_ceiling_gas</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().subsidy_ceiling_gas
}
</code></pre>



</details>

<a name="0x1_Globals_get_max_node_density"></a>

## Function `get_max_node_density`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_node_density">get_max_node_density</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_max_node_density">get_max_node_density</a>(): u64 {
   <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().max_node_density
}
</code></pre>



</details>

<a name="0x1_Globals_get_burn_accounts"></a>

## Function `get_burn_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_burn_accounts">get_burn_accounts</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_burn_accounts">get_burn_accounts</a>(): vector&lt;address&gt; {
   *&<a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().burn_accounts
}
</code></pre>



</details>

<a name="0x1_Globals_get_difficulty"></a>

## Function `get_difficulty`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_difficulty">get_difficulty</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_difficulty">get_difficulty</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().difficulty
}
</code></pre>



</details>

<a name="0x1_Globals_get_mining_threshold"></a>

## Function `get_mining_threshold`



<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_mining_threshold">get_mining_threshold</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Globals.md#0x1_Globals_get_mining_threshold">get_mining_threshold</a>(): u64 {
  <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>().epoch_mining_threshold
}
</code></pre>



</details>

<a name="0x1_Globals_get_constants"></a>

## Function `get_constants`



<pre><code><b>fun</b> <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>(): <a href="Globals.md#0x1_Globals_GlobalConstants">Globals::GlobalConstants</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Globals.md#0x1_Globals_get_constants">get_constants</a>(): <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {

  <b>let</b> coin_scale = 1000000; //<a href="Diem.md#0x1_Diem_scaling_factor">Diem::scaling_factor</a>&lt;GAS::T&gt;();
  <b>assert</b>(coin_scale == <a href="Diem.md#0x1_Diem_scaling_factor">Diem::scaling_factor</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;(), 07010110001);

  <b>if</b> (<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>()) {
    <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60, // seconds
      max_validator_per_epoch: 10,
      subsidy_ceiling_gas: 296 * coin_scale,
      min_node_density: 4,
      max_node_density: 300,
      burn_accounts: <a href="Vector.md#0x1_Vector_singleton">Vector::singleton</a>(0xDEADDEAD),
      difficulty: 100,
      epoch_mining_threshold: 1,
    }

  } <b>else</b> {
    <b>if</b> (<a href="Testnet.md#0x1_StagingNet_is_staging_net">StagingNet::is_staging_net</a>()){
    <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60 * 20, // 20 mins, enough for a hard miner proof.
      max_validator_per_epoch: 300,
      subsidy_ceiling_gas: 8640000 * coin_scale,
      min_node_density: 4,
      max_node_density: 300,
      burn_accounts: <a href="Vector.md#0x1_Vector_singleton">Vector::singleton</a>(0xDEADDEAD),
      difficulty: 5000000,
      epoch_mining_threshold: 1,
    }
  } <b>else</b> {
      <b>return</b> <a href="Globals.md#0x1_Globals_GlobalConstants">GlobalConstants</a> {
      epoch_length: 60 * 60 * 24, // approx 24 hours at 1.4 blocks/sec
      max_validator_per_epoch: 300, // max expected for BFT limits.
      // See <a href="DiemVMConfig.md#0x1_DiemVMConfig">DiemVMConfig</a> for gas constants:
      // Target max gas units per transaction 100000000
      // target max block time: 2 secs
      // target transaction per sec max gas: 20
      // uses "scaled representation", since there are no decimals.
      subsidy_ceiling_gas: 8640000 * coin_scale, // subsidy amount assumes 24 hour epoch lengths. Also needs <b>to</b> be adjusted for coin_scale the onchain representation of human readable value.
      min_node_density: 4,
      max_node_density: 300,
      burn_accounts: <a href="Vector.md#0x1_Vector_singleton">Vector::singleton</a>(0xDEADDEAD),
      difficulty: 5000000, //10 mins on macbook pro 2.5 ghz quadcore
      epoch_mining_threshold: 20,
      }
    }
  }
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
