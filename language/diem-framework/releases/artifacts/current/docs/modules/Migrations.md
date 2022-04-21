
<a name="0x1_MigrateTowerCounter"></a>

# Module `0x1::MigrateTowerCounter`


<a name="@Summary_0"></a>

## Summary

Module to migrate the tower statistics from TowerState to TowerCounter


-  [Summary](#@Summary_0)
-  [Constants](#@Constants_1)
-  [Function `migrate_tower_counter`](#0x1_MigrateTowerCounter_migrate_tower_counter)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Migrations.md#0x1_Migrations">0x1::Migrations</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="0x1_MigrateTowerCounter_UID"></a>



<pre><code><b>const</b> <a href="Migrations.md#0x1_MigrateTowerCounter_UID">UID</a>: u64 = 1;
</code></pre>



<a name="0x1_MigrateTowerCounter_migrate_tower_counter"></a>

## Function `migrate_tower_counter`



<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateTowerCounter_migrate_tower_counter">migrate_tower_counter</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateTowerCounter_migrate_tower_counter">migrate_tower_counter</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<a href="Migrations.md#0x1_Migrations_has_run">Migrations::has_run</a>(<a href="Migrations.md#0x1_MigrateTowerCounter_UID">UID</a>)) {
    <b>let</b> (<b>global</b>, val, fn) = <a href="TowerState.md#0x1_TowerState_danger_migrate_get_lifetime_proof_count">TowerState::danger_migrate_get_lifetime_proof_count</a>();
    <a href="TowerState.md#0x1_TowerState_init_tower_counter">TowerState::init_tower_counter</a>(vm, <b>global</b>, val, fn);
    <a href="Migrations.md#0x1_Migrations_push">Migrations::push</a>(vm, <a href="Migrations.md#0x1_MigrateTowerCounter_UID">UID</a>, b"<a href="Migrations.md#0x1_MigrateTowerCounter">MigrateTowerCounter</a>");
  };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
