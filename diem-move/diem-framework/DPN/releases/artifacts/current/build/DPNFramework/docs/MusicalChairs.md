
<a name="0x1_MusicalChairs"></a>

# Module `0x1::MusicalChairs`



-  [Resource `Chairs`](#0x1_MusicalChairs_Chairs)
-  [Function `initialize`](#0x1_MusicalChairs_initialize)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
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
        current_seats: 0,
        history: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u64&gt;(),
    });
}
</code></pre>



</details>
