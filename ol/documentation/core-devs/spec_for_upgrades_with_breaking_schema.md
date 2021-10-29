# Spec: Upgrades with breaking schema

# Background

When an stdlib module has a `resource struct` which changes its layout between stdlib versions, the network will halt when a attempting a hot upgrade.

A migration pattern is necessary for each module that has such changes to data structure. The migration pattern should consider:
- Than resources may be stored either in the 0x0 account, or in individual user accounts.
- The Libra framework, only allows an account holder to initialize a struct in their account.
- Users may not be able to submit transactions to initialize an updated resources in their account, BEFORE a system operation (e.g. reconfiguration) may need to access the struct (and cause a network halt).

# Identify breaking changes

The stdlib compiler, can check for compatibility changes. There are a few cases the compatibility checker identifies. However it does not offer any solutions.


# Preparing versioning
All migrations for each breaking upgrade need to be coded individually.

## 1. Minimize changes

Not all changes may be required:

- Changes to the name of a field in a struct may be desired but not necessary
- Fields may be added to a struct as a convenience, but it could possibly be a new struct. Adding structs do not cause network halts, so long as they are initialized on the fly.

## 2. Version the module
A module with breaking changes to the data structure, should be published to a new address. The previous module remains published at its original address for reference, and for migration purposes, but otherwise is deprecated.

Stdlib module addresses are published in sequentially increasing addresses. Addresses 0x0 through 0x1000 are reserved for versions of the standard library modules

Example: A resource in Epoch.move requires a breaking change. A new file called Epoch-v2.move is created, and in the code, the published address changes: from `0x1::Epoch` to `0x2::Epoch`.

Every other module upstream must now import with `use 0x2::Epoch`.

# Migration Pattern

Every migration is on a per-module basis. That is, the logic to read from the previous state version, and initialize the new resource, will be contained in the module (e.g Epoch).

## Writing a migration
- Every module needs a migration function for each struct which is changed.
- A struct may exist in 0x0 address, which means the vm needs to sign the change.
- A struct may exist in a user address, which means "alice" needs to sign, or the MigrationHandler needs to sign for alice.


## Migrating Resources in Accounts

LibraAccount has a native function, create_signer(), which effectively impersonates a signature for alice. This (private) function is reserved to LibraAccount, since it is necessary to manage accounts, and also extremely insecure.

TODO: Many stdlibs depend on libra account, and those will cause dependency cycling when using LibraAccount::create_signer().

## Calling a migration

- In LibraBlock::block_prologue there is a call maybe_migrate(), which checks if there is a migration which is due to run.

