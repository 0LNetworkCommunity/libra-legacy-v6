
<a name="0x0_Subsidy"></a>

# Module `0x0::Subsidy`

### Table of Contents

-  [Struct `PrivilegedCapability`](#0x0_Subsidy_PrivilegedCapability)
-  [Struct `T`](#0x0_Subsidy_T)
-  [Function `mint_gas`](#0x0_Subsidy_mint_gas)
-  [Function `subsidy_root_address`](#0x0_Subsidy_subsidy_root_address)
-  [Function `assert_is_subsidy`](#0x0_Subsidy_assert_is_subsidy)



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

<a name="0x0_Subsidy_subsidy_root_address"></a>

## Function `subsidy_root_address`

The address at which the root account will be published.


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_subsidy_root_address">subsidy_root_address</a>(): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Subsidy_subsidy_root_address">subsidy_root_address</a>(): address {
    0xDEED
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
  Transaction::assert(addr == <a href="#0x0_Subsidy_subsidy_root_address">subsidy_root_address</a>(), 1001);
}
</code></pre>



</details>
