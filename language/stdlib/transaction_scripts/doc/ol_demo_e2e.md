
<a name="demo_e2e"></a>

# Script `demo_e2e`





<pre><code><b>use</b> <a href="../../modules/doc/Debug.md#0x1_Debug">0x1::Debug</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_demo_e2e.md#demo_e2e">demo_e2e</a>(world: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_demo_e2e.md#demo_e2e">demo_e2e</a> (world: u64) {
    print(&0x0000000000000000000000000011e110); // Hello!
    print(&world); // World!
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/diem/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/diem/lip/blob/master/lips/lip-2.md#permissions
