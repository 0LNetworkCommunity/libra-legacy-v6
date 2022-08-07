
<a name="0x1_ValidatorScripts"></a>

# Module `0x1::ValidatorScripts`



-  [Constants](#@Constants_0)
-  [Function `ol_reconfig_bulk_update_setup`](#0x1_ValidatorScripts_ol_reconfig_bulk_update_setup)
-  [Function `self_unjail`](#0x1_ValidatorScripts_self_unjail)
-  [Function `voucher_unjail`](#0x1_ValidatorScripts_voucher_unjail)
-  [Function `val_add_self`](#0x1_ValidatorScripts_val_add_self)


<pre><code><b>use</b> <a href="DiemSystem.md#0x1_DiemSystem">0x1::DiemSystem</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_ValidatorScripts_NOT_ABOVE_THRESH_ADD"></a>



<pre><code><b>const</b> <a href="ol_validator.md#0x1_ValidatorScripts_NOT_ABOVE_THRESH_ADD">NOT_ABOVE_THRESH_ADD</a>: u64 = 220102;
</code></pre>



<a name="0x1_ValidatorScripts_NOT_ABOVE_THRESH_JOIN"></a>



<pre><code><b>const</b> <a href="ol_validator.md#0x1_ValidatorScripts_NOT_ABOVE_THRESH_JOIN">NOT_ABOVE_THRESH_JOIN</a>: u64 = 220101;
</code></pre>



<a name="0x1_ValidatorScripts_VAL_NOT_FOUND"></a>



<pre><code><b>const</b> <a href="ol_validator.md#0x1_ValidatorScripts_VAL_NOT_FOUND">VAL_NOT_FOUND</a>: u64 = 220103;
</code></pre>



<a name="0x1_ValidatorScripts_VAL_NOT_JAILED"></a>



<pre><code><b>const</b> <a href="ol_validator.md#0x1_ValidatorScripts_VAL_NOT_JAILED">VAL_NOT_JAILED</a>: u64 = 220104;
</code></pre>



<a name="0x1_ValidatorScripts_ol_reconfig_bulk_update_setup"></a>

## Function `ol_reconfig_bulk_update_setup`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_ol_reconfig_bulk_update_setup">ol_reconfig_bulk_update_setup</a>(account: signer, alice: address, bob: address, carol: address, sha: address, ram: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_ol_reconfig_bulk_update_setup">ol_reconfig_bulk_update_setup</a>(
    account: signer, alice: address,
    bob: address,
    carol: address,
    sha: address,
    ram: address
) {
    // Create vector of desired validators
    <b>let</b> vec = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, alice);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, bob);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, carol);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, sha);
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;address&gt;(&<b>mut</b> vec, ram);
    <b>assert</b>(<a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&vec) == 5, 1);

    // Set this <b>to</b> be the validator set
    <a href="DiemSystem.md#0x1_DiemSystem_bulk_update_validators">DiemSystem::bulk_update_validators</a>(&account, vec);

    // Tests on initial validator set
    <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_validator_set_size">DiemSystem::validator_set_size</a>() == 5, 2);
    <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(sha) == <b>true</b>, 3);
    <b>assert</b>(<a href="DiemSystem.md#0x1_DiemSystem_is_validator">DiemSystem::is_validator</a>(alice) == <b>true</b>, 4);
}
</code></pre>



</details>

<a name="0x1_ValidatorScripts_self_unjail"></a>

## Function `self_unjail`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_self_unjail">self_unjail</a>(validator: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_self_unjail">self_unjail</a>(validator: signer) {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(&validator);
    // <b>if</b> is above threshold <b>continue</b>, or raise error.
    <b>assert</b>(
        <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_NOT_ABOVE_THRESH_JOIN">NOT_ABOVE_THRESH_JOIN</a>)
    );
    // <b>if</b> is not in universe, add back
    <b>if</b> (!<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(addr)) {
        <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">ValidatorUniverse::add_self</a>(&validator);
    };
    // Initialize jailbit <b>if</b> not present
    <b>if</b> (!<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_exists_jailedbit">ValidatorUniverse::exists_jailedbit</a>(addr)) {
        <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_initialize">ValidatorUniverse::initialize</a>(&validator);
    };

    // <b>if</b> is jailed, try <b>to</b> unjail
    <b>if</b> (<a href="Jail.md#0x1_Jail_is_jailed">Jail::is_jailed</a>(addr)) {
        <a href="Jail.md#0x1_Jail_self_unjail">Jail::self_unjail</a>(&validator);
    };
}
</code></pre>



</details>

<a name="0x1_ValidatorScripts_voucher_unjail"></a>

## Function `voucher_unjail`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_voucher_unjail">voucher_unjail</a>(voucher: signer, addr: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_voucher_unjail">voucher_unjail</a>(voucher: signer, addr: address) {
    // <b>if</b> is above threshold <b>continue</b>, or raise error.
    <b>assert</b>(
        <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_NOT_ABOVE_THRESH_JOIN">NOT_ABOVE_THRESH_JOIN</a>)
    );
    // <b>if</b> is not in universe, add back
    <b>assert</b>(
        <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_VAL_NOT_FOUND">VAL_NOT_FOUND</a>)
    );

    <b>assert</b>(
        <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_VAL_NOT_FOUND">VAL_NOT_FOUND</a>)
    );

    <b>assert</b>(
        <a href="Jail.md#0x1_Jail_is_jailed">Jail::is_jailed</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_VAL_NOT_JAILED">VAL_NOT_JAILED</a>)
    );
    // <b>if</b> is jailed, try <b>to</b> unjail
    <a href="Jail.md#0x1_Jail_vouch_unjail">Jail::vouch_unjail</a>(&voucher, addr);
}
</code></pre>



</details>

<a name="0x1_ValidatorScripts_val_add_self"></a>

## Function `val_add_self`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_val_add_self">val_add_self</a>(validator: signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_validator.md#0x1_ValidatorScripts_val_add_self">val_add_self</a>(validator: signer) {
    <b>let</b> validator = &validator;
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(validator);
    // <b>if</b> is above threshold <b>continue</b>, or raise error.
    <b>assert</b>(
        <a href="TowerState.md#0x1_TowerState_node_above_thresh">TowerState::node_above_thresh</a>(addr),
        <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_validator.md#0x1_ValidatorScripts_NOT_ABOVE_THRESH_ADD">NOT_ABOVE_THRESH_ADD</a>)
    );
    // <b>if</b> is not in universe, add back
    <b>if</b> (!<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(addr)) {
        <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_add_self">ValidatorUniverse::add_self</a>(validator);
    };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
