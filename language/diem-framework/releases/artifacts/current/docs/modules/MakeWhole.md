
<a name="0x1_MakeWhole"></a>

# Module `0x1::MakeWhole`



-  [Resource `Balance`](#0x1_MakeWhole_Balance)
-  [Resource `Credit`](#0x1_MakeWhole_Credit)
-  [Constants](#@Constants_0)
-  [Function `vm_offer_credit`](#0x1_MakeWhole_vm_offer_credit)
-  [Function `claim_make_whole_payment`](#0x1_MakeWhole_claim_make_whole_payment)
-  [Function `claim_one`](#0x1_MakeWhole_claim_one)
-  [Function `query_make_whole_payment`](#0x1_MakeWhole_query_make_whole_payment)
-  [Function `test_helper_vm_offer`](#0x1_MakeWhole_test_helper_vm_offer)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MakeWhole_Balance"></a>

## Resource `Balance`



<pre><code><b>struct</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>credits: vector&lt;<a href="MakeWhole.md#0x1_MakeWhole_Credit">MakeWhole::Credit</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MakeWhole_Credit"></a>

## Resource `Credit`



<pre><code><b>struct</b> <a href="MakeWhole.md#0x1_MakeWhole_Credit">Credit</a> has store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>incident_name: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>claimed: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>coins: <a href="Diem.md#0x1_Diem_Diem">Diem::Diem</a>&lt;<a href="GAS.md#0x1_GAS_GAS">GAS::GAS</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_MakeWhole_EALREADY_PAID"></a>



<pre><code><b>const</b> <a href="MakeWhole.md#0x1_MakeWhole_EALREADY_PAID">EALREADY_PAID</a>: u64 = 22017;
</code></pre>



<a name="0x1_MakeWhole_EPAYEE_NOT_DELETED"></a>



<pre><code><b>const</b> <a href="MakeWhole.md#0x1_MakeWhole_EPAYEE_NOT_DELETED">EPAYEE_NOT_DELETED</a>: u64 = 22015;
</code></pre>



<a name="0x1_MakeWhole_EWRONG_PAYEE"></a>



<pre><code><b>const</b> <a href="MakeWhole.md#0x1_MakeWhole_EWRONG_PAYEE">EWRONG_PAYEE</a>: u64 = 22016;
</code></pre>



<a name="0x1_MakeWhole_vm_offer_credit"></a>

## Function `vm_offer_credit`



<pre><code><b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_vm_offer_credit">vm_offer_credit</a>(vm: &signer, account: &signer, value: u64, incident_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_vm_offer_credit">vm_offer_credit</a>(
  vm: &signer,
  account: &signer,
  value: u64,
  incident_name: vector&lt;u8&gt;
) <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> cred = <a href="MakeWhole.md#0x1_MakeWhole_Credit">Credit</a> {
      incident_name,
      claimed: <b>false</b>,
      coins: <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, value),
    };

    <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr)) {
        move_to&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(account, <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
          credits: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_singleton">Vector::singleton</a>(cred),
        });
    } <b>else</b> {
      <b>let</b> c = borrow_global_mut&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr);
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Credit">Credit</a>&gt;(&<b>mut</b> c.credits, cred);
    }
}
</code></pre>



</details>

<a name="0x1_MakeWhole_claim_make_whole_payment"></a>

## Function `claim_make_whole_payment`

claims the make whole payment and returns the amount paid out
ensures that the caller is the one owed the payment at index i


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_make_whole_payment">claim_make_whole_payment</a>(account: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_make_whole_payment">claim_make_whole_payment</a>(account: &signer): u64 <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr)) <b>return</b> 0;

    <b>let</b> total_amount = 0;
    <b>let</b> b = borrow_global_mut&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr);
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&b.credits)){
      <b>let</b> cred = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> b.credits, i);

      <b>let</b> amount = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&cred.coins);
      total_amount = total_amount + amount;
      <b>if</b> (amount &gt; 0 && !cred.claimed) {
        <b>let</b> to_pay = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&<b>mut</b> cred.coins, amount);

        <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
            <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
            <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
            to_pay,
            b"make whole",
            b""
        );
      };

      cred.claimed = <b>true</b>;

      i = i + 1;
    };
    total_amount
}
</code></pre>



</details>

<a name="0x1_MakeWhole_claim_one"></a>

## Function `claim_one`



<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_one">claim_one</a>(account: &signer, i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_one">claim_one</a>(account: &signer, i: u64): u64 <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
  <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr)) <b>return</b> 0;

  <b>let</b> b = borrow_global_mut&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr);
  <b>let</b> cred = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> b.credits, i);
  <b>let</b> value = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&cred.coins);

  <b>if</b> (value &gt; 0 && !cred.claimed) {
    <b>let</b> to_pay = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&<b>mut</b> cred.coins, value);

    <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
        <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
        to_pay,
        b"make whole",
        b""
    );

  };

  value
}
</code></pre>



</details>

<a name="0x1_MakeWhole_query_make_whole_payment"></a>

## Function `query_make_whole_payment`

queries whether or not a make whole payment is available for addr
returns (amount, index) if a payment exists, else (0, 0)


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_query_make_whole_payment">query_make_whole_payment</a>(addr: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_query_make_whole_payment">query_make_whole_payment</a>(addr: address): u64 <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr)) <b>return</b> 0;

  <b>let</b> b = borrow_global&lt;<a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a>&gt;(addr);
  <b>let</b> val = 0;
  <b>let</b> i = 0;
  <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&b.credits)){
    <b>let</b> cred = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&b.credits, i);
    val = val + <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&cred.coins);

    i = i + 1;
  };

  val
}
</code></pre>



</details>

<a name="0x1_MakeWhole_test_helper_vm_offer"></a>

## Function `test_helper_vm_offer`



<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_test_helper_vm_offer">test_helper_vm_offer</a>(vm: &signer, account: &signer, value: u64, incident_name: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_test_helper_vm_offer">test_helper_vm_offer</a>(
  vm: &signer,
  account: &signer,
  value: u64,
  incident_name: vector&lt;u8&gt;
) <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Balance">Balance</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), 7357000);
  <a href="MakeWhole.md#0x1_MakeWhole_vm_offer_credit">vm_offer_credit</a>(vm, account, value, incident_name);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
