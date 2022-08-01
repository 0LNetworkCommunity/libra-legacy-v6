
<a name="0x1_Wallet"></a>

# Module `0x1::Wallet`



-  [Resource `CommunityWalletList`](#0x1_Wallet_CommunityWalletList)
-  [Resource `CommunityTransfers`](#0x1_Wallet_CommunityTransfers)
-  [Resource `TimedTransfer`](#0x1_Wallet_TimedTransfer)
-  [Struct `Veto`](#0x1_Wallet_Veto)
-  [Resource `CommunityFreeze`](#0x1_Wallet_CommunityFreeze)
-  [Constants](#@Constants_0)
-  [Function `init`](#0x1_Wallet_init)
-  [Function `is_init_comm`](#0x1_Wallet_is_init_comm)
-  [Function `set_comm`](#0x1_Wallet_set_comm)
-  [Function `vm_remove_comm`](#0x1_Wallet_vm_remove_comm)
-  [Function `new_timed_transfer`](#0x1_Wallet_new_timed_transfer)
-  [Function `veto`](#0x1_Wallet_veto)
-  [Function `reject`](#0x1_Wallet_reject)
-  [Function `mark_processed`](#0x1_Wallet_mark_processed)
-  [Function `reset_rejection_counter`](#0x1_Wallet_reset_rejection_counter)
-  [Function `tally_veto`](#0x1_Wallet_tally_veto)
-  [Function `calculate_proportional_voting_threshold`](#0x1_Wallet_calculate_proportional_voting_threshold)
-  [Function `list_tx_by_epoch`](#0x1_Wallet_list_tx_by_epoch)
-  [Function `list_transfers`](#0x1_Wallet_list_transfers)
-  [Function `find`](#0x1_Wallet_find)
-  [Function `maybe_freeze`](#0x1_Wallet_maybe_freeze)
-  [Function `get_tx_args`](#0x1_Wallet_get_tx_args)
-  [Function `get_tx_epoch`](#0x1_Wallet_get_tx_epoch)
-  [Function `transfer_is_proposed`](#0x1_Wallet_transfer_is_proposed)
-  [Function `transfer_is_rejected`](#0x1_Wallet_transfer_is_rejected)
-  [Function `get_comm_list`](#0x1_Wallet_get_comm_list)
-  [Function `is_comm`](#0x1_Wallet_is_comm)
-  [Function `is_frozen`](#0x1_Wallet_is_frozen)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Wallet_CommunityWalletList"></a>

## Resource `CommunityWalletList`



<pre><code><b>struct</b> <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_CommunityTransfers"></a>

## Resource `CommunityTransfers`



<pre><code><b>struct</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>proposed: vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>rejected: vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>max_uid: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_TimedTransfer"></a>

## Resource `TimedTransfer`



<pre><code><b>struct</b> <a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>uid: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>expire_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>payer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>payee: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>description: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>veto: <a href="Wallet.md#0x1_Wallet_Veto">Wallet::Veto</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_Veto"></a>

## Struct `Veto`



<pre><code><b>struct</b> <a href="Wallet.md#0x1_Wallet_Veto">Veto</a> <b>has</b> <b>copy</b>, drop, store
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
<code>count: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>threshold: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_CommunityFreeze"></a>

## Resource `CommunityFreeze`



<pre><code><b>struct</b> <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>is_frozen: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>consecutive_rejections: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>unfreeze_votes: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Wallet_APPROVED"></a>



<pre><code><b>const</b> <a href="Wallet.md#0x1_Wallet_APPROVED">APPROVED</a>: u8 = 1;
</code></pre>



<a name="0x1_Wallet_EIS_NOT_SLOW_WALLET"></a>



<pre><code><b>const</b> <a href="Wallet.md#0x1_Wallet_EIS_NOT_SLOW_WALLET">EIS_NOT_SLOW_WALLET</a>: u64 = 231010;
</code></pre>



<a name="0x1_Wallet_ERR_PREFIX"></a>



<pre><code><b>const</b> <a href="Wallet.md#0x1_Wallet_ERR_PREFIX">ERR_PREFIX</a>: u64 = 23;
</code></pre>



<a name="0x1_Wallet_PROPOSED"></a>



<pre><code><b>const</b> <a href="Wallet.md#0x1_Wallet_PROPOSED">PROPOSED</a>: u8 = 0;
</code></pre>



<a name="0x1_Wallet_REJECTED"></a>



<pre><code><b>const</b> <a href="Wallet.md#0x1_Wallet_REJECTED">REJECTED</a>: u8 = 2;
</code></pre>



<a name="0x1_Wallet_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_init">init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_init">init</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0)) {
    <b>move_to</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(
      vm,
      <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
        proposed: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(),
        approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(),
        rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(),
        max_uid: 0,
      }
    )
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0)) {
    <b>move_to</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(vm, <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a> {
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    });
  };
}
</code></pre>



</details>

<a name="0x1_Wallet_is_init_comm"></a>

## Function `is_init_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_init_comm">is_init_comm</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_init_comm">is_init_comm</a>():bool {
  <b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0)
}
</code></pre>



</details>

<a name="0x1_Wallet_set_comm"></a>

## Function `set_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_comm">set_comm</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_comm">set_comm</a>(sig: &signer) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0)) <b>return</b>;

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &addr)) {
    <b>let</b> s = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
  };

  <b>move_to</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(
    sig,
    <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> {
      is_frozen: <b>false</b>,
      consecutive_rejections: 0,
      unfreeze_votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    }
  )
}
</code></pre>



</details>

<a name="0x1_Wallet_vm_remove_comm"></a>

## Function `vm_remove_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_vm_remove_comm">vm_remove_comm</a>(vm: &signer, addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_vm_remove_comm">vm_remove_comm</a>(vm: &signer, addr: <b>address</b>) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0)) <b>return</b>;

  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
  <b>let</b> (yes, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;<b>address</b>&gt;(&list, &addr);
  <b>if</b> (yes) {
    <b>let</b> s = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> s.list, i);
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_new_timed_transfer"></a>

## Function `new_timed_transfer`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_new_timed_transfer">new_timed_transfer</a>(sender: &signer, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_new_timed_transfer">new_timed_transfer</a>(
  sender: &signer, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;
): u64 <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>, <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a> {
  // firstly check <b>if</b> payee is a slow wallet
  // TODO: This function should check <b>if</b> the account is a slow wallet before sending
  // but there's a circular dependency <b>with</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> which <b>has</b> the slow wallet <b>struct</b>.
  // curretly we <b>move</b> that check <b>to</b> the transaction <b>script</b> <b>to</b> initialize the payment.
  // <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(payee), <a href="Wallet.md#0x1_Wallet_EIS_NOT_SLOW_WALLET">EIS_NOT_SLOW_WALLET</a>);

  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
  <b>assert</b>!(
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &sender_addr),
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="Wallet.md#0x1_Wallet_ERR_PREFIX">ERR_PREFIX</a> + 001)
  );

  <b>let</b> transfers = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
  transfers.max_uid = transfers.max_uid + 1;

  // add current epoch + 1
  <b>let</b> current_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  <b>let</b> t = <a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a> {
    uid: transfers.max_uid,
    expire_epoch: current_epoch + 2, // pays at the end of second (start of third epoch),
    payer: sender_addr,
    payee: payee,
    value: value,
    description: description,
    veto: <a href="Wallet.md#0x1_Wallet_Veto">Veto</a> {
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      count: 0,
      threshold: 0,
    }
  };

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> transfers.proposed, t);
  <b>return</b> transfers.max_uid
}
</code></pre>



</details>

<a name="0x1_Wallet_veto"></a>

## Function `veto`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_veto">veto</a>(sender: &signer, uid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_veto">veto</a>(
  sender: &signer,
  uid: u64
) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>, <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>assert</b>!(
    <a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr),
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="Wallet.md#0x1_Wallet_ERR_PREFIX">ERR_PREFIX</a> + 001)
  );
  <b>let</b> (opt, i) = <a href="Wallet.md#0x1_Wallet_find">find</a>(uid, <a href="Wallet.md#0x1_Wallet_PROPOSED">PROPOSED</a>);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&opt)) {
    <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
    // add voters <b>address</b> <b>to</b> the veto list
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> t.veto.list, addr);
    // <b>if</b> not at rejection threshold
    // add latency <b>to</b> the payment, <b>to</b> get further reviews
    t.expire_epoch = t.expire_epoch + 1;

    <b>if</b> (<a href="Wallet.md#0x1_Wallet_tally_veto">tally_veto</a>(i)) {
      <a href="Wallet.md#0x1_Wallet_reject">reject</a>(uid)
    }
  };
}
</code></pre>



</details>

<a name="0x1_Wallet_reject"></a>

## Function `reject`



<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_reject">reject</a>(uid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_reject">reject</a>(uid: u64) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>, <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> {
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
  <b>let</b> list = *&c.proposed;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&list, i);
    <b>if</b> (t.uid == uid) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(*&t.payer);
      f.consecutive_rejections = f.consecutive_rejections + 1;
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.rejected, t);
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_Wallet_mark_processed"></a>

## Function `mark_processed`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_mark_processed">mark_processed</a>(vm: &signer, t: <a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_mark_processed">mark_processed</a>(vm: &signer, t: <a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
  <b>let</b> list = *&c.proposed;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> search = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&list, i);
    <b>if</b> (search.uid == t.uid) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.approved, search);
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_Wallet_reset_rejection_counter"></a>

## Function `reset_rejection_counter`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_reset_rejection_counter">reset_rejection_counter</a>(vm: &signer, wallet: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_reset_rejection_counter">reset_rejection_counter</a>(vm: &signer, wallet: <b>address</b>) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(wallet).consecutive_rejections = 0;
}
</code></pre>



</details>

<a name="0x1_Wallet_tally_veto"></a>

## Function `tally_veto`



<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_tally_veto">tally_veto</a>(index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_tally_veto">tally_veto</a>(index: u64): bool <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
  <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, index);

  <b>let</b> votes = 0;
  <b>let</b> threshold = <a href="Wallet.md#0x1_Wallet_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>();

  <b>let</b> k = 0;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&t.veto.list);

  <b>while</b> (k &lt; len) {
    <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&t.veto.list, k);
    // ignore votes that are no longer in the validator set,
    // BUT DON'T REMOVE, since they may rejoin the validator set,
    // and shouldn't need <b>to</b> vote again.

    <b>if</b> (<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr)) {
      votes = votes + <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">NodeWeight::proof_of_weight</a>(addr)
    };
    k = k + 1;
  };

  t.veto.count = votes;
  t.veto.threshold = threshold;

  <b>return</b> votes &gt; threshold
}
</code></pre>



