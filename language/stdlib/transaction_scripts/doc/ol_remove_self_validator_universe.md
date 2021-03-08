
<a name="remove_self"></a>

# Script `remove_self`





<pre><code><b>use</b> <a href="../../modules/doc/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_remove_self_validator_universe.md#remove_self">remove_self</a>(validator: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_remove_self_validator_universe.md#remove_self">remove_self</a>(validator: &signer) {
    <b>let</b> addr = <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(validator);
    <b>if</b> (<a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(addr)) {
        <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse_remove_self">ValidatorUniverse::remove_self</a>(validator);
    };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
