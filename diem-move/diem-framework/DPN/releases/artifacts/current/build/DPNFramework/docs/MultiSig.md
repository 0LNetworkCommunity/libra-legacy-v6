
<a name="0x1_MultiSig"></a>

# Module `0x1::MultiSig`



-  [Resource `MultiSig`](#0x1_MultiSig_MultiSig)
-  [Resource `Action`](#0x1_MultiSig_Action)
-  [Resource `Proposal`](#0x1_MultiSig_Proposal)
-  [Resource `PropGovSigners`](#0x1_MultiSig_PropGovSigners)
-  [Constants](#@Constants_0)
-  [Function `assert_authorized`](#0x1_MultiSig_assert_authorized)
-  [Function `init_gov`](#0x1_MultiSig_init_gov)
-  [Function `is_init`](#0x1_MultiSig_is_init)
-  [Function `has_action`](#0x1_MultiSig_has_action)
-  [Function `init_type`](#0x1_MultiSig_init_type)
-  [Function `maybe_extract_withdraw_cap`](#0x1_MultiSig_maybe_extract_withdraw_cap)
-  [Function `maybe_restore_withdraw_cap`](#0x1_MultiSig_maybe_restore_withdraw_cap)
-  [Function `finalize_and_brick`](#0x1_MultiSig_finalize_and_brick)
-  [Function `is_finalized`](#0x1_MultiSig_is_finalized)
-  [Function `propose`](#0x1_MultiSig_propose)
-  [Function `vote`](#0x1_MultiSig_vote)
-  [Function `tally`](#0x1_MultiSig_tally)
-  [Function `lazy_cleanup_expired`](#0x1_MultiSig_lazy_cleanup_expired)
-  [Function `get_expired`](#0x1_MultiSig_get_expired)
-  [Function `check_expired`](#0x1_MultiSig_check_expired)
-  [Function `find_index_of_pending`](#0x1_MultiSig_find_index_of_pending)
-  [Function `find_by_id`](#0x1_MultiSig_find_by_id)
-  [Function `get_proposal`](#0x1_MultiSig_get_proposal)
-  [Function `is_authority`](#0x1_MultiSig_is_authority)
-  [Function `propose_governance`](#0x1_MultiSig_propose_governance)
-  [Function `maybe_update_authorities`](#0x1_MultiSig_maybe_update_authorities)
-  [Function `maybe_update_threshold`](#0x1_MultiSig_maybe_update_threshold)
-  [Function `get_authorities`](#0x1_MultiSig_get_authorities)
-  [Function `get_n_of_m_cfg`](#0x1_MultiSig_get_n_of_m_cfg)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MultiSig_MultiSig"></a>

## Resource `MultiSig`

A MultiSig account is an account which requires multiple votes from Authorities to  send a transaction.
A multisig can be used to get agreement on different types of Actions, such as a payment transaction where the handler code for the transaction is an a separate contract. See for example MultiSigPayment.
MultiSig struct holds the metadata for all the instances of Actions on this account.
Every action has the same set of authorities and governance.
This is intentional, since privilege escalation can happen if each action has a different set of governance, but access to funds and other state.
If the organization wishes to have Actions with different governance, then a separate Account is necessary.
DANGER
The WithdrawCapability can be used to withdraw funds from the account.
Ordinarily only the signer/owner of this address can use it.
We are bricking the signer, and as such the withdraw capability is now controlled by the MultiSig logic.
Core Devs: This is a major attack vector. The WithdrawCapability should NEVER be returned to a public caller, UNLESS it is within the vote and approve flow.
Note, the WithdrawCApability is moved to this shared structure, and as such the signer of the account is bricked. The signer who was the original owner of this account ("sponsor") can no longer issue transactions to this account, and as such the WithdrawCapability would be inaccessible. So on initialization we extract the WithdrawCapability into the MultiSig governance struct.


<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cfg_duration_epochs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_default_n_sigs: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>signers: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;</code>
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

<a name="0x1_MultiSig_Action"></a>

## Resource `Action`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>can_withdraw: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>pending: vector&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>approved: vector&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>rejected: vector&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSig_Proposal"></a>

## Resource `Proposal`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; <b>has</b> <b>copy</b>, drop, store, key
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
<code>proposal_data: ProposalData</code>
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

<a name="0x1_MultiSig_PropGovSigners"></a>

## Resource `PropGovSigners`

Tis is a ProposalData type for governance. This Proposal adds or removes a list of addresses as authorities. The handlers are located in this contract.


<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> <b>has</b> <b>copy</b>, drop, store, key
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
<code>n_of_m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE"></a>

default setting for a proposal to expire


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>: u64 = 14;
</code></pre>



<a name="0x1_MultiSig_EACTION_ALREADY_EXISTS"></a>

Already registered thie action type


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EACTION_ALREADY_EXISTS">EACTION_ALREADY_EXISTS</a>: u64 = 440006;
</code></pre>



<a name="0x1_MultiSig_EACTION_NOT_FOUND"></a>

Action not found


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EACTION_NOT_FOUND">EACTION_NOT_FOUND</a>: u64 = 440007;
</code></pre>



<a name="0x1_MultiSig_EGOV_NOT_INITIALIZED"></a>



<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EGOV_NOT_INITIALIZED">EGOV_NOT_INITIALIZED</a>: u64 = 440000;
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



<a name="0x1_MultiSig_EPROPOSAL_EXPIRED"></a>

Proposal is expired


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EPROPOSAL_EXPIRED">EPROPOSAL_EXPIRED</a>: u64 = 440008;
</code></pre>



<a name="0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY"></a>

The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY">ESIGNER_CANT_BE_AUTHORITY</a>: u64 = 440001;
</code></pre>



<a name="0x1_MultiSig_assert_authorized"></a>

## Function `assert_authorized`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig: &signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig: &signer, multisig_address: <b>address</b>) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
      // cannot start manipulating contract until it is finalized
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK">ENOT_FINALIZED_NOT_BRICK</a>));

  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

  // check sender is authorized
  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>(multisig_address, sender_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));
}
</code></pre>



</details>

<a name="0x1_MultiSig_init_gov"></a>

## Function `init_gov`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_gov">init_gov</a>(sig: &signer, cfg_default_n_sigs: u64, m_seed_authorities: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_gov">init_gov</a>(sig: &signer, cfg_default_n_sigs: u64, m_seed_authorities: &vector&lt;<b>address</b>&gt;) {
  <b>assert</b>!(cfg_default_n_sigs &gt; 0, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENO_SIGNERS">ENO_SIGNERS</a>));

  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  // User footgun. The <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">Signer</a> of this account is bricked, and <b>as</b> such the signer can no longer be an authority.
  <b>assert</b>!(!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(m_seed_authorities, &multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY">ESIGNER_CANT_BE_AUTHORITY</a>));
  print(&10002);

  <b>if</b> (!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address)) {
      <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
      cfg_duration_epochs: <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>,
      cfg_default_n_sigs,
      withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(),
      signers: *m_seed_authorities,
      counter: 0,
    });
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address)) {
    <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt; {
      can_withdraw: <b>false</b>,
      pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    });
  }
}
</code></pre>



</details>

<a name="0x1_MultiSig_is_init"></a>

## Function `is_init`

Is the Multisig Governance initialized?


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_init">is_init</a>(multisig_address: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_init">is_init</a>(multisig_address: <b>address</b>): bool {
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address)
}
</code></pre>



</details>

<a name="0x1_MultiSig_has_action"></a>

## Function `has_action`

Has a multisig struct for a given action been created?


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_has_action">has_action</a>&lt;ProposalData: store, key&gt;(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_has_action">has_action</a>&lt;ProposalData: key + store&gt;(addr: <b>address</b>):bool {
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_init_type"></a>

## Function `init_type`

An initial "sponsor" who is the signer of the initialization account calls this function.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;ProposalData: store, key&gt;(sig: &signer, can_withdraw: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;ProposalData: key + store &gt;(
  sig: &signer,
  can_withdraw: bool,
 ) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  // TODO: there is no way of creating a new <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> by multisig. The "signer" would need <b>to</b> be spoofed, which <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> does only in specific and scary situations (e.g. vm_create_account_migration)



  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_init">is_init</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EGOV_NOT_INITIALIZED">EGOV_NOT_INITIALIZED</a>));

  <b>assert</b>!(!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EACTION_ALREADY_EXISTS">EACTION_ALREADY_EXISTS</a>));
  // make sure the signer's <b>address</b> is not in the list of authorities.
  // This account's signer will now be useless.
  print(&10001);



  // maybe the withdraw cap was never extracted in previous set up.
  // but we won't extract it <b>if</b> none of the Actions require it.
  <b>if</b> (can_withdraw) {
    <a href="MultiSig.md#0x1_MultiSig_maybe_extract_withdraw_cap">maybe_extract_withdraw_cap</a>(sig);
  };

  <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt; {
      can_withdraw,
      pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    });
}
</code></pre>



</details>

<a name="0x1_MultiSig_maybe_extract_withdraw_cap"></a>

## Function `maybe_extract_withdraw_cap`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_extract_withdraw_cap">maybe_extract_withdraw_cap</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_extract_withdraw_cap">maybe_extract_withdraw_cap</a>(sig: &signer) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address);
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&ms.withdraw_capability)) {
    <b>return</b>
  } <b>else</b> {
    <b>let</b> cap = <a href="DiemAccount.md#0x1_DiemAccount_extract_withdraw_capability">DiemAccount::extract_withdraw_capability</a>(sig);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> ms.withdraw_capability, cap);
  }
}
</code></pre>



</details>

<a name="0x1_MultiSig_maybe_restore_withdraw_cap"></a>

## Function `maybe_restore_withdraw_cap`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">maybe_restore_withdraw_cap</a>(sig: &signer, multisig_addr: <b>address</b>, w: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">maybe_restore_withdraw_cap</a>(sig: &signer, multisig_addr: <b>address</b>, w: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_addr);
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&w)) {
    <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_addr);
    <b>let</b> cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> w);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> ms.withdraw_capability, cap);
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(w);

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

<a name="0x1_MultiSig_propose"></a>

## Function `propose`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose">propose</a>&lt;ProposalData: <b>copy</b>, drop, store, key&gt;(sig: &signer, multisig_address: <b>address</b>, proposal_data: ProposalData, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose">propose</a>&lt;ProposalData: key + store + <b>copy</b> + drop&gt;(
  sig: &signer,
  multisig_address: <b>address</b>,
  proposal_data: ProposalData,
  duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;
):(bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  print(&20001);
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address);

  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address);
  <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);

  // go through all proposals and clean up expired ones.
  <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>(action);

  <b>let</b> n = *&ms.cfg_default_n_sigs;


  // check <b>if</b> we have this proposal already
  <b>let</b> (found, idx) = <a href="MultiSig.md#0x1_MultiSig_find_index_of_pending">find_index_of_pending</a>&lt;ProposalData&gt;(action, &proposal_data);

  <b>let</b> approved = <b>if</b> (found) {
    print(&20002);

    <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_get_proposal">get_proposal</a>(action, &proposal_data);

    // belt and suspenders, the lazy cleaning should have removed expired proposals.
    // stop here <b>if</b> it's expired, but first <b>move</b> the the ms.rejected list.
    <b>if</b> (<a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>(prop)) {
      <b>let</b> rej = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> action.pending, idx);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> action.rejected, rej);
      <b>return</b> (<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>())
    };

    <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>(prop, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig), n)

  } <b>else</b> {
    // TODO: the single interface for proposing and voting causes a UI issue. Theres a case that a straggler voter will inadvertently start a new proposal <b>if</b> the vote just closed.
    // Though it may be that the thirdparty modules need <b>to</b> check for this themselves when voting.
    print(&20003);

    <b>let</b> dur = <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&duration_epochs)) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&duration_epochs)
    } <b>else</b> {
      &ms.cfg_duration_epochs
    };

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> action.pending, <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
      id: ms.counter,
      proposal_data: proposal_data,
      votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig)),
      approved: <b>false</b>,
      expiration_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + *dur,
    });
    ms.counter = ms.counter + 1;
    <b>false</b>
  };

  print(&20004);
  // <b>let</b> w = <b>borrow_global_mut</b>&lt;Withdraw&gt;(multisig_address);

  <b>if</b> (approved &&
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&ms.withdraw_capability) &&
    action.can_withdraw
  ) {
    print(&20005);
      <b>let</b> cap = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> ms.withdraw_capability);
      print(&20006);

      <b>return</b> (approved, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(cap))
  };
  (approved, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>())
}
</code></pre>



