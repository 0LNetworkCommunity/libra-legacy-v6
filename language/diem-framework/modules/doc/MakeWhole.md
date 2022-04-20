
<a name="0x1_MakeWhole"></a>

# Module `0x1::MakeWhole`



-  [Resource `Payments`](#0x1_MakeWhole_Payments)
-  [Constants](#@Constants_0)
-  [Function `make_whole_init`](#0x1_MakeWhole_make_whole_init)
-  [Function `make_whole_test`](#0x1_MakeWhole_make_whole_test)
-  [Function `claim_make_whole_payment`](#0x1_MakeWhole_claim_make_whole_payment)
-  [Function `query_make_whole_payment`](#0x1_MakeWhole_query_make_whole_payment)
-  [Function `mark_paid`](#0x1_MakeWhole_mark_paid)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GAS.md#0x1_GAS">0x1::GAS</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MakeWhole_Payments"></a>

## Resource `Payments`



<pre><code><b>struct</b> <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a> has key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>payees: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>amounts: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>paid: vector&lt;bool&gt;</code>
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



<a name="0x1_MakeWhole_make_whole_init"></a>

## Function `make_whole_init`



<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_make_whole_init">make_whole_init</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_make_whole_init">make_whole_init</a>(vm: &signer){
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())) {
        <b>let</b> payees: vector&lt;address&gt; = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;();
        <b>let</b> amounts: vector&lt;u64&gt; = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;();

        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> payees, @0xb2e86a1bee0e63602920eaa90a37c91e);
        <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> amounts, 582694323);

        <b>let</b> i = 0;
        <b>let</b> total = 0;
        <b>let</b> paid = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;bool&gt;();

        <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;u64&gt;(&amounts)) {
            total = total + *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&amounts, i);
            i = i + 1;
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;bool&gt;(&<b>mut</b> paid, <b>false</b>);
        };

        <b>let</b> coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, total);

        move_to&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(
            vm,
            <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>{
                payees: payees,
                amounts: amounts,
                paid: paid,
                coins: coins
            }
        );
    };
}
</code></pre>



</details>

<a name="0x1_MakeWhole_make_whole_test"></a>

## Function `make_whole_test`



<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_make_whole_test">make_whole_test</a>(vm: &signer, payees: vector&lt;address&gt;, amounts: vector&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_make_whole_test">make_whole_test</a>(vm: &signer, payees: vector&lt;address&gt;, amounts: vector&lt;u64&gt;){
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>if</b> (!<b>exists</b>&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>())) {
        <b>let</b> i = 0;
        <b>let</b> total = 0;
        <b>let</b> paid = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;bool&gt;();

        <b>while</b> (i &lt; <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;u64&gt;(&amounts)) {
            total = total + *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&amounts, i);
            i = i + 1;
            <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;bool&gt;(&<b>mut</b> paid, <b>false</b>);
        };

        <b>let</b> coins = <a href="Diem.md#0x1_Diem_mint">Diem::mint</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(vm, total);

        move_to&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(
            vm,
            <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>{
                payees: payees,
                amounts: amounts,
                paid: paid,
                coins: coins
            }
        );
    };
}
</code></pre>



</details>

<a name="0x1_MakeWhole_claim_make_whole_payment"></a>

## Function `claim_make_whole_payment`

claims the make whole payment and returns the amount paid out
ensures that the caller is the one owed the payment at index i


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_make_whole_payment">claim_make_whole_payment</a>(account: &signer, i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_claim_make_whole_payment">claim_make_whole_payment</a>(account: &signer, i: u64): u64 <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>{
    // find amount
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> payments = borrow_global_mut&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
    );

    //make sure sender is the one owed funds and that the funds have not been paid
    //<b>if</b> i is invalid (&lt;0 or &gt;length) vector will throw error
    <b>assert</b>(*<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&payments.payees, i) == addr, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_internal">Errors::internal</a>(<a href="MakeWhole.md#0x1_MakeWhole_EWRONG_PAYEE">EWRONG_PAYEE</a>));
    <b>assert</b>(*<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;bool&gt;(&payments.paid, i) == <b>false</b>, <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_internal">Errors::internal</a>(<a href="MakeWhole.md#0x1_MakeWhole_EALREADY_PAID">EALREADY_PAID</a>));

    <b>let</b> amount = *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&payments.amounts, i);


    <b>if</b> (amount &gt; 0) {
        //make the payment
        <b>let</b> to_pay = <a href="Diem.md#0x1_Diem_withdraw">Diem::withdraw</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(&<b>mut</b> payments.coins, amount);

        <a href="DiemAccount.md#0x1_DiemAccount_deposit">DiemAccount::deposit</a>&lt;<a href="GAS.md#0x1_GAS">GAS</a>&gt;(
            <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>(),
            <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
            to_pay,
            b"carpe miner make whole",
            b""
        );


        //clear the payment from the list
        <a href="MakeWhole.md#0x1_MakeWhole_mark_paid">mark_paid</a>(account, i);
    };
    //<b>return</b> the amount paid out
    amount

}
</code></pre>



</details>

<a name="0x1_MakeWhole_query_make_whole_payment"></a>

## Function `query_make_whole_payment`

queries whether or not a make whole payment is available for addr
returns (amount, index) if a payment exists, else (0, 0)


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_query_make_whole_payment">query_make_whole_payment</a>(addr: address): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_query_make_whole_payment">query_make_whole_payment</a>(addr: address): (u64, u64) <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a> {
    <b>let</b> payments = borrow_global&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
    );

    <b>let</b> (found, i) = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&payments.payees, &addr);

    <b>if</b> (found && *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;bool&gt;(&payments.paid, i) == <b>false</b>) {
        (*<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&payments.amounts, i), i)
    }
    <b>else</b> {
        (0, 0)
    }
}
</code></pre>



</details>

<a name="0x1_MakeWhole_mark_paid"></a>

## Function `mark_paid`

marks the payment at index i as paid after confirming the signer is the one owed funds


<pre><code><b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_mark_paid">mark_paid</a>(account: &signer, i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="MakeWhole.md#0x1_MakeWhole_mark_paid">mark_paid</a>(account: &signer, i: u64) <b>acquires</b> <a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a> {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);

    <b>let</b> payments = borrow_global_mut&lt;<a href="MakeWhole.md#0x1_MakeWhole_Payments">Payments</a>&gt;(
        <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()
    );

    <b>assert</b> (addr == *<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&payments.payees, i), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_internal">Errors::internal</a>(<a href="MakeWhole.md#0x1_MakeWhole_EPAYEE_NOT_DELETED">EPAYEE_NOT_DELETED</a>));

    <b>let</b> p = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>&lt;bool&gt;(&<b>mut</b> payments.paid, i);
    *p = <b>true</b>;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
