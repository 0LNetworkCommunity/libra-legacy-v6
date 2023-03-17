
<a name="0x1_MultiSig"></a>

# Module `0x1::MultiSig`



-  [Resource `RootMultiSigRegistry`](#0x1_MultiSig_RootMultiSigRegistry)
-  [Resource `MultiSig`](#0x1_MultiSig_MultiSig)
-  [Resource `PropPayment`](#0x1_MultiSig_PropPayment)
-  [Resource `PropGovSigners`](#0x1_MultiSig_PropGovSigners)
-  [Resource `PropGeneric`](#0x1_MultiSig_PropGeneric)
-  [Constants](#@Constants_0)
-  [Function `root_init`](#0x1_MultiSig_root_init)
-  [Function `init_type`](#0x1_MultiSig_init_type)
-  [Function `finalize_and_brick`](#0x1_MultiSig_finalize_and_brick)
-  [Function `is_finalized`](#0x1_MultiSig_is_finalized)
-  [Function `is_authority`](#0x1_MultiSig_is_authority)
-  [Function `propose_authorities`](#0x1_MultiSig_propose_authorities)
-  [Function `vote`](#0x1_MultiSig_vote)
-  [Function `tally`](#0x1_MultiSig_tally)
-  [Function `get_gov_prop_by_param`](#0x1_MultiSig_get_gov_prop_by_param)
-  [Function `find_gov_idx_by_param`](#0x1_MultiSig_find_gov_idx_by_param)
-  [Function `maybe_update_authorities`](#0x1_MultiSig_maybe_update_authorities)
-  [Function `get_authorities`](#0x1_MultiSig_get_authorities)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="VectorHelper.md#0x1_VectorHelper">0x1::VectorHelper</a>;
</code></pre>



<a name="0x1_MultiSig_RootMultiSigRegistry"></a>

## Resource `RootMultiSigRegistry`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_RootMultiSigRegistry">RootMultiSigRegistry</a> <b>has</b> key
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

<a name="0x1_MultiSig_MultiSig"></a>

## Resource `MultiSig`

A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
A multisig can be used to get agreement on different types of transactions, such as:


<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;Prop&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cfg_expire_epochs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_default_n_sigs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>signers: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>pending: vector&lt;Prop&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: vector&lt;Prop&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>rejected: vector&lt;Prop&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>gov_pending: vector&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>gov_approved: vector&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>gov_rejected: vector&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSig_PropPayment"></a>

## Resource `PropPayment`

This is the data structure which tracks the authorities and the votes for a given transaction.


<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_PropPayment">PropPayment</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: u64</code>
</dt>
<dd>

</dd>
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
<dt>
<code>votes: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>expiration_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSig_PropGovSigners"></a>

## Resource `PropGovSigners`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>add_remove: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>addresses: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>votes: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>expiration_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_n_sigs: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSig_PropGeneric"></a>

## Resource `PropGeneric`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_PropGeneric">PropGeneric</a> <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>n: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>prop_type: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>expiration_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE"></a>



<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>: u64 = 14;
</code></pre>



<a name="0x1_MultiSig_ENOT_AUTHORIZED"></a>

Signer not authorized to approve a transaction.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>: u64 = 440002;
</code></pre>



<a name="0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK"></a>

The multisig setup  is not finalized, the sponsor needs to brick their authkey. The account setup sponsor needs to be verifiably locked out before operations can begin.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK">ENOT_FINALIZED_NOT_BRICK</a>: u64 = 440005;
</code></pre>



<a name="0x1_MultiSig_ENO_SIGNERS"></a>

Not enough signers configured


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ENO_SIGNERS">ENO_SIGNERS</a>: u64 = 440004;
</code></pre>



<a name="0x1_MultiSig_EPENDING_EMPTY"></a>

There are no pending transactions to search


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EPENDING_EMPTY">EPENDING_EMPTY</a>: u64 = 440003;
</code></pre>



<a name="0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY"></a>

The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY">ESIGNER_CANT_BE_AUTHORITY</a>: u64 = 440001;
</code></pre>



<a name="0x1_MultiSig_PERCENT_SCALE"></a>



<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_PERCENT_SCALE">PERCENT_SCALE</a>: u64 = 1000000;
</code></pre>



<a name="0x1_MultiSig_STARTING_FEE"></a>

Genesis starting fee for multisig service


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_STARTING_FEE">STARTING_FEE</a>: u64 = 27;
</code></pre>



<a name="0x1_MultiSig_root_init"></a>

## Function `root_init`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_root_init">root_init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_root_init">root_init</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>move_to</b>(vm, <a href="MultiSig.md#0x1_MultiSig_RootMultiSigRegistry">RootMultiSigRegistry</a> {
    list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    fee: <a href="MultiSig.md#0x1_MultiSig_STARTING_FEE">STARTING_FEE</a>,
  });
}
</code></pre>



</details>

<a name="0x1_MultiSig_init_type"></a>

## Function `init_type`

An initial "sponsor" who is the signer of the initialization account calls this function.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;PropType: store, key&gt;(sig: &signer, m_seed_authorities: vector&lt;<b>address</b>&gt;, cfg_default_n_sigs: u64, withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;PropType: key + store&gt;(
  sig: &signer,
  m_seed_authorities: vector&lt;<b>address</b>&gt;,
  cfg_default_n_sigs: u64,
  withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;,
// ) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_RootMultiSigRegistry">RootMultiSigRegistry</a>  {
 ) {
  <b>assert</b>!(cfg_default_n_sigs &gt; 0, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENO_SIGNERS">ENO_SIGNERS</a>));
  // make sure the signer's <b>address</b> is not in the list of authorities.
  // This account's signer will now be useless.
  print(&10001);
  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&m_seed_authorities, &sender_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY">ESIGNER_CANT_BE_AUTHORITY</a>));
  print(&10002);
  <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt; {
    cfg_expire_epochs: <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>,
    cfg_default_n_sigs,
    withdraw_capability,
    signers: <b>copy</b> m_seed_authorities,
    // m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&m_seed_authorities),
    pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    counter: 0,
    gov_pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    gov_approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    gov_rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  });

  // maybe_init_gov(sig, <b>copy</b> m_seed_authorities, cfg_default_n_sigs);

  // print(&10003);
  // <a href="DiemAccount.md#0x1_DiemAccount_brick_this">DiemAccount::brick_this</a>(sig, b"yes I know what I'm doing");
  // print(&10004);

  // // add the sender <b>to</b> the root registry for billing.
  // upsert_root_registry(sender_addr);
}
</code></pre>



</details>

<a name="0x1_MultiSig_finalize_and_brick"></a>

## Function `finalize_and_brick`

Once the "sponsor" which is setting up the multisig has created all the multisig types (payment, generic, gov), they need to brick this account so that the signer for this address is rendered useless, and it is a true multisig.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_finalize_and_brick">finalize_and_brick</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_finalize_and_brick">finalize_and_brick</a>(sig: &signer) {
  <a href="DiemAccount.md#0x1_DiemAccount_brick_this">DiemAccount::brick_this</a>(sig, b"yes I know what I'm doing");
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK">ENOT_FINALIZED_NOT_BRICK</a>));
}
</code></pre>



</details>

<a name="0x1_MultiSig_is_finalized"></a>

## Function `is_finalized`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(addr: <b>address</b>): bool {
  <a href="DiemAccount.md#0x1_DiemAccount_is_a_brick">DiemAccount::is_a_brick</a>(addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_is_authority"></a>

## Function `is_authority`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>&lt;P: store, key&gt;(multisig_addr: <b>address</b>, addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>&lt;P: store + key&gt;(multisig_addr: <b>address</b>, addr: <b>address</b>): bool <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;P&gt;&gt;(multisig_addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&m.signers, &addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_propose_authorities"></a>

## Function `propose_authorities`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_authorities">propose_authorities</a>&lt;PropType: store, key&gt;(sig: &signer, multisig_address: <b>address</b>, new_addresses: vector&lt;<b>address</b>&gt;, add_remove: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_authorities">propose_authorities</a>&lt;PropType: store + key&gt;(sig: &signer, multisig_address: <b>address</b>, new_addresses: vector&lt;<b>address</b>&gt;, add_remove: bool)<b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  // cannot start manipulating contract until it is finalized
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK">ENOT_FINALIZED_NOT_BRICK</a>));

  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

  // check sender is authorized
  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>&lt;PropType&gt;(multisig_address, sender_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));


  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;&gt;(multisig_address);
  <b>let</b> prop_opt = <a href="MultiSig.md#0x1_MultiSig_get_gov_prop_by_param">get_gov_prop_by_param</a>&lt;PropType&gt;(ms, <b>copy</b> new_addresses);

  <b>let</b> prop = <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&prop_opt)) {
    <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> prop_opt);
    <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>(&<b>mut</b> p, sender_addr);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(prop_opt);
    p
  } <b>else</b> {
    <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> {
      add_remove,
      addresses: new_addresses,
      votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(sender_addr),
      approved: <b>false</b>,
      expiration_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + ms.cfg_expire_epochs,
      cfg_n_sigs: ms.cfg_default_n_sigs, // <b>use</b> the default config at time of voting.
    }

  };

  <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>(&<b>mut</b> prop);

  // print(&p);
  <b>if</b> (prop.approved) {
    <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>&lt;PropType&gt;(ms, prop.add_remove, *&prop.addresses);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ms.gov_approved, prop);
  } <b>else</b> {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ms.gov_pending, prop);
  }

}
</code></pre>



</details>

<a name="0x1_MultiSig_vote"></a>

## Function `vote`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>, auth: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>, auth: <b>address</b>) {
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> prop.votes, auth);
}
</code></pre>



</details>

<a name="0x1_MultiSig_tally"></a>

## Function `tally`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>): bool {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&prop.votes) &gt; prop.cfg_n_sigs) {
    prop.approved = <b>true</b>;
    <b>return</b> <b>true</b>
  };

  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_gov_prop_by_param"></a>

## Function `get_gov_prop_by_param`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_gov_prop_by_param">get_gov_prop_by_param</a>&lt;PropType: store, key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_MultiSig">MultiSig::MultiSig</a>&lt;PropType&gt;, new_addresses: vector&lt;<b>address</b>&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">MultiSig::PropGovSigners</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_gov_prop_by_param">get_gov_prop_by_param</a>&lt;PropType: store + key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;, new_addresses: vector&lt;<b>address</b>&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt; {
  <b>let</b> (found, idx) = <a href="MultiSig.md#0x1_MultiSig_find_gov_idx_by_param">find_gov_idx_by_param</a>&lt;PropType&gt;(ms, new_addresses);
  <b>if</b> (found) {
    <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> ms.gov_pending, idx);
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(p)
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()

}
</code></pre>



</details>

<a name="0x1_MultiSig_find_gov_idx_by_param"></a>

## Function `find_gov_idx_by_param`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_gov_idx_by_param">find_gov_idx_by_param</a>&lt;PropType: store, key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_MultiSig">MultiSig::MultiSig</a>&lt;PropType&gt;, new_addresses: vector&lt;<b>address</b>&gt;): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_gov_idx_by_param">find_gov_idx_by_param</a>&lt;PropType: store + key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;, new_addresses: vector&lt;<b>address</b>&gt;): (bool, u64) {

  // find and <b>update</b> existing proposal, or create a new one and add <b>to</b> "pending"
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&ms.gov_pending);

  <b>if</b> (len &gt; 0) {
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      // <b>let</b> prop = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> gov_prop.pending, i);
      <b>let</b> prop = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&ms.gov_pending, i);
      <b>if</b> (
        <a href="VectorHelper.md#0x1_VectorHelper_compare">VectorHelper::compare</a>(&prop.addresses, &new_addresses)
      ) {
        <b>return</b> (<b>true</b>, i)
      };
      i = i + 1;
    };


};

(<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_MultiSig_maybe_update_authorities"></a>

## Function `maybe_update_authorities`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>&lt;PropType: store, key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_MultiSig">MultiSig::MultiSig</a>&lt;PropType&gt;, add_remove: bool, addresses: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>&lt;PropType: store + key&gt;(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;, add_remove: bool, addresses: vector&lt;<b>address</b>&gt;) {

      <b>if</b> (add_remove) {
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> ms.signers, addresses);
      } <b>else</b> {
        // remove the signers
        <b>let</b> i = 0;
        <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&addresses)) {
          <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&addresses, i);
          <b>let</b> (found, idx) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&ms.signers, addr);
          <b>if</b> (found) {
            <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> ms.signers, idx);
          };
          i = i + 1;
        };
      };
  }
</code></pre>



</details>

<a name="0x1_MultiSig_get_authorities"></a>

## Function `get_authorities`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_authorities">get_authorities</a>&lt;Prop: store, key&gt;(multisig_address: <b>address</b>): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_authorities">get_authorities</a>&lt;Prop: key + store &gt;(multisig_address: <b>address</b>): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;Prop&gt;&gt;(multisig_address);
  *&m.signers
}
</code></pre>



</details>
