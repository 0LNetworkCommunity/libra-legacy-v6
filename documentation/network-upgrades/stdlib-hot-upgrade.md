# Hot Upgrades

## Summary
Hot upgrades to 0L Move framework (AKA "stdlib") require no halting of the network and are achieved with the Upgrade Oracle. This can be done when there are non-breaking changes to the vm (in Rust), and the stdlib (Move) has migrations in place in case of schema changes.

## Voting on Upgrades
Validators vote on upgrades. They vote by either sending the full binary of the stdlib or the hash of an stdlib binary which has already been submitted.

Proposals for upgrade expire after 1M blocks have elapsed.

It takes a minimum of two epochs (48h) for an upgrade to take place.

At the beginning of each epoch (specifically round 2), the VM checks if the quorum has been met (2/3 of validators by voting power) for an upgrade. Assuming there is quorum the upgrade does not take place immediately, instead there's a cooling off period of 1 epoch. The upgrade happens on the subsequent epoch.


## A First Proposal
If there is no stdlib binary yet proposed, any validator can submit one with these steps. You will need to have the source code.

1. Checkout the tag of the release indended for upgrade of the `libra` repo.
2. Build the new stdlib using the Makefile helper `make stdlib`.
3. From a CLI issue the oracle upgrade command to vote on upgrade:

When you compile the stdlib by default they go to: `<0L source>/language/diem-framework/staged/stdlib.mv`). You should pass the path explicitly with:

```
txs oracle-upgrade --vote -f <path/to/file>
```
Note: You may edit your 0L.toml file under `workspace` to include `stdlib_bin_path = "/root/libra/language/diem-framework/staged/stdlib.mv`. Then you don't need to pass the file path explicitly. This may become deprecated.
## Subsequent Proposals
Subsequent proposals can use the exact same step above. In that case the validator is verifying the compilation of stdlib when voting. That is the preferred method.

The validator can also vote by simply sending the hash of the stdlib of a previously proposed binary. In that case it can be done with:

`txs oracle-upgrade -v -h <hash of binary>`

WARNING: this is lazy, and reduces the security of the network, but may be necessary at times given your local configuration. If you are lazy, that's ok, but you should instead "delegate" your upgrade authority to another validator.

# Delegation

A validator (Alice) can delegate the authority for the operation of an upgrade to another validator (Bob). When Oracle delegation happens, effectively the consensus voting power of Alice, is added to Bob only for the effect of calculating the preference on electing a stdlib binary. Whatever binary Bob proposes, Alice will also propose without needing to be submitting transactions.

First Bob must have delegation enabled, which can be done with:

```
txs oracle-upgrade --enable-delegation

```

Assigment of a delegate (by Alice), can be done with:

```
txs oracle-upgrade --delegate <bob address>

```

Alice can remove Bob as the delegate with this function.
```
txs oracle-upgrade --remove-delegate

```

### How do we know it's successful

The `web-monitor` displays current upgrade proposals under the tab `upgrade`.

Otherwise with the CLI:

Using ol client, you can query the system address for the stucts OracleUpgrade
```
cargo r -p ol -- -a 00000000000000000000000000000000 query --move-state --move-module Oracle --move-struct OracleUpgrade --move-value validators_voted
```

Or for the Upgrade state

```
cargo r -p ol -- -a 00000000000000000000000000000000 query --move-state --move-module Upgrade --move-struct UpgradeHistory --move-value records
```

It's also possible to query `diem-client` with `query ar 0x0` but this is a very noisy display.

## Node Logs

The upgrade happens on every "upgrade tick" (block 2 of the epoch) on the epoch following when 2/3 operators have reached consensus on upgrade.

in the node logs you will see:

```
====================================== checking upgrade
====================================== consensus reached
====================================== published 59 modules
====================================== end publish module at <timestamp>

```

## Trouble Shooting:	
1. Server returned error: reqwest::Error { kind: Status(413), url: "http://localhost:8080/" }

-- Ensure you updated ~/.0L/node.yaml file	

2. Transaction submission failed with error: JsonRpcError { code: -32001, message: "Server error: VM Validation error: INSUFFICIENT_BALANCE_FOR_TRANSACTION_FEE", data: Some(StatusCode(INSUFFICIENT_BALANCE_FOR_TRANSACTION_FEE)) }

-- This is likely testnet and you don't have balance from mining.
