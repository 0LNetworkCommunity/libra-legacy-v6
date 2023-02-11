
<a name="0x1_PledgeAccounts"></a>

# Module `0x1::PledgeAccounts`



-  [Resource `MyPledges`](#0x1_PledgeAccounts_MyPledges)
-  [Resource `PledgeAccount`](#0x1_PledgeAccounts_PledgeAccount)
-  [Resource `BeneficiaryPolicy`](#0x1_PledgeAccounts_BeneficiaryPolicy)
-  [Constants](#@Constants_0)
-  [Function `publish_beneficiary_policy`](#0x1_PledgeAccounts_publish_beneficiary_policy)
-  [Function `initialize_my_pledges`](#0x1_PledgeAccounts_initialize_my_pledges)
-  [Function `create_pledge_account`](#0x1_PledgeAccounts_create_pledge_account)
-  [Function `add_funds_to_pledge_account`](#0x1_PledgeAccounts_add_funds_to_pledge_account)
-  [Function `withdraw_from_all_pledge_accounts`](#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts)
-  [Function `withdraw_from_one_pledge_account`](#0x1_PledgeAccounts_withdraw_from_one_pledge_account)
-  [Function `vote_to_revoke_beneficiary_policy`](#0x1_PledgeAccounts_vote_to_revoke_beneficiary_policy)
-  [Function `try_cancel_vote`](#0x1_PledgeAccounts_try_cancel_vote)
-  [Function `find_index_of_vote`](#0x1_PledgeAccounts_find_index_of_vote)
-  [Function `tally_vote`](#0x1_PledgeAccounts_tally_vote)
-  [Function `dissolve_beneficiary_project`](#0x1_PledgeAccounts_dissolve_beneficiary_project)
-  [Function `get_pledge_amount`](#0x1_PledgeAccounts_get_pledge_amount)


<pre><code><b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_PledgeAccounts_MyPledges"></a>

## Resource `MyPledges`



<pre><code><b>struct</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_PledgeAccount">PledgeAccounts::PledgeAccount</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_PledgeAccounts_PledgeAccount"></a>

## Resource `PledgeAccount`



<pre><code><b>struct</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_PledgeAccount">PledgeAccount</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>project_id: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>address_of_beneficiary: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_of_last_deposit: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_deposited: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_withdrawn: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_PledgeAccounts_BeneficiaryPolicy"></a>

## Resource `BeneficiaryPolicy`



<pre><code><b>struct</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> <b>has</b> <b>copy</b>, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>purpose: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>vote_threshold_to_revoke: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_funds_on_revoke: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>total_pledged: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>pledgers: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>table_votes_to_revoke: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>table_revoking_electors: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_revoke_vote: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>revoked: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_PledgeAccounts_ENON_ZERO_BALANCE"></a>



<pre><code><b>const</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_ENON_ZERO_BALANCE">ENON_ZERO_BALANCE</a>: u64 = 150002;
</code></pre>



<a name="0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY"></a>



<pre><code><b>const</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY">ENO_BENEFICIARY_POLICY</a>: u64 = 150001;
</code></pre>



<a name="0x1_PledgeAccounts_publish_beneficiary_policy"></a>

## Function `publish_beneficiary_policy`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(account: &signer, purpose: vector&lt;u8&gt;, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(account: &signer, purpose: vector&lt;u8&gt;, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>if</b> (!<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account))) {
        <b>let</b> beneficiary_policy = <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
            purpose: purpose,
            vote_threshold_to_revoke: vote_threshold_to_revoke,
            burn_funds_on_revoke: burn_funds_on_revoke,
            total_pledged: 0,
            pledgers: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
            table_votes_to_revoke: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
            table_revoking_electors: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
            total_revoke_vote: 0,
            revoked: <b>false</b>

        };
        <b>move_to</b>(account, beneficiary_policy);
    } <b>else</b> {
      // allow the beneficiary <b>to</b> write drafts, and modify the policy, <b>as</b> long <b>as</b> no pledge <b>has</b> been made.
      <b>let</b> b = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));
      <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&b.pledgers) == 0) {
        b.purpose = purpose;
        b.vote_threshold_to_revoke = vote_threshold_to_revoke;
        b.burn_funds_on_revoke = burn_funds_on_revoke;
      }
    }
    // no changes can be made <b>if</b> a pledge <b>has</b> been made.
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_initialize_my_pledges"></a>

## Function `initialize_my_pledges`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_initialize_my_pledges">initialize_my_pledges</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_initialize_my_pledges">initialize_my_pledges</a>(account: &signer) {
    <b>if</b> (!<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account))) {
        <b>let</b> my_pledges = <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> { list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>() };
        <b>move_to</b>(account, my_pledges);
    }
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_create_pledge_account"></a>

## Function `create_pledge_account`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">create_pledge_account</a>(account: &signer, project_id: vector&lt;u8&gt;, address_of_beneficiary: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">create_pledge_account</a>(account: &signer, project_id: vector&lt;u8&gt;, address_of_beneficiary: <b>address</b>, amount: u64) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
    <b>let</b> my_pledges = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));

    // check a beneficiary policy <b>exists</b>
    <b>assert</b>!(<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="PledgeAccounts.md#0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY">ENO_BENEFICIARY_POLICY</a>));

    <b>let</b> new_pledge_account = <a href="PledgeAccounts.md#0x1_PledgeAccounts_PledgeAccount">PledgeAccount</a> {
        project_id: project_id,
        address_of_beneficiary: address_of_beneficiary,
        amount: amount,
        epoch_of_last_deposit: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>(),
        lifetime_deposited: amount,
        lifetime_withdrawn: 0
    };
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> my_pledges.list, new_pledge_account);
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_add_funds_to_pledge_account"></a>

## Function `add_funds_to_pledge_account`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_funds_to_pledge_account">add_funds_to_pledge_account</a>(account: &signer, address_of_beneficiary: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_funds_to_pledge_account">add_funds_to_pledge_account</a>(account: &signer, address_of_beneficiary: <b>address</b>, amount: u64) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> my_pledges = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&my_pledges.list)) {
        <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&my_pledges.list, i).address_of_beneficiary == address_of_beneficiary) {
            <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> my_pledges.list, i);
            pledge_account.amount = pledge_account.amount + amount;
            pledge_account.epoch_of_last_deposit = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
            pledge_account.lifetime_deposited = pledge_account.lifetime_deposited + amount;

            // must add pledger <b>address</b> the ProjectPledgers list on beneficiary account

            <b>let</b> b = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);
            <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> b.pledgers, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));

            <b>break</b>
        };
        i = i + 1;
    };

  // exits silently <b>if</b> nothing is found.
  // this is <b>to</b> prevent halting in the event that a VM route is calling the function and is unable <b>to</b> check the <b>return</b> value.
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_withdraw_from_all_pledge_accounts"></a>

