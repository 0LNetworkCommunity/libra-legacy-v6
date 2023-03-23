
<a name="0x1_BinaryBallot"></a>

# Module `0x1::BinaryBallot`



-  [Struct `BinaryBallot`](#0x1_BinaryBallot_BinaryBallot)
-  [Struct `BallotDeadline`](#0x1_BinaryBallot_BallotDeadline)


<pre><code></code></pre>



<a name="0x1_BinaryBallot_BinaryBallot"></a>

## Struct `BinaryBallot`



<pre><code><b>struct</b> <a href="BinaryBallot.md#0x1_BinaryBallot">BinaryBallot</a>&lt;Issue, TallyType&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cfg_deadline: <a href="BinaryBallot.md#0x1_BinaryBallot_BallotDeadline">BinaryBallot::BallotDeadline</a></code>
</dt>
<dd>

</dd>
<dt>
<code>cfg_enrollment_votes: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>issue: Issue</code>
</dt>
<dd>

</dd>
<dt>
<code>tally: TallyType</code>
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

<a name="0x1_BinaryBallot_BallotDeadline"></a>

## Struct `BallotDeadline`



<pre><code><b>struct</b> <a href="BinaryBallot.md#0x1_BinaryBallot_BallotDeadline">BallotDeadline</a> <b>has</b> drop, store
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
