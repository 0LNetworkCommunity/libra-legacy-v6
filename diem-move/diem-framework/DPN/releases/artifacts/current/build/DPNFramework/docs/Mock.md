
<a name="0x1_Mock"></a>

# Module `0x1::Mock`



-  [Function `mock_case_1`](#0x1_Mock_mock_case_1)
-  [Function `mock_case_4`](#0x1_Mock_mock_case_4)
-  [Function `all_good_validators`](#0x1_Mock_all_good_validators)
-  [Function `pof_default`](#0x1_Mock_pof_default)
-  [Function `mock_bids`](#0x1_Mock_mock_bids)
-  [Function `mock_network_fees`](#0x1_Mock_mock_network_fees)


<pre><code><b>use</b> <a href="Cases.md#0x1_Cases">0x1::Cases</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="ProofOfFee.md#0x1_ProofOfFee">0x1::ProofOfFee</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Mock_mock_case_1"></a>

## Function `mock_case_1`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_1">mock_case_1</a>(vm: &signer, addr: <b>address</b>, start_height: u64, end_height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_1">mock_case_1</a>(vm: &signer, addr: <b>address</b>, start_height: u64, end_height: u64){
    <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);

    // can only <b>apply</b> this <b>to</b> a validator
    // <b>assert</b>!(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr) == <b>true</b>, 777701);
    // mock mining for the <b>address</b>
    // the validator would already have 1 proof from genesis
    // <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining_vm">TowerState::test_helper_mock_mining_vm</a>(vm, addr, 10);

    // mock the consensus votes for the <b>address</b>
    <b>let</b> voters = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> voters, addr);

    <b>let</b> num_blocks = end_height - start_height;
    // Overwrite the statistics <b>to</b> mock that all have been validating.
    <b>let</b> i = 1;
    <b>let</b> above_thresh = num_blocks / 2; // just be above 5% signatures

    <b>while</b> (i &lt; above_thresh) {
        // <a href="Mock.md#0x1_Mock">Mock</a> the validator doing work for 15 blocks, and stats being updated.
        <a href="Stats.md#0x1_Stats_process_set_votes">Stats::process_set_votes</a>(vm, &voters);
        i = i + 1;
    };

    // print(&addr);
    // print(&<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height));
    // TODO: careful that the range of heights is within the test
    <b>assert</b>!(<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height) == 1, 777703);
  }
</code></pre>



</details>

<a name="0x1_Mock_mock_case_4"></a>

## Function `mock_case_4`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_4">mock_case_4</a>(vm: &signer, addr: <b>address</b>, start_height: u64, end_height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_4">mock_case_4</a>(vm: &signer, addr: <b>address</b>, start_height: u64, end_height: u64){
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);


  <b>let</b> voters = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>&lt;<b>address</b>&gt;(addr);

  // Overwrite the statistics <b>to</b> mock that all have been validating.
  <b>let</b> i = 1;
  <b>let</b> above_thresh = 1; // just be above 5% signatures
  <a href="Stats.md#0x1_Stats_test_helper_remove_votes">Stats::test_helper_remove_votes</a>(vm, addr);
  <b>while</b> (i &lt; above_thresh) {
      // <a href="Mock.md#0x1_Mock">Mock</a> the validator doing work for 15 blocks, and stats being updated.

      <a href="Stats.md#0x1_Stats_process_set_votes">Stats::process_set_votes</a>(vm, &voters);
      i = i + 1;
  };
  // print(&<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height) );
  // TODO: careful that the range of heights is within the test
  <b>assert</b>!(<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height) == 4, 777706);

}
</code></pre>



</details>

<a name="0x1_Mock_all_good_validators"></a>

## Function `all_good_validators`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_all_good_validators">all_good_validators</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_all_good_validators">all_good_validators</a>(vm: &signer) {

  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);
  <b>let</b> vals = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&vals)) {

    <b>let</b> a = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&vals, i);
    <a href="Mock.md#0x1_Mock_mock_case_1">mock_case_1</a>(vm, *a, 0, 15);
    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_Mock_pof_default"></a>

## Function `pof_default`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_pof_default">pof_default</a>(vm: &signer): (vector&lt;<b>address</b>&gt;, vector&lt;u64&gt;, vector&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_pof_default">pof_default</a>(vm: &signer): (vector&lt;<b>address</b>&gt;, vector&lt;u64&gt;, vector&lt;u64&gt;){

  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);
  <b>let</b> vals = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();

  <b>let</b> (bids, expiry) = <a href="Mock.md#0x1_Mock_mock_bids">mock_bids</a>(vm, &vals);

  <a href="DiemAccount.md#0x1_DiemAccount_slow_wallet_epoch_drip">DiemAccount::slow_wallet_epoch_drip</a>(vm, 100000); // unlock some coins for the validators

  // make all validators pay auction fee
  // the clearing price in the fibonacci sequence is is 1
  <a href="DiemAccount.md#0x1_DiemAccount_vm_multi_pay_fee">DiemAccount::vm_multi_pay_fee</a>(vm, &vals, 1, &b"proof of fee");

  (vals, bids, expiry)
}
</code></pre>



</details>

<a name="0x1_Mock_mock_bids"></a>

## Function `mock_bids`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_bids">mock_bids</a>(vm: &signer, vals: &vector&lt;<b>address</b>&gt;): (vector&lt;u64&gt;, vector&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_bids">mock_bids</a>(vm: &signer, vals: &vector&lt;<b>address</b>&gt;): (vector&lt;u64&gt;, vector&lt;u64&gt;) {
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);

  <b>let</b> bids = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> expiry = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> i = 0;
  <b>let</b> prev = 0;
  <b>let</b> fib = 1;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(vals)) {

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> expiry, 1000);
    <b>let</b> b = prev + fib;
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> bids, b);

    <b>let</b> a = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(vals, i);
    <b>let</b> sig = <a href="DiemAccount.md#0x1_DiemAccount_scary_create_signer_for_migrations">DiemAccount::scary_create_signer_for_migrations</a>(vm, *a);
    // initialize and set.
    <a href="ProofOfFee.md#0x1_ProofOfFee_set_bid">ProofOfFee::set_bid</a>(&sig, b, 1000);
    prev = fib;
    fib = b;
    i = i + 1;
  };

  (bids, expiry)

}
</code></pre>



</details>

<a name="0x1_Mock_mock_network_fees"></a>

## Function `mock_network_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_network_fees">mock_network_fees</a>(vm: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_network_fees">mock_network_fees</a>(vm: &signer, amount: u64) {
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);
  <b>let</b> c = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, amount);
  <b>let</b> c_value = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&c);
  <b>assert</b>!(c_value == amount, 777707);
  <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">TransactionFee::pay_fee</a>(c);
}
</code></pre>



</details>