</details>

<a name="0x1_MultiSig_vote"></a>

## Function `vote`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>&lt;ProposalData: drop, store, key&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;, sender_addr: <b>address</b>, n: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote">vote</a>&lt;ProposalData: key + store + drop&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;, sender_addr: <b>address</b>, n: u64): bool {
  print(&30001);
  // should not get here <b>if</b> it is expired. Should have checked before.
  <b>assert</b>!(!<a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>(prop), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="MultiSig.md#0x1_MultiSig_EPROPOSAL_EXPIRED">EPROPOSAL_EXPIRED</a>));

  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&prop.votes, &sender_addr)) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> prop.votes, sender_addr);
    print(&30002);

  };
  <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>(prop, n)
}
</code></pre>



</details>

<a name="0x1_MultiSig_tally"></a>

## Function `tally`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>&lt;ProposalData: drop, store, key&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;, n: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>&lt;ProposalData: key + store + drop&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;, n: u64): bool {
  print(&40001);

  print(&prop.votes);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&prop.votes) &gt;= n) {
    prop.approved = <b>true</b>;
    print(&40002);

    <b>return</b> <b>true</b>
  };

  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_MultiSig_lazy_cleanup_expired"></a>

## Function `lazy_cleanup_expired`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>&lt;ProposalData: store, key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">MultiSig::Action</a>&lt;ProposalData&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>&lt;ProposalData: store + key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;) {
  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&a.pending);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> ex = *&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&a.pending, i).expiration_epoch;
    <b>if</b> (epoch &gt; ex) {
      <b>let</b> rej = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> a.pending, i);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> a.rejected, rej);

    };
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_expired"></a>

