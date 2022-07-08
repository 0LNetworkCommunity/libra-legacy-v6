
<a name="0x1_DemoScripts"></a>

# Module `0x1::DemoScripts`



-  [Function `demo_e2e`](#0x1_DemoScripts_demo_e2e)


<pre><code><b>use</b> <a href="Debug.md#0x1_Debug">0x1::Debug</a>;
</code></pre>



<a name="0x1_DemoScripts_demo_e2e"></a>

## Function `demo_e2e`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_demo_e2e.md#0x1_DemoScripts_demo_e2e">demo_e2e</a>(world: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_demo_e2e.md#0x1_DemoScripts_demo_e2e">demo_e2e</a> (world: u64) {
    print(&0x0000000000000000000000000011e110); // Hello!
    print(&world); // World!
}
</code></pre>



</details>
