
<a name="minerstate_helper"></a>

# Script `minerstate_helper`





<pre><code><b>use</b> <a href="../../modules/doc/Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../modules/doc/MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="../../modules/doc/TestFixtures.md#0x1_TestFixtures">0x1::TestFixtures</a>;
<b>use</b> <a href="../../modules/doc/Testnet.md#0x1_Testnet">0x1::Testnet</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_miner_state_helper.md#minerstate_helper">minerstate_helper</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_miner_state_helper.md#minerstate_helper">minerstate_helper</a>(sender: &signer) {
    <b>assert</b>(<a href="../../modules/doc/Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 01);

    <a href="../../modules/doc/MinerState.md#0x1_MinerState_test_helper">MinerState::test_helper</a>(
      sender,
      <a href="../../modules/doc/Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>(),
      <a href="../../modules/doc/TestFixtures.md#0x1_TestFixtures_alice_0_easy_chal">TestFixtures::alice_0_easy_chal</a>(),
      <a href="../../modules/doc/TestFixtures.md#0x1_TestFixtures_alice_0_easy_sol">TestFixtures::alice_0_easy_sol</a>()
    );

}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
