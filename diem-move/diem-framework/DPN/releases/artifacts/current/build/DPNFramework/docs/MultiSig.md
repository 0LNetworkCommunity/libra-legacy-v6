
<a name="0x1_MultiSig"></a>

# Module `0x1::MultiSig`



-  [Resource `Governance`](#0x1_MultiSig_Governance)
-  [Resource `Action`](#0x1_MultiSig_Action)
-  [Struct `Proposal`](#0x1_MultiSig_Proposal)
-  [Resource `PropGovSigners`](#0x1_MultiSig_PropGovSigners)
-  [Constants](#@Constants_0)
-  [Function `proposal_constructor`](#0x1_MultiSig_proposal_constructor)
-  [Function `assert_authorized`](#0x1_MultiSig_assert_authorized)
-  [Function `init_gov`](#0x1_MultiSig_init_gov)
-  [Function `is_init`](#0x1_MultiSig_is_init)
-  [Function `has_action`](#0x1_MultiSig_has_action)
-  [Function `init_type`](#0x1_MultiSig_init_type)
-  [Function `maybe_extract_withdraw_cap`](#0x1_MultiSig_maybe_extract_withdraw_cap)
-  [Function `maybe_restore_withdraw_cap`](#0x1_MultiSig_maybe_restore_withdraw_cap)
-  [Function `finalize_and_brick`](#0x1_MultiSig_finalize_and_brick)
-  [Function `is_finalized`](#0x1_MultiSig_is_finalized)
-  [Function `propose_new`](#0x1_MultiSig_propose_new)
-  [Function `vote_with_data`](#0x1_MultiSig_vote_with_data)
-  [Function `vote_with_id`](#0x1_MultiSig_vote_with_id)
-  [Function `vote_impl`](#0x1_MultiSig_vote_impl)
-  [Function `tally`](#0x1_MultiSig_tally)
-  [Function `find_expired`](#0x1_MultiSig_find_expired)
-  [Function `lazy_cleanup_expired`](#0x1_MultiSig_lazy_cleanup_expired)
-  [Function `check_expired`](#0x1_MultiSig_check_expired)
-  [Function `is_authority`](#0x1_MultiSig_is_authority)
-  [Function `extract_proposal_data`](#0x1_MultiSig_extract_proposal_data)
-  [Function `search_proposals_for_guid`](#0x1_MultiSig_search_proposals_for_guid)
-  [Function `find_index_of_ballot_by_data`](#0x1_MultiSig_find_index_of_ballot_by_data)
-  [Function `get_proposal_status_by_id`](#0x1_MultiSig_get_proposal_status_by_id)
-  [Function `propose_governance`](#0x1_MultiSig_propose_governance)
-  [Function `vote_governance`](#0x1_MultiSig_vote_governance)
-  [Function `maybe_update_authorities`](#0x1_MultiSig_maybe_update_authorities)
-  [Function `maybe_update_threshold`](#0x1_MultiSig_maybe_update_threshold)
-  [Function `get_authorities`](#0x1_MultiSig_get_authorities)
-  [Function `get_n_of_m_cfg`](#0x1_MultiSig_get_n_of_m_cfg)


<pre><code><b>use</b> <a href="Ballot.md#0x1_Ballot">0x1::Ballot</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MultiSig_Governance"></a>

## Resource `Governance`

A Governance account is an account which requires multiple votes from Authorities to  send a transaction.
A multisig can be used to get agreement on different types of Actions, such as a payment transaction where the handler code for the transaction is an a separate contract. See for example MultiSigPayment.
Governance struct holds the metadata for all the instances of Actions on this account.
Every action has the same set of authorities and governance.
This is intentional, since privilege escalation can happen if each action has a different set of governance, but access to funds and other state.
If the organization wishes to have Actions with different governance, then a separate Account is necessary.
DANGER
The WithdrawCapability can be used to withdraw funds from the account.
Ordinarily only the signer/owner of this address can use it.
We are bricking the signer, and as such the withdraw capability is now controlled by the Governance logic.
Core Devs: This is a major attack vector. The WithdrawCapability should NEVER be returned to a public caller, UNLESS it is within the vote and approve flow.
Note, the WithdrawCApability is moved to this shared structure, and as such the signer of the account is bricked. The signer who was the original owner of this account ("sponsor") can no longer issue transactions to this account, and as such the WithdrawCapability would be inaccessible. So on initialization we extract the WithdrawCapability into the Governance governance struct.


<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> <b>has</b> key
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
<code>guid_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_CreateCapability">GUID::CreateCapability</a></code>
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
<code>vote: <a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MultiSig_Proposal"></a>

## Struct `Proposal`



<pre><code><b>struct</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
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

Already registered this action type


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EACTION_ALREADY_EXISTS">EACTION_ALREADY_EXISTS</a>: u64 = 440006;
</code></pre>



<a name="0x1_MultiSig_EACTION_NOT_FOUND"></a>

Action not found


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EACTION_NOT_FOUND">EACTION_NOT_FOUND</a>: u64 = 440007;
</code></pre>



<a name="0x1_MultiSig_EDUPLICATE_PROPOSAL"></a>

Proposal is expired


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EDUPLICATE_PROPOSAL">EDUPLICATE_PROPOSAL</a>: u64 = 440009;
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



<a name="0x1_MultiSig_EPROPOSAL_NOT_FOUND"></a>

Proposal is expired


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_EPROPOSAL_NOT_FOUND">EPROPOSAL_NOT_FOUND</a>: u64 = 440010;
</code></pre>



<a name="0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY"></a>

The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the Governance logic.


<pre><code><b>const</b> <a href="MultiSig.md#0x1_MultiSig_ESIGNER_CANT_BE_AUTHORITY">ESIGNER_CANT_BE_AUTHORITY</a>: u64 = 440001;
</code></pre>



<a name="0x1_MultiSig_proposal_constructor"></a>

## Function `proposal_constructor`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">proposal_constructor</a>&lt;ProposalData: drop, store&gt;(proposal_data: ProposalData, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;): <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">proposal_constructor</a>&lt;ProposalData: store + drop&gt;(proposal_data: ProposalData, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;): <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {

  <b>let</b> duration_epochs = <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&duration_epochs)) {
    *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_borrow">Option::borrow</a>(&duration_epochs)
  } <b>else</b> {
    <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>
  };

  <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
    // id: 0,
    proposal_data,
    votes: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;(),
    approved: <b>false</b>,
    expiration_epoch: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>() + duration_epochs,
  }
}
</code></pre>



</details>

<a name="0x1_MultiSig_assert_authorized"></a>

## Function `assert_authorized`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig: &signer, multisig_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig: &signer, multisig_address: <b>address</b>) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
      // cannot start manipulating contract until it is finalized
  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_finalized">is_finalized</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_FINALIZED_NOT_BRICK">ENOT_FINALIZED_NOT_BRICK</a>));

  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

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

  <b>if</b> (!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address)) {
      <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
      cfg_duration_epochs: <a href="MultiSig.md#0x1_MultiSig_DEFAULT_EPOCHS_EXPIRE">DEFAULT_EPOCHS_EXPIRE</a>,
      cfg_default_n_sigs,
      signers: *m_seed_authorities,
      // counter: 0,
      withdraw_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>(),
      guid_capability: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_gen_create_capability">GUID::gen_create_capability</a>(sig),
    });
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address)) {
    <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt; {
      can_withdraw: <b>false</b>,
      // pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      // approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      // rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      vote: <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(),
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
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address) &&
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address)
}
</code></pre>



</details>

<a name="0x1_MultiSig_has_action"></a>

## Function `has_action`

Has a multisig struct for a given action been created?


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_has_action">has_action</a>&lt;ProposalData: store&gt;(addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_has_action">has_action</a>&lt;ProposalData: store&gt;(addr: <b>address</b>):bool {
  <b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_init_type"></a>

## Function `init_type`

An initial "sponsor" who is the signer of the initialization account calls this function.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;ProposalData: drop, store&gt;(sig: &signer, can_withdraw: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_init_type">init_type</a>&lt;ProposalData: store + drop &gt;(
  sig: &signer,
  can_withdraw: bool,
 ) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  // TODO: there is no way of creating a new <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> by multisig. The "signer" would need <b>to</b> be spoofed, which <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> does only in specific and scary situations (e.g. vm_create_account_migration)

  <b>assert</b>!(<a href="MultiSig.md#0x1_MultiSig_is_init">is_init</a>(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EGOV_NOT_INITIALIZED">EGOV_NOT_INITIALIZED</a>));

  <b>assert</b>!(!<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EACTION_ALREADY_EXISTS">EACTION_ALREADY_EXISTS</a>));
  // make sure the signer's <b>address</b> is not in the list of authorities.
  // This account's signer will now be useless.



  // maybe the withdraw cap was never extracted in previous set up.
  // but we won't extract it <b>if</b> none of the Actions require it.
  <b>if</b> (can_withdraw) {
    <a href="MultiSig.md#0x1_MultiSig_maybe_extract_withdraw_cap">maybe_extract_withdraw_cap</a>(sig);
  };

  <b>move_to</b>(sig, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt; {
      can_withdraw,
      // pending: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      // approved: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      // rejected: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
      vote: <a href="Ballot.md#0x1_Ballot_new_tracker">Ballot::new_tracker</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(),
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


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_extract_withdraw_cap">maybe_extract_withdraw_cap</a>(sig: &signer) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <b>let</b> multisig_address = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));

  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
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


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">maybe_restore_withdraw_cap</a>(sig: &signer, multisig_addr: <b>address</b>, w: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_addr);
  <b>assert</b>!(<b>exists</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_addr), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_ENOT_AUTHORIZED">ENOT_AUTHORIZED</a>));
  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&w)) {
    <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_addr);
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

<a name="0x1_MultiSig_propose_new"></a>

## Function `propose_new`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_new">propose_new</a>&lt;ProposalData: drop, store&gt;(sig: &signer, multisig_address: <b>address</b>, proposal_data: <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_new">propose_new</a>&lt;ProposalData: store + drop&gt;(
  sig: &signer,
  multisig_address: <b>address</b>,
  proposal_data: <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;,
): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  // print(&20);
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address);
// print(&21);
  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
  <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  // print(&22);
  // go through all proposals and clean up expired ones.
  <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>(action);
// print(&23);
  // does this proposal already exist in the pending list?
  <b>let</b> (found, guid, _idx, status_enum, _is_complete) = <a href="MultiSig.md#0x1_MultiSig_search_proposals_for_guid">search_proposals_for_guid</a>&lt;ProposalData&gt;(&action.vote, &proposal_data);
  // print(&found);
  // print(&status_enum);
  // print(&24);
  <b>if</b> (found && status_enum == <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>()) {
    // print(&2401);
    // this exact proposal is already pending, so we we will just <b>return</b> the guid of the existing proposal.
    // we'll <b>let</b> the caller decide what <b>to</b> do (we wont vote by default)
    <b>return</b> guid
  };

// print(&25);
  <b>let</b> ballot = <a href="Ballot.md#0x1_Ballot_propose_ballot">Ballot::propose_ballot</a>(&<b>mut</b> action.vote, &ms.guid_capability, proposal_data);
// print(&26);
  <b>let</b> id = <a href="Ballot.md#0x1_Ballot_get_ballot_id">Ballot::get_ballot_id</a>(ballot);
// print(&27);
  id
}
</code></pre>



</details>

<a name="0x1_MultiSig_vote_with_data"></a>

## Function `vote_with_data`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_with_data">vote_with_data</a>&lt;ProposalData: drop, store&gt;(sig: &signer, proposal: &<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;, multisig_address: <b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_with_data">vote_with_data</a>&lt;ProposalData: store + drop&gt;(sig: &signer, proposal: &<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;, multisig_address: <b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address);

  <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  // <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
  // go through all proposals and clean up expired ones.
  // <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>(action);

  // does this proposal already exist in the pending list?
  <b>let</b> (found, uid, _idx, _status_enum, _is_complete) = <a href="MultiSig.md#0x1_MultiSig_search_proposals_for_guid">search_proposals_for_guid</a>&lt;ProposalData&gt;(&action.vote, proposal);

  <b>assert</b>!(found, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EPROPOSAL_NOT_FOUND">EPROPOSAL_NOT_FOUND</a>));

  <a href="MultiSig.md#0x1_MultiSig_vote_impl">vote_impl</a>&lt;ProposalData&gt;(sig, multisig_address, &uid)

}
</code></pre>



</details>

<a name="0x1_MultiSig_vote_with_id"></a>

## Function `vote_with_id`

helper function to vote with ID only


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_with_id">vote_with_id</a>&lt;ProposalData: drop, store&gt;(sig: &signer, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, multisig_address: <b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_with_id">vote_with_id</a>&lt;ProposalData: store + drop&gt;(sig: &signer, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, multisig_address: <b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address);

  // <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  <a href="MultiSig.md#0x1_MultiSig_vote_impl">vote_impl</a>&lt;ProposalData&gt;(sig, multisig_address, id)

}
</code></pre>



</details>

<a name="0x1_MultiSig_vote_impl"></a>

## Function `vote_impl`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_impl">vote_impl</a>&lt;ProposalData: drop, store&gt;(sig: &signer, multisig_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="DiemAccount.md#0x1_DiemAccount_WithdrawCapability">DiemAccount::WithdrawCapability</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_impl">vote_impl</a>&lt;ProposalData: store + drop&gt;(
  sig: &signer,
  // ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>,
  multisig_address: <b>address</b>,
  id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;WithdrawCapability&gt;) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {

  // print(&60);
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address); // belt and suspenders
  <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
  <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  // print(&61);
  <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>(action);
  // print(&62);

  // does this proposal already exist in the pending list?
  <b>let</b> (found, _idx, status_enum, is_complete) = <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(&action.vote, id);
  // print(&63);
  <b>assert</b>!((found && status_enum == <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>() && !is_complete), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="MultiSig.md#0x1_MultiSig_EPROPOSAL_NOT_FOUND">EPROPOSAL_NOT_FOUND</a>));
  // print(&64);
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id_mut">Ballot::get_ballot_by_id_mut</a>(&<b>mut</b> action.vote, id);
  <b>let</b> t = <a href="Ballot.md#0x1_Ballot_get_type_struct_mut">Ballot::get_type_struct_mut</a>(b);
  // print(&65);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> t.votes, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig));
  // print(&66);
  <b>let</b> passed = <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>(t, *&ms.cfg_default_n_sigs);
  // print(&67);

  <b>if</b> (passed) {
    <a href="Ballot.md#0x1_Ballot_complete_ballot">Ballot::complete_ballot</a>(b);
  };

  // get the withdrawal capability, we're not allowed <b>copy</b>, but we can
  // extract and fill, and then replace it. See <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a> for an example.
  <b>let</b> withdraw_cap = <b>if</b> (
    passed &&
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&ms.withdraw_capability) &&
    action.can_withdraw
  ) {
    <b>let</b> c = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> ms.withdraw_capability);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(c)
  } <b>else</b> {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()
  };

  // print(&withdraw_cap);
  // print(&68);

  (passed, withdraw_cap)
}
</code></pre>



</details>

<a name="0x1_MultiSig_tally"></a>

## Function `tally`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>&lt;ProposalData: drop, store&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;, n: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_tally">tally</a>&lt;ProposalData: store + drop&gt;(prop: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;, n: u64): bool {
  // print(&40001);

  // print(&prop.votes);

  <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&prop.votes) &gt;= n) {
    prop.approved = <b>true</b>;
    // print(&40002);

    <b>return</b> <b>true</b>
  };

  <b>false</b>
}
</code></pre>



</details>

<a name="0x1_MultiSig_find_expired"></a>

## Function `find_expired`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_expired">find_expired</a>&lt;ProposalData: drop, store&gt;(a: &<a href="MultiSig.md#0x1_MultiSig_Action">MultiSig::Action</a>&lt;ProposalData&gt;): vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_expired">find_expired</a>&lt;ProposalData: store + drop&gt;(a: & <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;): vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>&gt;{
  // print(&40);
  <b>let</b> epoch = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  <b>let</b> b_vec = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">Ballot::get_list_ballots_by_enum</a>(&a.vote, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>());
  <b>let</b> id_vec = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>();
  // print(&41);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(b_vec)) {
    // print(&4101);
    <b>let</b> b = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(b_vec, i);
    <b>let</b> t = <a href="Ballot.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);


    <b>if</b> (epoch &gt; t.expiration_epoch) {
      // print(&4010101);
      <b>let</b> id = <a href="Ballot.md#0x1_Ballot_get_ballot_id">Ballot::get_ballot_id</a>(b);
      // print(&4010102);
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> id_vec, id);

    };
    i = i + 1;
  };

  id_vec
}
</code></pre>



</details>

<a name="0x1_MultiSig_lazy_cleanup_expired"></a>

## Function `lazy_cleanup_expired`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>&lt;ProposalData: drop, store&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">MultiSig::Action</a>&lt;ProposalData&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_lazy_cleanup_expired">lazy_cleanup_expired</a>&lt;ProposalData: store + drop&gt;(a: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;) {
  <b>let</b> expired_vec = <a href="MultiSig.md#0x1_MultiSig_find_expired">find_expired</a>(a);
  // print(&expired_vec);
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&expired_vec);
  // print(&len);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> id = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&expired_vec, i);
    // lets check the status just in case.
     <a href="Ballot.md#0x1_Ballot_move_ballot">Ballot::move_ballot</a>(&<b>mut</b> a.vote, id, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>(), <a href="Ballot.md#0x1_Ballot_get_rejected_enum">Ballot::get_rejected_enum</a>());
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_MultiSig_check_expired"></a>

## Function `check_expired`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>&lt;ProposalData: store&gt;(prop: &<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_check_expired">check_expired</a>&lt;ProposalData: store&gt;(prop: &<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;): bool {
  <b>let</b> epoch_now = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  epoch_now &gt; prop.expiration_epoch
}
</code></pre>



</details>

<a name="0x1_MultiSig_is_authority"></a>

## Function `is_authority`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>(multisig_addr: <b>address</b>, addr: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_is_authority">is_authority</a>(multisig_addr: <b>address</b>, addr: <b>address</b>): bool <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_addr);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&m.signers, &addr)
}
</code></pre>



</details>

<a name="0x1_MultiSig_extract_proposal_data"></a>

## Function `extract_proposal_data`

This function is used to copy the data from the proposal that is in the multisig.
Note that this is the only way to get the data out of the multisig, and it is the only function to use the <code><b>copy</b></code> trait. If you have a workflow that needs copying, then the data struct for the action payload will need to use the <code><b>copy</b></code> trait.


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_extract_proposal_data">extract_proposal_data</a>&lt;ProposalData: <b>copy</b>, drop, store&gt;(multisig_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): ProposalData
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_extract_proposal_data">extract_proposal_data</a>&lt;ProposalData: store + <b>copy</b> + drop&gt;(multisig_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): ProposalData <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <b>let</b> a = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(&a.vote, uid);
  <b>let</b> t = <a href="Ballot.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);

  <b>let</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
      proposal_data: existing_data,
      expiration_epoch: _,
      votes: _,
      approved: _,
  } = t;

  *existing_data
}
</code></pre>



</details>

<a name="0x1_MultiSig_search_proposals_for_guid"></a>

## Function `search_proposals_for_guid`

returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_search_proposals_for_guid">search_proposals_for_guid</a>&lt;ProposalData: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;, data: &<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_search_proposals_for_guid">search_proposals_for_guid</a>&lt;ProposalData: drop + store&gt; (
  tracker: &BallotTracker&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;,
  data: &<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;,
): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64, u8, bool)  {
 // looking in pending

 <b>let</b> (found, guid, idx) = <a href="MultiSig.md#0x1_MultiSig_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(tracker, data, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>());
 <b>if</b> (found) {
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(tracker, &guid);
  <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">Ballot::is_completed</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);
   <b>return</b> (<b>true</b>, guid, idx, <a href="Ballot.md#0x1_Ballot_get_pending_enum">Ballot::get_pending_enum</a>(), complete)
 };

<b>let</b> (found, guid, idx) = <a href="MultiSig.md#0x1_MultiSig_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(tracker, data, <a href="Ballot.md#0x1_Ballot_get_approved_enum">Ballot::get_approved_enum</a>());
 <b>if</b> (found) {
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(tracker, &guid);
  <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">Ballot::is_completed</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);
   <b>return</b> (<b>true</b>, guid, idx, <a href="Ballot.md#0x1_Ballot_get_approved_enum">Ballot::get_approved_enum</a>(), complete)
 };

<b>let</b> (found, guid, idx) = <a href="MultiSig.md#0x1_MultiSig_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>(tracker, data, <a href="Ballot.md#0x1_Ballot_get_rejected_enum">Ballot::get_rejected_enum</a>());
 <b>if</b> (found) {
  <b>let</b> b = <a href="Ballot.md#0x1_Ballot_get_ballot_by_id">Ballot::get_ballot_by_id</a>(tracker, &guid);
  <b>let</b> complete = <a href="Ballot.md#0x1_Ballot_is_completed">Ballot::is_completed</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);
   <b>return</b> (<b>true</b>, guid, idx, <a href="Ballot.md#0x1_Ballot_get_rejected_enum">Ballot::get_rejected_enum</a>(), complete)
 };

  (<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(@0x0, 0), 0, 0, <b>false</b>)
}
</code></pre>



</details>

<a name="0x1_MultiSig_find_index_of_ballot_by_data"></a>

## Function `find_index_of_ballot_by_data`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>&lt;ProposalData: drop, store&gt;(tracker: &<a href="Ballot.md#0x1_Ballot_BallotTracker">Ballot::BallotTracker</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;&gt;, incoming_proposal: &<a href="MultiSig.md#0x1_MultiSig_Proposal">MultiSig::Proposal</a>&lt;ProposalData&gt;, status_enum: u8): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_find_index_of_ballot_by_data">find_index_of_ballot_by_data</a>&lt;ProposalData: drop + store&gt; (
  tracker: &BallotTracker&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;,
  incoming_proposal: &<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;,
  status_enum: u8,
): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, u64) {
  <b>let</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
      proposal_data: incoming_data,
      expiration_epoch: _,
      votes: _,
      approved: _,
  } = incoming_proposal;

 <b>let</b> list = <a href="Ballot.md#0x1_Ballot_get_list_ballots_by_enum">Ballot::get_list_ballots_by_enum</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(tracker, status_enum);

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(list)) {
    <b>let</b> b = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(list, i);
    <b>let</b> t = <a href="Ballot.md#0x1_Ballot_get_type_struct">Ballot::get_type_struct</a>&lt;<a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt;&gt;(b);

    // strip the votes and approved fields for comparison
    <b>let</b> <a href="MultiSig.md#0x1_MultiSig_Proposal">Proposal</a>&lt;ProposalData&gt; {
        proposal_data: existing_data,
        expiration_epoch: _,
        votes: _,
        approved: _,
    } = t;

    <b>if</b> (existing_data == incoming_data) {
      <b>let</b> uid = <a href="Ballot.md#0x1_Ballot_get_ballot_id">Ballot::get_ballot_id</a>(b);
      <b>return</b> (<b>true</b>, uid, i)
    };
    i = i + 1;
  };

  (<b>false</b>, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_create_id">GUID::create_id</a>(@0x0, 0), 0)
}
</code></pre>



</details>

<a name="0x1_MultiSig_get_proposal_status_by_id"></a>

## Function `get_proposal_status_by_id`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_proposal_status_by_id">get_proposal_status_by_id</a>&lt;ProposalData: drop, store&gt;(multisig_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_proposal_status_by_id">get_proposal_status_by_id</a>&lt;ProposalData: drop + store&gt;(multisig_address: <b>address</b>, uid: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64, u8, bool) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> { // found, index, status_enum, is_complete
  <b>let</b> a = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;ProposalData&gt;&gt;(multisig_address);
  <a href="Ballot.md#0x1_Ballot_find_anywhere">Ballot::find_anywhere</a>(&a.vote, uid)
}
</code></pre>



</details>

<a name="0x1_MultiSig_propose_governance"></a>

## Function `propose_governance`



<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_governance">propose_governance</a>(sig: &signer, multisig_address: <b>address</b>, addresses: vector&lt;<b>address</b>&gt;, add_remove: bool, n_of_m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_propose_governance">propose_governance</a>(sig: &signer, multisig_address: <b>address</b>, addresses: vector&lt;<b>address</b>&gt;, add_remove: bool, n_of_m: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;, duration_epochs: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt; ): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a> <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address); // Duplicated <b>with</b> propose(), belt and suspenders
  <b>let</b> data = <a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a> {
    addresses,
    add_remove,
    n_of_m,
  };

  <b>let</b> prop = <a href="MultiSig.md#0x1_MultiSig_proposal_constructor">proposal_constructor</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;(data, duration_epochs);
  <b>let</b> id = <a href="MultiSig.md#0x1_MultiSig_propose_new">propose_new</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;(sig, multisig_address, prop);
  <a href="MultiSig.md#0x1_MultiSig_vote_governance">vote_governance</a>(sig, multisig_address, &id);

  id
}
</code></pre>



