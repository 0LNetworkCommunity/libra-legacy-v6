
<a name="0x1_DonorDirected"></a>

# Module `0x1::DonorDirected`

Donor directed wallets is a service of the chain.
Any address can voluntarily turn their account into a donor directed account.
The DonorDirected payment workflow is:
Managers use a MultiSig to schedule ->
Once scheduled the Donors use a TurnoutTally to Veto ->
Epoch boundary: transaction executes when the VM reads the Schedule struct at the epoch boundary, and issues payment.
By creating a TxSchedule wallet you are providing certain restrictions and guarantees to the users that interact with this wallet.
1. The wallet's contents is propoperty of the owner. The owner is free to issue transactions which change the state of the wallet, including transferring funds. There are however time, and veto policies.
2. All transfers out of the account are timed. Meaning, they will execute automatically after a set period of time passes. The VM address triggers these events at each epoch boundary. The purpose of the delayed transfers is that the transaction can be paused for analysis, and eventually rejected by the donors of the wallet.
3. Every pending transaction can be "vetoed". The vetos delay the finalizing of the transaction, to allow more time for analysis. Each veto adds one day/epoch to the transaction PER DAY THAT A VETO OCCURRS. That is, two vetos happening in the same day, only extend the vote by one day. If a sufficient number of Donors vote on the Veto, then the transaction will be rejected. Since TxSchedule has an expiration time, as does ParticipationVote, each time there is a veto, the deadlines for both are syncronized, based on the new TxSchedule expiration time.
4. After three consecutive transaction rejections, the account will become frozen. The funds remain in the account but no operations are available until the Donors, un-freeze the account.
5. Voting for all purposes are done on a pro-rata basis according to the amounts donated. Voting using ParticipationVote method, which in short, biases the threshold based on the turnout of the vote. TL;DR a low turnout of 12.5% would require 100% of the voters to veto, and lower thresholds for higher turnouts until 51%.
6. The donors can vote to liquidate a frozen TxSchedule account. The result will depend on the configuration of the TxSchedule account from when it was initialized: the funds by default return to the end user who was the donor.
7. Third party contracts can wrap the Donor Directed wallet. The outcomes of the votes can be returned to a handler in a third party contract For example, liquidiation of a frozen account is programmable: a handler can be coded to determine the outcome of the donor directed wallet. See in CommunityWallets the funds return to the InfrastructureEscrow side-account of the user.


