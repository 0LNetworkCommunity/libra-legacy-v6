
<a name="0x1_DonorDirected"></a>

# Module `0x1::DonorDirected`

Donor directed wallets is a service of the chain.
Any address can voluntarily turn their account into a donor directed account.
By creating a DonorDirected wallet you are providing certain restrictions and guarantees to the users that interact with this wallet.
1. The wallet's contents is propoperty of the owner. The owner is free to issue transactions which change the state of the wallet, including transferring funds. There are however time, and veto policies.
2. All transfers out of the account are timed. Meaning, they will execute automatically after a set period of time passes. The VM address triggers these events at each epoch boundary. The purpose of the delayed transfers is that the transaction can be paused for analysis, and eventually rejected by the donors of the wallet.
3. Every pending transaction can be "vetoed". The vetos delay the finalizing of the transaction, to allow more time for analysis. Each veto adds one day/epoch to the transaction PER DAY THAT A VETO OCCURRS. That is, two vetos happening in the same day, only extend the vote by one day. If a sufficient number of Donors vote on the Veto, then the transaction will be rejected. Since DonorDirected has an expiration time, as does ParticipationVote, each time there is a veto, the deadlines for both are syncronized, based on the new DonorDirected expiration time.
4. After three consecutive transaction rejections, the account will become frozen. The funds remain in the account but no operations are available until the Donors, un-freeze the account.
5. Voting for all purposes are done on a pro-rata basis according to the amounts donated. Voting using ParticipationVote method, which in short, biases the threshold based on the turnout of the vote. TL;DR a low turnout of 12.5% would require 100% of the voters to veto, and lower thresholds for higher turnouts until 51%.
6. The donors can vote to liquidate a frozen DonorDirected account. The result will depend on the configuration of the DonorDirected account from when it was initialized: the funds by default return to the end user who was the donor.
7. Third party contracts can wrap the Donor Directed wallet. The outcomes of the votes can be returned to a handler in a third party contract For example, liquidiation of a frozen account is programmable: a handler can be coded to determine the outcome of the donor directed wallet. See in CommunityWallets the funds return to the InfrastructureEscrow side-account of the user.