## Function `get_expired`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_expired">get_expired</a>&lt;ProposalData: store, key&gt;(multisig_address: <b>address</b>, proposal: &ProposalData): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_expired">get_expired</a>&lt;ProposalData: store + key&gt;(multisig_address: <b>address</b>, proposal: &ProposalData): bool <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="MultiSig.md#0x1_MultiSig_EACTION_NOT_FOUND">EACTION_NOT_FOUND</a>));
  <b>let</b> a = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  <b>let</b> p = <a href="MultiSig.md#0x1_MultiSig_get_proposal">get_proposal</a>(a, proposal);
  <a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>&lt;ProposalData&gt;(p)
}
</code></pre>



</details>

<a name="0x1_MultiSig_check_expired"></a>

## Function `check_expired`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>&lt;ProposalData: store, key&gt;(prop: &<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>&lt;ProposalData: key + store&gt;(prop: &<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;): bool {
  <b>let</b> epoch_now = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  epoch_now &gt; prop.expiration_epoch
}
</code></pre>



</details>

<a name="0x1_MultiSig_find_index_of_pending"></a>

## Function `find_index_of_pending`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_index_of_pending">find_index_of_pending</a>&lt;ProposalData: store, key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">MultiSig::Action</a>&lt;ProposalData&gt;, proposal_data: &ProposalData): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_index_of_pending">find_index_of_pending</a>&lt;ProposalData: store + key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;, proposal_data: &ProposalData): (bool, u64) {

  // find and <b>update</b> existing proposal, or create a new one and add <b>to</b> "pending"
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&a.pending);

  <b>if</b> (len &gt; 0) {
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
      // <b>let</b> prop = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> gov_prop.pending, i);
      <b>let</b> prop = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&a.pending, i);
      <b>if</b> (
        &prop.proposal_data == proposal_data
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

<a name="0x1_MultiSig_find_by_id"></a>

## Function `find_by_id`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_by_id">find_by_id</a>&lt;ProposalData: store, key&gt;(multisig_address: <b>address</b>, id: u64): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_by_id">find_by_id</a>&lt;ProposalData: store + key&gt;(multisig_address: <b>address</b>, id: u64): (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="MultiSig.md#0x1_MultiSig_EACTION_NOT_FOUND">EACTION_NOT_FOUND</a>));
  <b>let</b> a = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&a.pending);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&a.pending, i);
    <b>if</b> (p.id == id) { <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(i), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()) };
    i = i + 1;
  };

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&a.approved);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&a.pending, i);
    <b>if</b> (p.id == id) { <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(i), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()) };
    i = i + 1;
  };

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&a.rejected);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&a.pending, i);
    <b>if</b> (p.id == id) { <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(i)) };
    i = i + 1;
  };

  // is_found, and index of pending, approved, rejected
  (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>())
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_proposal"></a>