-  [Resource `Registry`](#0x1_DonorDirected_Registry)
-  [Resource `TxSchedule`](#0x1_DonorDirected_TxSchedule)
-  [Struct `Payment`](#0x1_DonorDirected_Payment)
-  [Struct `TimedTransfer`](#0x1_DonorDirected_TimedTransfer)
-  [Resource `Freeze`](#0x1_DonorDirected_Freeze)
-  [Resource `Donors`](#0x1_DonorDirected_Donors)
-  [Constants](#@Constants_0)
-  [Function `init_root_registry`](#0x1_DonorDirected_init_root_registry)
-  [Function `is_root_init`](#0x1_DonorDirected_is_root_init)
-  [Function `migrate_root_registry`](#0x1_DonorDirected_migrate_root_registry)
-  [Function `set_donor_directed`](#0x1_DonorDirected_set_donor_directed)
-  [Function `add_to_registry`](#0x1_DonorDirected_add_to_registry)
-  [Function `make_multisig`](#0x1_DonorDirected_make_multisig)
-  [Function `is_donor_directed`](#0x1_DonorDirected_is_donor_directed)
-  [Function `get_root_registry`](#0x1_DonorDirected_get_root_registry)
-  [Function `propose_payment`](#0x1_DonorDirected_propose_payment)
-  [Function `schedule`](#0x1_DonorDirected_schedule)
-  [Function `find_schedule_by_id`](#0x1_DonorDirected_find_schedule_by_id)
-  [Function `process_donor_directed_accounts`](#0x1_DonorDirected_process_donor_directed_accounts)
-  [Function `maybe_pay_deadline`](#0x1_DonorDirected_maybe_pay_deadline)
-  [Function `find_by_deadline`](#0x1_DonorDirected_find_by_deadline)
-  [Function `veto_handler`](#0x1_DonorDirected_veto_handler)
-  [Function `reject`](#0x1_DonorDirected_reject)
-  [Function `propose_veto`](#0x1_DonorDirected_propose_veto)
-  [Function `reset_rejection_counter`](#0x1_DonorDirected_reset_rejection_counter)
-  [Function `maybe_freeze`](#0x1_DonorDirected_maybe_freeze)
-  [Function `get_pending_timed_transfer_mut`](#0x1_DonorDirected_get_pending_timed_transfer_mut)
-  [Function `schedule_status`](#0x1_DonorDirected_schedule_status)
-  [Function `propose_liquidation`](#0x1_DonorDirected_propose_liquidation)
-  [Function `liquidation_handler`](#0x1_DonorDirected_liquidation_handler)
-  [Function `get_liquidation_queue`](#0x1_DonorDirected_get_liquidation_queue)
-  [Function `vm_liquidate`](#0x1_DonorDirected_vm_liquidate)
-  [Function `get_tx_params`](#0x1_DonorDirected_get_tx_params)
-  [Function `get_multisig_proposal_state`](#0x1_DonorDirected_get_multisig_proposal_state)
-  [Function `get_schedule_state`](#0x1_DonorDirected_get_schedule_state)
-  [Function `is_scheduled`](#0x1_DonorDirected_is_scheduled)
-  [Function `is_paid`](#0x1_DonorDirected_is_paid)
-  [Function `is_veto`](#0x1_DonorDirected_is_veto)
-  [Function `is_account_frozen`](#0x1_DonorDirected_is_account_frozen)
-  [Function `liquidates_to_escrow`](#0x1_DonorDirected_liquidates_to_escrow)
-  [Function `init_donor_directed`](#0x1_DonorDirected_init_donor_directed)
-  [Function `set_liquidate_to_community_wallets`](#0x1_DonorDirected_set_liquidate_to_community_wallets)
-  [Function `finalize_init`](#0x1_DonorDirected_finalize_init)
-  [Function `propose_payment_tx`](#0x1_DonorDirected_propose_payment_tx)
-  [Function `propose_veto_tx`](#0x1_DonorDirected_propose_veto_tx)
-  [Function `veto_tx`](#0x1_DonorDirected_veto_tx)
-  [Function `propose_liquidate_tx`](#0x1_DonorDirected_propose_liquidate_tx)
-  [Function `vote_liquidation_tx`](#0x1_DonorDirected_vote_liquidation_tx)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance">0x1::DonorDirectedGovernance</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="MultiSig.md#0x1_MultiSig">0x1::MultiSig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
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
<dt>
<code>liquidation_queue: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirected_TxSchedule"></a>

## Resource `TxSchedule`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>scheduled: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>veto: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>paid: vector&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>&gt;</code>
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

<a name="0x1_DonorDirected_Payment"></a>

## Struct `Payment`

This is the basic payment information.
This is used initially in a MultiSig, for the managers
initially to schedule.


<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x1_DonorDirected_TimedTransfer"></a>

## Struct `TimedTransfer`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>uid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>deadline: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tx: <a href="DonorDirected.md#0x1_DonorDirected_Payment">DonorDirected::Payment</a></code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_latest_veto_received: u64</code>
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
<dt>
<code>liquidate_to_community_wallets: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DonorDirected_Donors"></a>

## Resource `Donors`



<pre><code><b>struct</b> <a href="DonorDirected.md#0x1_DonorDirected_Donors">Donors</a> <b>has</b> key
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

<a name="@Constants_0"></a>

## Constants


<a name="0x1_DonorDirected_DEFAULT_PAYMENT_DURATION"></a>

number of epochs to wait before a transaction is executed
Veto can happen in this time
at the end of the third epoch from when multisig gets consensus


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_DEFAULT_PAYMENT_DURATION">DEFAULT_PAYMENT_DURATION</a>: u64 = 3;
</code></pre>



<a name="0x1_DonorDirected_DEFAULT_VETO_DURATION"></a>

minimum amount of time to evaluate when one donor flags for veto.


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_DEFAULT_VETO_DURATION">DEFAULT_VETO_DURATION</a>: u64 = 7;
</code></pre>



<a name="0x1_DonorDirected_EMULTISIG_NOT_INIT"></a>

No enum for this number


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_EMULTISIG_NOT_INIT">EMULTISIG_NOT_INIT</a>: u64 = 231013;
</code></pre>



<a name="0x1_DonorDirected_ENOT_AUTHORIZED_TO_VOTE"></a>

User is not a donor and cannot vote on this account


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENOT_AUTHORIZED_TO_VOTE">ENOT_AUTHORIZED_TO_VOTE</a>: u64 = 231010;
</code></pre>



<a name="0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED"></a>

Not initialized as a donor directed account.


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>: u64 = 231001;
</code></pre>



<a name="0x1_DonorDirected_ENOT_VALID_STATE_ENUM"></a>

No enum for this number


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENOT_VALID_STATE_ENUM">ENOT_VALID_STATE_ENUM</a>: u64 = 231012;
</code></pre>



<a name="0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID"></a>

Could not find a pending transaction by this GUID


<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID">ENO_PEDNING_TRANSACTION_AT_UID</a>: u64 = 231011;
</code></pre>



<a name="0x1_DonorDirected_PAID"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_PAID">PAID</a>: u8 = 3;
</code></pre>



<a name="0x1_DonorDirected_SCHEDULED"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_SCHEDULED">SCHEDULED</a>: u8 = 1;
</code></pre>



<a name="0x1_DonorDirected_VETO"></a>



<pre><code><b>const</b> <a href="DonorDirected.md#0x1_DonorDirected_VETO">VETO</a>: u8 = 2;
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
      list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      liquidation_queue: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
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

<a name="0x1_DonorDirected_migrate_root_registry"></a>

## Function `migrate_root_registry`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_migrate_root_registry">migrate_root_registry</a>(vm: &signer, list: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_migrate_root_registry">migrate_root_registry</a>(vm: &signer, list: vector&lt;<b>address</b>&gt;) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<a href="DonorDirected.md#0x1_DonorDirected_is_root_init">is_root_init</a>()) {
    <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(vm, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
      list,
      liquidation_queue: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    });
  };
}
</code></pre>



</details>

<a name="0x1_DonorDirected_set_donor_directed"></a>

## Function `set_donor_directed`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(sig: &signer, liquidate_to_community_wallets: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(sig: &signer, liquidate_to_community_wallets: bool) {
  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved)) <b>return</b>;

  <b>move_to</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(
    sig,
    <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
      is_frozen: <b>false</b>,
      consecutive_rejections: 0,
      unfreeze_votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
      liquidate_to_community_wallets,
    }
  );

  <b>let</b> guid_capability = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig);
  <b>move_to</b>(sig, <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
      scheduled: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      veto: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      paid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      guid_capability,
    });

  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_init_donor_governance">DonorDirectedGovernance::init_donor_governance</a>(sig);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_add_to_registry"></a>

## Function `add_to_registry`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_add_to_registry">add_to_registry</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_add_to_registry">add_to_registry</a>(sig: &signer) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved)) <b>return</b>;

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>();
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;<b>address</b>&gt;(&list, &addr)) {
    <b>let</b> s = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
  };
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
  <a href="MultiSig.md#0x1_MultiSig_init_type">MultiSig::init_type</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(sponsor, <b>true</b>); // "<b>true</b>": We make this multisig instance hold the WithdrawCapability. Even though we don't need it for any <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> pay functions, we can <b>use</b> it <b>to</b> make sure the entire pipeline of private functions scheduling a payment are authorized. Belt and suspenders.
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
  <a href="MultiSig.md#0x1_MultiSig_has_action">MultiSig::has_action</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address)
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

<a name="0x1_DonorDirected_propose_payment"></a>

## Function `propose_payment`

As in any MultiSig instance, the transaction which proposes the action (the scheduled transfer) must be signed by an authority on the MultiSig.
The same function is the handler for the approval case of the MultiSig action.
Since Donor Directed accounts are involved with sensitive assets, we have moved the WithdrawCapability to the MultiSig instance. Even though we don't need it for any DiemAccount functions for paying, we use it to ensure no private functions related to assets can be called. Belt and suspenders.
Returns the GUID of the transfer.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_payment">propose_payment</a>(sender: &signer, multisig_address: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_payment">propose_payment</a>(
  sender: &signer,
  multisig_address: <b>address</b>,
  payee: <b>address</b>,
  value: u64,
  description: vector&lt;u8&gt;
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> tx = <a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a> {
    payee,
    value,
    description,
  };

  // TODO: get expiration
  <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">MultiSig::proposal_constructor</a>(tx, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>());

  <b>let</b> uid = <a href="MultiSig.md#0x1_MultiSig_propose_new">MultiSig::propose_new</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(sender, multisig_address, prop);

  <b>let</b> (passed, withdraw_cap_opt) = <a href="MultiSig.md#0x1_MultiSig_vote_with_id">MultiSig::vote_with_id</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(sender, &uid, multisig_address);

  <b>let</b> tx = <a href="MultiSig.md#0x1_MultiSig_extract_proposal_data">MultiSig::extract_proposal_data</a>(multisig_address, &uid);

  <b>if</b> (passed && <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&withdraw_cap_opt)) {
    <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&withdraw_cap_opt), tx, &uid);
  };

  <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">MultiSig::maybe_restore_withdraw_cap</a>(sender, multisig_address, withdraw_cap_opt);

  uid

}
</code></pre>



</details>

<a name="0x1_DonorDirected_schedule"></a>

## Function `schedule`

Private function which handles the logic of adding a new timed transfer
DANGER upstream functions need to check the sender is authorized.


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(withdraw_capability: &<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>, tx: <a href="DonorDirected.md#0x1_DonorDirected_Payment">DonorDirected::Payment</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule">schedule</a>(
  withdraw_capability: &WithdrawCapability, tx: <a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {

  <b>let</b> multisig_address = <a href="DiemAccount.md#0x1_DiemAccount_get_withdraw_cap_address">DiemAccount::get_withdraw_cap_address</a>(withdraw_capability);
  <b>let</b> transfers = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);

  <b>let</b> deadline = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + <a href="DonorDirected.md#0x1_DonorDirected_DEFAULT_PAYMENT_DURATION">DEFAULT_PAYMENT_DURATION</a>;

  <b>let</b> t = <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> {
    uid: *uid,
    deadline, // pays automatically at the end of seventh epoch. Unless there is a veto by a Donor. In that case a day is added for every day there is a veto. This deduplicates Vetos.
    tx,
    epoch_latest_veto_received: 0,
  };

  // <b>let</b> id = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id">GUID::id</a>(&t.uid);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> transfers.scheduled, t);
  // <b>return</b> id
}
</code></pre>



</details>

<a name="0x1_DonorDirected_find_schedule_by_id"></a>

## Function `find_schedule_by_id`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find_schedule_by_id">find_schedule_by_id</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">DonorDirected::TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find_schedule_by_id">find_schedule_by_id</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8) { // (is_found, index, state)
  <b>let</b> (found, i) = <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state, uid, <a href="DonorDirected.md#0x1_DonorDirected_SCHEDULED">SCHEDULED</a>);
  <b>if</b> (found) <b>return</b> (found, i, <a href="DonorDirected.md#0x1_DonorDirected_SCHEDULED">SCHEDULED</a>);

  <b>let</b> (found, i) = <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state, uid, <a href="DonorDirected.md#0x1_DonorDirected_VETO">VETO</a>);
  <b>if</b> (found) <b>return</b> (found, i, <a href="DonorDirected.md#0x1_DonorDirected_VETO">VETO</a>);

  <b>let</b> (found, i) = <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state, uid, <a href="DonorDirected.md#0x1_DonorDirected_PAID">PAID</a>);
  <b>if</b> (found) <b>return</b> (found, i, <a href="DonorDirected.md#0x1_DonorDirected_PAID">PAID</a>);

  (<b>false</b>, 0, 0)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_process_donor_directed_accounts"></a>

## Function `process_donor_directed_accounts`

The VM on epoch boundaries will execute the payments without the users
needing to intervene.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_donor_directed_accounts">process_donor_directed_accounts</a>(vm: &signer, epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_process_donor_directed_accounts">process_donor_directed_accounts</a>(
  vm: &signer,
  epoch: u64,
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>, <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  // <b>while</b> we are here <b>let</b>'s liquidate any expired accounts.
  <a href="DonorDirected.md#0x1_DonorDirected_vm_liquidate">vm_liquidate</a>(vm);

  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">get_root_registry</a>();

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list)) {
    <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>if</b> (<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(*multisig_address)) {
      <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(*multisig_address);
      <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_deadline">maybe_pay_deadline</a>(vm, state, epoch);
    };
    i = i + 1;
  }
}
</code></pre>



</details>

<a name="0x1_DonorDirected_maybe_pay_deadline"></a>

## Function `maybe_pay_deadline`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_deadline">maybe_pay_deadline</a>(vm: &signer, state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">DonorDirected::TxSchedule</a>, epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_maybe_pay_deadline">maybe_pay_deadline</a>(vm: &signer, state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, epoch: u64) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  // <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  <b>let</b> i = 0;

  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&state.scheduled)) {

    <b>let</b> this_exp = *&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&state.scheduled, i).deadline;
    <b>if</b> (this_exp == epoch) {
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> state.scheduled, i);
      <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(&t.uid);

      // Note the VM can do this without the WithdrawCapability
      <b>let</b> coin = <a href="DiemAccount.md#0x1_DiemAccount_vm_withdraw">DiemAccount::vm_withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, multisig_address, t.tx.value);
      <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, multisig_address, t.tx.payee, coin, *&t.tx.description, b"");


      // <b>update</b> the records
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> state.paid, t);

      // <b>if</b> theres a single transaction that gets approved, then the <b>freeze</b> consecutive rejection counter is reset
      <a href="DonorDirected.md#0x1_DonorDirected_reset_rejection_counter">reset_rejection_counter</a>(vm, multisig_address)
    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_find_by_deadline"></a>

## Function `find_by_deadline`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find_by_deadline">find_by_deadline</a>(multisig_address: <b>address</b>, epoch: u64): vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_find_by_deadline">find_by_deadline</a>(multisig_address: <b>address</b>, epoch: u64): vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);
  <b>let</b> i = 0;
  <b>let</b> list = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>&gt;();

  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&state.scheduled)) {

    <b>let</b> prop = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&state.scheduled, i);
    <b>if</b> (prop.deadline == epoch) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> list, *&prop.uid);
    };

    i = i + 1;
  };

  list
}
</code></pre>



</details>

<a name="0x1_DonorDirected_veto_handler"></a>

## Function `veto_handler`



<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_handler">veto_handler</a>(sender: &signer, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_handler">veto_handler</a>(
  sender: &signer,
  uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>,
) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(uid);
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">DonorDirectedGovernance::assert_authorized</a>(sender, multisig_address);

  <b>let</b> veto_is_approved = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_veto_by_id">DonorDirectedGovernance::veto_by_id</a>(sender, uid);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(&veto_is_approved)) <b>return</b>;

  <b>if</b> (*<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&veto_is_approved)) {
    // <b>if</b> the veto passes, <b>freeze</b> the account
    <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid);

    <a href="DonorDirected.md#0x1_DonorDirected_maybe_freeze">maybe_freeze</a>(multisig_address);
  } <b>else</b> {
    // per the <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> policy we need <b>to</b> slow
    // down the payments further <b>if</b> there are rejections.
    // Add another day for each veto
    <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);
    <b>let</b> tx_mut = <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state, uid);
    <b>if</b> (tx_mut.epoch_latest_veto_received &lt; <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>()) {
      tx_mut.deadline = tx_mut.deadline + 1;

      // check that the expiration of the payment
      // is the same <b>as</b> the end of the veto ballot
      // This is because the ballot expiration can be
      // extended based on the threshold of votes.
      <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_sync_ballot_and_tx_expiration">DonorDirectedGovernance::sync_ballot_and_tx_expiration</a>(sender, uid, tx_mut.deadline)
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


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_reject">reject</a>(uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(uid);
  <b>let</b> c = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&c.scheduled);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&c.scheduled, i);
    <b>if</b> (&t.uid == uid) {
      // remove from proposed list
      <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> c.scheduled, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> c.veto, t);
      // increment consecutive rejections counter
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address);
      f.consecutive_rejections = f.consecutive_rejections + 1;

    };

    i = i + 1;
  };

}
</code></pre>



</details>

<a name="0x1_DonorDirected_propose_veto"></a>

## Function `propose_veto`

propose and vote on the veto of a specific transacation


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_veto">propose_veto</a>(donor: &signer, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_veto">propose_veto</a>(donor: &signer, guid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_id_creator_address">GUID::id_creator_address</a>(guid);
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">DonorDirectedGovernance::assert_authorized</a>(donor, multisig_address);
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);
  <b>let</b> epochs_duration = <a href="DonorDirected.md#0x1_DonorDirected_DEFAULT_VETO_DURATION">DEFAULT_VETO_DURATION</a>;
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_veto">DonorDirectedGovernance::propose_veto</a>(&state.guid_capability, guid,  epochs_duration);
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

TxSchedule wallets get frozen if 3 consecutive attempts to transfer are rejected.


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

<a name="0x1_DonorDirected_get_pending_timed_transfer_mut"></a>

## Function `get_pending_timed_transfer_mut`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">DonorDirected::TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">DonorDirected::TimedTransfer</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_pending_timed_transfer_mut">get_pending_timed_transfer_mut</a>(state: &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): &<b>mut</b> <a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a> {
  <b>let</b> (found, i) = <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state, uid, <a href="DonorDirected.md#0x1_DonorDirected_SCHEDULED">SCHEDULED</a>);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENO_PEDNING_TRANSACTION_AT_UID">ENO_PEDNING_TRANSACTION_AT_UID</a>));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(&<b>mut</b> state.scheduled, i)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_schedule_status"></a>

## Function `schedule_status`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">DonorDirected::TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, state_enum: u8): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_schedule_status">schedule_status</a>(state: &<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, state_enum: u8): (bool, u64) {
  <b>let</b> list = <b>if</b> (state_enum == <a href="DonorDirected.md#0x1_DonorDirected_SCHEDULED">SCHEDULED</a>) { &state.scheduled }
  <b>else</b> <b>if</b> (state_enum == <a href="DonorDirected.md#0x1_DonorDirected_VETO">VETO</a>) { &state.veto }
  <b>else</b> <b>if</b> (state_enum == <a href="DonorDirected.md#0x1_DonorDirected_PAID">PAID</a>) { &state.paid }
  <b>else</b> {
    <b>assert</b>!(<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENOT_VALID_STATE_ENUM">ENOT_VALID_STATE_ENUM</a>));
    &state.scheduled  // dummy
  };

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> t = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TimedTransfer">TimedTransfer</a>&gt;(list, i);
    <b>if</b> (&t.uid == uid) {
      <b>return</b> (<b>true</b>, i)
    };

    i = i + 1;
  };
  (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_propose_liquidation"></a>

## Function `propose_liquidation`

propose and vote on the liquidation of this wallet


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_liquidation">propose_liquidation</a>(donor: &signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_liquidation">propose_liquidation</a>(donor: &signer, multisig_address: <b>address</b>)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">DonorDirectedGovernance::assert_authorized</a>(donor, multisig_address);
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address);
  <b>let</b> epochs_duration = 365; // liquidation vote can take a whole year
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_propose_liquidate">DonorDirectedGovernance::propose_liquidate</a>(&state.guid_capability, epochs_duration);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_liquidation_handler"></a>

## Function `liquidation_handler`

Once a liquidation has been proposed, other donors can vote on it.


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_liquidation_handler">liquidation_handler</a>(donor: &signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_liquidation_handler">liquidation_handler</a>(donor: &signer, multisig_address: <b>address</b>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_assert_authorized">DonorDirectedGovernance::assert_authorized</a>(donor, multisig_address);
  <b>let</b> res = <a href="DonorDirectedGovernance.md#0x1_DonorDirectedGovernance_vote_liquidation">DonorDirectedGovernance::vote_liquidation</a>(donor, multisig_address);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&res)) {
    <b>if</b> (*<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&res)) {
      // The VM will call this function <b>to</b> liquidate the wallet.
      // the donors cannot do this because they cant get the withdrawal capability
      // from the multisig account.

      // first we <b>freeze</b> it so nothing can happen in the interim.
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address);
      f.is_frozen = <b>true</b>;
      <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> f.liquidation_queue, multisig_address);
  }
}
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_liquidation_queue"></a>

## Function `get_liquidation_queue`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_liquidation_queue">get_liquidation_queue</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_liquidation_queue">get_liquidation_queue</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>{
  <b>let</b> f = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
  *&f.liquidation_queue
}
</code></pre>



</details>

<a name="0x1_DonorDirected_vm_liquidate"></a>

## Function `vm_liquidate`

The VM will call this function to liquidate all donor directed
wallets in the queue.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_vm_liquidate">vm_liquidate</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_vm_liquidate">vm_liquidate</a>(vm: &signer) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
   <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
   <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a>&gt;(@VMReserved);
   <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&f.liquidation_queue);

   <b>let</b> i = 0;
   <b>while</b> (i &lt; len) {
     <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> f.liquidation_queue, i);

     // <b>if</b> this account was tagged a community wallet, then the
     // funds get split pro-rata at the current split of the
     // burn recycle algorithm.
     // Easiest way <b>to</b> do this is <b>to</b> send it <b>to</b> transaction fee account
     // so it can be split up by the burn recycle algorithm.
     // and trying <b>to</b> call <a href="Burn.md#0x1_Burn">Burn</a>, here will create a circular dependency.

     <b>if</b> (<a href="DonorDirected.md#0x1_DonorDirected_liquidates_to_escrow">liquidates_to_escrow</a>(multisig_address)) {
       <b>let</b> balance = <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(multisig_address);
       <b>let</b> c = <a href="DiemAccount.md#0x1_DiemAccount_vm_withdraw">DiemAccount::vm_withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, multisig_address, balance);
       <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">TransactionFee::pay_fee</a>(c);

       <b>return</b>
     };


     // otherwise the default case is that donors get their funds back.
     <b>let</b> (pro_rata_addresses, _, pro_rata_amounts) = <a href="DiemAccount.md#0x1_DiemAccount_get_pro_rata_cumu_deposits">DiemAccount::get_pro_rata_cumu_deposits</a>(multisig_address);
     <b>let</b> k = 0;
     <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pro_rata_addresses);
     // then we split the funds and send it back <b>to</b> the user's wallet
     <b>while</b> (k &lt; len) {
         <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pro_rata_addresses, k);
         <b>let</b> amount = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pro_rata_amounts, k);
         <a href="DiemAccount.md#0x1_DiemAccount_vm_make_payment_no_limit">DiemAccount::vm_make_payment_no_limit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(multisig_address, *addr, *amount, b"liquidation", b"", vm);

         k = k + 1;
     };
     i = i + 1;
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
  (t.tx.payee, t.tx.value, *&t.tx.description, t.deadline)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_multisig_proposal_state"></a>

