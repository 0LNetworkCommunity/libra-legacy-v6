
<a name="0x0_NodeWeight"></a>

# Module `0x0::NodeWeight`

### Table of Contents

-  [Function `top_n_accounts`](#0x0_NodeWeight_top_n_accounts)



<a name="0x0_NodeWeight_top_n_accounts"></a>

## Function `top_n_accounts`



<pre><code><b>public</b> <b>fun</b> <a href="#0x0_NodeWeight_top_n_accounts">top_n_accounts</a>(accounts: vector&lt;address&gt;, n: u64): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x0_NodeWeight_top_n_accounts">top_n_accounts</a>(accounts: vector&lt;address&gt;, n: u64): vector&lt;address&gt; {

  <b>let</b> length = <a href="Vector.md#0x0_Vector_length">Vector::length</a>&lt;address&gt;(&accounts);

  //BASE CASE
  // If n is greater than or equal <b>to</b> accounts vector length - <b>return</b> the vector.
  <b>if</b>(length&lt;=n)
    <b>return</b> accounts;

  // Now we rank <b>to</b> find out top n accounts based on weights.
  //Weight - currently only considers the account balance.
  // TODO: <a href="stats.md#0x0_Stats">Stats</a> <b>module</b> results.

  // <a href="Vector.md#0x0_Vector">Vector</a> <b>to</b> store node_weights
  <b>let</b> weights = <a href="Vector.md#0x0_Vector_empty">Vector::empty</a>&lt;u64&gt;();
  <b>let</b> k = 0;
  <b>while</b> (k &lt; length) {
      <b>let</b> cur_address = <a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;address&gt;(&accounts, k);
      // Retrieve balance for the current account
      <b>let</b> balance = <a href="LibraAccount.md#0x0_LibraAccount_balance">LibraAccount::balance</a>&lt;<a href="gas.md#0x0_GAS_T">GAS::T</a>&gt;({{*cur_address}});
      // Weight is just account balance for now.
      <a href="Vector.md#0x0_Vector_push_back">Vector::push_back</a>&lt;u64&gt;(&<b>mut</b> weights, balance);
      k = k + 1;
  };


  // Sorting the accounts vector based on value (weights).
  // Bubble sort algorithm
  <b>let</b> i = 0;
  <b>while</b> (i &lt; length){
    <b>let</b> j = 0;
    <b>while</b>(j &lt; length-i-1){
      <b>let</b> value_j = *(<a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j));
      <b>let</b> value_jp1 = *(<a href="Vector.md#0x0_Vector_borrow">Vector::borrow</a>&lt;u64&gt;(&weights, j+1));
      <b>if</b>(value_j &gt; value_jp1){
        <a href="Vector.md#0x0_Vector_swap">Vector::swap</a>&lt;u64&gt;(&<b>mut</b> weights, j, j+1);
        <a href="Vector.md#0x0_Vector_swap">Vector::swap</a>&lt;address&gt;(&<b>mut</b> accounts, j, j+1);
      };
      j = j + 1;
    };
    i = i + 1;
  };

  // Reverse <b>to</b> have sorted order - high <b>to</b> low.
  <a href="Vector.md#0x0_Vector_reverse">Vector::reverse</a>&lt;address&gt;(&<b>mut</b> accounts);
  <b>let</b> index = n;
  <b>while</b>(index &lt; length){
    <a href="Vector.md#0x0_Vector_pop_back">Vector::pop_back</a>&lt;address&gt;(&<b>mut</b> accounts);
    index = index + 1;
  };
  <b>return</b> accounts
}
</code></pre>



</details>
