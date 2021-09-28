## Reproduce stdlib upgrade on devnet for 4.2

On a new version devnet is used for testing four cases for QA:
- [ ] Genesis test, can start a network
- [ ] Upgrade test, can hot upgrade from previous version
- [ ] Sync test, after upgrade a new validator can sync
- [ ] Miner test, after onboarding a validator can mine

The tests below consider the Upgrade test, can hot upgrade from previous version

### Log into devnet nodes
- alice
`root@157.230.15.42`

- bob
`root@167.71.84.248`

- carol
`root@104.131.56.224`

`screen -rd node`

### Mock mainnet
1. Checkout the mainnet version: 

`git checkout 4.2rc2 --force`

2. Start network with on each node

`screen -rd node`

`miner start`

- Let it run for 60 seconds (until next devnet epoch)

3. Run the miner on each node for a few blocks (or resubmit from any left from previous runs)

`screen -rd miner`

`miner start`

- Stop after 2 blocks or more. (ctrl+c)

This will create enough state for a mock pre-upgrade mainnet.

4. Stop all nodes alice, bob, carol. (ctrl+c from `make smoke` screen).

- `screen -rd node`

- ctrl + c

### Upgrade 1: Stage the `libra-node` upgrade (Rust)

Now the validators will update the Rust code first, and run a new node.

1. Checkout user-role branch

3. restart the nodes, with old state

`make start`

### Upgrade 2: Stage the `stdlib` upgrade (Move)

1. Switch to screen with cli: screen -rd cli

2. Start a libra CLI

`Make client`
3. Recover Wallets on each alice, bob, carol

libra% `account recover <mnemonic file>`, or `a r <mnemonic file>`

- alice
  `a r ./libra/fixtures/mnemonic/alice.mnem`

- bob
  `a r ./libra/fixtures/mnemonic/bob.mnem`

- carol
  `a r ./libra/fixtures/mnemonic/carol.mnem`


4. Send upgrade Transaction in CLI

libra% `oracle upgrade <sender account> <path to stdlib compile>`, or `o u <sender account> <path to stdlib compile>`

- alice

`o u 4c613c2f4b1e67ca8d98a542ee3f59f5 ./libra/fixtures/upgrade_payload/foo_stdlib.mv`

- bob

`o u 88e74dfed34420f2ad8032148280a84b ./libra/fixtures/upgrade_payload/foo_stdlib.mv`

- carol

`o u E660402D586AD220ED9BEFF47D662D54 ./libra/fixtures/upgrade_payload/foo_stdlib.mv`

#### Troubleshooting

If you get SEQUENCE_NUMBER_TOO_OLD, try sending tx again. It’s just that the client doesn’t have the current sequence number if miner is running in background.

If you get `413` error. Check the node.yaml and confirm that the json_rpc: content_length is 400000 (400kb)


### Watch for upgrade

`tail -f ~/.0L/node.log | grep -e reached -e upgrade -e publish`

On the next epoch at round 2 you should see:

```
======================================  round is 2
====================================== checking upgrade
====================================== Consensus has been reached in the previous block
====================================== published 59 modules
====================================== end publish module at 1608755241615084
```