## Function `get_multisig_proposal_state`

Check the status of proposals in the MultiSig Workflow
NOTE: These are payments that have not yet been scheduled.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_multisig_proposal_state">get_multisig_proposal_state</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_multisig_proposal_state">get_multisig_proposal_state</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool) { // (is_found, index, state)

  <a href="MultiSig.md#0x1_MultiSig_get_proposal_status_by_id">MultiSig::get_proposal_status_by_id</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(directed_address, uid)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_get_schedule_state"></a>

## Function `get_schedule_state`

Get the status of a SCHEDULED payment which as already passed the multisig stage.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_schedule_state">get_schedule_state</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_get_schedule_state">get_schedule_state</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> { // (is_found, index, state)
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(directed_address);
  <a href="DonorDirected.md#0x1_DonorDirected_find_schedule_by_id">find_schedule_by_id</a>(state, uid)
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_scheduled"></a>

## Function `is_scheduled`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_scheduled">is_scheduled</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_scheduled">is_scheduled</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> (_, _, state) = <a href="DonorDirected.md#0x1_DonorDirected_get_schedule_state">get_schedule_state</a>(directed_address, uid);
  state == <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>()
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_paid"></a>

## Function `is_paid`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_paid">is_paid</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_paid">is_paid</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> (_, _, state) = <a href="DonorDirected.md#0x1_DonorDirected_get_schedule_state">get_schedule_state</a>(directed_address, uid);
  state == <a href="Ballot.md#0x1_Ballot_get_approved_enum">Ballot::get_approved_enum</a>()
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_veto"></a>

## Function `is_veto`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_veto">is_veto</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_veto">is_veto</a>(directed_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> (_, _, state) = <a href="DonorDirected.md#0x1_DonorDirected_get_schedule_state">get_schedule_state</a>(directed_address, uid);
  state == <a href="Ballot.md#0x1_Ballot_get_rejected_enum">Ballot::get_rejected_enum</a>()
}
</code></pre>



</details>

<a name="0x1_DonorDirected_is_account_frozen"></a>

## Function `is_account_frozen`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_account_frozen">is_account_frozen</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_is_account_frozen">is_account_frozen</a>(addr: <b>address</b>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>{
  <b>let</b> f = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(addr);
  f.is_frozen
}
</code></pre>



