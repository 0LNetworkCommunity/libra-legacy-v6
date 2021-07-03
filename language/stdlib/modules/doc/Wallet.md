
<a name="0x1_Wallet"></a>

# Module `0x1::Wallet`



-  [Resource `CommunityWallets`](#0x1_Wallet_CommunityWallets)
-  [Resource `SlowWallet`](#0x1_Wallet_SlowWallet)
-  [Function `init_comm_list`](#0x1_Wallet_init_comm_list)
-  [Function `set_comm`](#0x1_Wallet_set_comm)
-  [Function `remove_comm`](#0x1_Wallet_remove_comm)
-  [Function `vm_set_comm`](#0x1_Wallet_vm_set_comm)
-  [Function `get_comm_list`](#0x1_Wallet_get_comm_list)
-  [Function `is_comm`](#0x1_Wallet_is_comm)
-  [Function `set_slow`](#0x1_Wallet_set_slow)
-  [Function `is_slow`](#0x1_Wallet_is_slow)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Wallet_CommunityWallets"></a>

## Resource `CommunityWallets`



<pre><code><b>resource</b> <b>struct</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_SlowWallet"></a>

## Resource `SlowWallet`



<pre><code><b>resource</b> <b>struct</b> <a href="Wallet.md#0x1_Wallet_SlowWallet">SlowWallet</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>is_slow: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Wallet_init_comm_list"></a>

## Function `init_comm_list`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_init_comm_list">init_comm_list</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_init_comm_list">init_comm_list</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_libra_root">CoreAddresses::assert_libra_root</a>(vm);
  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0)) {
    move_to&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(vm, <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a> {
      list: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
    });
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_set_comm"></a>

## Function `set_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_comm">set_comm</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_comm">set_comm</a>(sig: &signer) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0)) {
    <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
    <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
    <b>if</b> (!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&list, &addr)) {
        <b>let</b> s = borrow_global_mut&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0);
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
      }
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_remove_comm"></a>

## Function `remove_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_remove_comm">remove_comm</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_remove_comm">remove_comm</a>(sig: &signer) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0)) {
    <b>let</b> addr = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
    <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
    <b>let</b> (yes, i) = <a href="Vector.md#0x1_Vector_index_of">Vector::index_of</a>&lt;address&gt;(&list, &addr);
    <b>if</b> (yes) {
        <b>let</b> s = borrow_global_mut&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0);
        <a href="Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> s.list, i);
      }
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_vm_set_comm"></a>

## Function `vm_set_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_vm_set_comm">vm_set_comm</a>(vm: &signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_vm_set_comm">vm_set_comm</a>(vm: &signer, addr: address) <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_libra_root">CoreAddresses::assert_libra_root</a>(vm);
  <b>if</b> (<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0)) {
    <b>let</b> list = <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>();
    <b>if</b> (!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&list, &addr)) {

      <b>let</b> s = borrow_global_mut&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0);
      <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> s.list, addr);
    }
  } <b>else</b> {
    <a href="Wallet.md#0x1_Wallet_init_comm_list">init_comm_list</a>(vm);
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_get_comm_list"></a>

## Function `get_comm_list`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_get_comm_list">get_comm_list</a>(): vector&lt;address&gt; <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>{
  <b>if</b> (<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0)) {
    <b>let</b> s = borrow_global&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0);
    <b>return</b> *&s.list
  } <b>else</b> {
    <b>return</b> <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_is_comm"></a>

## Function `is_comm`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_comm">is_comm</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_comm">is_comm</a>(addr: address): bool <b>acquires</b> <a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>{
  <b>let</b> s = borrow_global&lt;<a href="Wallet.md#0x1_Wallet_CommunityWallets">CommunityWallets</a>&gt;(0x0);
  <a href="Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&s.list, &addr)
}
</code></pre>



</details>

<a name="0x1_Wallet_set_slow"></a>

## Function `set_slow`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_slow">set_slow</a>(sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_set_slow">set_slow</a>(sig: &signer) {
  <b>if</b> (!<b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_SlowWallet">SlowWallet</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig))) {
    move_to&lt;<a href="Wallet.md#0x1_Wallet_SlowWallet">SlowWallet</a>&gt;(sig, <a href="Wallet.md#0x1_Wallet_SlowWallet">SlowWallet</a> {
      is_slow: <b>true</b>
    });
  }
}
</code></pre>



</details>

<a name="0x1_Wallet_is_slow"></a>

## Function `is_slow`



<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_slow">is_slow</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Wallet.md#0x1_Wallet_is_slow">is_slow</a>(addr: address): bool {
  <b>exists</b>&lt;<a href="Wallet.md#0x1_Wallet_SlowWallet">SlowWallet</a>&gt;(addr)
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
