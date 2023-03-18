
<a name="0x1_MultiSigPayment"></a>

# Module `0x1::MultiSigPayment`



-  [Resource `RootMultiSigRegistry`](#0x1_MultiSigPayment_RootMultiSigRegistry)
-  [Resource `PaymentType`](#0x1_MultiSigPayment_PaymentType)
-  [Constants](#@Constants_0)
-  [Function `new_payment`](#0x1_MultiSigPayment_new_payment)
-  [Function `propose_payment`](#0x1_MultiSigPayment_propose_payment)


<pre><code><b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
</code></pre>



<a name="0x1_MultiSigPayment_RootMultiSigRegistry"></a>

## Resource `RootMultiSigRegistry`



<pre><code><b>struct</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>fee: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSigPayment_PaymentType"></a>

## Resource `PaymentType`

A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
A multisig can be used to get agreement on different types of transactions, such as:


<pre><code><b>struct</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>destination: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>note: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_MultiSigPayment_PERCENT_SCALE"></a>



<pre><code><b>const</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_PERCENT_SCALE">PERCENT_SCALE</a>: u64 = 1000000;
</code></pre>



<a name="0x1_MultiSigPayment_STARTING_FEE"></a>

Genesis starting fee for multisig service


<pre><code><b>const</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_STARTING_FEE">STARTING_FEE</a>: u64 = 27;
</code></pre>



<a name="0x1_MultiSigPayment_new_payment"></a>

## Function `new_payment`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_new_payment">new_payment</a>(destination: <b>address</b>, amount: u64, note: vector&lt;u8&gt;): <a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">MultiSigPayment::PaymentType</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_new_payment">new_payment</a>(destination: <b>address</b>, amount: u64, note: vector&lt;u8&gt;): <a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a> {
  <a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a> {
    destination,
    amount,
    note,
  }
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_propose_payment"></a>

## Function `propose_payment`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, destination: <b>address</b>, amount: u64, note: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, destination: <b>address</b>, amount: u64, note: vector&lt;u8&gt;) {
  <b>let</b> p = <a href="MultiSigPayment.md#0x1_MultiSigPayment_new_payment">new_payment</a>(destination, amount, note);
  <a href="MultiSig.md#0x1_MultiSig_propose">MultiSig::propose</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sig, destination, p);
}
</code></pre>



</details>
