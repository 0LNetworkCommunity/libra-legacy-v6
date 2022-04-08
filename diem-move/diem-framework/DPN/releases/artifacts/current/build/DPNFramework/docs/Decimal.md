
<a name="0x1_Decimal"></a>

# Module `0x1::Decimal`



-  [Resource `Decimal`](#0x1_Decimal_Decimal)
-  [Constants](#@Constants_0)
-  [Function `demo`](#0x1_Decimal_demo)
-  [Function `single`](#0x1_Decimal_single)
-  [Function `pair`](#0x1_Decimal_pair)
-  [Function `new`](#0x1_Decimal_new)
-  [Function `trunc`](#0x1_Decimal_trunc)
-  [Function `sqrt`](#0x1_Decimal_sqrt)
-  [Function `add`](#0x1_Decimal_add)
-  [Function `sub`](#0x1_Decimal_sub)
-  [Function `mul`](#0x1_Decimal_mul)
-  [Function `div`](#0x1_Decimal_div)
-  [Function `rescale`](#0x1_Decimal_rescale)
-  [Function `round`](#0x1_Decimal_round)
-  [Function `power`](#0x1_Decimal_power)
-  [Function `unwrap`](#0x1_Decimal_unwrap)
-  [Function `borrow_sign`](#0x1_Decimal_borrow_sign)
-  [Function `borrow_int`](#0x1_Decimal_borrow_int)
-  [Function `borrow_scale`](#0x1_Decimal_borrow_scale)


<pre><code></code></pre>



<a name="0x1_Decimal_Decimal"></a>

## Resource `Decimal`



<pre><code><b>struct</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sign: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>int: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>scale: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Decimal_ADD"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_ADD">ADD</a>: u8 = 1;
</code></pre>



<a name="0x1_Decimal_DIV"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_DIV">DIV</a>: u8 = 4;
</code></pre>



<a name="0x1_Decimal_MAX_RUST_DECIMAL_U128"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_MAX_RUST_DECIMAL_U128">MAX_RUST_DECIMAL_U128</a>: u128 = 79228162514264337593543950335;
</code></pre>



<a name="0x1_Decimal_MUL"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_MUL">MUL</a>: u8 = 3;
</code></pre>



<a name="0x1_Decimal_POW"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_POW">POW</a>: u8 = 5;
</code></pre>



<a name="0x1_Decimal_ROUND"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_ROUND">ROUND</a>: u8 = 6;
</code></pre>



<a name="0x1_Decimal_ROUND_MID_FROM_ZERO"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_ROUND_MID_FROM_ZERO">ROUND_MID_FROM_ZERO</a>: u8 = 1;
</code></pre>



<a name="0x1_Decimal_ROUND_MID_TO_EVEN"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>: u8 = 0;
</code></pre>



<a name="0x1_Decimal_SQRT"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_SQRT">SQRT</a>: u8 = 100;
</code></pre>



<a name="0x1_Decimal_SUB"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_SUB">SUB</a>: u8 = 2;
</code></pre>



<a name="0x1_Decimal_TRUNC"></a>



<pre><code><b>const</b> <a href="Decimal.md#0x1_Decimal_TRUNC">TRUNC</a>: u8 = 101;
</code></pre>



<a name="0x1_Decimal_demo"></a>

## Function `demo`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_demo">demo</a>(sign: bool, int: u128, scale: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_demo">demo</a>(sign: bool, int: u128, scale: u8): (bool, u128, u8);
</code></pre>



</details>

<a name="0x1_Decimal_single"></a>

## Function `single`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_single">single</a>(op_id: u8, sign: bool, int: u128, scale: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_single">single</a>(op_id: u8, sign: bool, int: u128, scale: u8): (bool, u128, u8);
</code></pre>



</details>

<a name="0x1_Decimal_pair"></a>

## Function `pair`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_pair">pair</a>(op_id: u8, rounding_strategy_id: u8, sign_1: bool, int_1: u128, scale_1: u8, sign_2: bool, int_2: u128, scale_3: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_pair">pair</a>(
  op_id: u8,
  rounding_strategy_id: u8,
  // left number
  sign_1: bool,
  int_1: u128,
  scale_1: u8,
  // right number
  sign_2: bool,
  int_2: u128,
  scale_3: u8
): (bool, u128, u8);
</code></pre>



</details>

<a name="0x1_Decimal_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_new">new</a>(sign: bool, int: u128, scale: u8): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_new">new</a>(sign: bool, int: u128, scale: u8): <a href="Decimal.md#0x1_Decimal">Decimal</a> {

  <b>assert</b>!(int &lt; <a href="Decimal.md#0x1_Decimal_MAX_RUST_DECIMAL_U128">MAX_RUST_DECIMAL_U128</a>, 01);

  // check scale &lt; 28
  <b>assert</b>!(scale &lt; 28, 02);

  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_trunc"></a>

## Function `trunc`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_trunc">trunc</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_trunc">trunc</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_single">single</a>(<a href="Decimal.md#0x1_Decimal_TRUNC">TRUNC</a>, *&d.sign, *&d.int, *&d.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_sqrt"></a>

## Function `sqrt`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_sqrt">sqrt</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_sqrt">sqrt</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_single">single</a>(<a href="Decimal.md#0x1_Decimal_SQRT">SQRT</a>, *&d.sign, *&d.int, *&d.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_add"></a>

## Function `add`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_add">add</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_add">add</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_ADD">ADD</a>, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_sub"></a>

## Function `sub`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_sub">sub</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_sub">sub</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_SUB">SUB</a>, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_mul"></a>

## Function `mul`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_mul">mul</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_mul">mul</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_MUL">MUL</a>, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_div"></a>

## Function `div`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_div">div</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_div">div</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
 <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_DIV">DIV</a>, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
 <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
   sign: sign,
   int: int,
   scale: scale,
 }
}
</code></pre>



</details>

<a name="0x1_Decimal_rescale"></a>

## Function `rescale`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_rescale">rescale</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_rescale">rescale</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(0, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_round"></a>

## Function `round`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_round">round</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, strategy: u8): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_round">round</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, strategy: u8): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_ROUND">ROUND</a>, strategy, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_power"></a>

## Function `power`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_power">power</a>(l: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_power">power</a>(l: &<a href="Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): <a href="Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="Decimal.md#0x1_Decimal_pair">pair</a>(<a href="Decimal.md#0x1_Decimal_POW">POW</a>, <a href="Decimal.md#0x1_Decimal_ROUND_MID_TO_EVEN">ROUND_MID_TO_EVEN</a>, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_unwrap"></a>

## Function `unwrap`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_unwrap">unwrap</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_unwrap">unwrap</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): (bool, u128, u8) {
  <b>return</b> (*&d.sign, *&d.int, *&d.scale)
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_sign"></a>

## Function `borrow_sign`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_sign">borrow_sign</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_sign">borrow_sign</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): &bool {
  <b>return</b> &d.sign
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_int"></a>

## Function `borrow_int`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_int">borrow_int</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_int">borrow_int</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): &u128 {
  <b>return</b> &d.int
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_scale"></a>

## Function `borrow_scale`



<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_scale">borrow_scale</a>(d: &<a href="Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Decimal.md#0x1_Decimal_borrow_scale">borrow_scale</a>(d: &<a href="Decimal.md#0x1_Decimal">Decimal</a>): &u8 {
  <b>return</b> &d.scale
}
</code></pre>



</details>
