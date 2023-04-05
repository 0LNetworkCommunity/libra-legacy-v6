
<a name="0x1_MultiSigPayment"></a>

# Module `0x1::MultiSigPayment`



-  [Resource `PaymentType`](#0x1_MultiSigPayment_PaymentType)
-  [Resource `RootMultiSigRegistry`](#0x1_MultiSigPayment_RootMultiSigRegistry)
-  [Constants](#@Constants_0)
-  [Function `init_payment_multisig`](#0x1_MultiSigPayment_init_payment_multisig)
-  [Function `new_payment`](#0x1_MultiSigPayment_new_payment)
-  [Function `propose_payment`](#0x1_MultiSigPayment_propose_payment)
-  [Function `vote_payment`](#0x1_MultiSigPayment_vote_payment)
-  [Function `is_payment_multisig`](#0x1_MultiSigPayment_is_payment_multisig)
-  [Function `release_payment`](#0x1_MultiSigPayment_release_payment)
-  [Function `root_init`](#0x1_MultiSigPayment_root_init)
-  [Function `add_to_registry`](#0x1_MultiSigPayment_add_to_registry)
-  [Function `root_security_fee_billing`](#0x1_MultiSigPayment_root_security_fee_billing)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MultiSigPayment_PaymentType"></a>

## Resource `PaymentType`

This is the data structure which is stored in the Action for the multisig.


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

This fucntion initiates governance for the multisig. It is called by the sponsor address, and is only callable once.
init_gov fails gracefully if the governance is already initialized.
init_type will throw errors if the type is already initialized.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_init_payment_multisig">init_payment_multisig</a>(sponsor: &signer, init_signers: vector&lt;<b>address</b>&gt;, cfg_n_signers: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_init_payment_multisig">init_payment_multisig</a>(sponsor: &signer, init_signers: vector&lt;<b>address</b>&gt;, cfg_n_signers: u64) <b>acquires</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a> {
  <a href="MultiSig.md#0x1_MultiSig_init_gov">MultiSig::init_gov</a>(sponsor, cfg_n_signers, &init_signers);
  <a href="MultiSig.md#0x1_MultiSig_init_type">MultiSig::init_type</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sponsor, <b>true</b>);
  <a href="MultiSigPayment.md#0x1_MultiSigPayment_add_to_registry">add_to_registry</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sponsor));
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_new_payment"></a>

## Function `new_payment`

create a payment object, whcih can be send in a proposal.


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



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, multisig_addr: <b>address</b>, recipient: <b>address</b>, amount: u64, note: vector&lt;u8&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_propose_payment">propose_payment</a>(sig: &signer, multisig_addr: <b>address</b>, recipient: <b>address</b>, amount: u64, note: vector&lt;u8&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;) {
  // print(&10);
  <b>let</b> pay = <a href="MultiSigPayment.md#0x1_MultiSigPayment_new_payment">new_payment</a>(recipient, amount, *&note);
  // print(&11);
  <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">MultiSig::proposal_constructor</a>(pay, duration_epochs);
  // print(&12);
  <b>let</b> guid = <a href="MultiSig.md#0x1_MultiSig_propose_new">MultiSig::propose_new</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sig, multisig_addr, prop);
  // print(&guid);
  // print(&13);
  <a href="MultiSigPayment.md#0x1_MultiSigPayment_vote_payment">vote_payment</a>(sig, multisig_addr, &guid);
  // print(&14);
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_vote_payment"></a>

## Function `vote_payment`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_vote_payment">vote_payment</a>(sig: &signer, multisig_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_vote_payment">vote_payment</a>(sig: &signer, multisig_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>) {
  // print(&50);
  <b>let</b> (passed, cap_opt) = <a href="MultiSig.md#0x1_MultiSig_vote_with_id">MultiSig::vote_with_id</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(sig, id, multisig_address);
  // print(&passed);
  // // print(&data);
  // print(&cap_opt);

  // print(&51);

  <b>if</b> (passed && <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&cap_opt)) {
    <b>let</b> cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&cap_opt);
    // print(&5010);
    <b>let</b> data = <a href="MultiSig.md#0x1_MultiSig_extract_proposal_data">MultiSig::extract_proposal_data</a>(multisig_address, id);
    <a href="MultiSigPayment.md#0x1_MultiSigPayment_release_payment">release_payment</a>(&data, cap);
    // print(&5011);

  };


  <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">MultiSig::maybe_restore_withdraw_cap</a>(sig, multisig_address, cap_opt); // don't need this and can't drop.
  // print(&52);

}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_is_payment_multisig"></a>

## Function `is_payment_multisig`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_is_payment_multisig">is_payment_multisig</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_is_payment_multisig">is_payment_multisig</a>(addr: <b>address</b>):bool {
  <a href="MultiSig.md#0x1_MultiSig_has_action">MultiSig::has_action</a>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_PaymentType">PaymentType</a>&gt;(addr)
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
  // print(&90001);
  <a href="DiemAccount.md#0x1_DiemAccount_pay_from">DiemAccount::pay_from</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
    cap,
    p.destination,
    p.amount,
    *&p.note,
    b""
  );
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_root_init"></a>

## Function `root_init`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_init">root_init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_init">root_init</a>(vm: &signer) {
 <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
 <b>if</b> (!<b>exists</b>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a>&gt;(@VMReserved)) {
   <b>move_to</b>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a>&gt;(vm, <a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a> {
     list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
     fee: <a href="MultiSigPayment.md#0x1_MultiSigPayment_STARTING_FEE">STARTING_FEE</a>,
   });
 };
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_add_to_registry"></a>

## Function `add_to_registry`



<pre><code><b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_add_to_registry">add_to_registry</a>(addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_add_to_registry">add_to_registry</a>(addr: <b>address</b>) <b>acquires</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a> {
  <b>let</b> reg = <b>borrow_global_mut</b>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a>&gt;(@VMReserved);
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&reg.list, &addr)) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> reg.list, addr);
  };
}
</code></pre>



</details>

<a name="0x1_MultiSigPayment_root_security_fee_billing"></a>

## Function `root_security_fee_billing`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_security_fee_billing">root_security_fee_billing</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_root_security_fee_billing">root_security_fee_billing</a>(vm: &signer) <b>acquires</b> <a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> reg = <b>borrow_global</b>&lt;<a href="MultiSigPayment.md#0x1_MultiSigPayment_RootMultiSigRegistry">RootMultiSigRegistry</a>&gt;(@VMReserved);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&reg.list)) {
    // print(&7777777790001);
    <b>let</b> multi_sig_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&reg.list, i);

    <b>let</b> pct = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(reg.fee, <a href="MultiSigPayment.md#0x1_MultiSigPayment_PERCENT_SCALE">PERCENT_SCALE</a>);
    // print(&pct);
    <b>let</b> fee = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(<a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(*multi_sig_addr), pct);
    // print(&fee);
    <b>let</b> c = <a href="DiemAccount.md#0x1_DiemAccount_vm_withdraw">DiemAccount::vm_withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, *multi_sig_addr, fee);
    <a href="TransactionFee.md#0x1_TransactionFee_pay_fee_and_track">TransactionFee::pay_fee_and_track</a>(*multi_sig_addr, c);
    i = i + 1;
  };

}
</code></pre>



</details>
