
<a name="0x1_DonorDirected"></a>

# Module `0x1::DonorDirected`

Donor directed wallets is a service of the chain.
Any address can voluntarily turn their account into a donor directed account.
By creating a DonorDirected wallet you are providing certain restrictions and guarantees to the users that interact with this wallet.
1. The wallet's contents is propoperty of the owner. The owner is free to issue transactions which change the state of the wallet, including transferring funds. There are however time, and veto policies.
2. All transfers out of the account are timed. Meaning, they will execute automatically after a set period of time passes. The VM address triggers these events at each epoch boundary. The purpose of the delayed transfers is that the transaction can be paused for analysis, and eventually rejected by the donors of the wallet.
3. Every pending transaction can be "vetoed". This adds one day/epoch to the transaction, extending the delay. If a sufficient number of Donors vote on the Veto, then the transaction will be rejected.
4. After three consecutive transaction rejections, the account will become frozen. The funds remain in the account but no operations are available until the Donors, un-freeze the account.
5. Voting for all purposes are done on a pro-rata basis according to the amounts donated. Voting using ParticipationVote method, which in short, biases the threshold based on the turnout of the vote. TL;DR a low turnout of 12.5% would require 100% of the voters to veto, and lower thresholds for higher turnouts until 51%.
6. The donors can vote to liquidate a frozen DonorDirected account. The result will depend on the configuration of the DonorDirected account from when it was initialized: the funds by default return to the end user who was the donor.
7. Third party contracts can wrap the Donor Directed wallet. The outcomes of the votes can be returned to a handler in a third party contract For example, liquidiation of a frozen account is programmable: a handler can be coded to determine the outcome of the donor directed wallet. See in CommunityWallets the funds return to the InfrastructureEscrow side-account of the user.


