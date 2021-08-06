
<a name="0x1_MinerStateScripts"></a>

# Module `0x1::MinerStateScripts`



-  [Function `minerstate_commit_by_operator`](#0x1_MinerStateScripts_minerstate_commit_by_operator)
-  [Function `minerstate_commit`](#0x1_MinerStateScripts_minerstate_commit)
-  [Function `minerstate_helper`](#0x1_MinerStateScripts_minerstate_helper)


<pre><code><b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="MinerState.md#0x1_MinerState">0x1::MinerState</a>;
<b>use</b> <a href="TestFixtures.md#0x1_TestFixtures">0x1::TestFixtures</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
</code></pre>



<a name="0x1_MinerStateScripts_minerstate_commit_by_operator"></a>

## Function `minerstate_commit_by_operator`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_commit_by_operator">minerstate_commit_by_operator</a>(operator_sig: signer, owner_address: address, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_commit_by_operator">minerstate_commit_by_operator</a>(
    operator_sig: signer, owner_address: address,
    challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;
) {
    <b>let</b> proof = <a href="MinerState.md#0x1_MinerState_create_proof_blob">MinerState::create_proof_blob</a>(
        challenge,
        <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>(),
        solution
    );

    <a href="MinerState.md#0x1_MinerState_commit_state_by_operator">MinerState::commit_state_by_operator</a>(&operator_sig, owner_address, proof);
}
</code></pre>



</details>

<a name="0x1_MinerStateScripts_minerstate_commit"></a>

## Function `minerstate_commit`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_commit">minerstate_commit</a>(sender: signer, challenge: vector&lt;u8&gt;, solution: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_commit">minerstate_commit</a>(
    sender: signer, challenge: vector&lt;u8&gt;,
    solution: vector&lt;u8&gt;
) {
    <b>let</b> proof = <a href="MinerState.md#0x1_MinerState_create_proof_blob">MinerState::create_proof_blob</a>(
        challenge,
        <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>(),
        solution
    );

    <a href="MinerState.md#0x1_MinerState_commit_state">MinerState::commit_state</a>(&sender, proof);
}
</code></pre>



</details>

<a name="0x1_MinerStateScripts_minerstate_helper"></a>

## Function `minerstate_helper`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_helper">minerstate_helper</a>(sender: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_miner_state.md#0x1_MinerStateScripts_minerstate_helper">minerstate_helper</a>(sender: signer) {
    <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 01);

    <a href="MinerState.md#0x1_MinerState_test_helper">MinerState::test_helper</a>(
        &sender,
        <a href="Globals.md#0x1_Globals_get_difficulty">Globals::get_difficulty</a>(),
        <a href="TestFixtures.md#0x1_TestFixtures_alice_0_easy_chal">TestFixtures::alice_0_easy_chal</a>(),
        <a href="TestFixtures.md#0x1_TestFixtures_alice_0_easy_sol">TestFixtures::alice_0_easy_sol</a>()
    );
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
