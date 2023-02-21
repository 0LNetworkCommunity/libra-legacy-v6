
<a name="0x1_Burn"></a>

# Module `0x1::Burn`



-  [Resource `BurnPreference`](#0x1_Burn_BurnPreference)
-  [Resource `DepositInfo`](#0x1_Burn_DepositInfo)
-  [Function `reset_ratios`](#0x1_Burn_reset_ratios)
-  [Function `get_address_list`](#0x1_Burn_get_address_list)
-  [Function `get_value`](#0x1_Burn_get_value)
-  [Function `burn_network_fees`](#0x1_Burn_burn_network_fees)
-  [Function `send_coin_to_comm_wallet`](#0x1_Burn_send_coin_to_comm_wallet)
-  [Function `get_community_recycling`](#0x1_Burn_get_community_recycling)
-  [Function `set_send_community`](#0x1_Burn_set_send_community)
-  [Function `get_ratios`](#0x1_Burn_get_ratios)
-  [Function `get_user_pref`](#0x1_Burn_get_user_pref)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="Receipts.md#0x1_Receipts">0x1::Receipts</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TransactionFee.md#0x1_TransactionFee">0x1::TransactionFee</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
<b>use</b> <a href="Wallet.md#0x1_Wallet">0x1::Wallet</a>;
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

<a name="0x1_Burn_reset_ratios"></a>

## Function `reset_ratios`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_reset_ratios">reset_ratios</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_reset_ratios">reset_ratios</a>(vm: &signer) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

  // First find the list of all community wallets
  // fail fast <b>if</b> none are found
  <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">Wallet::get_comm_list</a>();
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&list);
  <b>if</b> (len == 0) <b>return</b>;

  <b>let</b> i = 0;
  <b>let</b> global_deposits = 0;
  <b>let</b> deposit_vec = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();

  // Now we <b>loop</b> through all the community wallets
  // and find the comulative deposits <b>to</b> that wallet.
  // we make a table from that (a new list)
  // we also take a tally of the <b>global</b> amount of deposits
  // Note that we are using a time-weighted index of deposits
  // which favors most recent deposits. (see <a href="DiemAccount.md#0x1_DiemAccount_deposit_index_curve">DiemAccount::deposit_index_curve</a>)
  print(&300000);
  print(&len);
  <b>while</b> (i &lt; len) {

    <b>let</b> addr = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&list, i);
    <b>let</b> cumu = <a href="DiemAccount.md#0x1_DiemAccount_get_index_cumu_deposits">DiemAccount::get_index_cumu_deposits</a>(addr);
    print(&cumu);
    global_deposits = global_deposits + cumu;
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> deposit_vec, cumu);
    i = i + 1;
  };

  print(&300001);

  // check <b>if</b> anything went wrong, and we don't have any cumulatives
  // <b>to</b> calculate.
  <b>if</b> (global_deposits == 0) <b>return</b>;

  // Now we <b>loop</b> through the table and calculate the ratio
  // since we now know the <b>global</b> total of the ajusted cumulative deposits.
  // and here we create another columns in our table (another list).
  // this is a list of fixedpoint ratios.
  <b>let</b> ratios_vec = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; len) {
    <b>let</b> cumu = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&deposit_vec, k);
    print(&cumu);

    <b>let</b> ratio = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(cumu, global_deposits);
    print(&ratio);

    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ratios_vec, ratio);
    k = k + 1;
  };
  print(&300002);
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
  };
  print(&300003);
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

<a name="0x1_Burn_get_value"></a>

## Function `get_value`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_value">get_value</a>(payee: <b>address</b>, value: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_value">get_value</a>(payee: <b>address</b>, value: u64): u64 <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved))
    <b>return</b> 0;

  <b>let</b> d = <b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>&gt;(@VMReserved);
  <b>let</b> contains = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>(&d.addr, &payee);
  print(&contains);
  <b>let</b> (is_found, i) = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>(&d.addr, &payee);
  <b>if</b> (is_found) {
    print(&is_found);
    <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&d.ratio);
    print(&i);
    print(&len);
    <b>if</b> (i + 1 &gt; len) <b>return</b> 0;
    <b>let</b> ratio = *<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&d.ratio, i);
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_is_zero">FixedPoint32::is_zero</a>(<b>copy</b> ratio)) <b>return</b> 0;
    print(&ratio);
    <b>return</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(value, ratio)
  };

  0
}
</code></pre>



</details>

<a name="0x1_Burn_burn_network_fees"></a>

## Function `burn_network_fees`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_burn_network_fees">burn_network_fees</a>(vm: &signer, clearing: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_burn_network_fees">burn_network_fees</a>(
  vm: &signer,
  clearing: u64 // what was the clearing price of the auction for purposes of calculating recycling.
) <b>acquires</b> <a href="Burn.md#0x1_Burn_DepositInfo">DepositInfo</a>, <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> {
  // <b>let</b> amount_remaining = <a href="TransactionFee.md#0x1_TransactionFee_get_amount_to_distribute">TransactionFee::get_amount_to_distribute</a>(vm);
  <b>let</b> coins = <a href="TransactionFee.md#0x1_TransactionFee_get_transaction_fees_coins">TransactionFee::get_transaction_fees_coins</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm);

  <b>let</b> (burners, amount_to_comm) = <a href="Burn.md#0x1_Burn_get_community_recycling">get_community_recycling</a>(clearing);
  <b>let</b> len_burners = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&burners);
  <b>if</b> (amount_to_comm &lt; len_burners) {
    <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>(vm, coins);
    <b>return</b>
  };


  <b>let</b> (comm_addr_list, _, comm_split_list) = <a href="Burn.md#0x1_Burn_get_ratios">get_ratios</a>();

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&comm_addr_list);

  <b>let</b> i = 0;


  <b>while</b> (i &lt; len) {
    <b>let</b> comm_wall = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&comm_addr_list, i);
    <b>let</b> wall_split = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&comm_split_list, i);

    <b>let</b> coin_val = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(amount_to_comm, *wall_split);
    <b>let</b> split = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>(&<b>mut</b> coins, coin_val);

    <a href="Burn.md#0x1_Burn_send_coin_to_comm_wallet">send_coin_to_comm_wallet</a>(vm, *comm_wall, split);

    // write the correct receipt amount <b>to</b> each validator who opted <b>to</b> send <b>to</b> community wallet. The communit wallets give some governance rights <b>to</b> donors.
    <b>let</b> k = 0;
    <b>while</b> (k &lt; len_burners) {
      <b>let</b> burner = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&burners, k);
      <b>let</b> this_split = coin_val/len_burners;
      <a href="Receipts.md#0x1_Receipts_write_receipt">Receipts::write_receipt</a>(vm, *burner, *comm_wall, this_split);
      k = k + 1;
    };

  };

  // anything that is remaining should be burnt
  <a href="Diem.md#0x1_Diem_vm_burn_this_coin">Diem::vm_burn_this_coin</a>(vm, coins);

}
</code></pre>



