
<a name="0x1_MusicalChairs"></a>

# Module `0x1::MusicalChairs`



-  [Resource `Chairs`](#0x1_MusicalChairs_Chairs)
-  [Function `initialize`](#0x1_MusicalChairs_initialize)
-  [Function `stop_the_music`](#0x1_MusicalChairs_stop_the_music)
-  [Function `eval_compliance`](#0x1_MusicalChairs_eval_compliance)
-  [Function `get_current_seats`](#0x1_MusicalChairs_get_current_seats)


<pre><code><b>use</b> <a href="Cases.md#0x1_Cases">0x1::Cases</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
<b>use</b> <a href="Globals.md#0x1_Globals">0x1::Globals</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_MusicalChairs_Chairs"></a>

## Resource `Chairs`



<pre><code><b>struct</b> <a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>current_seats: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>history: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MusicalChairs_initialize"></a>

## Function `initialize`

Called by root in genesis to initialize the GAS coin


<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_initialize">initialize</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_initialize">initialize</a>(
    vm: &signer,
) {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);

    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <b>if</b> (<b>exists</b>&lt;<a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a>&gt;(@VMReserved)) {
        <b>return</b>
    };

    <b>move_to</b>(vm, <a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a> {
        current_seats: <a href="Globals.md#0x1_Globals_get_val_set_at_genesis">Globals::get_val_set_at_genesis</a>(),
        history: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
    });
}
</code></pre>



</details>

<a name="0x1_MusicalChairs_stop_the_music"></a>

## Function `stop_the_music`



<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_stop_the_music">stop_the_music</a>(vm: &signer, height_start: u64, height_end: u64): (vector&lt;<b>address</b>&gt;, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_stop_the_music">stop_the_music</a>( // sorry, had <b>to</b>.
  vm: &signer,
  height_start: u64,
  height_end: u64
): (vector&lt;<b>address</b>&gt;, u64) <b>acquires</b> <a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a> {
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
    <b>let</b> (compliant, _non, ratio) = <a href="MusicalChairs.md#0x1_MusicalChairs_eval_compliance">eval_compliance</a>(vm, height_start, height_end);

    <b>let</b> chairs = <b>borrow_global_mut</b>&lt;<a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a>&gt;(@VMReserved);
    <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_is_zero">FixedPoint32::is_zero</a>(*&ratio)) {
      chairs.current_seats = chairs.current_seats + 1;
    } <b>else</b> <b>if</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_multiply_u64">FixedPoint32::multiply_u64</a>(100, *&ratio) &gt; 5) {
      // remove chairs
      // reduce the validator set <b>to</b> the size of the compliant set.
      chairs.current_seats = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&compliant);
    };
    // otherwise do nothing, the validator set is within a tolerable range.

    (compliant, chairs.current_seats)
}
</code></pre>



</details>

<a name="0x1_MusicalChairs_eval_compliance"></a>

## Function `eval_compliance`



<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_eval_compliance">eval_compliance</a>(vm: &signer, height_start: u64, height_end: u64): (vector&lt;<b>address</b>&gt;, vector&lt;<b>address</b>&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_eval_compliance">eval_compliance</a>(
  vm: &signer,
  height_start: u64,
  height_end: u64
) : (vector&lt;<b>address</b>&gt;, vector&lt;<b>address</b>&gt;, <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_FixedPoint32">FixedPoint32::FixedPoint32</a>) {
    <b>let</b> validators = <a href="DiemSystem.md#0x1_DiemSystem_get_val_set_addr">DiemSystem::get_val_set_addr</a>();
    <b>let</b> val_set_len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&validators);

    <b>let</b> compliant_nodes = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();
    <b>let</b> non_compliant_nodes = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<b>address</b>&gt;();

    <b>let</b> i = 0;
    <b>while</b> (i &lt; val_set_len) {
        <b>let</b> addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&validators, i);
        <b>let</b> case = <a href="Cases.md#0x1_Cases_get_case">Cases::get_case</a>(vm, *addr, height_start, height_end);
        <b>if</b> (case == 1) {
            <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> compliant_nodes, *addr);
        } <b>else</b> {
            <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> non_compliant_nodes, *addr);
        };
        i = i + 1;
    };

    <b>let</b> good_len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&compliant_nodes) ;
    <b>let</b> bad_len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&non_compliant_nodes);

    // Note: sorry for repetition but necessary for writing tests and debugging.
    <b>let</b> null = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_raw_value">FixedPoint32::create_from_raw_value</a>(0);
    <b>if</b> (good_len &gt; val_set_len) { // safety
      <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), null)
    };

    <b>if</b> (bad_len &gt; val_set_len) { // safety
      <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), null)
    };

    <b>if</b> ((good_len + bad_len) != val_set_len) { // safety
      <b>return</b> (<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(), null)
    };


    <b>let</b> ratio = <b>if</b> (bad_len &gt; 0) {
      <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(bad_len, val_set_len)
    } <b>else</b> {
      null
    };

    (compliant_nodes, non_compliant_nodes, ratio)
}
</code></pre>



</details>

<a name="0x1_MusicalChairs_get_current_seats"></a>

## Function `get_current_seats`



<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_get_current_seats">get_current_seats</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="MusicalChairs.md#0x1_MusicalChairs_get_current_seats">get_current_seats</a>(): u64 <b>acquires</b> <a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a> {
    <b>borrow_global</b>&lt;<a href="MusicalChairs.md#0x1_MusicalChairs_Chairs">Chairs</a>&gt;(@VMReserved).current_seats
}
</code></pre>



</details>
