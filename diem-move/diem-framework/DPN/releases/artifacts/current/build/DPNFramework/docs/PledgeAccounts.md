
<a name="0x1_PledgeAccounts"></a>

# Module `0x1::PledgeAccounts`



-  [Resource `MyPledges`](#0x1_PledgeAccounts_MyPledges)
-  [Resource `PledgeAccount`](#0x1_PledgeAccounts_PledgeAccount)
-  [Resource `BeneficiaryPolicy`](#0x1_PledgeAccounts_BeneficiaryPolicy)
-  [Constants](#@Constants_0)
-  [Function `publish_beneficiary_policy`](#0x1_PledgeAccounts_publish_beneficiary_policy)
-  [Function `maybe_initialize_my_pledges`](#0x1_PledgeAccounts_maybe_initialize_my_pledges)
-  [Function `save_pledge`](#0x1_PledgeAccounts_save_pledge)
-  [Function `create_pledge_account`](#0x1_PledgeAccounts_create_pledge_account)
-  [Function `add_coin_to_pledge_account`](#0x1_PledgeAccounts_add_coin_to_pledge_account)
-  [Function `withdraw_from_all_pledge_accounts`](#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts)
-  [Function `withdraw_from_one_pledge_account`](#0x1_PledgeAccounts_withdraw_from_one_pledge_account)
-  [Function `withdraw_pct_from_one_pledge_account`](#0x1_PledgeAccounts_withdraw_pct_from_one_pledge_account)
-  [Function `vote_to_revoke_beneficiary_policy`](#0x1_PledgeAccounts_vote_to_revoke_beneficiary_policy)
-  [Function `try_cancel_vote`](#0x1_PledgeAccounts_try_cancel_vote)
-  [Function `find_index_of_vote`](#0x1_PledgeAccounts_find_index_of_vote)
-  [Function `tally_vote`](#0x1_PledgeAccounts_tally_vote)
-  [Function `dissolve_beneficiary_project`](#0x1_PledgeAccounts_dissolve_beneficiary_project)
-  [Function `genesis_infra_escrow_pledge`](#0x1_PledgeAccounts_genesis_infra_escrow_pledge)
-  [Function `user_pledge_tx`](#0x1_PledgeAccounts_user_pledge_tx)
-  [Function `pledge_at_idx`](#0x1_PledgeAccounts_pledge_at_idx)
-  [Function `get_user_pledge_amount`](#0x1_PledgeAccounts_get_user_pledge_amount)
-  [Function `get_available_to_beneficiary`](#0x1_PledgeAccounts_get_available_to_beneficiary)
-  [Function `get_lifetime_to_beneficiary`](#0x1_PledgeAccounts_get_lifetime_to_beneficiary)
-  [Function `get_all_pledgers`](#0x1_PledgeAccounts_get_all_pledgers)
-  [Function `get_revoke_vote`](#0x1_PledgeAccounts_get_revoke_vote)
-  [Function `test_single_withdrawal`](#0x1_PledgeAccounts_test_single_withdrawal)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemConfig.md#0x1_DiemConfig">0x1::DiemConfig</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option">0x1::Option</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
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
<code>pledge: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_of_last_deposit: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_pledged: u64</code>
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
<code>amount_available: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_pledged: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime_withdrawn: u64</code>
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



<a name="0x1_PledgeAccounts_ENO_PLEDGE_INIT"></a>



<pre><code><b>const</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_ENO_PLEDGE_INIT">ENO_PLEDGE_INIT</a>: u64 = 150003;
</code></pre>



<a name="0x1_PledgeAccounts_publish_beneficiary_policy"></a>

## Function `publish_beneficiary_policy`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(account: &signer, purpose: vector&lt;u8&gt;, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(
  account: &signer,
  purpose: vector&lt;u8&gt;,
  vote_threshold_to_revoke: u64,
  burn_funds_on_revoke: bool
) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>if</b> (!<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account))) {
        <b>let</b> beneficiary_policy = <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
            purpose: purpose,
            vote_threshold_to_revoke: vote_threshold_to_revoke,
            burn_funds_on_revoke: burn_funds_on_revoke,
            amount_available: 0,
            lifetime_pledged: 0,
            lifetime_withdrawn: 0,
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

<a name="0x1_PledgeAccounts_maybe_initialize_my_pledges"></a>

## Function `maybe_initialize_my_pledges`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_maybe_initialize_my_pledges">maybe_initialize_my_pledges</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_maybe_initialize_my_pledges">maybe_initialize_my_pledges</a>(account: &signer) {
    <b>if</b> (!<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account))) {
        <b>let</b> my_pledges = <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> { list: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>() };
        <b>move_to</b>(account, my_pledges);
    }
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_save_pledge"></a>

## Function `save_pledge`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_save_pledge">save_pledge</a>(sig: &signer, address_of_beneficiary: <b>address</b>, pledge: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_save_pledge">save_pledge</a>(
  sig: &signer,
  address_of_beneficiary: <b>address</b>,
  pledge: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;
  ) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="PledgeAccounts.md#0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY">ENO_BENEFICIARY_POLICY</a>));
    <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
    <b>let</b> (found, idx) = <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(&sender_addr, &address_of_beneficiary);
    <b>if</b> (found) {
      <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_coin_to_pledge_account">add_coin_to_pledge_account</a>(sig, idx, <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&pledge), pledge)
    } <b>else</b> {
      <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">create_pledge_account</a>(sig, address_of_beneficiary, pledge)
    }
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_create_pledge_account"></a>

## Function `create_pledge_account`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">create_pledge_account</a>(sig: &signer, address_of_beneficiary: <b>address</b>, init_pledge: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_create_pledge_account">create_pledge_account</a>(
  sig: &signer,
  // project_id: vector&lt;u8&gt;,
  address_of_beneficiary: <b>address</b>,
  init_pledge: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;,
) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
    <a href="PledgeAccounts.md#0x1_PledgeAccounts_maybe_initialize_my_pledges">maybe_initialize_my_pledges</a>(sig);
    <b>let</b> my_pledges = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(account);
    <b>let</b> value = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&init_pledge);
    <b>let</b> new_pledge_account = <a href="PledgeAccounts.md#0x1_PledgeAccounts_PledgeAccount">PledgeAccount</a> {
        // project_id: project_id,
        address_of_beneficiary: address_of_beneficiary,
        amount: value,
        pledge: init_pledge,
        epoch_of_last_deposit: <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>(),
        lifetime_pledged: value,
        lifetime_withdrawn: 0
    };
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> my_pledges.list, new_pledge_account);

  <b>let</b> b = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> b.pledgers, account);

  b.amount_available = b.amount_available  + value;
  b.lifetime_pledged = b.lifetime_pledged + value;
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_add_coin_to_pledge_account"></a>

## Function `add_coin_to_pledge_account`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_coin_to_pledge_account">add_coin_to_pledge_account</a>(sender: &signer, idx: u64, amount: u64, coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_coin_to_pledge_account">add_coin_to_pledge_account</a>(sender: &signer, idx: u64, amount: u64, coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  <b>let</b> sender_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // <b>let</b> (found, _idx) = <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(&sender_addr, &address_of_beneficiary);

  <b>let</b> my_pledges = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(sender_addr);
  <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> my_pledges.list, idx);

  pledge_account.amount = pledge_account.amount + amount;
  pledge_account.epoch_of_last_deposit = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
  pledge_account.lifetime_pledged = pledge_account.lifetime_pledged + amount;

  // merge the coins in the account
  <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> pledge_account.pledge, coin);

  // must add pledger <b>address</b> the ProjectPledgers list on beneficiary account

  <b>let</b> b = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(pledge_account.address_of_beneficiary);
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> b.pledgers, sender_addr);

  b.amount_available = b.amount_available  + amount;
  b.lifetime_pledged = b.lifetime_pledged + amount;

  // exits silently <b>if</b> nothing is found.
  // this is <b>to</b> prevent halting in the event that a VM route is calling the function and is unable <b>to</b> check the <b>return</b> value.
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_withdraw_from_all_pledge_accounts"></a>

## Function `withdraw_from_all_pledge_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">withdraw_from_all_pledge_accounts</a>(sig_beneficiary: &signer, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_all_pledge_accounts">withdraw_from_all_pledge_accounts</a>(sig_beneficiary: &signer, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt; <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
    <b>let</b> pledgers = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig_beneficiary)).pledgers;

    <b>let</b> amount_available = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig_beneficiary)).amount_available;
    // print(&amount_available);
    // print(&amount);

    <b>if</b> (amount_available &lt; 1) {
      <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;()
    };

    <b>let</b> pct_withdraw = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(amount, amount_available);

    <b>let</b> address_of_beneficiary = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig_beneficiary);

    <b>let</b> i = 0;
    <b>let</b> all_coins = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;();

    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pledgers)) {
        <b>let</b> pledge_account = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pledgers, i);

        // DANGER: this is a private function that changes balances.
        <b>let</b> c = <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_pct_from_one_pledge_account">withdraw_pct_from_one_pledge_account</a>(&address_of_beneficiary, &pledge_account, &pct_withdraw);



        // GROSS: dealing <b>with</b> options in Move.
        // TODO: find a better way.
        <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_none">Option::is_none</a>(&all_coins) && <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&c)) {
          <b>let</b> coin =  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> c);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_fill">Option::fill</a>(&<b>mut</b> all_coins, coin);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
          // <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        } <b>else</b> <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&c)) {
          <b>let</b> temp = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> all_coins);
          <b>let</b> coin =  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> c);
          <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> temp, coin);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(all_coins);
          all_coins = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(temp);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        } <b>else</b> {
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        };

        i = i + 1;
    };

  all_coins
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_withdraw_from_one_pledge_account"></a>

