
<a name="0x1_MigrateInitDelegation"></a>

# Module `0x1::MigrateInitDelegation`



-  [Constants](#@Constants_0)
-  [Function `do_it`](#0x1_MigrateInitDelegation_do_it)


<pre><code><b>use</b> <a href="Migrations.md#0x1_Migrations">0x1::Migrations</a>;
<b>use</b> <a href="Teams.md#0x1_Teams">0x1::Teams</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_MigrateInitDelegation_UID"></a>



<pre><code><b>const</b> <a href="Migrations.md#0x1_MigrateInitDelegation_UID">UID</a>: u64 = 2;
</code></pre>



<a name="0x1_MigrateInitDelegation_do_it"></a>

## Function `do_it`



<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateInitDelegation_do_it">do_it</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateInitDelegation_do_it">do_it</a>(vm: &signer) {
  <b>if</b> (!<a href="Migrations.md#0x1_Migrations_has_run">Migrations::has_run</a>(<a href="Migrations.md#0x1_MigrateInitDelegation_UID">UID</a>)) {
    <a href="Teams.md#0x1_Teams_vm_init">Teams::vm_init</a>(vm);
    // also initialize relevant state in <a href="TowerState.md#0x1_TowerState">TowerState</a>
    <a href="TowerState.md#0x1_TowerState_init_team_thresholds">TowerState::init_team_thresholds</a>(vm);
    <a href="Migrations.md#0x1_Migrations_push">Migrations::push</a>(vm, <a href="Migrations.md#0x1_MigrateInitDelegation_UID">UID</a>, b"MigrateInitTeams");
  }
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