## Function `get_proposal`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_proposal">get_proposal</a>&lt;ProposalData: store, key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">MultiSig::Action</a>&lt;ProposalData&gt;, handler: &ProposalData): &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_proposal">get_proposal</a>&lt;ProposalData: store + key&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;, handler: &ProposalData): &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
  <b>let</b> (found, idx) = <a href="MultiSig.md#0x1_MultiSig_find_index_of_pending">find_index_of_pending</a>&lt;ProposalData&gt;(a, handler);
  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EPENDING_EMPTY">EPENDING_EMPTY</a>));
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> a.pending, idx)
}
</code></pre>



</details>

<a name="0x1_MultiSig_is_authority"></a>

## Function `is_authority`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>(multisig_addr: <b>address</b>, addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>(multisig_addr: <b>address</b>, addr: <b>address</b>): bool <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&m.signers, &addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_propose_governance"></a>

## Function `propose_governance`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_governance">propose_governance</a>(sig: &signer, multisig_address: <b>address</b>, addresses: vector&lt;<b>address</b>&gt;, add_remove: bool, n_of_m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_governance">propose_governance</a>(sig: &signer, multisig_address: <b>address</b>, addresses: vector&lt;<b>address</b>&gt;, add_remove: bool, n_of_m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt; )<b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address); // Duplicated <b>with</b> <a href="MultiSig.md#0x1_MultiSig_propose">propose</a>(), belt and suspenders
  <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> {
    addresses,
    add_remove,
    n_of_m,
  };

  <b>let</b> (passed, withdraw_opt) = <a href="MultiSig.md#0x1_MultiSig_propose">propose</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;(sig, multisig_address, <b>copy</b> prop, duration_epochs);


  <b>if</b> (passed) {
    print(&80001);
    <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address);
     <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms, prop.add_remove, *&prop.addresses);
     <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms, &prop.n_of_m);
  };

  <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">maybe_restore_withdraw_cap</a>(sig, multisig_address, withdraw_opt);
}
</code></pre>