## Function `withdraw_from_one_pledge_account`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt; <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {

    <b>let</b> (found, idx) = <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(payer, address_of_beneficiary);

    <b>if</b> (found) {
      <b>let</b> pledge_state = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*payer);

      <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> pledge_state.list, idx);
      // print(&66);
      // print(&pledge_account.amount);
      <b>if</b> (
        pledge_account.amount &gt; 0 &&
        pledge_account.amount &gt;= amount

        ) {
          // print(&1101);
          pledge_account.amount = pledge_account.amount - amount;
          // print(&1102);
          pledge_account.lifetime_withdrawn = pledge_account.lifetime_withdrawn + amount;
          // print(&1103);

          <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> pledge_account.pledge, amount);
          // print(&coin);
          // <b>return</b> coin

          // <b>update</b> the beneficiaries state too

          <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*address_of_beneficiary);

          // print(&bp.amount_available);
          bp.amount_available = bp.amount_available - amount;
          // print(&1104);
          // print(&bp.amount_available);
          bp.lifetime_withdrawn = bp.lifetime_withdrawn + amount;
          // print(&1105);

          <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(coin)
        };
    };

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_withdraw_pct_from_one_pledge_account"></a>

## Function `withdraw_pct_from_one_pledge_account`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_pct_from_one_pledge_account">withdraw_pct_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, pct: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_pct_from_one_pledge_account">withdraw_pct_from_one_pledge_account</a>(address_of_beneficiary: &<b>address</b>, payer: &<b>address</b>, pct: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt; <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {

    <b>let</b> (found, idx) = <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(payer, address_of_beneficiary);

    <b>if</b> (found) {
      <b>let</b> pledge_state = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*payer);

      <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> pledge_state.list, idx);

      <b>let</b> amount_withdraw = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(pledge_account.amount, *pct);

      // print(&amount_withdraw);
      // print(&pledge_account.amount);
      <b>if</b> (
        pledge_account.amount &gt; 0 &&
        pledge_account.amount &gt;= amount_withdraw

        ) {
          // print(&1101);
          pledge_account.amount = pledge_account.amount - amount_withdraw;
          // print(&1102);
          pledge_account.lifetime_withdrawn = pledge_account.lifetime_withdrawn + amount_withdraw;
          // print(&1103);

          <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> pledge_account.pledge, amount_withdraw);
          // print(&coin);
          // <b>return</b> coin

          // <b>update</b> the beneficiaries state too

          <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*address_of_beneficiary);

          // print(&bp.amount_available);
          bp.amount_available = bp.amount_available - amount_withdraw;
          // print(&1104);
          // print(&bp.amount_available);
          bp.lifetime_withdrawn = bp.lifetime_withdrawn + amount_withdraw;
          // print(&1105);

          <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_some">Option::some</a>(coin)
        };
    };

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_none">Option::none</a>()
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
    <b>let</b> user_pledge_balance = <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_user_pledge_amount">get_user_pledge_amount</a>(&pledger, &address_of_beneficiary);
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> bp.table_votes_to_revoke, user_pledge_balance);
    bp.total_revoke_vote = bp.total_revoke_vote + user_pledge_balance;

    // The first voter <b>to</b> cross the threshold  also
    // triggers the dissolution.
    <b>if</b> (<a href="PledgeAccounts.md#0x1_PledgeAccounts_tally_vote">tally_vote</a>(address_of_beneficiary)) {
      // print(&444);
      <a href="PledgeAccounts.md#0x1_PledgeAccounts_dissolve_beneficiary_project">dissolve_beneficiary_project</a>(address_of_beneficiary);
    };
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
    <b>let</b> amount_available = bp.amount_available;
    <b>let</b> total_revoke_vote = bp.total_revoke_vote;

    // TODO: <b>use</b> FixedPoint here.
    <b>let</b> ratio = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(total_revoke_vote, amount_available);
    <b>let</b> pct = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(100, ratio);
    <b>if</b> (pct &gt; bp.vote_threshold_to_revoke) {
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
    // print(&888888888);
    <b>let</b> pledgers = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary).pledgers;

    <b>let</b> is_burn = *&<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary).burn_funds_on_revoke;

    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&pledgers)) {
        // print(&888);
        <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&pledgers, i);
        <b>let</b> user_pledge_balance = <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_user_pledge_amount">get_user_pledge_amount</a>(pledge_account, &address_of_beneficiary);
        // print(&user_pledge_balance);
        <b>let</b> c = <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(&address_of_beneficiary, pledge_account, user_pledge_balance);
        // print(&coin);

        // TODO: <b>if</b> burn case.
        <b>if</b> (is_burn && <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&c)) {
          <b>let</b> burn_this = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> c);
          <a href="Diem.md#0x1_Diem_friend_burn_this_coin">Diem::friend_burn_this_coin</a>(burn_this);
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        } <b>else</b> <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_is_some">Option::is_some</a>(&c)) {
          <b>let</b> refund_coin = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_extract">Option::extract</a>(&<b>mut</b> c);
          <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>(
            address_of_beneficiary,
            *pledge_account,
            refund_coin,
            b"revoke pledge",
            b"", // TODO: clean this up in <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>.
            <b>false</b>, // TODO: clean this up in <a href="DiemAccount.md#0x1_DiemAccount">DiemAccount</a>.
          ) ;
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        } <b>else</b> {
          <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_destroy_none">Option::destroy_none</a>(c);
        };


        i = i + 1;
    };

  <b>let</b> bp = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(address_of_beneficiary);
  bp.revoked = <b>true</b>;
  // print(&bp.revoked);

  // otherwise leave the information <b>as</b>-is for reference purposes
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_genesis_infra_escrow_pledge"></a>

