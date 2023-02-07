# QA onboarding validator


0LNetworkCommunity devnet should be running. To reconfigure follow this: 

(provision_dev_net.md)

## Check genesis registration is correct for this test.


Note the set_layout file in the github genesis backend should EXCLUDE `eve`:
operators = ["alice", "bob", "carol", "dave"]
owners = ["alice", "bob", "carol", "dave"]
association = ["null"]

## Check state is blank

With client, query balance to confirm `eve` (`e9fbaf07795acc2e675961eb7649acdf`) does not have an account. And that there are 4 validators in set.

```
#From another connected validator, e.g. bob
cd libra/util/
make client

libra% q b e9fbaf07795acc2e675961eb7649acdf
```

You should see: epoch info:
```
INFO 2020-10-14 20:11:25 testsuite/cli/src/libra_client.rs:296 Verified epoch changed to EpochState [epoch: 1, validator: ValidatorSet: [07dcd9c8: 1, 4a6dcca7: 1, 5831d5f6: 1, f094dfc3: 1, ]]
```
and no account for `eve`:
```
[ERROR] Failed to get balances: No account exists at e9fbaf07795acc2e675961eb7649acdf
````

## Start Eve's node
Eve did not participate in genesis. She will not "register" with the same flow as the others. But the node state and keys needs to be initialized.
```
eve = 161.35.13.169
```

The validator "wizard" tool in the `miner` app will create the necessary configurations on `eve` machine, and produce an `account.json` manifest which can be used by another node (e.g. `alice`).

You'll need to add some devnet flags so that the wizard uses the dev-genesis genesis repo.

```
make smoke-new

# Is equivalent to running this command:
cargo r -p miner -- val-wizard --chain-id 1 --github-org 0LNetworkCommunity --repo dev-genesis --rebuild-genesis
```

The expected output from eve's node is that it cannot connect to anyone:

```
WARN 2020-10-14 20:19:50 network/src/peer_manager/mod.rs:471 Peer 07dcd9c8 is not connected
WARN 2020-10-14 20:19:50 network/src/peer_manager/mod.rs:471 Peer 4a6dcca7 is not connected
WARN 2020-10-14 20:19:50 network/src/peer_manager/mod.rs:471 Peer 5831d5f6 is not connected
WARN 2020-10-14 20:19:50 network/src/peer_manager/mod.rs:471 Peer f094dfc3 is not connected
```

The other nodes will see this log, showing a failure to connect:

```
WARN 2020-10-14 03:58:33 network/src/peer_manager/mod.rs:903 Connection from /ip4/134.122.115.12/tcp/55822 failed to upgrade noise: client connecting to us with an unknown public key: [X25519 public key: a6c74b1789e1a6974e62a6c5bbed691714b0c515f9080a8b73b102d39769a040]
```

## Onboard tx for Eve

Eve will be the new validator.

Use the `account.json` produced in the step above to create a new account.

For convenience there is a fixture in the repo called `../fixtures/eve_init_test.json` which contains the same information as produced by `val-wizard` to save the time of copying file over.

From the `alice` machine, submit a miner onboarding transaction with


Connect a client
```
cd libra/util/
make client

// Submit the tx from alice for eve's account
libra% account create_validator 0 /root/libra/fixtures/eve_init_test.json

// Check that Eve has a balance of 0, by connecting a client. 
libra% q b e9fbaf07795acc2e675961eb7649acdf
```

## Observe Eve's logs.
Expected behavior: on the next epoch change `eve` will be added to the validator set, and the other validators will recognize the pubkeys from `eve` machine.

Note that:
1. the tx above needs to be accepted.
2. the epoch reconfiguration  needs to happen at its regular time.
3. eve must must be in the new validator set.

If successful, on the epoch change, you will see sync requests in `eve` logs:

```
DEBUG 2020-10-14 20:32:24 state-synchronizer/src/coordinator.rs:883 [state sync] request next chunk. peer_id: PeerNetworkId(e9fbaf07795acc2e675961eb7649acdf, 07dcd9c8d1dbaaa16118
```