</details>

<a name="0x1_MultiSig_maybe_update_authorities"></a>

## Function `maybe_update_authorities`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_MultiSig">MultiSig::MultiSig</a>, add_remove: bool, addresses: vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>, add_remove: bool, addresses: vector&lt;<b>address</b>&gt;) {

      <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&addresses)) {
        // The <b>address</b> field may be empty <b>if</b> the multisif is only changing the threshold
        <b>return</b>
      };

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

<a name="0x1_MultiSig_maybe_update_threshold"></a>

## Function `maybe_update_threshold`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_MultiSig">MultiSig::MultiSig</a>, n_of_m_opt: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a>, n_of_m_opt: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;) {
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(n_of_m_opt)) {
    ms.cfg_default_n_sigs = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(n_of_m_opt);
  };
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_authorities"></a>

## Function `get_authorities`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_authorities">get_authorities</a>(multisig_address: <b>address</b>): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_authorities">get_authorities</a>(multisig_address: <b>address</b>): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address);
  *&m.signers
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_n_of_m_cfg"></a>

## Function `get_n_of_m_cfg`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_n_of_m_cfg">get_n_of_m_cfg</a>(multisig_address: <b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_n_of_m_cfg">get_n_of_m_cfg</a>(multisig_address: <b>address</b>): (u64, u64) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig">MultiSig</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig">MultiSig</a>&gt;(multisig_address);
  (*&m.cfg_default_n_sigs, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&m.signers))
}
</code></pre>



</details>
