# Provision a devnet (REX)

# Quick start
(This assumes the node is configured and source built. Also that devnet genesis repos on github have been created, and you have write permissions to it. Skip to Infra section below);

0. make sure you have a `github_token.txt` with a github developer api key there.
1. Establish who are the `personas` participating: `alice`, `bob`, `carol`, `dave`, `eve`. We have standard keys for these personas. Assign them to each node (up to 5).
2. Edit the ol/devnet/set_layout.toml file, with the participants in genesis (their address) and submit `make testnet-layout`.
3. On each node `NS=<persona> TEST=y make testnet-register`
4. Wait for all nodes/personas to complete this step.
5. Build the genesis files on each node `NS=<persona> TEST=y make testnet-genesis`
6. Start the validator `make start`


# Infrastructure

## Repositories
These repos are necessary for accurate mocking of main net. 

* 0LNetworkCommunity/dev-genesis: the mock repo for genesis registrations.
* 0LNetworkCommunity/dev-epoch-archive: the mock repo for epoch archives.


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


## Genesis Participants

This assumes there is a github repo which is dedicated to devnet. These instruction assume the layout of the genesis set is found in: `github.com/0LNetworkCommunity/dev-genesis`.

The defaults use personas in the genesis set are: `alice`, `bob`, `carol` whose configs and mnemonics can be found in `/fixtures/`

Optionally change the set layout with:
1. Create a new set layout with the accounts of nodes participating in devnet, file: `util/set_layout_devnet.toml`
2. On any of the nodes run `make layout` (just run once).


# Node configuration

## 1. OS dependencies can be installed with `sh libra/ol/util/setup.sh`. Devnet nodes usually are already configured, run this only if adding new nodes.

## 2. Set environment variables 

### TL;DR

For each node, set the NS (namespace) for that persona, e.g.:

`export NS=alice TEST=y`



### NS, namespace

`> export NS=alice`

### TEST, test

This variable is used both in the Makefile and Rust code to simplify init of config files.
It also tells the Make recipes to use the "test" genesis github repos 

4. Set if this is a test network

`> export TEST=y`


### NODE_ENV (optional)
There are differnt global parameters on the blockchain for testing. Usually the devnet will be started in production mode. But for quicker epochs of 1 minute "test" mode can be used.

for `prod`, `stage` or `test`. 

`> export NODE_ENV=test` 1minute epochs. For miners it will use "easy" difficulty of vdf and stdlib testnet settings. Only one miner tower proof needs to be submitted per epoch.

`> export NODE_ENV=stage` 20 minute epochs, will use "hard" difficulty of vdf and stdlib stagingnet settings which is similar to prod, except accelerated epochs. Only 1 miner tower proof needs to be submitted.

`> export NODE_ENV=prod` will use "hard" difficulty of vdf and the production stdlib (epochs take 24hrs, and account creation is rate limited).
3. Set the name of the persona on each machine, with the NS (namespace) env variable.

## Check env variables

use `make check` and inspect if the env variables are correct.

# Step by Step

0. Check the repos

If something is wrong with the genesis ceremony repository (github.com/0LNetworkCommunity/dev-genesis) then the ceremony needs to be rerun (instead of using the fixtures).

1. create the "layout" of participants in genesis.
For devnet you can simply edit the file `ol/devnet/set_layout.toml`, and comment or un-comment the validators that are expected to join.

Once that is done, this file must be committed to the genesis repo: `make testnet-layout`.

1. initialize all nodes with a persona, and register to the genesis testing repo.

`NS=alice TEST=y make testnet-register`

2. Wait.
There might be HTTP collisions from each persona/node registering in the previous step. Do one at a time.

Once they are all done, you can move to building genesis files.

3. Build the genesis.blob and other files, on each node.

Each node is responsible for generating their genesis file.

`NS=alice TEST=y make testnet-genesis`

This last step should print out an audit of the keys and of the genesis. You can also run it separately with `NS=alice TEST=y make verify-gen`


# Join a new validator to Devnet


After the genesis happened, new nodes join as on mainnet: a existing validator submits an `account.json` in a transaction to the network.

### Join a known persona, `eve` to network.

Eve can create her config as follows. The relevant output is `~/.0L/account.json`
`NS=eve TEST=y make testnet-onboard`

### Join from blank slate.
Another node can first do a keygen procedure, and then initialize the node.

`cargo r -p  onboard -- keygen`

Note that the REPO_ORG and REPO need to be filled in.

`cargo run -p onboard -- val --github-org <REPO_ORG> --repo <REPO> --chain-id 1`

## Create the account
Another user, Alice, can submit the transaction with the `~/.0L/account.json` from the new user/validator.

`cargo r -p txs -- create-validator -f <path to file>`