## Function `genesis_infra_escrow_pledge`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_genesis_infra_escrow_pledge">genesis_infra_escrow_pledge</a>(vm: &signer, account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_genesis_infra_escrow_pledge">genesis_infra_escrow_pledge</a>(vm: &signer, account: &signer) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  // TODO: add genesis time here, once the timestamp genesis issue is fixed.
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);

  <b>let</b> coin = <a href="DiemAccount.md#0x1_DiemAccount_vm_withdraw">DiemAccount::vm_withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, addr, 2500000);
  <a href="PledgeAccounts.md#0x1_PledgeAccounts_save_pledge">save_pledge</a>(account, @VMReserved, coin);
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_user_pledge_tx"></a>

## Function `user_pledge_tx`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_user_pledge_tx">user_pledge_tx</a>(user_sig: signer, beneficiary: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_user_pledge_tx">user_pledge_tx</a>(user_sig: signer, beneficiary: <b>address</b>, amount: u64)  <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
  <b>let</b> coin = <a href="DiemAccount.md#0x1_DiemAccount_simple_withdrawal">DiemAccount::simple_withdrawal</a>(&user_sig, amount);
  <a href="PledgeAccounts.md#0x1_PledgeAccounts_save_pledge">save_pledge</a>(&user_sig, beneficiary, coin);
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_pledge_at_idx"></a>

