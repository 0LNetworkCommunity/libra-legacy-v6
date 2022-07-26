# Provision a dev net (REX)

# Quick start

A OLSF devnet runs with the following nodes. If you have permissions connect with `shh root@ip-address`
```
alice = 161.35.13.169 
bob = 167.71.84.248
carol = 104.131.56.224

# eve is not in genesis set, but has configs to join
eve = 157.230.15.42
```

# Summary

1. (optional) Participants: Set-up the list of genesis participants
2. Infra: create devnet mock infrastucture (github repositories)
3. Install: Host setup for OS and binaries
4. End-to-end: Do a full devnet start: `make devnet`
5. Quick: Do a quick smoke test with fixture genesis.blob: `make smoke`
6. Onboard: Onboard a new validator (eve): `make devnet-join`

# Access

Access to nodes is controlled by this github administrators.

Upon logging in, administrators should check the saved terminal sessions with `tmux a`.

# Devnet Genesis ceremony (optional)

This assumes there is a github repo which is dedicated to devnet. These instruction assume the layout of the genesis set is found in: `github.com/OLSF/dev-genesis`.

The defaults use personas in the genesis set are: `alice`, `bob`, `carol` whose configs and mnemonics can be found in `/fixtures/`

Optionally change the set layout with:
1. Create a new set layout with the accounts of nodes participating in devnet, file: `util/set_layout_devnet.toml`
2. On any of the nodes run `make set-layout` (just run once).

# Infrastructure

These repos are necessary for accurate mocking of main net. 

* OLSF/dev-genesis: the mock repo for genesis registrations.
* OLSF/dev-epoch-archive: the mock repo for epoch archives.


This only needs to be done once per session, or time the devnet configs change: Move standard library, set_layout, IP addresses.

1. On one machine (`alice`) pull both of those repos.

1. Do a genesis "registration" for each of the nodes alice, bob, carol.
```
make dev-register
```

1. From /libra/  source:

```
make dev-infra
```

# Node configuration

## 1. OS dependencies can be installed with `libra/util/setup.sh`. Devnet nodes usually are already configured, run this only if adding new nodes.

## 2. Set environment variables 

### TL;DR

For each node, set the NS (namespace) for that persona, e.g.:

`export NODE_ENV=test NS=alice TEST=y`

### NODE_ENV

for `prod`, `stage` or `test`. 

`> export NODE_ENV=test` will use "easy" difficulty of vdf and stdlib testnet settings.

`> export NODE_ENV=stage` will use "hard" difficulty of vdf and stdlib stagingnet settings which is similar to prod, except accelerated epochs.
`> export NODE_ENV=prod` will use "hard" difficulty of vdf and the production stdlib (epochs take 24hrs, and account creation is rate limited).
3. Set the name of the persona on each machine, with the NS (namespace) env variable.

### NS, namespace

`> export NS=alice`

### TEST, is test

4. Set if this is a test network

`> export TEST=y`

### V, version

5. This is a shortcut for quick `smoke` testing of the devnet. You can set the nodes to do a genesis from a previously created genesis.blob which was stored to `/fixtures/`. The `make smoke` command will default to `V=current`.

These "versions" need to be in `./fixtures/genesis/` they are a shortcut for configuring a devnet. Certain versions for the alice, bob, carol configurations are stored to /fixtures/genesis.

`>export V=v2.4.6`

## Check env variables

use `make check` and inspect if the env variables are correct.

Note: if some fields are missing `make fixtures` can copy files to correct locations. Only needed for debugging as this command is already run with `smoke-reg` below.


# Make commands

These instructions assumes three nodes in ceremony (Alice, Bob, Carol), plus one which will be onboarded (Eve). As per the "layout" file.


Preferably run these commands in a `screen` or `tmux`, such as `screen -S node`, and connect with `screen -rd node`

### End-to-end devnet setup

If something is wrong with the genesis ceremony repository (github.com/OLSF/dev-genesis) then the ceremony needs to be rerun (instead of using the fixtures).

1. (OPTIONAL) This instruciton is in the INFRA section above. But if standard library changes for genesis, need to reregister, alice, bob, carol to the mock genesis repo. Do this on all hosts. 

```
make  dev-register
```

2. Run ceremony on all nodes, and start:
```
make devnet
```

### Frozen: use a backed up devnet setting from fixtures


1. Start each node from genesis fixtures 

```
# use './fixtures/genesis/current' for genesis blob and waypoint
make frozen

# use './fixtures/genesis/<version>' for fixtures
V=<version> make frozen
```


# Join a new validator to Devnet

### Join a known persona, `eve` to network.

Using the mnemonic from `/fixtures/memonic/eve.mnem`:
NOTE: remember to pull same code above.

```
make dev-join
```

### Join a new blank validator
NOTE: backups of devnet should be created for this version number at this repo: github.com/OLSF/dev-epoch-archive 
Do as the typical onboarding procedure.

0. pull same <version> number as above, and build with `make bins`
1. `onboard keygen` to make new keys
2. `ol onboard --next -t` to start each step of the onboarding process.

NOTE: the validator-wizard will be pulling data from `dev-epoch-archive`


# Mining

To start the tower app, you'll need to exit `screen`, and start a new one. (ctrl+a then ctrl+d to exit without disconnecting screen)
1. Start a new screen with `screen -S tower` or reconnect to existing with `screen -rd tower`
2. execute the tower app `cargo run -p tower -- start`
3. Enter the mnemonic for the persona of that node. Can be found for example in `/fixtures/mnemonic/alice.mnem`
