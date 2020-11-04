
<a name="ol_reconfig_bulk_update_e2e_test_helper"></a>

# Script `ol_reconfig_bulk_update_e2e_test_helper`





<pre><code><b>use</b> <a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem">0x1::LibraSystem</a>;
<b>use</b> <a href="../../modules/doc/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../modules/doc/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_reconfig_bulk_update_e2e_test_helper.md#ol_reconfig_bulk_update_e2e_test_helper">ol_reconfig_bulk_update_e2e_test_helper</a>(account: &signer, alice: &signer, bob: &signer, carol: &signer, dave: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_reconfig_bulk_update_e2e_test_helper.md#ol_reconfig_bulk_update_e2e_test_helper">ol_reconfig_bulk_update_e2e_test_helper</a>(
    account: &signer,
    alice: &signer,
    bob: &signer,
    carol: &signer,
    dave: &signer,
) {
    // Create vector of validators and add the desired new validator set
    <b>let</b> vec = <a href="../../modules/doc/Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse_add_validator">ValidatorUniverse::add_validator</a>(alice);
    <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse_add_validator">ValidatorUniverse::add_validator</a>(bob);
    <a href="../../modules/doc/ValidatorUniverse.md#0x1_ValidatorUniverse_add_validator">ValidatorUniverse::add_validator</a>(carol);

    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(alice));
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(bob));
    <a href="../../modules/doc/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(carol));

    <b>assert</b>(<a href="../../modules/doc/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&vec) == 3, 5);

    // Update the validator set
    <a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_bulk_update_validators">LibraSystem::bulk_update_validators</a>(account, vec);

    // Assert that updates happened correctly
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_validator_set_size">LibraSystem::validator_set_size</a>() == 3, 6);
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(<a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(dave)) == <b>false</b>, 7);
    <b>assert</b>(<a href="../../modules/doc/LibraSystem.md#0x1_LibraSystem_is_validator">LibraSystem::is_validator</a>(<a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(bob)) == <b>true</b>, 8);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
