
<a name="0x1_TransactionFee"></a>

# Module `0x1::TransactionFee`



-  [Resource `TransactionFee`](#0x1_TransactionFee_TransactionFee)
-  [Resource `FeeMaker`](#0x1_TransactionFee_FeeMaker)
-  [Resource `EpochFeeMakerRegistry`](#0x1_TransactionFee_EpochFeeMakerRegistry)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_TransactionFee_initialize)
-  [Function `is_coin_initialized`](#0x1_TransactionFee_is_coin_initialized)
-  [Function `is_initialized`](#0x1_TransactionFee_is_initialized)
-  [Function `add_txn_fee_currency`](#0x1_TransactionFee_add_txn_fee_currency)
-  [Function `pay_fee`](#0x1_TransactionFee_pay_fee)
-  [Function `pay_fee_and_track`](#0x1_TransactionFee_pay_fee_and_track)
-  [Function `burn_fees`](#0x1_TransactionFee_burn_fees)
    -  [Specification of the case where burn type is XDX.](#@Specification_of_the_case_where_burn_type_is_XDX._1)
    -  [Specification of the case where burn type is not XDX.](#@Specification_of_the_case_where_burn_type_is_not_XDX._2)
-  [Function `get_fees_collected`](#0x1_TransactionFee_get_fees_collected)
-  [Function `vm_withdraw_all_coins`](#0x1_TransactionFee_vm_withdraw_all_coins)
-  [Function `get_transaction_fees_coins_amount`](#0x1_TransactionFee_get_transaction_fees_coins_amount)
-  [Function `initialize_epoch_fee_maker_registry`](#0x1_TransactionFee_initialize_epoch_fee_maker_registry)
-  [Function `initialize_fee_maker`](#0x1_TransactionFee_initialize_fee_maker)
-  [Function `epoch_reset_fee_maker`](#0x1_TransactionFee_epoch_reset_fee_maker)
-  [Function `reset_one_fee_maker`](#0x1_TransactionFee_reset_one_fee_maker)
-  [Function `track_user_fee`](#0x1_TransactionFee_track_user_fee)
-  [Function `get_fee_makers`](#0x1_TransactionFee_get_fee_makers)
-  [Function `get_epoch_fees_made`](#0x1_TransactionFee_get_epoch_fees_made)
-  [Module Specification](#@Module_Specification_3)
    -  [Initialization](#@Initialization_4)
    -  [Helper Function](#@Helper_Function_5)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Roles.md#0x1_Roles">0x1::Roles</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="XDX.md#0x1_XDX">0x1::XDX</a>;
</code></pre>



<a name="0x1_TransactionFee_TransactionFee"></a>

## Resource `TransactionFee`

The <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource holds a preburn resource for each
fiat <code>CoinType</code> that can be collected as a transaction fee.


<pre><code><b>struct</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>balance: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>preburn: <a href="Diem.md#0x1_Diem_Preburn">Diem::Preburn</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TransactionFee_FeeMaker"></a>

## Resource `FeeMaker`

FeeMaker struct lives on an individual's account
We check how many fees the user has paid.
This will interact with Burn preferences when there is a remainder of fees in the TransactionFee account


<pre><code><b>struct</b> <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lifetime: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TransactionFee_EpochFeeMakerRegistry"></a>

## Resource `EpochFeeMakerRegistry`

We need a list of who is producing fees this epoch.
This lives on the VM address


<pre><code><b>struct</b> <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>fee_makers: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TransactionFee_ETRANSACTION_FEE"></a>

A <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource is not in the required state


<pre><code><b>const</b> <a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>: u64 = 20000;
</code></pre>



<a name="0x1_TransactionFee_initialize"></a>

## Function `initialize`

Called in genesis. Sets up the needed resources to collect transaction fees from the
<code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resource with the TreasuryCompliance account.


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize">initialize</a>(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize">initialize</a>(
    dr_account: &signer, /////// 0L /////////
) {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    // accept fees in all the currencies
    <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(dr_account); /////// 0L /////////
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
<b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: dr_account};
<b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf">AddTxnFeeCurrencyAbortsIf</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;;
<b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>();
<b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;().balance.value == 0;
</code></pre>




<a name="0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_AddTxnFeeCurrencyAbortsIf">AddTxnFeeCurrencyAbortsIf</a>&lt;CoinType&gt; {
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;CoinType&gt;;
    <b>aborts_if</b> <b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
        <b>with</b> Errors::ALREADY_PUBLISHED;
}
</code></pre>



</details>

<a name="0x1_TransactionFee_is_coin_initialized"></a>

## Function `is_coin_initialized`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(): bool {
    <b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
}
</code></pre>



</details>

<a name="0x1_TransactionFee_is_initialized"></a>

## Function `is_initialized`



<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>(): bool {
    <a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;() //////// 0L ////////
}
</code></pre>



</details>

<a name="0x1_TransactionFee_add_txn_fee_currency"></a>

## Function `add_txn_fee_currency`

Sets up the needed transaction fee state for a given <code>CoinType</code> currency by
(1) configuring <code>dr_account</code> to accept <code>CoinType</code>
(2) publishing a wrapper of the <code>Preburn&lt;CoinType&gt;</code> resource under <code>dr_account</code>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;CoinType&gt;(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_add_txn_fee_currency">add_txn_fee_currency</a>&lt;CoinType&gt;(dr_account: &signer) {
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    <a href="Diem.md#0x1_Diem_assert_is_currency">Diem::assert_is_currency</a>&lt;CoinType&gt;();
    <b>assert</b>!(
        !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(),
        <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>)
    );
    <b>move_to</b>(
        dr_account,
        <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; {
            balance: <a href="Diem.md#0x1_Diem_zero">Diem::zero</a>(),
            preburn: <a href="Diem.md#0x1_Diem_create_preburn">Diem::create_preburn</a>(dr_account)
        }
    )
}
</code></pre>



</details>

<a name="0x1_TransactionFee_pay_fee"></a>

## Function `pay_fee`

Deposit <code>coin</code> into the transaction fees bucket


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">pay_fee</a>&lt;CoinType&gt;(coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee">pay_fee</a>&lt;CoinType&gt;(coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <b>assert</b>!(<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>));
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance); // TODO: this is just the VM root actually
    <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> fees.balance, coin);
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeAbortsIf">PayFeeAbortsIf</a>&lt;CoinType&gt;;
<b>include</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeEnsures">PayFeeEnsures</a>&lt;CoinType&gt;;
</code></pre>




<a name="0x1_TransactionFee_PayFeeAbortsIf"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeAbortsIf">PayFeeAbortsIf</a>&lt;CoinType&gt; {
    coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;;
    <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
    <b>aborts_if</b> !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;() <b>with</b> Errors::NOT_PUBLISHED;
    <b>include</b> <a href="Diem.md#0x1_Diem_DepositAbortsIf">Diem::DepositAbortsIf</a>&lt;CoinType&gt;{coin: fees, check: coin};
}
</code></pre>




<a name="0x1_TransactionFee_PayFeeEnsures"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_PayFeeEnsures">PayFeeEnsures</a>&lt;CoinType&gt; {
    coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;;
    <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>let</b> <b>post</b> post_fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance;
    <b>ensures</b> post_fees.value == fees.value + coin.value;
}
</code></pre>



</details>

<a name="0x1_TransactionFee_pay_fee_and_track"></a>

## Function `pay_fee_and_track`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee_and_track">pay_fee_and_track</a>&lt;CoinType&gt;(user: <b>address</b>, coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_pay_fee_and_track">pay_fee_and_track</a>&lt;CoinType&gt;(user: <b>address</b>, coin: <a href="Diem.md#0x1_Diem">Diem</a>&lt;CoinType&gt;) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>, <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>, <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <b>assert</b>!(<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>));
    <b>let</b> amount = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&coin);
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance); // TODO: this is just the VM root actually
    <a href="Diem.md#0x1_Diem_deposit">Diem::deposit</a>(&<b>mut</b> fees.balance, coin);
    <a href="TransactionFee.md#0x1_TransactionFee_track_user_fee">track_user_fee</a>(user, amount);
}
</code></pre>



</details>

<a name="0x1_TransactionFee_burn_fees"></a>

## Function `burn_fees`

Preburns the transaction fees collected in the <code>CoinType</code> currency.
If the <code>CoinType</code> is XDX, it unpacks the coin and preburns the
underlying fiat.


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_burn_fees">burn_fees</a>&lt;CoinType&gt;(dr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_burn_fees">burn_fees</a>&lt;CoinType&gt;(
    dr_account: &signer,
) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_operating">DiemTimestamp::assert_operating</a>();
    <a href="Roles.md#0x1_Roles_assert_diem_root">Roles::assert_diem_root</a>(dr_account); /////// 0L /////////
    <b>assert</b>!(<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_not_published">Errors::not_published</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>));
    <b>if</b> (<a href="XDX.md#0x1_XDX_is_xdx">XDX::is_xdx</a>&lt;CoinType&gt;()) {
        // TODO: Once the composition of <a href="XDX.md#0x1_XDX">XDX</a> is determined fill this in <b>to</b>
        // unpack and burn the backing coins of the <a href="XDX.md#0x1_XDX">XDX</a> coin.
        <b>abort</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="TransactionFee.md#0x1_TransactionFee_ETRANSACTION_FEE">ETRANSACTION_FEE</a>)
    } <b>else</b> {
        // extract fees
        <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance);
        <b>let</b> coin = <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance);
        <b>let</b> burn_cap = <a href="Diem.md#0x1_Diem_remove_burn_capability">Diem::remove_burn_capability</a>&lt;CoinType&gt;(dr_account);
        // burn
        <a href="Diem.md#0x1_Diem_burn_now">Diem::burn_now</a>(
            coin,
            &<b>mut</b> fees.preburn,
            @TreasuryCompliance,
            &burn_cap
        );
        <a href="Diem.md#0x1_Diem_publish_burn_capability">Diem::publish_burn_capability</a>(dr_account, burn_cap);
    }
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> disable_invariants_in_body;
</code></pre>


Must abort if the account does not have the TreasuryCompliance role [[H3]][PERMISSION].


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: dr_account};
<b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotOperating">DiemTimestamp::AbortsIfNotOperating</a>;
<b>aborts_if</b> !<a href="TransactionFee.md#0x1_TransactionFee_is_coin_initialized">is_coin_initialized</a>&lt;CoinType&gt;() <b>with</b> Errors::NOT_PUBLISHED;
<b>include</b> <b>if</b> (<a href="XDX.md#0x1_XDX_spec_is_xdx">XDX::spec_is_xdx</a>&lt;CoinType&gt;()) <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesXDX">BurnFeesXDX</a> <b>else</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesNotXDX">BurnFeesNotXDX</a>&lt;CoinType&gt;;
</code></pre>


The correct amount of fees is burnt and subtracted from market cap.


<pre><code><b>ensures</b> <a href="Diem.md#0x1_Diem_spec_market_cap">Diem::spec_market_cap</a>&lt;CoinType&gt;()
    == <b>old</b>(<a href="Diem.md#0x1_Diem_spec_market_cap">Diem::spec_market_cap</a>&lt;CoinType&gt;()) - <b>old</b>(<a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance.value);
</code></pre>


All the fees is burnt so the balance becomes 0.


<pre><code><b>ensures</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;().balance.value == 0;
</code></pre>


STUB: To be filled in at a later date once the makeup of the XDX has been determined.


<a name="@Specification_of_the_case_where_burn_type_is_XDX._1"></a>

### Specification of the case where burn type is XDX.



<a name="0x1_TransactionFee_BurnFeesXDX"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesXDX">BurnFeesXDX</a> {
    dr_account: signer;
    <b>aborts_if</b> <b>true</b> <b>with</b> Errors::INVALID_STATE;
}
</code></pre>



<a name="@Specification_of_the_case_where_burn_type_is_not_XDX._2"></a>

### Specification of the case where burn type is not XDX.



<a name="0x1_TransactionFee_BurnFeesNotXDX"></a>


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesNotXDX">BurnFeesNotXDX</a>&lt;CoinType&gt; {
    dr_account: signer;
}
</code></pre>


Must abort if the account does not have BurnCapability [[H3]][PERMISSION].


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesNotXDX">BurnFeesNotXDX</a>&lt;CoinType&gt; {
    <b>include</b> <a href="Diem.md#0x1_Diem_AbortsIfNoBurnCapability">Diem::AbortsIfNoBurnCapability</a>&lt;CoinType&gt;{account: dr_account};
    <b>let</b> fees = <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;();
    <b>include</b> <a href="Diem.md#0x1_Diem_BurnNowAbortsIf">Diem::BurnNowAbortsIf</a>&lt;CoinType&gt;{coin: fees.balance, preburn: fees.preburn};
}
</code></pre>


dr_account retrieves BurnCapability [[H3]][PERMISSION].
BurnCapability is not transferrable [[J3]][PERMISSION].


<pre><code><b>schema</b> <a href="TransactionFee.md#0x1_TransactionFee_BurnFeesNotXDX">BurnFeesNotXDX</a>&lt;CoinType&gt; {
    <b>ensures</b> <b>exists</b>&lt;<a href="Diem.md#0x1_Diem_BurnCapability">Diem::BurnCapability</a>&lt;CoinType&gt;&gt;(<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(dr_account));
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_fees_collected"></a>

## Function `get_fees_collected`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">get_fees_collected</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_fees_collected">get_fees_collected</a>(): u64 <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    // <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;&gt;(
        @DiemRoot
    );

    <b>let</b> amount_collected = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&fees.balance);
    amount_collected
}
</code></pre>



</details>

<a name="0x1_TransactionFee_vm_withdraw_all_coins"></a>

## Function `vm_withdraw_all_coins`

only to be used by VM through the Burn.move module


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_vm_withdraw_all_coins">vm_withdraw_all_coins</a>&lt;Token: store&gt;(dr_account: &signer): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_vm_withdraw_all_coins">vm_withdraw_all_coins</a>&lt;Token: store&gt;(
    dr_account: &signer
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt; <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;Token&gt;&gt;(
        @DiemRoot
    );

    <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance)

}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_transaction_fees_coins_amount"></a>

## Function `get_transaction_fees_coins_amount`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">get_transaction_fees_coins_amount</a>&lt;Token: store&gt;(dr_account: &signer, withdraw: u64): <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;Token&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins_amount">get_transaction_fees_coins_amount</a>&lt;Token: store&gt;(
    dr_account: &signer, withdraw: u64
): <a href="Diem.md#0x1_Diem">Diem</a>&lt;Token&gt;  <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> {
    // Can only be invoked by DiemVM privilege.
    // Allowed association <b>to</b> invoke for testing purposes.
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(dr_account);
    // TODO: Return <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a> gracefully <b>if</b> there ino 0xFEE balance
    // <a href="DiemAccount.md#0x1_DiemAccount_balance">DiemAccount::balance</a>&lt;Token&gt;(0xFEE);
    <b>let</b> fees = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;Token&gt;&gt;(
        @DiemRoot
    );

    <b>let</b> amount_collected = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(&fees.balance);
    <b>if</b> ((amount_collected &gt; withdraw) && (withdraw &gt; 0)) {
      <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> fees.balance, withdraw)
    } <b>else</b> {
       <a href="Diem.md#0x1_Diem_withdraw_all">Diem::withdraw_all</a>(&<b>mut</b> fees.balance)
    }

}
</code></pre>



</details>

<a name="0x1_TransactionFee_initialize_epoch_fee_maker_registry"></a>

## Function `initialize_epoch_fee_maker_registry`

Initialize the registry at the VM address.


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize_epoch_fee_maker_registry">initialize_epoch_fee_maker_registry</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize_epoch_fee_maker_registry">initialize_epoch_fee_maker_registry</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> registry = <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a> {
    fee_makers: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
  };
  <b>move_to</b>(vm, registry);
}
</code></pre>



</details>

<a name="0x1_TransactionFee_initialize_fee_maker"></a>

## Function `initialize_fee_maker`

FeeMaker is initialized when the account is created


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize_fee_maker">initialize_fee_maker</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_initialize_fee_maker">initialize_fee_maker</a>(account: &signer) {
  <b>let</b> fee_maker = <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a> {
    epoch: 0,
    lifetime: 0,
  };
  <b>move_to</b>(account, fee_maker);
}
</code></pre>



</details>

<a name="0x1_TransactionFee_epoch_reset_fee_maker"></a>

## Function `epoch_reset_fee_maker`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_epoch_reset_fee_maker">epoch_reset_fee_maker</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_epoch_reset_fee_maker">epoch_reset_fee_maker</a>(vm: &signer) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a>, <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> registry = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a>&gt;(@VMReserved);
  <b>let</b> fee_makers = &registry.fee_makers;

  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(fee_makers)) {
    <b>let</b> account = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(fee_makers, i);
    <a href="TransactionFee.md#0x1_TransactionFee_reset_one_fee_maker">reset_one_fee_maker</a>(vm, account);
    i = i + 1;
  };
  registry.fee_makers = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>();
}
</code></pre>



</details>

<a name="0x1_TransactionFee_reset_one_fee_maker"></a>

## Function `reset_one_fee_maker`

FeeMaker is reset at the epoch boundary, and the lifetime is updated.


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_reset_one_fee_maker">reset_one_fee_maker</a>(vm: &signer, account: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_reset_one_fee_maker">reset_one_fee_maker</a>(vm: &signer, account: <b>address</b>) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> fee_maker = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>&gt;(account);
    fee_maker.lifetime = fee_maker.lifetime + fee_maker.epoch;
    fee_maker.epoch = 0;
}
</code></pre>