-  [Resource `Registry`](#0x1_DonorDirected_Registry)
-  [Resource `DonorDirected`](#0x1_DonorDirected_DonorDirected)
-  [Resource `TimedTransfer`](#0x1_DonorDirected_TimedTransfer)
-  [Resource `DonorDirectedProp`](#0x1_DonorDirected_DonorDirectedProp)
-  [Resource `Freeze`](#0x1_DonorDirected_Freeze)
-  [Constants](#@Constants_0)
-  [Function `init_root_registry`](#0x1_DonorDirected_init_root_registry)
-  [Function `is_root_init`](#0x1_DonorDirected_is_root_init)
-  [Function `set_donor_directed`](#0x1_DonorDirected_set_donor_directed)
-  [Function `make_multisig`](#0x1_DonorDirected_make_multisig)
-  [Function `is_donor_directed`](#0x1_DonorDirected_is_donor_directed)
-  [Function `get_root_registry`](#0x1_DonorDirected_get_root_registry)
-  [Function `new_timed_transfer_multisig`](#0x1_DonorDirected_new_timed_transfer_multisig)
-  [Function `schedule`](#0x1_DonorDirected_schedule)
-  [Function `process_donor_directed_accounts`](#0x1_DonorDirected_process_donor_directed_accounts)
-  [Function `maybe_pay_if_deadline_today`](#0x1_DonorDirected_maybe_pay_if_deadline_today)
-  [Function `veto_handler`](#0x1_DonorDirected_veto_handler)
-  [Function `reject`](#0x1_DonorDirected_reject)
-  [Function `reset_rejection_counter`](#0x1_DonorDirected_reset_rejection_counter)
-  [Function `maybe_freeze`](#0x1_DonorDirected_maybe_freeze)
-  [Function `get_tx_params`](#0x1_DonorDirected_get_tx_params)
-  [Function `get_pending_timed_transfer_mut`](#0x1_DonorDirected_get_pending_timed_transfer_mut)
-  [Function `get_index_of_pending`](#0x1_DonorDirected_get_index_of_pending)
-  [Function `is_frozen`](#0x1_DonorDirected_is_frozen)
-  [Function `init_donor_directed`](#0x1_DonorDirected_init_donor_directed)
-  [Function `finalize_init`](#0x1_DonorDirected_finalize_init)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance">0x1::DonorDirectedGovernance</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
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
<code>guid_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirected_TimedTransfer"></a>

## Resource `TimedTransfer`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>uid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_GUID">GUID::GUID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>expire_epoch: u64</code>
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
<code>last_veto_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirected_DonorDirectedProp"></a>

## Resource `DonorDirectedProp`

each multisig auth will propose a transfer
once it gets consensus a TimedTransfer is created
the timed transfer will exevute unless the Donors veto the transaction.


<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_DonorDirectedProp">DonorDirectedProp</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
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


<a name="0x1_DonorDirected_ENOT_AUTHORIZED_TO_VOTE"></a>

User is not a donor and cannot vote on this account


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENOT_AUTHORIZED_TO_VOTE">ENOT_AUTHORIZED_TO_VOTE</a>: u64 = 231010;
</code></pre>



<a name="0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED"></a>

Not initialized as a donor directed account.


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>: u64 = 231001;
</code></pre>



<a name="0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID"></a>

Could not find a pending transaction by this GUID


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID">ENO_PEDNING_TRANSACTION_AT_UID</a>: u64 = 231011;
</code></pre>



<a name="0x1_DonorDirected_init_root_registry"></a>

## Function `init_root_registry`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_root_registry">init_root_registry</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_root_registry">init_root_registry</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<a href="DonorDirected.md#0x1_DonorDirected_is_root_init">is_root_init</a>()) {
    <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(vm, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    });
  };
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_root_init"></a>

## Function `is_root_init`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_root_init">is_root_init</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_root_init">is_root_init</a>():bool {
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_set_donor_directed"></a>

## Function `set_donor_directed`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(sig: &signer) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved)) <b>return</b>;

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>();
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &addr)) {
    <b>let</b> s = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
  };

  <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(
    sig,
    <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
      is_frozen: <b>false</b>,
      consecutive_rejections: 0,
      unfreeze_votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
    }
  );

  <b>let</b> guid_capability = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);
  <b>move_to</b>(sig, <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {
      proposed: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      guid_capability,
    })

}
</code></pre>



</details>

<a name="0x1_DonorDirected_make_multisig"></a>

## Function `make_multisig`

Like any MultiSig instance, a sponsor which is the original owner of the account, needs to initialize the account.
The account must be "bricked" by the owner before MultiSig actions can be taken.
Note, as with any multisig, the new_authorities cannot include the sponsor, since that account will no longer be able to sign transactions.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector&lt;<b>address</b>&gt;) {
  <a href="MultiSig.md#0x1_MultiSig_init_gov">MultiSig::init_gov</a>(sponsor, cfg_default_n_sigs, &new_authorities);
  <a href="MultiSig.md#0x1_MultiSig_init_type">MultiSig::init_type</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(sponsor, <b>true</b>); // "<b>true</b>": We make this multisig instance hold the WithdrawCapability. Even though we don't need it for any <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> pay functions, we can <b>use</b> it <b>to</b> make sure the entire pipeline of private functions scheduling a payment are authorized. Belt and suspenders.
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_donor_directed"></a>

## Function `is_donor_directed`

Check if the account is a donor directed account, and initialized properly.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(multisig_address: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(multisig_address: <b>address</b>):bool {
  <a href="MultiSig.md#0x1_MultiSig_is_init">MultiSig::is_init</a>(multisig_address) &&
  <a href="MultiSig.md#0x1_MultiSig_has_action">MultiSig::has_action</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_DonorDirectedProp">DonorDirectedProp</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(multisig_address)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_root_registry"></a>

## Function `get_root_registry`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved)) {
    <b>let</b> s = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
    <b>return</b> *&s.list
  } <b>else</b> {
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_new_timed_transfer_multisig"></a>

## Function `new_timed_transfer_multisig`

As in any MultiSig instance, the transaction which proposes the action (the scheduled transfer) must be signed by an authority on the MultiSig.
The same function is the handler for the approval case of the MultiSig action.
Since Donor Directed accounts are involved with sensitive assets, we have moved the WithdrawCapability to the MultiSig instance. Even though we don't need it for any DiemAccount functions for paying, we use it to ensure no private functions related to assets can be called. Belt and suspenders.
Returns the GUID of the transfer.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_new_timed_transfer_multisig">new_timed_transfer_multisig</a>(sender: &signer, multisig_address: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_new_timed_transfer_multisig">new_timed_transfer_multisig</a>(
  sender: &signer, multisig_address: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> {
  <b>let</b> p = <a href="DonorDirected.md#0x1_DonorDirected_DonorDirectedProp">DonorDirectedProp</a> {
    payee,
    value,
    description: <b>copy</b> description,
  };

  // TODO: get expiration
  <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">MultiSig::proposal_constructor</a>(p, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>());

  <a href="MultiSig.md#0x1_MultiSig_propose_new">MultiSig::propose_new</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_DonorDirectedProp">DonorDirectedProp</a>&gt;(sender, multisig_address, prop)

  // <b>let</b> id_opt = <b>if</b> (passed && <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&withdraw_cap_opt)) {
  //   <b>let</b> id = <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&withdraw_cap_opt), payee, value, description);
  //   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(id)
  // } <b>else</b> {
  //   <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()
  // };

  // <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">MultiSig::maybe_restore_withdraw_cap</a>(sender, multisig_address, withdraw_cap_opt);

  // id_opt


}
</code></pre>



</details>

<a name="0x1_DonorDirected_schedule"></a>

## Function `schedule`

Private function which handles the logic of adding a new timed transfer
DANGER upstream functions need to check the sender is authorized.


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(withdraw_capability: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(
  withdraw_capability: &WithdrawCapability, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> {

  <b>let</b> multisig_address = <a href="DiemAccount.md#0x1_DiemAccount_get_withdraw_cap_address">DiemAccount::get_withdraw_cap_address</a>(withdraw_capability);
  <b>let</b> transfers = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(multisig_address);
  <b>let</b> uid = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_with_capability">GUID::create_with_capability</a>(multisig_address, &transfers.guid_capability);

  // add current epoch + 1
  <b>let</b> current_epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  <b>let</b> t = <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> {
    uid,
    expire_epoch: current_epoch + 7, // pays automativally at the end of seventh epoch. Unless there is a veto by a Donor. In that case a day is added for every day there is a veto. This deduplicates Vetos.
    payee: payee,
    value: value,
    description: description,
    last_veto_epoch: 0,
  };

  <b>let</b> id = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&t.uid);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> transfers.proposed, t);
  <b>return</b> id
}
</code></pre>



</details>

<a name="0x1_DonorDirected_process_donor_directed_accounts"></a>

## Function `process_donor_directed_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_donor_directed_accounts">process_donor_directed_accounts</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_donor_directed_accounts">process_donor_directed_accounts</a>(
  vm: &signer,
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>, <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {

  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>();

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list)) {
    <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>if</b> (<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(*multisig_address)) {
      <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(*multisig_address);
      <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_if_deadline_today">maybe_pay_if_deadline_today</a>(vm, state);
    };
    i = i + 1;
  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_maybe_pay_if_deadline_today"></a>

## Function `maybe_pay_if_deadline_today`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_if_deadline_today">maybe_pay_if_deadline_today</a>(vm: &signer, state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_DonorDirected">DonorDirected::DonorDirected</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_if_deadline_today">maybe_pay_if_deadline_today</a>(vm: &signer, state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&state.proposed)) {

    <b>let</b> this_exp = *&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&state.proposed, i).expire_epoch;
    <b>if</b> (this_exp == epoch) {
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> state.proposed, i);

      <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_creator_address">GUID::creator_address</a>(&t.uid);
      <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">DiemAccount::vm_make_payment_no_limit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(multisig_address, t.payee, t.value, *&t.description, b"", vm);

      // <b>update</b> the records
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.approved, t);

      // <b>if</b> theres a single transaction that gets approved, then the <b>freeze</b> consecutive rejection counter is reset
      <a href="DonorDirected.md#0x1_DonorDirected_reset_rejection_counter">reset_rejection_counter</a>(vm, multisig_address)
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_veto_handler"></a>

## Function `veto_handler`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_handler">veto_handler</a>(sender: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_handler">veto_handler</a>(
  sender: &signer,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(uid);
  // <b>let</b> id_from_guid = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(multisig_address, uid);
  <b>let</b> veto_approved = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">DonorDirectedGovernance::veto_by_id</a>(sender, uid);

  <b>if</b> (veto_approved) {
    // <b>if</b> the veto passes, <b>freeze</b> the account
    <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid);

    <a href="DonorDirected.md#0x1_DonorDirected_maybe_freeze">maybe_freeze</a>(multisig_address);
  } <b>else</b> {
    // per the <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a> policy we need <b>to</b> slow
    // down the payments further <b>if</b> there are rejections.
    // Add another day for each veto
    <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(multisig_address);
    <b>let</b> tx_mut = <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state, uid);
    <b>if</b> (tx_mut.last_veto_epoch &lt; <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>()) {
      tx_mut.expire_epoch = tx_mut.expire_epoch + 1;

      // check that the expiration of the payment
      // is the same <b>as</b> the end of the veto ballot
      // This is because the ballot expiration can be
      // extended based on the threshold of votes.
      <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration">DonorDirectedGovernance::sync_ballot_and_tx_expiration</a>(sender, uid, tx_mut.expire_epoch)
    }

  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_reject"></a>

## Function `reject`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(uid);
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>&gt;(multisig_address);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&c.proposed);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&c.proposed, i);
    <b>if</b> (&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&t.uid) == uid) {
      // remove from proposed list
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.proposed, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.rejected, t);
      // increment consecutive rejections counter
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address);
      f.consecutive_rejections = f.consecutive_rejections + 1;

    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_reset_rejection_counter"></a>

## Function `reset_rejection_counter`

If there are approved transactions, then the consectutive rejection counter is reset.


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

<a name="0x1_DonorDirected_maybe_freeze"></a>

## Function `maybe_freeze`

DonorDirected wallets get frozen if 3 consecutive attempts to transfer are rejected.


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

<a name="0x1_DonorDirected_get_tx_params"></a>

## Function `get_tx_params`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_params">get_tx_params</a>(t: &<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>): (<b>address</b>, u64, vector&lt;u8&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_tx_params">get_tx_params</a>(t: &<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>): (<b>address</b>, u64, vector&lt;u8&gt;, u64) {
  (t.payee, t.value, *&t.description, t.expire_epoch)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_pending_timed_transfer_mut"></a>

## Function `get_pending_timed_transfer_mut`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_DonorDirected">DonorDirected::DonorDirected</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> {
  <b>let</b> (found, i) = <a href="DonorDirected.md#0x1_DonorDirected_get_index_of_pending">get_index_of_pending</a>(state, uid);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID">ENO_PEDNING_TRANSACTION_AT_UID</a>));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> state.proposed, i)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_index_of_pending"></a>

## Function `get_index_of_pending`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_index_of_pending">get_index_of_pending</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected_DonorDirected">DonorDirected::DonorDirected</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_index_of_pending">get_index_of_pending</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected">DonorDirected</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64) {
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&state.proposed);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&state.proposed, i);
    <b>if</b> (&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&t.uid) == uid) {
      <b>return</b> (<b>true</b>, i)
    };

    i = i + 1;
  };
  (<b>false</b>, 0)
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

<a name="0x1_DonorDirected_init_donor_directed"></a>

## Function `init_donor_directed`

Initialize the DonorDirected wallet with Three Signers


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_donor_directed">init_donor_directed</a>(sig: signer, signer_one: <b>address</b>, signer_two: <b>address</b>, signer_three: <b>address</b>, cfg_n_signers: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_donor_directed">init_donor_directed</a>(sig: signer, signer_one: <b>address</b>, signer_two: <b>address</b>, signer_three: <b>address</b>, cfg_n_signers: u64) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <b>let</b> init_signers = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(signer_one);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_two);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_three);

  <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(&sig);
  <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(&sig, cfg_n_signers, init_signers);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_finalize_init"></a>

## Function `finalize_init`

the sponsor must finalize the initialization, this is a separate step so that the user can optionally check everything is in order before bricking the account key.


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_finalize_init">finalize_init</a>(sponsor: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_finalize_init">finalize_init</a>(sponsor: signer) {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&sponsor);
  <b>assert</b>!(<a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>));
  <a href="MultiSig.md#0x1_MultiSig_finalize_and_brick">MultiSig::finalize_and_brick</a>(&sponsor);
}
</code></pre>



</details>