-  [Resource `Registry`](#0x1_DonorDirected_Registry)
-  [Resource `DonorDirected`](#0x1_DonorDirected_DonorDirected)
-  [Resource `TimedTransfer`](#0x1_DonorDirected_TimedTransfer)
-  [Struct `Veto`](#0x1_DonorDirected_Veto)
-  [Resource `Freeze`](#0x1_DonorDirected_Freeze)
-  [Constants](#@Constants_0)
-  [Function `init`](#0x1_DonorDirected_init)
-  [Function `make_multisig`](#0x1_DonorDirected_make_multisig)
-  [Function `is_init`](#0x1_DonorDirected_is_init)
-  [Function `is_donor_directed`](#0x1_DonorDirected_is_donor_directed)
-  [Function `set_comm`](#0x1_DonorDirected_set_comm)
-  [Function `get_comm_list`](#0x1_DonorDirected_get_comm_list)
-  [Function `new_timed_transfer`](#0x1_DonorDirected_new_timed_transfer)
-  [Function `veto`](#0x1_DonorDirected_veto)
-  [Function `reject`](#0x1_DonorDirected_reject)
-  [Function `mark_processed`](#0x1_DonorDirected_mark_processed)
-  [Function `reset_rejection_counter`](#0x1_DonorDirected_reset_rejection_counter)
-  [Function `tally_veto`](#0x1_DonorDirected_tally_veto)
-  [Function `calculate_proportional_voting_threshold`](#0x1_DonorDirected_calculate_proportional_voting_threshold)
-  [Function `list_tx_by_epoch`](#0x1_DonorDirected_list_tx_by_epoch)
-  [Function `list_transfers`](#0x1_DonorDirected_list_transfers)
-  [Function `find`](#0x1_DonorDirected_find)
-  [Function `maybe_freeze`](#0x1_DonorDirected_maybe_freeze)
-  [Function `get_tx_args`](#0x1_DonorDirected_get_tx_args)
-  [Function `get_tx_epoch`](#0x1_DonorDirected_get_tx_epoch)
-  [Function `transfer_is_proposed`](#0x1_DonorDirected_transfer_is_proposed)
-  [Function `transfer_is_rejected`](#0x1_DonorDirected_transfer_is_rejected)
-  [Function `is_frozen`](#0x1_DonorDirected_is_frozen)
-  [Function `process_community_wallets`](#0x1_DonorDirected_process_community_wallets)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
<b>use</b> <a href="NodeWeight.md#0x1_NodeWeight">0x1::NodeWeight</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_DonorDirected_Registry"></a>

## Resource `Registry`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> <b>has</b> key
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

<a name="0x1_DonorDirected_DonorDirected"></a>

## Resource `DonorDirected`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>proposed: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>rejected: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
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

<a name="0x1_DonorDirected_TimedTransfer"></a>

## Resource `TimedTransfer`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> <b>has</b> <b>copy</b>, drop, store, key
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
<code>veto: <a href="DonorDirected.md#0x1_DonorDirected_Veto">DonorDirected::Veto</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirected_Veto"></a>

## Struct `Veto`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_Veto">Veto</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x1_DonorDirected_Freeze"></a>

## Resource `Freeze`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> <b>has</b> key
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


<a name="0x1_DonorDirected_APPROVED"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_APPROVED">APPROVED</a>: u8 = 1;
</code></pre>



<a name="0x1_DonorDirected_EIS_NOT_SLOW_WALLET"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_EIS_NOT_SLOW_WALLET">EIS_NOT_SLOW_WALLET</a>: u64 = 231010;
</code></pre>



<a name="0x1_DonorDirected_ERR_PREFIX"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ERR_PREFIX">ERR_PREFIX</a>: u64 = 23;
</code></pre>



<a name="0x1_DonorDirected_PROPOSED"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_PROPOSED">PROPOSED</a>: u8 = 0;
</code></pre>



<a name="0x1_DonorDirected_REJECTED"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_REJECTED">REJECTED</a>: u8 = 2;
</code></pre>



<a name="0x1_DonorDirected_init"></a>

## Function `init`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init">init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init">init</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  // TODO: this <b>struct</b> goes <b>to</b> the individual accounts.
  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0)) {
    <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(
      vm,
      <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
        proposed: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(),
        approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(),
        rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(),
        max_uid: 0,
      }
    )
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@0x0)) {
    <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(vm, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    });
  };
}
</code></pre>



</details>

<a name="0x1_DonorDirected_make_multisig"></a>

## Function `make_multisig`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector&lt;<b>address</b>&gt;) {
  <a href="MultiSig.md#0x1_MultiSig_init_gov">MultiSig::init_gov</a>(sponsor, cfg_default_n_sigs, &new_authorities);
  <a href="MultiSig.md#0x1_MultiSig_init_type">MultiSig::init_type</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(sponsor, <b>false</b>); // cannot withdraw through multisig process
  <a href="MultiSig.md#0x1_MultiSig_finalize_and_brick">MultiSig::finalize_and_brick</a>(sponsor);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_init"></a>

## Function `is_init`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_init">is_init</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_init">is_init</a>():bool {
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_donor_directed"></a>

## Function `is_donor_directed`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(addr: <b>address</b>):bool {
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_set_comm"></a>

## Function `set_comm`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_comm">set_comm</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_comm">set_comm</a>(sig: &signer) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@0x0)) <b>return</b>;

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_comm_list">get_comm_list</a>();
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &addr)) {
    <b>let</b> s = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@0x0);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
  };

  <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(
    sig,
    <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
      is_frozen: <b>false</b>,
      consecutive_rejections: 0,
      unfreeze_votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    }
  )
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_comm_list"></a>

## Function `get_comm_list`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_comm_list">get_comm_list</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_comm_list">get_comm_list</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@0x0)) {
    <b>let</b> s = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@0x0);
    <b>return</b> *&s.list
  } <b>else</b> {
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_new_timed_transfer"></a>

## Function `new_timed_transfer`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_new_timed_transfer">new_timed_transfer</a>(sender: &signer, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_new_timed_transfer">new_timed_transfer</a>(
  sender: &signer, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;
): u64 <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  // firstly check <b>if</b> payee is a slow wallet
  // TODO: This function should check <b>if</b> the account is a slow wallet before sending
  // but there's a circular dependency <b>with</b> <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> which <b>has</b> the slow wallet <b>struct</b>.
  // curretly we <b>move</b> that check <b>to</b> the transaction <b>script</b> <b>to</b> initialize the payment.
  // <b>assert</b>!(<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(payee), <a href="DonorDirected.md#0x1_DonorDirected_EIS_NOT_SLOW_WALLET">EIS_NOT_SLOW_WALLET</a>);

  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_comm_list">get_comm_list</a>();
  // <b>assert</b>!(
  //   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &sender_addr),
  //   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="DonorDirected.md#0x1_DonorDirected_ERR_PREFIX">ERR_PREFIX</a> + 001)
  // );

  <b>let</b> transfers = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
  transfers.max_uid = transfers.max_uid + 1;

  // add current epoch + 1
  <b>let</b> current_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  <b>let</b> t = <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> {
    uid: transfers.max_uid,
    expire_epoch: current_epoch + 2, // pays at the end of second (start of third epoch),
    payer: sender_addr,
    payee: payee,
    value: value,
    description: description,
    veto: <a href="DonorDirected.md#0x1_DonorDirected_Veto">Veto</a> {
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      count: 0,
      threshold: 0,
    }
  };

  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> transfers.proposed, t);
  <b>return</b> transfers.max_uid
}
</code></pre>



</details>

<a name="0x1_DonorDirected_veto"></a>

## Function `veto`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto">veto</a>(sender: &signer, uid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto">veto</a>(
  sender: &signer,
  uid: u64
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>assert</b>!(
    <a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(addr),
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_requires_role">Errors::requires_role</a>(<a href="DonorDirected.md#0x1_DonorDirected_ERR_PREFIX">ERR_PREFIX</a> + 001)
  );
  <b>let</b> (opt, i) = <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(uid, <a href="DonorDirected.md#0x1_DonorDirected_PROPOSED">PROPOSED</a>);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&opt)) {
    <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
    // add voters <b>address</b> <b>to</b> the veto list
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<b>address</b>&gt;(&<b>mut</b> t.veto.list, addr);
    // <b>if</b> not at rejection threshold
    // add latency <b>to</b> the payment, <b>to</b> get further reviews
    t.expire_epoch = t.expire_epoch + 1;

    <b>if</b> (<a href="DonorDirected.md#0x1_DonorDirected_tally_veto">tally_veto</a>(i)) {
      <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid)
    }
  };
}
</code></pre>



</details>

<a name="0x1_DonorDirected_reject"></a>

## Function `reject`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid: u64) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
  <b>let</b> list = *&c.proposed;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&list, i);
    <b>if</b> (t.uid == uid) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(*&t.payer);
      f.consecutive_rejections = f.consecutive_rejections + 1;
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.rejected, t);
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_mark_processed"></a>

## Function `mark_processed`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_mark_processed">mark_processed</a>(vm: &signer, t: <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_mark_processed">mark_processed</a>(vm: &signer, t: <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
  <b>let</b> list = *&c.proposed;
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> search = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&list, i);
    <b>if</b> (search.uid == t.uid) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.approved, search);
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_reset_rejection_counter"></a>

## Function `reset_rejection_counter`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reset_rejection_counter">reset_rejection_counter</a>(vm: &signer, wallet: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reset_rejection_counter">reset_rejection_counter</a>(vm: &signer, wallet: <b>address</b>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(wallet).consecutive_rejections = 0;
}
</code></pre>



</details>

<a name="0x1_DonorDirected_tally_veto"></a>

## Function `tally_veto`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_tally_veto">tally_veto</a>(index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_tally_veto">tally_veto</a>(index: u64): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
  <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, index);

  <b>let</b> votes = 0;
  <b>let</b> threshold = <a href="DonorDirected.md#0x1_DonorDirected_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>();

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

<a name="0x1_DonorDirected_calculate_proportional_voting_threshold"></a>

## Function `calculate_proportional_voting_threshold`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_calculate_proportional_voting_threshold">calculate_proportional_voting_threshold</a>(): u64 {
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

<a name="0x1_DonorDirected_list_tx_by_epoch"></a>

## Function `list_tx_by_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_list_tx_by_epoch">list_tx_by_epoch</a>(epoch: u64): vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_list_tx_by_epoch">list_tx_by_epoch</a>(epoch: u64): vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
    <b>let</b> c = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);

    // <b>loop</b> proposed list
    <b>let</b> pending = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;();
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&c.proposed);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&c.proposed, i);
      <b>if</b> (t.expire_epoch == epoch) {

        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> pending, *t);
      };
      i = i + 1;
    };
    <b>return</b> pending
  }