## Function `pledge_at_idx`



<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): (bool, u64) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*account)) {
  <b>let</b> my_pledges = &<b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*account).list;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(my_pledges)) {
        <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(my_pledges, i);
        <b>if</b> (&p.address_of_beneficiary == address_of_beneficiary) {
            <b>return</b> (<b>true</b>, i)
        };
        i = i + 1;
    };
  };
  (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_user_pledge_amount"></a>

## Function `get_user_pledge_amount`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_user_pledge_amount">get_user_pledge_amount</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_user_pledge_amount">get_user_pledge_amount</a>(account: &<b>address</b>, address_of_beneficiary: &<b>address</b>): u64 <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
    <b>let</b> (found, idx) = <a href="PledgeAccounts.md#0x1_PledgeAccounts_pledge_at_idx">pledge_at_idx</a>(account, address_of_beneficiary);
    <b>if</b> (found) {
      <b>let</b> my_pledges = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(*account);
      <b>let</b> p = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&my_pledges.list, idx);
      <b>return</b> p.amount
    };
    <b>return</b> 0
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_available_to_beneficiary"></a>

## Function `get_available_to_beneficiary`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_available_to_beneficiary">get_available_to_beneficiary</a>(bene: &<b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_available_to_beneficiary">get_available_to_beneficiary</a>(bene: &<b>address</b>): u64 <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene)) {
    <b>let</b> bp = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene);
    <b>return</b> bp.amount_available
  };
  0
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_lifetime_to_beneficiary"></a>

