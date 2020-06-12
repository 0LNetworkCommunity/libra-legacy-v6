
<a name="0x0_Stats"></a>

# Module `0x0::Stats`

### Table of Contents

-  [Struct `Chunk`](#0x0_Stats_Chunk)
-  [Struct `Node`](#0x0_Stats_Node)
-  [Struct `History`](#0x0_Stats_History)
-  [Function `initialize`](#0x0_Stats_initialize)
-  [Function `Node_Heuristics`](#0x0_Stats_Node_Heuristics)
-  [Function `Network_Heuristics`](#0x0_Stats_Network_Heuristics)
-  [Function `newBlock`](#0x0_Stats_newBlock)
-  [Function `insert`](#0x0_Stats_insert)
-  [Function `get_node`](#0x0_Stats_get_node)
-  [Function `get_node_mut`](#0x0_Stats_get_node_mut)
-  [Function `exists`](#0x0_Stats_exists)



<a name="0x0_Stats_Chunk"></a>

## Struct `Chunk`



<pre><code><b>struct</b> <a href="#0x0_Stats_Chunk">Chunk</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>start_block: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>end_block: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_Node"></a>

## Struct `Node`



<pre><code><b>struct</b> <a href="#0x0_Stats_Node">Node</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>validator: address</code>
</dt>
<dd>

</dd>
<dt>

<code>chunks: vector&lt;<a href="#0x0_Stats_Chunk">Stats::Chunk</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_History"></a>

## Struct `History`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x0_Stats_History">History</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>val_list: vector&lt;<a href="#0x0_Stats_Node">Stats::Node</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_Stats_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_initialize">initialize</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_initialize">initialize</a>() {
  // Eventually want <b>to</b> ensue that only the <a href="Association.md#0x0_Association">Association</a> and make a history block.
  // This should happen in genesis
  move_to_sender&lt;<a href="#0x0_Stats_History">History</a>&gt;(<a href="#0x0_Stats_History">History</a>{ val_list: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>() });
}
</code></pre>



</details>

<a name="0x0_Stats_Node_Heuristics"></a>

## Function `Node_Heuristics`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_Node_Heuristics">Node_Heuristics</a>(node_addr: address, start_height: u64, end_height: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_Node_Heuristics">Node_Heuristics</a>(node_addr: address, start_height: u64,
  end_height: u64): u64 <b>acquires</b> <a href="#0x0_Stats_History">History</a> {
  // Returns the percentage of blocks in the given range that the block voted on

  <b>if</b> (start_height &gt; end_height) <b>return</b> 0;
  <b>let</b> history = borrow_global&lt;<a href="#0x0_Stats_History">History</a>&gt;(Transaction::sender());

  // This is the case where the validator has voted on nothing and does not have a <a href="#0x0_Stats_Node">Node</a>
  <b>if</b> (!<a href="#0x0_Stats_exists">exists</a>(history, node_addr)) <b>return</b> 0;

  <b>let</b> node = <a href="#0x0_Stats_get_node">get_node</a>(history, node_addr);
  <b>let</b> chunks = &node.chunks;
  <b>let</b> i = 0;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(chunks);
  <b>let</b> num_voted = 0;

  // Go though all the chunks of the validator and accumulate
  <b>while</b> (i &lt; len) {
    <b>let</b> chunk = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(chunks, i);
    // Check <b>if</b> the chunk has segments in desired region
    <b>if</b> (chunk.end_block &gt; start_height && chunk.start_block &lt; end_height) {
      // Find the lower and upper blockheights within desired region
      <b>let</b> lower = chunk.start_block;
      <b>if</b> (start_height &gt; lower) lower = start_height;

      <b>let</b> upper = chunk.end_block;
      <b>if</b> (end_height &lt; upper) upper = end_height;

      // +1 because bounds are inclusive.
      // E.g. a node which participated in only block 30 would have
      // upper - lower = 0 even though it voted in a block.
      num_voted = num_voted + (upper - lower + 1);
    }
  };
  num_voted
  // This should be added <b>to</b> get a percentage: num_voted / (end_height - start_height + 1)
}
</code></pre>



</details>

<a name="0x0_Stats_Network_Heuristics"></a>

## Function `Network_Heuristics`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_Network_Heuristics">Network_Heuristics</a>(start_height: u64, end_height: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_Network_Heuristics">Network_Heuristics</a>(start_height: u64, end_height: u64): u64 <b>acquires</b> <a href="#0x0_Stats_History">History</a>{
  <b>if</b> (start_height &gt; end_height) <b>return</b> 0;
  <b>let</b> history = borrow_global&lt;<a href="#0x0_Stats_History">History</a>&gt;(Transaction::sender());
  <b>let</b> val_list = &history.val_list;

  // This keeps track of how many voters voted on every single block in the range
  <b>let</b> num_voters = 0;
  <b>let</b> num_nodes = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(val_list);
  <b>if</b> (num_nodes == 0) <b>return</b> 0;
  <b>let</b> i = 0;

  // Go though all the nodes and find the ones which paticipated
  <b>while</b> (i &lt; num_nodes) {
    <b>let</b> j = 0;
    <b>let</b> node = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(val_list, i);
    <b>let</b> chunks = &node.chunks;
    <b>let</b> num_chunks = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(chunks);

    // If the node has participated in every single block in a range, then that entire
    // range will be a subset of one of the chunks in the data structure. So, we need
    // only <b>to</b> find the chunk whose start_block is just below (or equal <b>to</b>) the start_height
    // This is faster in a BST, but we do a linear search for the POC implementation
    <b>if</b> (num_chunks == 0) <b>continue</b>;
    <b>let</b> chunk = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(chunks, 0);
    <b>while</b> (j &lt; num_chunks) {
      <b>let</b> cand_chunk = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(chunks, j);
      <b>if</b> (cand_chunk.start_block &lt;= start_height && cand_chunk.start_block &lt; chunk.start_block) {
        chunk = cand_chunk;
      }
    };
    // This is the case that this voter has voted for all blocks in the range
    <b>if</b> (chunk.start_block &lt;= start_height && chunk.end_block &gt;= end_height){
      num_voters = num_voters + 1;
    }
  };
  <b>return</b> num_voters
}
</code></pre>



</details>

<a name="0x0_Stats_newBlock"></a>

## Function `newBlock`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_newBlock">newBlock</a>(height: u64, votes: &vector&lt;address&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_newBlock">newBlock</a>(height: u64, votes: &vector&lt;address&gt;) <b>acquires</b> <a href="#0x0_Stats_History">History</a> {
  <b>let</b> i = 0;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;address&gt;(votes);

  <b>while</b> (i &lt; len) {
    <a href="#0x0_Stats_insert">insert</a>(*<a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>(votes, i), height, height);
  };
}
</code></pre>



</details>

<a name="0x0_Stats_insert"></a>

## Function `insert`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_insert">insert</a>(node_addr: address, start_block: u64, end_block: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_Stats_insert">insert</a>(node_addr: address, start_block: u64, end_block: u64) <b>acquires</b> <a href="#0x0_Stats_History">History</a> {
  <b>let</b> history = borrow_global_mut&lt;<a href="#0x0_Stats_History">History</a>&gt;(Transaction::sender());
  //<b>let</b> node_list = &<b>mut</b> history.val_list;

  // Add the a <a href="#0x0_Stats_Node">Node</a> for the validator <b>if</b> one doesn't aleady exist
  <b>if</b> (!<a href="#0x0_Stats_exists">exists</a>(history, node_addr)) {
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> history.val_list, <a href="#0x0_Stats_Node">Node</a>{ validator: node_addr, chunks: <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>() });
  };

  <b>let</b> node = <a href="#0x0_Stats_get_node_mut">get_node_mut</a>(history, node_addr);
  <b>let</b> i = 0;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Chunk">Chunk</a>&gt;(&node.chunks);

  <b>if</b> (len == 0) {
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> node.chunks, <a href="#0x0_Stats_Chunk">Chunk</a>{ start_block: start_block, end_block: end_block });
    <b>return</b>
  };

  // This is a temporary reference <b>to</b> an existing chunk. Assuming there are no
  // conflicts and it is not adjacent <b>to</b> an existing chunk, it will be discarded.
  // If it is adjacent, we will assign this reference <b>to</b> the adjacent chunk so
  // we don't have <b>to</b> search for it again.
  // This should all be simpler in the final implementation in Rust since we will
  // be able <b>to</b> <b>use</b> binary trees and the <a href="Option.md#0x0_Option">Option</a>&lt;T&gt; type.
  <b>let</b> adjacent = <b>false</b>;
  <b>let</b> chunk = <a href="Vector.md#0x0_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> node.chunks, 0);

  // Check <b>to</b> see <b>if</b> the insert conflicts with what is already stored
  <b>while</b> (i &lt; len) {
    chunk = <a href="Vector.md#0x0_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> node.chunks, i);
    Transaction::assert(chunk.start_block &gt; end_block, 1);
    Transaction::assert(chunk.end_block &lt; start_block, 1);
    // If chunk.end_block == start_block, then we are just adding on <b>to</b> the last block
    <b>if</b> (chunk.end_block == start_block) {
      adjacent = <b>true</b>;
      <b>break</b>
    };
  };

  // Add in the new chunk
  <b>if</b> (adjacent){
    chunk.end_block = end_block
  } <b>else</b> {
    <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>(&<b>mut</b> node.chunks, <a href="#0x0_Stats_Chunk">Chunk</a>{ start_block: start_block, end_block: end_block });
  }
}
</code></pre>



</details>

<a name="0x0_Stats_get_node"></a>

## Function `get_node`



<pre><code><b>fun</b> <a href="#0x0_Stats_get_node">get_node</a>(hist: &<a href="#0x0_Stats_History">Stats::History</a>, add: address): &<a href="#0x0_Stats_Node">Stats::Node</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Stats_get_node">get_node</a>(hist: &<a href="#0x0_Stats_History">History</a>, add: address): &<a href="#0x0_Stats_Node">Node</a> {
  <b>let</b> i = 0;
  <b>let</b> node_list = &hist.val_list;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list);
  <b>let</b> node = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list, i);

  <b>while</b> (i &lt; len) {
    node = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list, i);
    <b>if</b> (node.validator == add) <b>break</b>;
  };
  node
}
</code></pre>



