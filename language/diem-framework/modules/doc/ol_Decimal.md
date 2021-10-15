
<a name="0x1_Decimal"></a>

# Module `0x1::Decimal`



-  [Resource `Decimal`](#0x1_Decimal_Decimal)
-  [Constants](#@Constants_0)
-  [Function `decimal_demo`](#0x1_Decimal_decimal_demo)
-  [Function `single_op`](#0x1_Decimal_single_op)
-  [Function `pair_op`](#0x1_Decimal_pair_op)
-  [Function `new`](#0x1_Decimal_new)
-  [Function `sqrt`](#0x1_Decimal_sqrt)
-  [Function `add`](#0x1_Decimal_add)
-  [Function `sub`](#0x1_Decimal_sub)
-  [Function `mul`](#0x1_Decimal_mul)
-  [Function `div`](#0x1_Decimal_div)
-  [Function `rescale`](#0x1_Decimal_rescale)
-  [Function `power`](#0x1_Decimal_power)
-  [Function `unwrap`](#0x1_Decimal_unwrap)
-  [Function `borrow_sign`](#0x1_Decimal_borrow_sign)
-  [Function `borrow_int`](#0x1_Decimal_borrow_int)
-  [Function `borrow_scale`](#0x1_Decimal_borrow_scale)


<pre><code></code></pre>



<a name="0x1_Decimal_Decimal"></a>

## Resource `Decimal`



<pre><code><b>struct</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> has drop, store, key
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



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_ADD">ADD</a>: u8 = 1;
</code></pre>



<a name="0x1_Decimal_DIV"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_DIV">DIV</a>: u8 = 4;
</code></pre>



<a name="0x1_Decimal_MAX_RUST_U64"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_MAX_RUST_U64">MAX_RUST_U64</a>: u128 = 18446744073709551615;
</code></pre>



<a name="0x1_Decimal_MULT"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_MULT">MULT</a>: u8 = 3;
</code></pre>



<a name="0x1_Decimal_ROUNDING_UP"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_ROUNDING_UP">ROUNDING_UP</a>: u8 = 1;
</code></pre>



<a name="0x1_Decimal_SQRT"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_SQRT">SQRT</a>: u8 = 5;
</code></pre>



<a name="0x1_Decimal_SUB"></a>



<pre><code><b>const</b> <a href="ol_Decimal.md#0x1_Decimal_SUB">SUB</a>: u8 = 2;
</code></pre>



<a name="0x1_Decimal_decimal_demo"></a>

## Function `decimal_demo`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_decimal_demo">decimal_demo</a>(sign: bool, int: u128, scale: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_decimal_demo">decimal_demo</a>(sign: bool, int: u128, scale: u8): (bool, u128, u8);
</code></pre>



</details>

<a name="0x1_Decimal_single_op"></a>

## Function `single_op`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_single_op">single_op</a>(op_id: u8, sign: bool, int: u128, scale: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_single_op">single_op</a>(op_id: u8, sign: bool, int: u128, scale: u8): (bool, u128, u8);
</code></pre>



</details>

<a name="0x1_Decimal_pair_op"></a>

## Function `pair_op`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(op_id: u8, rounding_strategy_id: u8, sign_1: bool, int_1: u128, scale_1: u8, sign_2: bool, int_2: u128, scale_3: u8): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(
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



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_new">new</a>(sign: bool, int: u128, scale: u8): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_new">new</a>(sign: bool, int: u128, scale: u8): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  // in Rust, the integer is downcast <b>to</b> u64
  // so we limit new <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> types <b>to</b> that scale.
  <b>assert</b>(int &lt; <a href="ol_Decimal.md#0x1_Decimal_MAX_RUST_U64">MAX_RUST_U64</a>, 01);

  // check scale &lt; 28
  <b>assert</b>(scale &lt; 28, 02);

  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_sqrt"></a>

## Function `sqrt`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_sqrt">sqrt</a>(d: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_sqrt">sqrt</a>(d: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_single_op">single_op</a>(5, *&d.sign, *&d.int, *&d.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_add"></a>

## Function `add`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_add">add</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_add">add</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(1, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_sub"></a>

## Function `sub`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_sub">sub</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_sub">sub</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(2, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_mul"></a>

## Function `mul`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_mul">mul</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_mul">mul</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(3, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_div"></a>

## Function `div`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_div">div</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_div">div</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
 <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(4, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
 <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
   sign: sign,
   int: int,
   scale: scale,
 }
}
</code></pre>



</details>

<a name="0x1_Decimal_rescale"></a>

## Function `rescale`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_rescale">rescale</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_rescale">rescale</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(0, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_power"></a>

## Function `power`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_power">power</a>(l: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_power">power</a>(l: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>, r: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
  <b>let</b> (sign, int, scale) = <a href="ol_Decimal.md#0x1_Decimal_pair_op">pair_op</a>(5, 0, *&l.sign, *&l.int, *&l.scale,  *&r.sign, *&r.int, *&r.scale);
  <b>return</b> <a href="ol_Decimal.md#0x1_Decimal">Decimal</a> {
    sign: sign,
    int: int,
    scale: scale,
  }
}
</code></pre>



</details>

<a name="0x1_Decimal_unwrap"></a>

## Function `unwrap`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_unwrap">unwrap</a>(d: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): (bool, u128, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_unwrap">unwrap</a>(d: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): (bool, u128, u8) {
  <b>return</b> (*&d.sign, *&d.int, *&d.scale)
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_sign"></a>

## Function `borrow_sign`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_sign">borrow_sign</a>(d: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_sign">borrow_sign</a>(d: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): &bool {
  <b>return</b> &d.sign
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_int"></a>

## Function `borrow_int`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_int">borrow_int</a>(d: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_int">borrow_int</a>(d: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): &u128 {
  <b>return</b> &d.int
}
</code></pre>



</details>

<a name="0x1_Decimal_borrow_scale"></a>

## Function `borrow_scale`



<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_scale">borrow_scale</a>(d: &<a href="ol_Decimal.md#0x1_Decimal_Decimal">Decimal::Decimal</a>): &u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ol_Decimal.md#0x1_Decimal_borrow_scale">borrow_scale</a>(d: &<a href="ol_Decimal.md#0x1_Decimal">Decimal</a>): &u8 {
  <b>return</b> &d.scale
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