</details>

<a name="0x1_MultiSig_vote_governance"></a>

## Function `vote_governance`



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_governance">vote_governance</a>(sig: &signer, multisig_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_vote_governance">vote_governance</a>(sig: &signer, multisig_address: <b>address</b>, id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, <a href="MultiSig.md#0x1_MultiSig_Action">Action</a> {
  <a href="MultiSig.md#0x1_MultiSig_assert_authorized">assert_authorized</a>(sig, multisig_address);


  <b>let</b> (passed, cap_opt) = {
    // <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
    // <b>let</b> action = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Action">Action</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;&gt;(multisig_address);
    <a href="MultiSig.md#0x1_MultiSig_vote_impl">vote_impl</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;(sig, multisig_address, id)
  };
  <a href="MultiSig.md#0x1_MultiSig_maybe_restore_withdraw_cap">maybe_restore_withdraw_cap</a>(sig, multisig_address, cap_opt); // don't need this and can't drop.

  <b>if</b> (passed) {
    <b>let</b> ms = <b>borrow_global_mut</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
    <b>let</b> data = <a href="MultiSig.md#0x1_MultiSig_extract_proposal_data">extract_proposal_data</a>&lt;<a href="MultiSig.md#0x1_MultiSig_PropGovSigners">PropGovSigners</a>&gt;(multisig_address, id);
    <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms, data.add_remove, &data.addresses);
    <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms, &data.n_of_m);
  }
}
</code></pre>