## Function `withdraw_from_all_pledge_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">withdraw_from_all_pledge_accounts</a>(sig_beneficiary: &signer, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">withdraw_from_all_pledge_accounts</a>(sig_beneficiary: &signer, amount: u64) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> pledgers = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig_beneficiary)).pledgers;
    <b>let</b> address_of_beneficiary = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig_beneficiary);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pledgers)) {
        <b>let</b> pledge_account = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pledgers, i);

        // DANGER: this is a private function that changes balances.
        <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(&address_of_beneficiary, &pledge_account, amount);
        i = i + 1;
    };
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_withdraw_from_one_pledge_account"></a>

## Function `withdraw_from_one_pledge_account`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, amount: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, amount: u64): u64 <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> pledge_state = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*payer);
    <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*address_of_beneficiary);

    // TODO: this will be replaced <b>with</b> an actual coin.
    <b>let</b> coin = 0;

    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pledge_state.list)) {
        <b>if</b> (&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pledge_state.list, i).address_of_beneficiary == address_of_beneficiary) {
            <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> pledge_state.list, i);
            pledge_account.amount = pledge_account.amount - amount;
            pledge_account.lifetime_withdrawn = pledge_account.lifetime_withdrawn + amount;

            // <b>update</b> the beneficiaries state too
            bp.total_pledged = bp.total_pledged - amount;
            // TODO: bp.lifetime_withdrawn = bp.lifetime_withdrawn + amount;

            coin = amount;
            <b>break</b>
        };
        i = i + 1;
    };

  // exits silently <b>if</b> nothing is found.
  // this is <b>to</b> prevent halting in the event that a VM route is calling the function and is unable <b>to</b> check the <b>return</b> value.
  coin
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_vote_to_revoke_beneficiary_policy"></a>