## Function `get_lifetime_to_beneficiary`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_lifetime_to_beneficiary">get_lifetime_to_beneficiary</a>(bene: &<b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_lifetime_to_beneficiary">get_lifetime_to_beneficiary</a>(bene: &<b>address</b>): (u64, u64)<b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene)) {
    <b>let</b> bp = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene);
    <b>return</b> (bp.lifetime_pledged, bp.lifetime_withdrawn)
  };
  (0, 0)
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_all_pledgers"></a>

## Function `get_all_pledgers`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_all_pledgers">get_all_pledgers</a>(bene: &<b>address</b>): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_all_pledgers">get_all_pledgers</a>(bene: &<b>address</b>): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene)) {
    <b>let</b> bp = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene);
    <b>return</b> *&bp.pledgers
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;()
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_get_revoke_vote"></a>

## Function `get_revoke_vote`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_revoke_vote">get_revoke_vote</a>(bene: &<b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_revoke_vote">get_revoke_vote</a>(bene: &<b>address</b>): (bool, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
  <b>let</b> null = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_raw_value">FixedPoint32::create_from_raw_value</a>(0);
  <b>if</b> (<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene)) {
    <b>let</b> bp = <b>borrow_global</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(*bene);
    <b>if</b> (bp.revoked) {
      <b>return</b> (<b>true</b>, null)
    } <b>else</b> <b>if</b> (
      bp.total_revoke_vote &gt; 0 &&
      bp.amount_available &gt; 0
    ) {
      <b>return</b> (
        <b>false</b>,
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(bp.total_revoke_vote, bp.amount_available)
      )
    }
  };
  (<b>false</b>, null)
}
</code></pre>



</details>

<a name="0x1_PledgeAccounts_test_single_withdrawal"></a>

## Function `test_single_withdrawal`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_test_single_withdrawal">test_single_withdrawal</a>(vm: &signer, bene: &<b>address</b>, donor: &<b>address</b>, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_test_single_withdrawal">test_single_withdrawal</a>(vm: &signer, bene: &<b>address</b>, donor: &<b>address</b>, amount: u64): <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt; <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>, <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>{
  <a href="Testnet.md#0x1_Testnet_assert_testnet">Testnet::assert_testnet</a>(vm);
  <a href="PledgeAccounts.md#0x1_PledgeAccounts_withdraw_from_one_pledge_account">withdraw_from_one_pledge_account</a>(bene, donor, amount)
}
</code></pre>



</details>
