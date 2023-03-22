
<a name="0x1_DemoBonding"></a>

# Module `0x1::DemoBonding`



-  [Resource `CurveState`](#0x1_DemoBonding_CurveState)
-  [Resource `Token`](#0x1_DemoBonding_Token)
-  [Function `initialize_curve`](#0x1_DemoBonding_initialize_curve)
-  [Function `deposit_calc`](#0x1_DemoBonding_deposit_calc)
-  [Function `test_bond_to_mint`](#0x1_DemoBonding_test_bond_to_mint)
-  [Function `get_curve_state`](#0x1_DemoBonding_get_curve_state)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
<b>use</b> <a href="Decimal.md#0x1_Decimal">0x1::Decimal</a>;
</code></pre>



<a name="0x1_DemoBonding_CurveState"></a>

## Resource `CurveState`



<pre><code><b>struct</b> <a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>is_deprecated: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>reserve: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>supply_issued: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DemoBonding_Token"></a>

## Resource `Token`



<pre><code><b>struct</b> <a href="DemoBonding.md#0x1_DemoBonding_Token">Token</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DemoBonding_initialize_curve"></a>

## Function `initialize_curve`



<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_initialize_curve">initialize_curve</a>(service: &signer, deposit: u128, supply_init: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_initialize_curve">initialize_curve</a>(
  service: &signer,
  deposit: u128, // <a href="Diem.md#0x1_Diem">Diem</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;,
  supply_init: u128,
) {
  // <b>let</b> deposit_value = <a href="Diem.md#0x1_Diem_value">Diem::value</a>&lt;<a href="XUS.md#0x1_XUS">XUS</a>&gt;(&deposit);
  <b>assert</b>!(deposit &gt; 0, 7357001);

  <b>let</b> init_state = <a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a> {
    is_deprecated: <b>false</b>, // deprecate mode
    reserve: deposit,
    supply_issued: supply_init,
  };

  // This initializes the contract, and stores the contract state at the <b>address</b> of sender. TDB <b>where</b> the state gets stored.
  <b>move_to</b>&lt;<a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a>&gt;(service, init_state);

  <b>let</b> first_token = <a href="DemoBonding.md#0x1_DemoBonding_Token">Token</a> {
    value: supply_init
  };

  // minting the first coin, sponsor is recipent of initial coin.
  <b>move_to</b>&lt;<a href="DemoBonding.md#0x1_DemoBonding_Token">Token</a>&gt;(service, first_token);
}
</code></pre>



</details>

<a name="0x1_DemoBonding_deposit_calc"></a>

## Function `deposit_calc`



<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_deposit_calc">deposit_calc</a>(add_to_reserve: u128, reserve: u128, supply: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_deposit_calc">deposit_calc</a>(add_to_reserve: u128, reserve: u128, supply: u128): u128 {

  <b>let</b> one = <a href="Decimal.md#0x1_Decimal_new">Decimal::new</a>(<b>true</b>, 1, 0);
  print(&one);

  <b>let</b> add_dec = <a href="Decimal.md#0x1_Decimal_new">Decimal::new</a>(<b>true</b>, add_to_reserve, 0);
  print(&add_dec);

  <b>let</b> reserve_dec = <a href="Decimal.md#0x1_Decimal_new">Decimal::new</a>(<b>true</b>, reserve, 0);
  print(&reserve_dec);

  <b>let</b> supply_dec = <a href="Decimal.md#0x1_Decimal_new">Decimal::new</a>(<b>true</b>, supply, 0);
  print(&supply_dec);

  // formula:
  // supply * sqrt(one+(add_to_reserve/reserve))

  <b>let</b> a = <a href="Decimal.md#0x1_Decimal_div">Decimal::div</a>(&add_dec, &reserve_dec);
  print(&a);
  <b>let</b> b = <a href="Decimal.md#0x1_Decimal_add">Decimal::add</a>(&one, &a);
  print(&b);
  <b>let</b> c = <a href="Decimal.md#0x1_Decimal_sqrt">Decimal::sqrt</a>(&b);
  print(&c);
  <b>let</b> d = <a href="Decimal.md#0x1_Decimal_mul">Decimal::mul</a>(&supply_dec, &c);
  print(&d);
  <b>let</b> int = <a href="Decimal.md#0x1_Decimal_borrow_int">Decimal::borrow_int</a>(&<a href="Decimal.md#0x1_Decimal_trunc">Decimal::trunc</a>(&d));
  print(int);

  <b>return</b> *int
}
</code></pre>



</details>

<a name="0x1_DemoBonding_test_bond_to_mint"></a>

## Function `test_bond_to_mint`



<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_test_bond_to_mint">test_bond_to_mint</a>(_sender: &signer, service_addr: <b>address</b>, deposit: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_test_bond_to_mint">test_bond_to_mint</a>(_sender: &signer, service_addr: <b>address</b>, deposit: u128): u128 <b>acquires</b> <a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a> {
  <b>assert</b>!(<b>exists</b>&lt;<a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a>&gt;(service_addr), 73570002);
  <b>let</b> state = <b>borrow_global_mut</b>&lt;<a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a>&gt;(service_addr);

  <b>let</b> post_supply = <a href="DemoBonding.md#0x1_DemoBonding_deposit_calc">deposit_calc</a>(deposit, state.reserve, state.supply_issued);
  print(&post_supply);
  <b>assert</b>!(post_supply &gt; state.supply_issued, 73570003);
  <b>let</b> mint = post_supply - state.supply_issued;
  print(&mint);
  // <b>update</b> the new curve state
  state.reserve = state.reserve + deposit;
  state.supply_issued = state.supply_issued + mint;
  // print(&state);
  mint
}
</code></pre>



</details>

<a name="0x1_DemoBonding_get_curve_state"></a>

## Function `get_curve_state`



<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_get_curve_state">get_curve_state</a>(sponsor_address: <b>address</b>): (u128, u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DemoBonding.md#0x1_DemoBonding_get_curve_state">get_curve_state</a>(sponsor_address: <b>address</b>): (u128, u128) <b>acquires</b> <a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a> {
  <b>let</b> state = <b>borrow_global</b>&lt;<a href="DemoBonding.md#0x1_DemoBonding_CurveState">CurveState</a>&gt;(sponsor_address);
  (state.reserve, state.supply_issued)
}
</code></pre>



</details>
