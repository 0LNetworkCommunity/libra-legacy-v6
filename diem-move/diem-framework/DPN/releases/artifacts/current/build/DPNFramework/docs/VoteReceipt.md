
<a name="0x1_VoteReceipt"></a>

# Module `0x1::VoteReceipt`



-  [Resource `VoteReceipt`](#0x1_VoteReceipt_VoteReceipt)
-  [Resource `IVoted`](#0x1_VoteReceipt_IVoted)
-  [Function `make_receipt`](#0x1_VoteReceipt_make_receipt)
-  [Function `find_prior_vote_idx`](#0x1_VoteReceipt_find_prior_vote_idx)
-  [Function `get_vote_receipt`](#0x1_VoteReceipt_get_vote_receipt)
-  [Function `remove_vote_receipt`](#0x1_VoteReceipt_remove_vote_receipt)
-  [Function `get_receipt_data`](#0x1_VoteReceipt_get_receipt_data)


<pre><code><b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID">0x1::GUID</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_VoteReceipt_VoteReceipt"></a>

## Resource `VoteReceipt`



<pre><code><b>struct</b> <a href="VoteReceipt.md#0x1_VoteReceipt">VoteReceipt</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>guid: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>approve_reject: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>weight: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_VoteReceipt_IVoted"></a>

## Resource `IVoted`



<pre><code><b>struct</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>elections: vector&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_VoteReceipt">VoteReceipt::VoteReceipt</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_VoteReceipt_make_receipt"></a>

## Function `make_receipt`



<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_make_receipt">make_receipt</a>(user_sig: &signer, vote_id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>, approve_reject: bool, weight: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_make_receipt">make_receipt</a>(user_sig: &signer, vote_id: &ID, approve_reject: bool, weight: u64) <b>acquires</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {

  <b>let</b> user_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(user_sig);

  <b>let</b> receipt = <a href="VoteReceipt.md#0x1_VoteReceipt">VoteReceipt</a> {
    guid: *vote_id,
    approve_reject: approve_reject,
    weight: weight,
  };

  <b>if</b> (!<b>exists</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr)) {
    <b>let</b> ivoted = <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {
      elections: <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    };
    <b>move_to</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_sig, ivoted);
  };

  <b>let</b> (idx, is_found) = <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">find_prior_vote_idx</a>(user_addr, vote_id);

  // for safety remove the <b>old</b> vote <b>if</b> it <b>exists</b>.
  <b>let</b> ivoted = <b>borrow_global_mut</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr);
  <b>if</b> (is_found) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> ivoted.elections, idx);
  };
  <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ivoted.elections, receipt);
}
</code></pre>



</details>

<a name="0x1_VoteReceipt_find_prior_vote_idx"></a>

## Function `find_prior_vote_idx`



<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">find_prior_vote_idx</a>(user_addr: <b>address</b>, vote_id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">find_prior_vote_idx</a>(user_addr: <b>address</b>, vote_id: &ID): (u64, bool) <b>acquires</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {
  <b>if</b> (!<b>exists</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr)) {
    <b>return</b> (0, <b>false</b>)
  };

  <b>let</b> ivoted = <b>borrow_global</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr);
  <b>let</b> len = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>(&ivoted.elections);
  <b>let</b> i = 0;
  <b>while</b> (i &lt; len) {
    <b>let</b> receipt = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&ivoted.elections, i);
    <b>if</b> (&receipt.guid == vote_id) {
      <b>return</b> (i, <b>true</b>)
    };
    i = i + 1;
  };

  <b>return</b> (0, <b>false</b>)
}
</code></pre>



</details>

<a name="0x1_VoteReceipt_get_vote_receipt"></a>

## Function `get_vote_receipt`



<pre><code><b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_get_vote_receipt">get_vote_receipt</a>(user_addr: <b>address</b>, idx: u64): <a href="VoteReceipt.md#0x1_VoteReceipt_VoteReceipt">VoteReceipt::VoteReceipt</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_get_vote_receipt">get_vote_receipt</a>(user_addr: <b>address</b>, idx: u64): <a href="VoteReceipt.md#0x1_VoteReceipt">VoteReceipt</a> <b>acquires</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {
  <b>let</b> ivoted = <b>borrow_global</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr);
  <b>let</b> r = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&ivoted.elections, idx);
  <b>return</b> *r
}
</code></pre>



</details>

<a name="0x1_VoteReceipt_remove_vote_receipt"></a>

## Function `remove_vote_receipt`



<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_remove_vote_receipt">remove_vote_receipt</a>(sig: &signer, vote_id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_remove_vote_receipt">remove_vote_receipt</a>(sig: &signer, vote_id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>) <b>acquires</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {
  <b>let</b> user_addr = <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sig);
  <b>let</b> (idx, is_found) = <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">find_prior_vote_idx</a>(user_addr, vote_id);

  <b>let</b> ivoted = <b>borrow_global_mut</b>&lt;<a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a>&gt;(user_addr);
  <b>if</b> (is_found) {
    <a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/Vector.md#0x1_Vector_remove">Vector::remove</a>(&<b>mut</b> ivoted.elections, idx);
  };
}
</code></pre>



</details>

<a name="0x1_VoteReceipt_get_receipt_data"></a>

## Function `get_receipt_data`

gets the receipt data


<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_get_receipt_data">get_receipt_data</a>(user_addr: <b>address</b>, vote_id: &<a href="../../../../../../../DPN/releases/artifacts/current/build/MoveStdlib/docs/GUID.md#0x1_GUID_ID">GUID::ID</a>): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="VoteReceipt.md#0x1_VoteReceipt_get_receipt_data">get_receipt_data</a>(user_addr: <b>address</b>, vote_id: &ID): (bool, u64) <b>acquires</b> <a href="VoteReceipt.md#0x1_VoteReceipt_IVoted">IVoted</a> {
  <b>let</b> (idx, found) = <a href="VoteReceipt.md#0x1_VoteReceipt_find_prior_vote_idx">find_prior_vote_idx</a>(user_addr, vote_id);
  <b>if</b> (found) {
      <b>let</b> v = <a href="VoteReceipt.md#0x1_VoteReceipt_get_vote_receipt">get_vote_receipt</a>(user_addr, idx);
      <b>return</b> (v.approve_reject, v.weight)
    };
  <b>return</b> (<b>false</b>, 0)
}
</code></pre>



</details>
