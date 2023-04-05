
<a name="0x1_Burn"></a>

# Module `0x1::Burn`



-  [Resource `BurnPreference`](#0x1_Burn_BurnPreference)
-  [Resource `DepositInfo`](#0x1_Burn_DepositInfo)
-  [Function `epoch_burn_fees`](#0x1_Burn_epoch_burn_fees)
-  [Function `reset_ratios`](#0x1_Burn_reset_ratios)
-  [Function `get_address_list`](#0x1_Burn_get_address_list)
-  [Function `get_payee_value`](#0x1_Burn_get_payee_value)
-  [Function `burn_or_recycle_user_fees`](#0x1_Burn_burn_or_recycle_user_fees)
-  [Function `recycle`](#0x1_Burn_recycle)
-  [Function `set_send_community`](#0x1_Burn_set_send_community)
-  [Function `get_ratios`](#0x1_Burn_get_ratios)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DonorDirected.md#0x1_DonorDirected">0x1::DonorDirected</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Burn_BurnPreference"></a>

## Resource `BurnPreference`



<pre><code><b>struct</b> <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>send_community: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Burn_DepositInfo"></a>

## Resource `DepositInfo`



<pre><code><b>struct</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>addr: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>deposits: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>ratio: vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Burn_epoch_burn_fees"></a>

## Function `epoch_burn_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_epoch_burn_fees">epoch_burn_fees</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_epoch_burn_fees">epoch_burn_fees</a>(
    vm: &signer,
)  <b>acquires</b> <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>, <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
    // extract fees
    <b>let</b> coins = <a href="TransactionFee.md#0x1_TransactionFee_vm_withdraw_all_coins">TransactionFee::vm_withdraw_all_coins</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm);

    // get the list of fee makers
    // <b>let</b> state = <b>borrow_global</b>&lt;EpochFeeMakerRegistry&gt;(@VMReserved);
    <b>let</b> fee_makers = <a href="TransactionFee.md#0x1_TransactionFee_get_fee_makers">TransactionFee::get_fee_makers</a>();
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&fee_makers);

    // for every user in the list burn their fees per <a href="Burn.md#0x1_Burn">Burn</a>.<b>move</b> preferences
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
        <b>let</b> user = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&fee_makers, i);
        <b>let</b> amount = <a href="TransactionFee.md#0x1_TransactionFee_get_epoch_fees_made">TransactionFee::get_epoch_fees_made</a>(*user);
        <b>let</b> user_share = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> coins, amount);
        <a href="Burn.md#0x1_Burn_burn_or_recycle_user_fees">burn_or_recycle_user_fees</a>(vm, *user, user_share);

        i = i + 1;
    };

  // Superman 3 decimal errors. https://www.youtube.com/watch?v=N7JBXGkBoFc
  // anything that is remaining should be burned
  <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>(vm, coins);
}
</code></pre>



</details>

<a name="0x1_Burn_reset_ratios"></a>

## Function `reset_ratios`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_reset_ratios">reset_ratios</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_reset_ratios">reset_ratios</a>(vm: &signer) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>let</b> list = <a href="DonorDirected.md#0x1_DonorDirected_get_root_registry">DonorDirected::get_root_registry</a>();

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>let</b> i = 0;
  <b>let</b> global_deposits = 0;
  <b>let</b> deposit_vec = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();

  <b>while</b> (i &lt; len) {

    <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>let</b> cumu = <a href="DiemAccount.md#0x1_DiemAccount_get_index_cumu_deposits">DiemAccount::get_index_cumu_deposits</a>(addr);

    global_deposits = global_deposits + cumu;
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> deposit_vec, cumu);
    i = i + 1;
  };

  <b>if</b> (global_deposits == 0) <b>return</b>;

  <b>let</b> ratios_vec = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; len) {
    <b>let</b> cumu = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&deposit_vec, k);

    <b>let</b> ratio = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(cumu, global_deposits);
    // print(&ratio);

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ratios_vec, ratio);
    k = k + 1;
  };

  <b>if</b> (<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved)) {
    <b>let</b> d = <b>borrow_global_mut</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved);
    d.addr = list;
    d.deposits = deposit_vec;
    d.ratio = ratios_vec;
  } <b>else</b> {
    <b>move_to</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(vm, <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
      addr: list,
      deposits: deposit_vec,
      ratio: ratios_vec,
    })
  }
}
</code></pre>



</details>

<a name="0x1_Burn_get_address_list"></a>