</code></pre>



</details>

<a name="0x1_DonorDirected_list_transfers"></a>

## Function `list_transfers`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_list_transfers">list_transfers</a>(type_of: u8): vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_list_transfers">list_transfers</a>(type_of: u8): vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> c = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(@0x0);
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

<a name="0x1_DonorDirected_find"></a>

## Function `find`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(uid: u64, type_of: u8): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(
  uid: u64,
  type_of: u8
): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;, u64) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> list = &<a href="DonorDirected.md#0x1_DonorDirected_list_transfers">list_transfers</a>(type_of);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(list, i);
    <b>if</b> (t.uid == uid) {
      <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(t), i)
    };
    i = i + 1;
  };
  (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(), 0)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_maybe_freeze"></a>

## Function `maybe_freeze`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_freeze">maybe_freeze</a>(wallet: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_freeze">maybe_freeze</a>(wallet: <b>address</b>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>if</b> (<b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(wallet).consecutive_rejections &gt; 2) {
    <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(wallet);
    f.is_frozen = <b>true</b>;
  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_tx_args"></a>

## Function `get_tx_args`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_args">get_tx_args</a>(t: <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>): (<b>address</b>, <b>address</b>, u64, vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_args">get_tx_args</a>(t: <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>): (<b>address</b>, <b>address</b>, u64, vector&lt;u8&gt;) {
  (t.payer, t.payee, t.value, *&t.description)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_tx_epoch"></a>