</details>

<a name="0x1_Wallet_calculate_proportional_voting_threshold"></a>

## Function `calculate_proportional_voting_threshold`



<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64 {
    <b>let</b> val_set_size = <a href="DiemSystem.md#0x1_DiemSystem_validator_set_size">DiemSystem::validator_set_size</a>();
    <b>let</b> i = 0;
    <b>let</b> voting_power = 0;
    <b>while</b> (i &lt; val_set_size) {
      <b>let</b> addr = <a href="DiemSystem.md#0x1_DiemSystem_get_ith_validator_address">DiemSystem::get_ith_validator_address</a>(i);
      voting_power = voting_power + <a href="NodeWeight.md#0x1_NodeWeight_proof_of_weight">NodeWeight::proof_of_weight</a>(addr);
      i = i + 1;
    };
    <b>let</b> threshold = voting_power * 2 / 3;
    threshold
}
</code></pre>



</details>

<a name="0x1_Wallet_list_tx_by_epoch"></a>

## Function `list_tx_by_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_list_tx_by_epoch">list_tx_by_epoch</a>(epoch: u64): vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_list_tx_by_epoch">list_tx_by_epoch</a>(epoch: u64): vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt; <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
    <b>let</b> c = <b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);

    // <b>loop</b> proposed list
    <b>let</b> pending = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;();
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&c.proposed);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&c.proposed, i);
      <b>if</b> (t.expire_epoch == epoch) {

        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> pending, *t);
      };
      i = i + 1;
    };
    <b>return</b> pending
  }
