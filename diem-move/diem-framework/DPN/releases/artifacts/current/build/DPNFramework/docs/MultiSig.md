
<a name="0x1_MultiSig"></a>

# Module `0x1::MultiSig`



-  [Resource `RootMultiSigRegistry`](#0x1_MultiSig_RootMultiSigRegistry)
-  [Resource `MultiSig`](#0x1_MultiSig_MultiSig)
-  [Resource `PropPayment`](#0x1_MultiSig_PropPayment)
-  [Resource `PropGovSigners`](#0x1_MultiSig_PropGovSigners)
-  [Resource `PropGeneric`](#0x1_MultiSig_PropGeneric)
-  [Constants](#@Constants_0)
-  [Function `root_init`](#0x1_MultiSig_root_init)
-  [Function `init_gov`](#0x1_MultiSig_init_gov)
-  [Function `is_authority`](#0x1_MultiSig_is_authority)
-  [Function `propose_add_authorities`](#0x1_MultiSig_propose_add_authorities)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
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
<code>n: u64</code>
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
<code>new_addrs: vector&lt;<b>address</b>&gt;</code>
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


<a name="0x1_MultiSig_ENOT_AUTHORIZED"></a>

Signer not authorized to approve a transaction.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>: u64 = 440002;
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

<a name="0x1_MultiSig_init_gov"></a>

## Function `init_gov`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_gov">init_gov</a>(sig: &signer, m_seed_authorities: vector&lt;<b>address</b>&gt;, cfg_n_sigs: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_gov">init_gov</a>(sig: &signer,  m_seed_authorities: vector&lt;<b>address</b>&gt;, cfg_n_sigs: u64) {
  // TODO: make this configurable
  <b>let</b> cfg_expire_epochs = 14;

  <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt; {
    cfg_expire_epochs,
    withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(),
    signers: m_seed_authorities,
    n: cfg_n_sigs,
    // m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&m_seed_authorities),
    pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    counter: 0,
  });
  // <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt; {
  //   cfg_n_sigs,
  //   cfg_expire_epochs,
  //   add: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  //   remove: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  //   threshold: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  //   reset_gov_votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  // });
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

<a name="0x1_MultiSig_propose_add_authorities"></a>

## Function `propose_add_authorities`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_add_authorities">propose_add_authorities</a>&lt;PropType: store, key&gt;(sig: &signer, multisig_address: <b>address</b>, new_addresses: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_add_authorities">propose_add_authorities</a>&lt;PropType: store + key&gt;(sig: &signer, multisig_address: <b>address</b>, new_addresses: vector&lt;<b>address</b>&gt;)  <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>{

  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));
  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  // check <b>if</b> the sender is an authority

  // <b>if</b> (<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;&gt;(sender_addr)) {
  //   <b>let</b> a = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;PropType&gt;&gt;(multisig_address);
  //   print(a);

  // }
  // <b>let</b> a = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;Prop&gt;&gt;(multisig_address);
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>&lt;PropType&gt;(multisig_address, sender_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

  <b>let</b> g = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address);

  // // reset everything beforehand.
  // // maybe_reset_gov(g);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&g.pending)) {
    <b>let</b> p = <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> {
        new_addrs: new_addresses,
        votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(sender_addr),
        approved: <b>false</b>,
        expiration_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + g.cfg_expire_epochs,
      };
      print(&p);
    };




  // <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&g.new_addrs);
  // <b>if</b> (len &gt; 0) {
  //   // check <b>if</b> there is already a proposal
  //   <b>let</b> i = 0;
  //   <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&g.new_addrs)) {
  //     <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> g.new_addrs, i);
  //     <b>if</b> (
  //       <a href="VectorHelper.md#0x1_VectorHelper_compare">VectorHelper::compare</a>(&p.new_addrs, &new_addresses) &&
  //       p.approved == <b>false</b>
  //     ) {
  //       <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> p.votes, sender_addr);

  //       <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&p.votes) &gt;= g.cfg_n_sigs) {
  //         p.approved = <b>true</b>;
  //         // finally append the new signers
  //         <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&lt;Prop&gt;&gt;(multisig_address);
  //         <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> ms.signers, *&p.new_addrs);
  //       };

  //     };
  //     i = i + 1;
  //   };
  // }
  // <b>else</b> {
  //   <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> {
  //       new_addrs: new_addresses,
  //       votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(sender_addr),
  //       approved: <b>false</b>,
  //       expiration_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + g.cfg_expire_epochs,
  //     };
  //     g.add = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(prop);
  //   };
}
</code></pre>



</details>