</details>

<a name="0x1_MultiSig_maybe_update_authorities"></a>

## Function `maybe_update_authorities`

Updates the authorities of the multisig. This is a helper function for governance.


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Governance">MultiSig::Governance</a>, add_remove: bool, addresses: &vector&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_authorities">maybe_update_authorities</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, add_remove: bool, addresses: &vector&lt;<b>address</b>&gt;) {

    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(addresses)) {
      // The <b>address</b> field may be empty <b>if</b> the multisig is only changing the threshold
      <b>return</b>
    };

    <b>if</b> (add_remove) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> ms.signers, *addresses);
    } <b>else</b> {

      // remove the signers
      <b>let</b> i = 0;
      <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(addresses)) {
        <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(addresses, i);
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



<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Governance">MultiSig::Governance</a>, n_of_m_opt: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MultiSig.md#0x1_MultiSig_maybe_update_threshold">maybe_update_threshold</a>(ms: &<b>mut</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>, n_of_m_opt: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">Option</a>&lt;u64&gt;) {
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


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_authorities">get_authorities</a>(multisig_address: <b>address</b>): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
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


<pre><code><b>public</b> <b>fun</b> <a href="MultiSig.md#0x1_MultiSig_get_n_of_m_cfg">get_n_of_m_cfg</a>(multisig_address: <b>address</b>): (u64, u64) <b>acquires</b> <a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a> {
  <b>let</b> m = <b>borrow_global</b>&lt;<a href="MultiSig.md#0x1_MultiSig_Governance">Governance</a>&gt;(multisig_address);
  (*&m.cfg_default_n_sigs, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&m.signers))
}
</code></pre>



</details>
