
<a name="0x1_FullnodeSubsidy"></a>

# Module `0x1::FullnodeSubsidy`



-  [Function `get_proof_price`](#0x1_FullnodeSubsidy_get_proof_price)
-  [Function `distribute_fullnode_subsidy`](#0x1_FullnodeSubsidy_distribute_fullnode_subsidy)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
</code></pre>



<a name="0x1_FullnodeSubsidy_get_proof_price"></a>

## Function `get_proof_price`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_get_proof_price">get_proof_price</a>(one_val_subsidy: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_get_proof_price">get_proof_price</a>(one_val_subsidy: u64): u64 {

  <b>let</b> global_proofs = <a href="TowerState.md#0x1_TowerState_get_fullnode_proofs_in_epoch_above_thresh">TowerState::get_fullnode_proofs_in_epoch_above_thresh</a>();

  // proof price is simple, miners divide the equivalent of one compliant
  // validator's subsidy.
  // Miners get a subsidy per proof in their tower.

  // Note <b>to</b> rascals: I know what you're thinking, but for the same effort
  // you'll put into that idea, it would be more profitable <b>to</b> just run
  // a validator node.
  <b>if</b> (global_proofs &gt; 0) {
    <b>return</b> one_val_subsidy/global_proofs
  };

  0
}
</code></pre>



</details>

<a name="0x1_FullnodeSubsidy_distribute_fullnode_subsidy"></a>

## Function `distribute_fullnode_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(vm: &signer, miner: <b>address</b>, subsidy: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="FullnodeSubsidy.md#0x1_FullnodeSubsidy_distribute_fullnode_subsidy">distribute_fullnode_subsidy</a>(
  vm: &signer,
  miner: <b>address</b>,
  subsidy: u64
):u64 {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  // Payment is only for fullnodes, ie. not validator candidates
  // TODO: this check is duplicated in reconfigure
  <b>if</b> (<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(miner)) <b>return</b> 0;
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
