
<a name="0x1_BinaryTally"></a>

# Module `0x1::BinaryTally`



-  [Struct `BinaryTally`](#0x1_BinaryTally_BinaryTally)
-  [Struct `BallotDeadline`](#0x1_BinaryTally_BallotDeadline)


<pre><code></code></pre>



<a name="0x1_BinaryTally_BinaryTally"></a>

## Struct `BinaryTally`



<pre><code><b>struct</b> <a href="BinaryBallot.md#0x1_BinaryTally">BinaryTally</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cfg_deadline: <a href="BinaryBallot.md#0x1_BinaryTally_BallotDeadline">BinaryTally::BallotDeadline</a></code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_enrollment_votes: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>votes_approve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>votes_reject: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>passed: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_BinaryTally_BallotDeadline"></a>

## Struct `BallotDeadline`



<pre><code><b>struct</b> <a href="BinaryBallot.md#0x1_BinaryTally_BallotDeadline">BallotDeadline</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cfg_deadline_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_can_extend: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_max_number_extensions: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>extended_deadline: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>
