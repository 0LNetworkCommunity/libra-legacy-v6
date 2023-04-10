
<a name="0x1_Subsidy"></a>

# Module `0x1::Subsidy`



-  [Function `genesis`](#0x1_Subsidy_genesis)
-  [Function `process_fees`](#0x1_Subsidy_process_fees)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="ProofOfFee.md#0x1_ProofOfFee">0x1::ProofOfFee</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



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
  <b>let</b> subsidy = 12500000;
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
  // subsidy_units: u64,
  outgoing_set: &vector&lt;<b>address</b>&gt;,
) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  // Get the split of payments from <a href="Stats.md#0x1_Stats">Stats</a>.
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(outgoing_set);

  // reward per validator
  // print(&70001);
  <b>let</b> (reward_per, _, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">ProofOfFee::get_consensus_reward</a>();

  // // equal subsidy for all active validators
  // <b>let</b> subsidy_granted;
  // TODO: This calculation is duplicated <b>with</b> get_subsidy
  <b>if</b> (reward_per &lt; 1 ) <b>return</b>; // arithmetic safety check

  // We draw from the network fee account.
  // It should already be funded <b>with</b>:
  // 1. Tx fees
  // 2. Proof of Fee, entry fees at clearning price
  // 3. Infra Escrow drawdown.
  // <b>as</b> such there should be sufficient coins <b>to</b> pay (we should not get an overdrawn error), and we check for that above.

  <b>let</b> nominal_cost_to_network = reward_per * len;
  // print(&70002);
  <b>let</b> balance_in_network_account = <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">TransactionFee::get_fees_collected</a>();
  // print(&balance_in_network_account);

  <b>if</b> (
    // the sum of consensus rewards should not be more than the
    // fees collected
    (nominal_cost_to_network &gt; balance_in_network_account) ||
    // do nothing <b>if</b> fees are 0 (expected only in test mode)
    (balance_in_network_account &lt; 1)
  ) <b>return</b>;

  // print(&70003);
  <b>let</b> check_sum = 0;
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    // V6: there is no more minting in V6. Only drawing the
    // baseline reward from Network Fees account.

    // print(&700031);

    <b>let</b> coin = <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">TransactionFee::get_transaction_fees_coins_amount</a>(vm, reward_per);

    // safety
    <b>if</b> (<a href="Diem.md#0x1_Diem_value">Diem::value</a>(&coin) &lt; 1) {
      <a href="Diem.md#0x1_Diem_destroy_zero">Diem::destroy_zero</a>(coin);
      <b>return</b>
    };
    // print(&700032);

    check_sum = check_sum + <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&coin);
    // print(&700033);
    <b>let</b> val = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(outgoing_set, i);
    // print(val);
    <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt; (
      @VMReserved,
      *val,
      coin,
      b"consensus_reward",
      b"",
      <b>false</b>,
    );
    // print(&700034);
    i = i + 1;
  };

  // V6: validators get their consensus_reward from the network fees account (transaction fees account). Any remainder at end of epoch is burnt (by <a href="Epoch.md#0x1_Epoch">Epoch</a> Boundary calling <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>)
}
</code></pre>



</details>