</details>

<a name="0x0_Stats_get_node_mut"></a>

## Function `get_node_mut`



<pre><code><b>fun</b> <a href="#0x0_Stats_get_node_mut">get_node_mut</a>(hist: &<b>mut</b> <a href="#0x0_Stats_History">Stats::History</a>, add: address): &<b>mut</b> <a href="#0x0_Stats_Node">Stats::Node</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Stats_get_node_mut">get_node_mut</a>(hist: &<b>mut</b> <a href="#0x0_Stats_History">History</a>, add: address): &<b>mut</b> <a href="#0x0_Stats_Node">Node</a> {
  <b>let</b> i = 0;
  <b>let</b> node_list = &<b>mut</b> hist.val_list;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list);
  <b>let</b> node = <a href="Vector.md#0x0_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list, i);

  <b>while</b> (i &lt; len) {
    node = <a href="Vector.md#0x0_Vector_borrow_mut">Vector::borrow_mut</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list, i);
    <b>if</b> (node.validator == add) <b>break</b>;
  };
  node
}
</code></pre>



</details>

<a name="0x0_Stats_exists"></a>

## Function `exists`



<pre><code><b>fun</b> <a href="#0x0_Stats_exists">exists</a>(hist: &<a href="#0x0_Stats_History">Stats::History</a>, add: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x0_Stats_exists">exists</a>(hist: &<a href="#0x0_Stats_History">History</a>, add: address): bool {
  <b>let</b> i = 0;
  <b>let</b> node_list = &hist.val_list;
  <b>let</b> len = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list);

  <b>while</b> (i &lt; len) {
    <b>if</b> (<a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;<a href="#0x0_Stats_Node">Node</a>&gt;(node_list, i).validator == add) <b>return</b> <b>true</b>;
  };
  <b>false</b>
}
</code></pre>



</details>