</details>

<a name="0x1_DonorDirected_liquidates_to_escrow"></a>

## Function `liquidates_to_escrow`



<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_liquidates_to_escrow">liquidates_to_escrow</a>(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_liquidates_to_escrow">liquidates_to_escrow</a>(addr: <b>address</b>): bool <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>{
  <b>let</b> f = <b>borrow_global</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(addr);
  f.liquidate_to_community_wallets
}
</code></pre>



</details>

<a name="0x1_DonorDirected_init_donor_directed"></a>

## Function `init_donor_directed`

Initialize the TxSchedule wallet with Three Signers


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_donor_directed">init_donor_directed</a>(sponsor: &signer, signer_one: <b>address</b>, signer_two: <b>address</b>, signer_three: <b>address</b>, cfg_n_signers: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_init_donor_directed">init_donor_directed</a>(sponsor: &signer, signer_one: <b>address</b>, signer_two: <b>address</b>, signer_three: <b>address</b>, cfg_n_signers: u64) {
  <b>let</b> init_signers = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(signer_one);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_two);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> init_signers, signer_three);

  // we are setting liquidation <b>to</b> infra escrow <b>as</b> <b>false</b> by default
  // the user can send another transacton <b>to</b> change this.
  <b>let</b> liquidate_to_community_wallets = <b>false</b>;
  <a href="DonorDirected.md#0x1_DonorDirected_set_donor_directed">set_donor_directed</a>(sponsor, liquidate_to_community_wallets);
  <a href="DonorDirected.md#0x1_DonorDirected_make_multisig">make_multisig</a>(sponsor, cfg_n_signers, init_signers);

  // <b>if</b> not tracking cumulative donations, then don't <b>use</b> previous balance.
  // start again.
  <a href="DiemAccount.md#0x1_DiemAccount_init_cumulative_deposits">DiemAccount::init_cumulative_deposits</a>(sponsor, <b>false</b>);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_set_liquidate_to_community_wallets"></a>