</details>

<a name="0x1_TransactionFee_track_user_fee"></a>

## Function `track_user_fee`

add a fee to the account fee maker for an epoch
PRIVATE function


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_track_user_fee">track_user_fee</a>(account: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_track_user_fee">track_user_fee</a>(account: <b>address</b>, amount: u64) <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>, <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>&gt;(account)) {
    <b>return</b>
  };

  <b>let</b> fee_maker = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>&gt;(account);
  fee_maker.epoch = fee_maker.epoch + amount;

  // <b>update</b> the registry
  <b>let</b> registry = <b>borrow_global_mut</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a>&gt;(@VMReserved);
  <b>if</b> (!<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&registry.fee_makers, &account)) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> registry.fee_makers, account);
  }
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_fee_makers"></a>

## Function `get_fee_makers`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_fee_makers">get_fee_makers</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_fee_makers">get_fee_makers</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a> {
  <b>let</b> registry = <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_EpochFeeMakerRegistry">EpochFeeMakerRegistry</a>&gt;(@VMReserved);
  *&registry.fee_makers
}
</code></pre>



</details>

<a name="0x1_TransactionFee_get_epoch_fees_made"></a>

## Function `get_epoch_fees_made`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_epoch_fees_made">get_epoch_fees_made</a>(account: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_get_epoch_fees_made">get_epoch_fees_made</a>(account: <b>address</b>): u64 <b>acquires</b> <a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>&gt;(account)) {
    <b>return</b> 0
  };
  <b>let</b> fee_maker = <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee_FeeMaker">FeeMaker</a>&gt;(account);
  fee_maker.epoch
}
</code></pre>



</details>

<a name="@Module_Specification_3"></a>

## Module Specification



<a name="@Initialization_4"></a>

### Initialization


If time has started ticking, then <code><a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a></code> resources have been initialized.


<pre><code><b>invariant</b> [suspendable] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <a href="TransactionFee.md#0x1_TransactionFee_is_initialized">is_initialized</a>();
</code></pre>



<a name="@Helper_Function_5"></a>

### Helper Function



<a name="0x1_TransactionFee_spec_transaction_fee"></a>


<pre><code><b>fun</b> <a href="TransactionFee.md#0x1_TransactionFee_spec_transaction_fee">spec_transaction_fee</a>&lt;CoinType&gt;(): <a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt; {
   <b>borrow_global</b>&lt;<a href="TransactionFee.md#0x1_TransactionFee">TransactionFee</a>&lt;CoinType&gt;&gt;(@TreasuryCompliance)
}
</code></pre>
