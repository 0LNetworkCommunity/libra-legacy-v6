
<a name="0x1_Mock"></a>

# Module `0x1::Mock`



-  [Function `mock_case_1`](#0x1_Mock_mock_case_1)
-  [Function `mock_case_2`](#0x1_Mock_mock_case_2)


<pre><code><b>use</b> <a href="Cases.md#0x1_Cases">0x1::Cases</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="Stats.md#0x1_Stats">0x1::Stats</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Mock_mock_case_1"></a>

## Function `mock_case_1`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_1">mock_case_1</a>(vm: &signer, addr: address, start_height: u64, end_height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_1">mock_case_1</a>(vm: &signer, addr: address, start_height: u64, end_height: u64){
  print(&addr);
    // can only <b>apply</b> this <b>to</b> a validator
    // <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr) == <b>true</b>, 777701);
    // mock mining for the address
    // the validator would already have 1 proof from genesis
    <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining_vm">TowerState::test_helper_mock_mining_vm</a>(vm, addr, 10);

    // mock the consensus votes for the address
    <b>let</b> voters = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> voters, addr);

    <b>let</b> num_blocks = end_height - start_height;
    // Overwrite the statistics <b>to</b> mock that all have been validating.
    <b>let</b> i = 1;
    <b>let</b> above_thresh = num_blocks / 2; // just be above 5% signatures

    <b>while</b> (i &lt; above_thresh) {
        // <a href="Mock.md#0x1_Mock">Mock</a> the validator doing work for 15 blocks, and stats being updated.
        <a href="Stats.md#0x1_Stats_process_set_votes">Stats::process_set_votes</a>(vm, &voters);
        i = i + 1;
    };

    // TODO: careful that the range of heights is within the test
    <b>assert</b>(<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height) == 1, 777703);

  }
</code></pre>



</details>

<a name="0x1_Mock_mock_case_2"></a>

## Function `mock_case_2`



<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_2">mock_case_2</a>(vm: &signer, addr: address, start_height: u64, end_height: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Mock.md#0x1_Mock_mock_case_2">mock_case_2</a>(vm: &signer, addr: address, start_height: u64, end_height: u64){
  // can only <b>apply</b> this <b>to</b> a validator
  // <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr) == <b>true</b>, 777704);
  // mock mining for the address
  // insufficient number of proofs
  <a href="TowerState.md#0x1_TowerState_test_helper_mock_mining_vm">TowerState::test_helper_mock_mining_vm</a>(vm, addr, 0);
  // <b>assert</b>(<a href="TowerState.md#0x1_TowerState_get_count_in_epoch">TowerState::get_count_in_epoch</a>(addr) == 0, 777705);

  // mock the consensus votes for the address
  <b>let</b> voters = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>&lt;address&gt;(addr);

  <b>let</b> num_blocks = end_height - start_height;
  // Overwrite the statistics <b>to</b> mock that all have been validating.
  <b>let</b> i = 1;
  <b>let</b> above_thresh = num_blocks / 2; // just be above 5% signatures

  <b>while</b> (i &lt; above_thresh) {
      // <a href="Mock.md#0x1_Mock">Mock</a> the validator doing work for 15 blocks, and stats being updated.
      <a href="Stats.md#0x1_Stats_process_set_votes">Stats::process_set_votes</a>(vm, &voters);
      i = i + 1;
  };

  // TODO: careful that the range of heights is within the test
  <b>assert</b>(<a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, addr, start_height, end_height) == 2, 777706);

}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