## Function `get_address_list`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_address_list">get_address_list</a>(): vector&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_address_list">get_address_list</a>(): vector&lt;<b>address</b>&gt; <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved))
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();

  *&<b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved).addr
}
</code></pre>



</details>

<a name="0x1_Burn_get_payee_value"></a>

## Function `get_payee_value`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_payee_value">get_payee_value</a>(payee: <b>address</b>, value: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_payee_value">get_payee_value</a>(payee: <b>address</b>, value: u64): u64 <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved))
    <b>return</b> 0;

  <b>let</b> d = <b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved);
  <b>let</b> _contains = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&d.addr, &payee);
  // print(&contains);
  <b>let</b> (is_found, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&d.addr, &payee);
  <b>if</b> (is_found) {
    // print(&is_found);
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&d.ratio);
    // print(&i);
    // print(&len);
    <b>if</b> (i + 1 &gt; len) <b>return</b> 0;
    <b>let</b> ratio = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&d.ratio, i);
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_is_zero">FixedPoint32::is_zero</a>(<b>copy</b> ratio)) <b>return</b> 0;
    // print(&ratio);
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(value, ratio)
  };

  0
}
</code></pre>



</details>

<a name="0x1_Burn_burn_or_recycle_user_fees"></a>

## Function `burn_or_recycle_user_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_burn_or_recycle_user_fees">burn_or_recycle_user_fees</a>(vm: &signer, payer: <b>address</b>, user_share: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_burn_or_recycle_user_fees">burn_or_recycle_user_fees</a>(
  vm: &signer, payer: <b>address</b>, user_share: <a href="Diem.md#0x1_Diem">Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;
) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>, <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>if</b> (<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(payer)) {
    <b>if</b> (<b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(payer).send_community) {
      <a href="Burn.md#0x1_Burn_recycle">recycle</a>(vm, payer, &<b>mut</b> user_share);
    }
  };

  // Superman 3
  <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>(vm, user_share);
}
</code></pre>



</details>

<a name="0x1_Burn_recycle"></a>

## Function `recycle`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_recycle">recycle</a>(vm: &signer, payer: <b>address</b>, coin: &<b>mut</b> <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_recycle">recycle</a>(vm: &signer, payer: <b>address</b>, coin: &<b>mut</b> <a href="Diem.md#0x1_Diem">Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <b>let</b> list = <a href="Burn.md#0x1_Burn_get_address_list">get_address_list</a>();
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;<b>address</b>&gt;(&list);

  <b>let</b> total_coin_value_to_recycle = <a href="Diem.md#0x1_Diem_value">Diem::value</a>(coin);
  // print(&list);

  // There could be errors in the array, and underpayment happen.
  <b>let</b> value_sent = 0;

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> payee = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;<b>address</b>&gt;(&list, i);
    // print(&payee);
    <b>let</b> amount_to_payee = <a href="Burn.md#0x1_Burn_get_payee_value">get_payee_value</a>(payee, total_coin_value_to_recycle);
    // print(&val);

    <b>let</b> to_deposit = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(coin, amount_to_payee);

    <a href="DiemAccount.md#0x1_DiemAccount_vm_deposit_with_metadata">DiemAccount::vm_deposit_with_metadata</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        vm,
        payer,
        payee,
        to_deposit,
        b"recycle",
        b"",
    );
    value_sent = value_sent + amount_to_payee;
    i = i + 1;
  };
}
</code></pre>



</details>

<a name="0x1_Burn_set_send_community"></a>

## Function `set_send_community`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_set_send_community">set_send_community</a>(sender: &signer, community: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_set_send_community">set_send_community</a>(sender: &signer, community: bool) <b>acquires</b> <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> {
  <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>if</b> (<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(addr)) {
    <b>let</b> b = <b>borrow_global_mut</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(addr);
    b.send_community = community;
  } <b>else</b> {
    <b>move_to</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(sender, <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> {
      send_community: community
    });
  }
}
</code></pre>



</details>

<a name="0x1_Burn_get_ratios"></a>

## Function `get_ratios`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_get_ratios">get_ratios</a>(): (vector&lt;<b>address</b>&gt;, vector&lt;u64&gt;, vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_get_ratios">get_ratios</a>():
  (vector&lt;<b>address</b>&gt;, vector&lt;u64&gt;, vector&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>
{
  <b>let</b> d = <b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved);
  (*&d.addr, *&d.deposits, *&d.ratio)
}
</code></pre>



</details>