</code></pre>



</details>

<a name="0x1_Wallet_list_transfers"></a>

## Function `list_transfers`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_list_transfers">list_transfers</a>(type_of: u8): vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_list_transfers">list_transfers</a>(type_of: u8): vector&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt; <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> c = <b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a>&gt;(@0x0);
  <b>if</b> (type_of == 0) {
    *&c.proposed
  } <b>else</b> <b>if</b> (type_of == 1) {
    *&c.approved
  } <b>else</b> {
    *&c.rejected
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_find"></a>

## Function `find`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_find">find</a>(uid: u64, type_of: u8): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_find">find</a>(
  uid: u64,
  type_of: u8
): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;, u64) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> list = &<a href="Wallet.md#0x1_Wallet_list_transfers">list_transfers</a>(type_of);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(list, i);
    <b>if</b> (t.uid == uid) {
      <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(t), i)
    };
    i = i + 1;
  };
  (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(), 0)
}
</code></pre>



</details>

<a name="0x1_Wallet_maybe_freeze"></a>

## Function `maybe_freeze`



<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_maybe_freeze">maybe_freeze</a>(wallet: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Wallet.md#0x1_Wallet_maybe_freeze">maybe_freeze</a>(wallet: <b>address</b>) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a> {
  <b>if</b> (<b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(wallet).consecutive_rejections &gt; 2) {
    <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(wallet);
    f.is_frozen = <b>true</b>;
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_get_tx_args"></a>

## Function `get_tx_args`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_tx_args">get_tx_args</a>(t: <a href="Wallet.md#0x1_Wallet_TimedTransfer">Wallet::TimedTransfer</a>): (<b>address</b>, <b>address</b>, u64, vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_tx_args">get_tx_args</a>(t: <a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>): (<b>address</b>, <b>address</b>, u64, vector&lt;u8&gt;) {
  (t.payer, t.payee, t.value, *&t.description)
}
</code></pre>



</details>

<a name="0x1_Wallet_get_tx_epoch"></a>

## Function `get_tx_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_tx_epoch">get_tx_epoch</a>(uid: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_tx_epoch">get_tx_epoch</a>(uid: u64): u64 <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> (opt, _) = <a href="Wallet.md#0x1_Wallet_find">find</a>(uid, <a href="Wallet.md#0x1_Wallet_PROPOSED">PROPOSED</a>);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&opt)) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&opt);
    <b>return</b> *&t.expire_epoch
  };
  0
}
</code></pre>



