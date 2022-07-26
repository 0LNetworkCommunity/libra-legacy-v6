
<a name="0x1_MigrateJail"></a>

# Module `0x1::MigrateJail`


<a name="@Summary_0"></a>

## Summary

Initializes the Jail structs


-  [Summary](#@Summary_0)
-  [Constants](#@Constants_1)
-  [Function `do_it`](#0x1_MigrateJail_do_it)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="Jail.md#0x1_Jail">0x1::Jail</a>;
<b>use</b> <a href="Migrations.md#0x1_Migrations">0x1::Migrations</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="0x1_MigrateJail_UID"></a>



<pre><code><b>const</b> <a href="Migrations.md#0x1_MigrateJail_UID">UID</a>: u64 = 4;
</code></pre>



<a name="0x1_MigrateJail_do_it"></a>

## Function `do_it`



<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateJail_do_it">do_it</a>(vm: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Migrations.md#0x1_MigrateJail_do_it">do_it</a>(vm: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_diem_root">CoreAddresses::assert_diem_root</a>(vm);
  <b>if</b> (!<a href="Migrations.md#0x1_Migrations_has_run">Migrations::has_run</a>(<a href="Migrations.md#0x1_MigrateJail_UID">UID</a>)) {
    <b>let</b> enabled_accounts = <a href="ValidatorUniverse.md#0x1_ValidatorUniverse_get_eligible_validators">ValidatorUniverse::get_eligible_validators</a>();
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&enabled_accounts);
    <b>while</b> (i &lt; len) {
      <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&enabled_accounts, i);
      <b>let</b> account_sig = <a href="DiemAccount.md#0x1_DiemAccount_scary_create_signer_for_migrations">DiemAccount::scary_create_signer_for_migrations</a>(vm, *addr);
      <a href="Jail.md#0x1_Jail_init">Jail::init</a>(&account_sig);
      i = i + 1;
    };


    <a href="Migrations.md#0x1_Migrations_push">Migrations::push</a>(vm, <a href="Migrations.md#0x1_MigrateJail_UID">UID</a>, b"<a href="Migrations.md#0x1_MigrateJail">MigrateJail</a>");
  };
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