## Function `get_tx_epoch`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_epoch">get_tx_epoch</a>(uid: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_epoch">get_tx_epoch</a>(uid: u64): u64 <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> (opt, _) = <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(uid, <a href="DonorDirected.md#0x1_DonorDirected_PROPOSED">PROPOSED</a>);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&opt)) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&opt);
    <b>return</b> *&t.expire_epoch
  };
  0
}
</code></pre>



</details>

<a name="0x1_DonorDirected_transfer_is_proposed"></a>

## Function `transfer_is_proposed`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_transfer_is_proposed">transfer_is_proposed</a>(uid: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_transfer_is_proposed">transfer_is_proposed</a>(uid: u64): bool <b>acquires</b>  <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> (opt, _) = <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(uid, <a href="DonorDirected.md#0x1_DonorDirected_PROPOSED">PROPOSED</a>);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&opt)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_transfer_is_rejected"></a>

## Function `transfer_is_rejected`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_transfer_is_rejected">transfer_is_rejected</a>(uid: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_transfer_is_rejected">transfer_is_rejected</a>(uid: u64): bool <b>acquires</b>  <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
  <b>let</b> (opt, _) = <a href="DonorDirected.md#0x1_DonorDirected_find">find</a>(uid, <a href="DonorDirected.md#0x1_DonorDirected_REJECTED">REJECTED</a>);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&opt)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_frozen"></a>

## Function `is_frozen`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_frozen">is_frozen</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_frozen">is_frozen</a>(addr: <b>address</b>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>{
  <b>let</b> f = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(addr);
  f.is_frozen
}
</code></pre>



</details>

<a name="0x1_DonorDirected_process_community_wallets"></a>

## Function `process_community_wallets`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_community_wallets">process_community_wallets</a>(vm: &signer, epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_community_wallets">process_community_wallets</a>(
    vm: &signer, epoch: u64
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>  { //////// 0L ////////
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(vm) != @DiemRoot) <b>return</b>;

    print(&990100);
    // Migrate on the fly <b>if</b> state doesn't exist on upgrade.
    <b>if</b> (!<a href="DonorDirected.md#0x1_DonorDirected_is_init">is_init</a>()) {
        <a href="DonorDirected.md#0x1_DonorDirected_init">init</a>(vm);
        <b>return</b>
    };
    print(&990200);
    <b>let</b> all = <a href="DonorDirected.md#0x1_DonorDirected_list_transfers">list_transfers</a>(0);
    print(&all);

    <b>let</b> v = <a href="DonorDirected.md#0x1_DonorDirected_list_tx_by_epoch">list_tx_by_epoch</a>(epoch);
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&v);
    print(&len);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
        print(&990201);
        <b>let</b> t: <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&v, i);
        // TODO: Is this the best way <b>to</b> access a <b>struct</b> property from
        // outside a <b>module</b>?
        <b>let</b> (payer, payee, value, description) = <a href="DonorDirected.md#0x1_DonorDirected_get_tx_args">get_tx_args</a>(*&t);
        <b>if</b> (<a href="DonorDirected.md#0x1_DonorDirected_is_frozen">is_frozen</a>(payer)) {
          i = i + 1;
          <b>continue</b>
        };
        print(&990202);
        <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">DiemAccount::vm_make_payment_no_limit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(payer, payee, value, description, b"", vm);
        print(&990203);
        <a href="DonorDirected.md#0x1_DonorDirected_mark_processed">mark_processed</a>(vm, t);
        <a href="DonorDirected.md#0x1_DonorDirected_reset_rejection_counter">reset_rejection_counter</a>(vm, payer);
        print(&990204);
        i = i + 1;
    };
}
</code></pre>



</details>
