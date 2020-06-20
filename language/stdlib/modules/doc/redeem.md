
<a name="0x0_Redeem"></a>

# Module `0x0::Redeem`

### Table of Contents

-  [Struct `VdfProofBlob`](#0x0_Redeem_VdfProofBlob)
-  [Struct `T`](#0x0_Redeem_T)
-  [Struct `InProcess`](#0x0_Redeem_InProcess)
-  [Function `create_proof_blob`](#0x0_Redeem_create_proof_blob)
-  [Function `begin_redeem`](#0x0_Redeem_begin_redeem)
-  [Function `end_redeem`](#0x0_Redeem_end_redeem)
-  [Function `initialize`](#0x0_Redeem_initialize)
-  [Function `default_redeem_address`](#0x0_Redeem_default_redeem_address)
-  [Function `has_in_process`](#0x0_Redeem_has_in_process)
-  [Function `init_in_process`](#0x0_Redeem_init_in_process)
-  [Function `has`](#0x0_Redeem_has)



<a name="0x0_Redeem_VdfProofBlob"></a>

## Struct `VdfProofBlob`



<pre><code><b>struct</b> <a href="#0x0_Redeem_VdfProofBlob">VdfProofBlob</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>challenge: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>difficulty: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>solution: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Redeem_T"></a>

## Struct `T`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Redeem_T">T</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>history: vector&lt;vector&lt;u8&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Redeem_InProcess"></a>

## Struct `InProcess`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Redeem_InProcess">InProcess</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>proofs: vector&lt;<a href="#0x0_Redeem_VdfProofBlob">Redeem::VdfProofBlob</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Redeem_create_proof_blob"></a>

## Function `create_proof_blob`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_create_proof_blob">create_proof_blob</a>(challenge: vector&lt;u8&gt;, difficulty: u64, solution: vector&lt;u8&gt;): <a href="#0x0_Redeem_VdfProofBlob">Redeem::VdfProofBlob</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_create_proof_blob">create_proof_blob</a>(challenge: vector&lt;u8&gt;, difficulty: u64, solution: vector&lt;u8&gt;,) : <a href="#0x0_Redeem_VdfProofBlob">VdfProofBlob</a> {
   <a href="#0x0_Redeem_VdfProofBlob">VdfProofBlob</a> {challenge,  difficulty, solution }
}
</code></pre>



</details>

<a name="0x0_Redeem_begin_redeem"></a>

## Function `begin_redeem`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_begin_redeem">begin_redeem</a>(vdf_proof_blob: <a href="#0x0_Redeem_VdfProofBlob">Redeem::VdfProofBlob</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_begin_redeem">begin_redeem</a>(vdf_proof_blob: <a href="#0x0_Redeem_VdfProofBlob">VdfProofBlob</a>) <b>acquires</b> <a href="#0x0_Redeem_T">T</a>, <a href="#0x0_Redeem_InProcess">InProcess</a>{
  // Initialize
  <b>if</b> (!<a href="#0x0_Redeem_has_in_process">has_in_process</a>()) {
       <a href="#0x0_Redeem_init_in_process">init_in_process</a>();
  };

  // Checks that the blob was not previously redeemed, <b>if</b> previously redeemed its a no-op, with error message.
  <b>let</b> user_redemption_state = borrow_global_mut&lt;<a href="#0x0_Redeem_T">T</a>&gt;(<a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>());
  <b>let</b> blob_redeemed = <a href="Vector.md#0x0_Vector_contains">Vector::contains</a>(&user_redemption_state.history, &vdf_proof_blob.solution);
  Transaction::assert(blob_redeemed == <b>false</b>, 10000);

  // QUESTION: Should we save a UserProof that is <b>false</b> so that we know it's been attempted multiple times?
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> user_redemption_state.history, *&vdf_proof_blob.solution);

  // Checks that the user did run the delay (<a href="vdf.md#0x0_VDF">VDF</a>). Calling Verify() <b>to</b> check the validity of Blob
  <b>let</b> valid = <a href="vdf.md#0x0_VDF_verify">VDF::verify</a>(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
  Transaction::assert(valid == <b>true</b>, 10001);

  // If successfully verified, store the pubkey, proof_blob, mint_transaction <b>to</b> the <a href="#0x0_Redeem">Redeem</a> k-v marked <b>as</b> a "redemption in process"
  <b>let</b> in_process = borrow_global_mut&lt;<a href="#0x0_Redeem_InProcess">InProcess</a>&gt;(Transaction::sender());
  <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> in_process.proofs, vdf_proof_blob);

}
</code></pre>



</details>

<a name="0x0_Redeem_end_redeem"></a>

## Function `end_redeem`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_end_redeem">end_redeem</a>(redeemed_addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_end_redeem">end_redeem</a>(redeemed_addr: address) <b>acquires</b> <a href="#0x0_Redeem_InProcess">InProcess</a> {
  // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
  <b>let</b> sender = Transaction::sender();
  Transaction::assert(sender == <a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>(), 10003);

  // Account do not have proof <b>to</b> verify.
  <b>let</b> in_process_redemption = borrow_global_mut&lt;<a href="#0x0_Redeem_InProcess">InProcess</a>&gt;(redeemed_addr);
  <b>let</b> counts = <a href="Vector.md#0x0_Vector_length">Vector::length</a>(&in_process_redemption.proofs);
  Transaction::assert(counts &gt; 0, 10002);

  // Calls <a href="stats.md#0x0_Stats">Stats</a> <b>module</b> <b>to</b> check that pubkey was engaged in consensus, that the n% liveness above.
  // <a href="stats.md#0x0_Stats">Stats</a>(pubkey, block)

  // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
  // TBD
  <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&counts);

  // If those checks are successful <a href="#0x0_Redeem">Redeem</a> calls <a href="subsidy.md#0x0_Subsidy">Subsidy</a> <b>module</b> (which subsequently calls the  Gas_Coin.Mint function).
  // <a href="subsidy.md#0x0_Subsidy">Subsidy</a>(pubkey, quantity)

  // Clean In Process
  in_process_redemption.proofs = <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>();
}
</code></pre>



</details>

<a name="0x0_Redeem_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_initialize">initialize</a>(config_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Redeem_initialize">initialize</a>(config_account: &signer) {
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&Transaction::sender());
    <a href="Debug.md#0x0_Debug_print">Debug::print</a>(&<a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>());
    Transaction::assert( Transaction::sender() == <a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>(), 10003);
    move_to&lt;<a href="#0x0_Redeem_T">T</a>&gt;( config_account ,<a href="#0x0_Redeem_T">T</a>{ history: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>()});
}
</code></pre>



</details>

<a name="0x0_Redeem_default_redeem_address"></a>

## Function `default_redeem_address`



<pre><code><b>fun</b> <a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>(): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Redeem_default_redeem_address">default_redeem_address</a>(): address {
    0x0000000000000000000000000a550c18
}
</code></pre>



</details>

<a name="0x0_Redeem_has_in_process"></a>

## Function `has_in_process`



<pre><code><b>fun</b> <a href="#0x0_Redeem_has_in_process">has_in_process</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Redeem_has_in_process">has_in_process</a>(): bool {
   ::exists&lt;<a href="#0x0_Redeem_InProcess">InProcess</a>&gt;(Transaction::sender())
}
</code></pre>



</details>

<a name="0x0_Redeem_init_in_process"></a>

## Function `init_in_process`



<pre><code><b>fun</b> <a href="#0x0_Redeem_init_in_process">init_in_process</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Redeem_init_in_process">init_in_process</a>(){
    move_to_sender&lt;<a href="#0x0_Redeem_InProcess">InProcess</a>&gt;(<a href="#0x0_Redeem_InProcess">InProcess</a>{ proofs: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>()})
}
</code></pre>



</details>

<a name="0x0_Redeem_has"></a>

## Function `has`



<pre><code><b>fun</b> <a href="#0x0_Redeem_has">has</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Redeem_has">has</a>(addr: address): bool {
   ::exists&lt;<a href="#0x0_Redeem_T">T</a>&gt;(addr)
}
</code></pre>



</details>