## Function `set_liquidate_to_community_wallets`

option to set the liquidation destination to infrastructure escrow
must be done before the multisig is finalized and the sponsor cannot control the account.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_liquidate_to_community_wallets">set_liquidate_to_community_wallets</a>(sponsor: &signer, liquidate_to_community_wallets: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_set_liquidate_to_community_wallets">set_liquidate_to_community_wallets</a>(sponsor: &signer, liquidate_to_community_wallets: bool) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> f = <b>borrow_global_mut</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sponsor));
  f.liquidate_to_community_wallets = liquidate_to_community_wallets;
}
</code></pre>



</details>

<a name="0x1_DonorDirected_finalize_init"></a>

## Function `finalize_init`

the sponsor must finalize the initialization, this is a separate step so that the user can optionally check everything is in order before bricking the account key.


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_finalize_init">finalize_init</a>(sponsor: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_finalize_init">finalize_init</a>(sponsor: &signer) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sponsor);
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_init">MultiSig::is_init</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_EMULTISIG_NOT_INIT">EMULTISIG_NOT_INIT</a>));

  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_has_action">MultiSig::has_action</a>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Payment">Payment</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_EMULTISIG_NOT_INIT">EMULTISIG_NOT_INIT</a>));

  <b>assert</b>!(<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>));

  <b>assert</b>!(<b>exists</b>&lt;<a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>));

  <a href="MultiSig.md#0x1_MultiSig_finalize_and_brick">MultiSig::finalize_and_brick</a>(sponsor);
  <b>assert</b>!(<a href="DonorDirected.md#0x1_DonorDirected_is_donor_directed">is_donor_directed</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="DonorDirected.md#0x1_DonorDirected_ENOT_INIT_DONOR_DIRECTED">ENOT_INIT_DONOR_DIRECTED</a>));

  // only add <b>to</b> registry <b>if</b> INIT is successful.
  <a href="DonorDirected.md#0x1_DonorDirected_add_to_registry">add_to_registry</a>(sponsor);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_propose_payment_tx"></a>