</details>

<a name="0x1_Burn_send_coin_to_comm_wallet"></a>

## Function `send_coin_to_comm_wallet`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_send_coin_to_comm_wallet">send_coin_to_comm_wallet</a>(vm: &signer, comm_wallet: <b>address</b>, coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_send_coin_to_comm_wallet">send_coin_to_comm_wallet</a>(
  vm: &signer,
  comm_wallet: <b>address</b>,
  coin: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;,
) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>(
    @VMReserved,
    comm_wallet,
    coin,
    b"epoch burn",
    b"",
    <b>false</b>,
  );
}
</code></pre>



</details>

<a name="0x1_Burn_get_community_recycling"></a>

## Function `get_community_recycling`



<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_community_recycling">get_community_recycling</a>(clearing: u64): (vector&lt;<b>address</b>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Burn.md#0x1_Burn_get_community_recycling">get_community_recycling</a>(clearing: u64): (vector&lt;<b>address</b>&gt;, u64) <b>acquires</b> <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a> {
  <b>let</b> burners = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
  // <b>let</b> total_payments = 0;
  <b>let</b> total_payments_of_comm_senders = 0;

  // reward and clearing price per validator
  // <b>let</b> (_, clearing, _) = <a href="ProofOfFee.md#0x1_ProofOfFee_get_consensus_reward">ProofOfFee::get_consensus_reward</a>();

  // find burn preferences of ALL previous validator set
  // the potential amount burned is only the entry fee (the auction clearing price)
  <b>let</b> all_vals = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();

  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&all_vals);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> a = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&all_vals, i);


    // total_payments = total_payments + clearing;

    <b>let</b> is_to_community = <a href="Burn.md#0x1_Burn_get_user_pref">get_user_pref</a>(a);

    <b>if</b> (is_to_community) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> burners, *a);
      total_payments_of_comm_senders = total_payments_of_comm_senders + clearing;
    };

    i = i + 1;
  };

  // // find burn preferences of ALL Infra Escrow pledgers.
  // <b>let</b> all_pledged = <a href="PledgeAccounts.md#0x1_PledgeAccounts_get_all_pledgers">PledgeAccounts::get_all_pledgers</a>(&@VMReserved);

  // // The pledgers paid from Infra Escrow, the nominal consensus reward.
  // // add those up and find proportions.

  // <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&all_pledged);
  // <b>let</b> i = 0;
  // <b>while</b> (i &lt; len) {
  //   <b>let</b> a = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&all_pledged, i);

  //   total_payments = total_payments + reward;

  //   <b>let</b> is_to_community = <a href="Burn.md#0x1_Burn_get_user_pref">Burn::get_user_pref</a>(a);

  //   <b>if</b> (is_to_community) {
  //     <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> burners, a);
  //     total_payments_of_comm_senders = total_payments_of_comm_senders + reward;
  //   };

  //   i = i + 1;
  // };


  // <b>let</b> ratio = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(total_payments_of_comm_senders, total_payments)

  // <b>return</b> the list of burners, for tracking, and the weighted average.
  (burners, total_payments_of_comm_senders)

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

<a name="0x1_Burn_get_user_pref"></a>

## Function `get_user_pref`



<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_get_user_pref">get_user_pref</a>(user: &<b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Burn.md#0x1_Burn_get_user_pref">get_user_pref</a>(user: &<b>address</b>): bool <b>acquires</b> <a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>{
  <b>borrow_global</b>&lt;<a href="Burn.md#0x1_Burn_BurnPreference">BurnPreference</a>&gt;(*user).send_community
}
</code></pre>



</details>
