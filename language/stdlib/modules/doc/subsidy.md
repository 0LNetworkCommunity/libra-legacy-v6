
<a name="0x0_Subsidy"></a>

# Module `0x0::Subsidy`

### Table of Contents

-  [Struct `PrivilegedCapability`](#0x0_Subsidy_PrivilegedCapability)
-  [Struct `T`](#0x0_Subsidy_T)
-  [Function `mint_gas`](#0x0_Subsidy_mint_gas)
-  [Function `assert_is_subsidy`](#0x0_Subsidy_assert_is_subsidy)
-  [Function `addr_is_subsidy`](#0x0_Subsidy_addr_is_subsidy)



<a name="0x0_Subsidy_PrivilegedCapability"></a>

## Struct `PrivilegedCapability`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Subsidy_PrivilegedCapability">PrivilegedCapability</a>&lt;Privilege&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Subsidy_T"></a>

## Struct `T`



<pre><code><b>struct</b> <a href="#0x0_Subsidy_T">T</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Subsidy_mint_gas"></a>

## Function `mint_gas`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_mint_gas">mint_gas</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_mint_gas">mint_gas</a>() {

}
</code></pre>



</details>

<a name="0x0_Subsidy_assert_is_subsidy"></a>

## Function `assert_is_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_assert_is_subsidy">assert_is_subsidy</a>(addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_assert_is_subsidy">assert_is_subsidy</a>(addr: address) {
  Transaction::assert(<a href="#0x0_Subsidy_addr_is_subsidy">addr_is_subsidy</a>(addr), 1001);
}
</code></pre>



</details>

<a name="0x0_Subsidy_addr_is_subsidy"></a>

## Function `addr_is_subsidy`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_addr_is_subsidy">addr_is_subsidy</a>(addr: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_addr_is_subsidy">addr_is_subsidy</a>(addr: address): bool {
    //TODO:Do we initialize subsidy <b>to</b> a particular address like association
    exists&lt;<a href="#0x0_Subsidy_PrivilegedCapability">PrivilegedCapability</a>&lt;<a href="#0x0_Subsidy_T">T</a>&gt;&gt;(addr)
}
</code></pre>



</details>
