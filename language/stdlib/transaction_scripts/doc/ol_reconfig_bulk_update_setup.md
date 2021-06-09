
<a name="ol_reconfig_bulk_update_setup"></a>

# Script `ol_reconfig_bulk_update_setup`





<pre><code><b>use</b> <a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem">0x1::LibraSystem</a>;
<b>use</b> <a href="../../modules/doc/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_reconfig_bulk_update_setup.md#ol_reconfig_bulk_update_setup">ol_reconfig_bulk_update_setup</a>(account: &signer, alice: address, bob: address, carol: address, sha: address, ram: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_reconfig_bulk_update_setup.md#ol_reconfig_bulk_update_setup">ol_reconfig_bulk_update_setup</a>(account: &signer, alice: address, bob: address, carol: address,
    sha: address, ram: address) {
    // Create vector of desired validators
    <b>let</b> vec = <a href="../../modules/doc/Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, alice);
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, bob);
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, carol);
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, sha);
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, ram);
    <b>assert</b>(<a href="../../modules/doc/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&vec) == 5, 1);

    // Set this <b>to</b> be the validator set
    <a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_bulk_update_validators">LibraSystem::bulk_update_validators</a>(account, vec);

    // Tests on initial validator set
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_validator_set_size">LibraSystem::validator_set_size</a>() == 5, 2);
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(sha) == <b>true</b>, 3);
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(alice) == <b>true</b>, 4);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