</details>

<a name="0x1_Wallet_transfer_is_proposed"></a>

## Function `transfer_is_proposed`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_transfer_is_proposed">transfer_is_proposed</a>(uid: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_transfer_is_proposed">transfer_is_proposed</a>(uid: u64): bool <b>acquires</b>  <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> (opt, _) = <a href="Wallet.md#0x1_Wallet_find">find</a>(uid, <a href="Wallet.md#0x1_Wallet_PROPOSED">PROPOSED</a>);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&opt)
}
</code></pre>



</details>

<a name="0x1_Wallet_transfer_is_rejected"></a>

## Function `transfer_is_rejected`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_transfer_is_rejected">transfer_is_rejected</a>(uid: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_transfer_is_rejected">transfer_is_rejected</a>(uid: u64): bool <b>acquires</b>  <a href="Wallet.md#0x1_Wallet_CommunityTransfers">CommunityTransfers</a> {
  <b>let</b> (opt, _) = <a href="Wallet.md#0x1_Wallet_find">find</a>(uid, <a href="Wallet.md#0x1_Wallet_REJECTED">REJECTED</a>);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="Wallet.md#0x1_Wallet_TimedTransfer">TimedTransfer</a>&gt;(&opt)
}
</code></pre>



</details>

<a name="0x1_Wallet_get_comm_list"></a>

## Function `get_comm_list`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0)) {
    <b>let</b> s = <b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0);
    <b>return</b> *&s.list
  } <b>else</b> {
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_is_comm"></a>

## Function `is_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_comm">is_comm</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_comm">is_comm</a>(addr: <b>address</b>): bool <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>{
  <b>let</b> s = <b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWalletList">CommunityWalletList</a>&gt;(@0x0);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&s.list, &addr)
}
</code></pre>



</details>

<a name="0x1_Wallet_is_frozen"></a>

## Function `is_frozen`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_frozen">is_frozen</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_frozen">is_frozen</a>(addr: <b>address</b>): bool <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>{
  <b>let</b> f = <b>borrow_global</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityFreeze">CommunityFreeze</a>&gt;(addr);
  f.is_frozen
}
</code></pre>



</details>