## Function `propose_payment_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_payment_tx">propose_payment_tx</a>(auth: signer, multisig_address: <b>address</b>, payee: <b>address</b>, value: u64, description: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_payment_tx">propose_payment_tx</a>(
  auth: signer,
  multisig_address: <b>address</b>,
  payee: <b>address</b>,
  value: u64,
  description: vector&lt;u8&gt;
)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <a href="DonorDirected.md#0x1_DonorDirected_propose_payment">propose_payment</a>(&auth, multisig_address, payee, value, description);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_propose_veto_tx"></a>

## Function `propose_veto_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_veto_tx">propose_veto_tx</a>(donor: signer, multisig_address: <b>address</b>, id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_veto_tx">propose_veto_tx</a>(donor: signer, multisig_address: <b>address</b>, id: u64)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <b>let</b> guid = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(multisig_address, id);
  <a href="DonorDirected.md#0x1_DonorDirected_propose_veto">propose_veto</a>(&donor, &guid);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_veto_tx"></a>

## Function `veto_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_tx">veto_tx</a>(donor: signer, multisig_address: <b>address</b>, id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_veto_tx">veto_tx</a>(donor: signer, multisig_address: <b>address</b>, id: u64)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a>, <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a> {
  <b>let</b> guid = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(multisig_address, id);
  <a href="DonorDirected.md#0x1_DonorDirected_veto_handler">veto_handler</a>(&donor, &guid);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_propose_liquidate_tx"></a>

## Function `propose_liquidate_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_liquidate_tx">propose_liquidate_tx</a>(donor: signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_propose_liquidate_tx">propose_liquidate_tx</a>(donor: signer, multisig_address: <b>address</b>)  <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_TxSchedule">TxSchedule</a> {
  <a href="DonorDirected.md#0x1_DonorDirected_propose_liquidation">propose_liquidation</a>(&donor, multisig_address);
}
</code></pre>



</details>

<a name="0x1_DonorDirected_vote_liquidation_tx"></a>

## Function `vote_liquidation_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_vote_liquidation_tx">vote_liquidation_tx</a>(donor: signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="DonorDirected.md#0x1_DonorDirected_vote_liquidation_tx">vote_liquidation_tx</a>(donor: signer, multisig_address: <b>address</b>) <b>acquires</b> <a href="DonorDirected.md#0x1_DonorDirected_Freeze">Freeze</a>, <a href="DonorDirected.md#0x1_DonorDirected_Registry">Registry</a> {
  <a href="DonorDirected.md#0x1_DonorDirected_liquidation_handler">liquidation_handler</a>(&donor, multisig_address);
}
</code></pre>



</details>
