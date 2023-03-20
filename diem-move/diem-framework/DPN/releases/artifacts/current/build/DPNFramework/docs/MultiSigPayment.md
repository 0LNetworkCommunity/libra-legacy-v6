
<a name="0x1_MultiSigPayment"></a>

# Module `0x1::MultiSigPayment`



-  [Resource `RootMultiSigRegistry`](#0x1_MultiSigPayment_RootMultiSigRegistry)
-  [Resource `PaymentType`](#0x1_MultiSigPayment_PaymentType)
-  [Constants](#@Constants_0)
-  [Function `init_payment_multisig`](#0x1_MultiSigPayment_init_payment_multisig)
-  [Function `new_payment`](#0x1_MultiSigPayment_new_payment)
-  [Function `propose_payment`](#0x1_MultiSigPayment_propose_payment)
-  [Function `release_payment`](#0x1_MultiSigPayment_release_payment)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
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


<pre><code><b>struct</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a> <b>has</b> <b>copy</b>, drop, store, key
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



<a name="0x1_MultiSigPayment_init_payment_multisig"></a>

## Function `init_payment_multisig`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_init_payment_multisig">init_payment_multisig</a>(sponsor: &signer, init_signers: vector&lt;<b>address</b>&gt;, cfg_n_signers: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_init_payment_multisig">init_payment_multisig</a>(sponsor: &signer, init_signers: vector&lt;<b>address</b>&gt;, cfg_n_signers: u64) {
  <a href="MultiSig.md#0x1_MultiSig_init_type">MultiSig::init_type</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sponsor, init_signers, cfg_n_signers, <b>true</b>);
}
</code></pre>



</details>

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



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, multisig_addr: <b>address</b>, recipient: <b>address</b>, amount: u64, note: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, multisig_addr: <b>address</b>, recipient: <b>address</b>, amount: u64, note: vector&lt;u8&gt;) {
  <b>let</b> p = <a href="MultiSigPayment.md#0x1_MultiSigPayment_new_payment">new_payment</a>(recipient, amount, *&note);

  <b>let</b> (approved, cap) = <a href="MultiSig.md#0x1_MultiSig_propose">MultiSig::propose</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sig, multisig_addr, <b>copy</b> p);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&cap)) {
    <b>let</b> c = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> cap);

    <b>if</b> (approved) {
      <a href="MultiSigPayment.md#0x1_MultiSigPayment_release_payment">release_payment</a>(&p, &c);
    };

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> cap, c);
  };

  <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">MultiSig::maybe_restore_withdraw_cap</a>(multisig_addr, cap)
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_release_payment"></a>

## Function `release_payment`



<pre><code><b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_release_payment">release_payment</a>(p: &<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">MultiSigPayment::PaymentType</a>, cap: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_release_payment">release_payment</a>(p: &<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>, cap: &WithdrawCapability) {
  print(&90001);
  <a href="DiemAccount.md#0x1_DiemAccount_pay_from">DiemAccount::pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    cap,
    p.destination,
    p.amount,
    *&p.note,
    b""
  );
  // MultiSig::restore_withdraw_cap(multisig_addr, cap)
}
</code></pre>



</details>