## Function `vote_to_revoke_beneficiary_policy`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_vote_to_revoke_beneficiary_policy">vote_to_revoke_beneficiary_policy</a>(account: &signer, address_of_beneficiary: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_vote_to_revoke_beneficiary_policy">vote_to_revoke_beneficiary_policy</a>(account: &signer, address_of_beneficiary: <b>address</b>) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {


    // first check <b>if</b> they have already voted
    // and <b>if</b> so, cancel in one step
    <a href="PledgeAccounts.md#0x1_PledgeAccounts_try_cancel_vote">try_cancel_vote</a>(account, address_of_beneficiary);

    <b>let</b> pledger = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> bp.table_revoking_electors, pledger);
    <b>let</b> user_pledge_balance = <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_pledge_amount">get_pledge_amount</a>(&pledger, &address_of_beneficiary);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> bp.table_votes_to_revoke, user_pledge_balance);
    bp.total_revoke_vote = bp.total_revoke_vote + user_pledge_balance;
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_try_cancel_vote"></a>

## Function `try_cancel_vote`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_try_cancel_vote">try_cancel_vote</a>(account: &signer, address_of_beneficiary: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_try_cancel_vote">try_cancel_vote</a>(account: &signer, address_of_beneficiary: <b>address</b>) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> pledger = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);

    <b>let</b> idx = <a href="PledgeAccounts.md#0x1_PledgeAccounts_find_index_of_vote">find_index_of_vote</a>(&bp.table_revoking_electors, &pledger);

    <b>if</b> (idx == 0) {
        <b>return</b>
    };
    //adjust the running totals
    <b>let</b> prior_vote = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&bp.table_votes_to_revoke, idx);
    bp.total_revoke_vote = bp.total_revoke_vote - *prior_vote;

    // <b>update</b> the vote
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> bp.table_revoking_electors, idx);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> bp.table_votes_to_revoke, idx);
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_find_index_of_vote"></a>

## Function `find_index_of_vote`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_find_index_of_vote">find_index_of_vote</a>(table_revoking_electors: &vector&lt;<b>address</b>&gt;, pledger: &<b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_find_index_of_vote">find_index_of_vote</a>(table_revoking_electors: &vector&lt;<b>address</b>&gt;, pledger: &<b>address</b>): u64 {
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(table_revoking_electors, pledger)) {
        <b>return</b> 0
    };

    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(table_revoking_electors)) {
        <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(table_revoking_electors, i) == pledger) {
            <b>return</b> i
        };
        i = i + 1;
    };
    0 // TODO: <b>return</b> an option type
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_tally_vote"></a>

## Function `tally_vote`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_tally_vote">tally_vote</a>(address_of_beneficiary: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_tally_vote">tally_vote</a>(address_of_beneficiary: <b>address</b>): bool <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> bp = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);
    <b>let</b> total_pledged = bp.total_pledged;
    <b>let</b> total_revoke_vote = bp.total_revoke_vote;

    <b>if</b> ((total_revoke_vote / total_pledged) &gt; bp.vote_threshold_to_revoke) {
        <b>return</b> <b>true</b>
    };
    <b>false</b>
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_dissolve_beneficiary_project"></a>

## Function `dissolve_beneficiary_project`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_dissolve_beneficiary_project">dissolve_beneficiary_project</a>(address_of_beneficiary: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_dissolve_beneficiary_project">dissolve_beneficiary_project</a>(address_of_beneficiary: <b>address</b>) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> pledgers = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary).pledgers;

    // <b>let</b> pledgers = *&bp.pledgers;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pledgers)) {
        <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pledgers, i);
        <b>let</b> user_pledge_balance = <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_pledge_amount">get_pledge_amount</a>(pledge_account, &address_of_beneficiary);

        <b>let</b> _coin = <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(&address_of_beneficiary, pledge_account, user_pledge_balance);

        i = i + 1;
    };

  <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);
  <b>assert</b>!(bp.total_pledged == 0, <a href="PledgeAccounts.md#0x1_PledgeAccounts_ENON_ZERO_BALANCE">ENON_ZERO_BALANCE</a>);

  bp.revoked = <b>true</b>;

    // leave the information for historical purposes
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_pledge_amount"></a>

## Function `get_pledge_amount`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_pledge_amount">get_pledge_amount</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_pledge_amount">get_pledge_amount</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): u64 <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
    <b>let</b> my_pledges = &<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*account).list;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(my_pledges)) {
        <b>if</b> (&<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(my_pledges, i).address_of_beneficiary == address_of_beneficiary) {
            <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(my_pledges, i).amount
        };
        i = i + 1;
    };
    0
}
</code></pre>



</details>
