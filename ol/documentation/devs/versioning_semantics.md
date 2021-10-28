# 0L Versioning Semantics
Global versioning follows a modified semver semantics. https://semver.org/

MAJOR.MINOR.PATCH-Prerelease.version

e.g 
`1.2.3-rc.1`

## PATCH version
When all changes to Rust and Move are backwards compatible, and no changes to the Stdlib data structures were made which could affect Stdlib or downstream user created modules.

## MINOR version
When there are backward compatible changes to VM and diem-node. The diem-node can be simply reloaded. However the Stdlib requires an on-chain data migration to run during the update process. This is likely if resource structs in the Stdlib in Move are added, or existing ones modified.


## MAJOR version
When there are compatibility changes across Rust and Move affecting backwards compatibility of the VM, On-chain state, which make hot updates (oracle) unlikely. A coordinated network halt and offline state migration is the default upgrade path.
