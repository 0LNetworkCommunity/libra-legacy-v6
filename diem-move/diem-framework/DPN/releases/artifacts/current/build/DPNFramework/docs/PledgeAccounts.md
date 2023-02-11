
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



<pre><code><b>struct</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> <b>has</b> store, key
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
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY"></a>



<pre><code><b>const</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_ENO_BENEFICIARY_POLICY">ENO_BENEFICIARY_POLICY</a>: u64 = 150001;
</code></pre>



<a name="0x1_PledgeAccounts_publish_beneficiary_policy"></a>

## Function `publish_beneficiary_policy`



<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(account: &signer, purpose: vector&lt;u8&gt;, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_publish_beneficiary_policy">publish_beneficiary_policy</a>(account: &signer, purpose: vector&lt;u8&gt;, vote_threshold_to_revoke: u64, burn_funds_on_revoke: bool) {
    <b>if</b> (!<b>exists</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account))) {
        <b>let</b> beneficiary_policy = <a href="PledgeAccounts.md#0x1_PledgeAccounts_BeneficiaryPolicy">BeneficiaryPolicy</a> {
            purpose: purpose,
            vote_threshold_to_revoke: vote_threshold_to_revoke,
            burn_funds_on_revoke: burn_funds_on_revoke
        };
        <b>move_to</b>(account, beneficiary_policy);
    }
    // TODO: make the controllers <b>to</b> be able <b>to</b> modify the policy <b>as</b> long <b>as</b> no pledge <b>has</b> been made.
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


<pre><code><b>public</b> <b>fun</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_add_funds_to_pledge_account">add_funds_to_pledge_account</a>(account: &signer, address_of_beneficiary: <b>address</b>, amount: u64) <b>acquires</b> <a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a> {
    <b>let</b> my_pledges = <b>borrow_global_mut</b>&lt;<a href="PledgeAccounts.md#0x1_PledgeAccounts_MyPledges">MyPledges</a>&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account));
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&my_pledges.list)) {
        <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&my_pledges.list, i).address_of_beneficiary == address_of_beneficiary) {
            <b>let</b> pledge_account = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> my_pledges.list, i);
            pledge_account.amount = pledge_account.amount + amount;
            pledge_account.epoch_of_last_deposit = <a href="DiemConfig.md#0x1_DiemConfig_get_current_epoch">DiemConfig::get_current_epoch</a>();
            pledge_account.lifetime_deposited = pledge_account.lifetime_deposited + amount;
            <b>break</b>
        };
        i = i + 1;
    };

  // exits silently <b>if</b> nothing is found.
  // this is <b>to</b> prevent halting in the event that a VM route is calling the function and is unable <b>to</b> check the <b>return</b> value.
}
</code></pre>



</details>
