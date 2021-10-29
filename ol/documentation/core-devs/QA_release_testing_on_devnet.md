# QA release test ing on devnet

# Scripts

Scenarios which must be tested on devnet, before a release can be tagged.

See here details on setting up devnet infrastructure: (provision_dev_net.md)

## 1. Current code can startup on proposed release
This tests if a new genesis is possible with the current stack. This is likely possible since all developers have used `swarm` to standup local networks. Different than swarm, testing on devnet confirms network connectivity, and block propagation.
This is a low value test, because running networks will be upgrading to the propsed release, and not starting new networks at this point.

## 2. Previous release stdlib can upgrade to new release
This tests if a state machine at the previous version of stdlib, will accept upgrade to the next release, and the network continues to operate.

This is the highest value test.

NOTE: Makefiles used for automation also change between releases. So you must first create fixtures using the previous release, and then copy them over to the new release branch once. fixtures/genesis/<version>. If anything changes in the devnet genesis configurations (ceremony, layout, ip addresses etc) these fixtures become invalid, and need to be recreated.

- create fixtures

`git checkout <tag of previous release> -f`

`make dev-register`

`cp ~/.0L/genesis* ~/libra/ol/fixtures/genesis/<tag of previous release>`


- start a network on the git commit of the last release. 

`V=<version in fixtures> make devnet`

- change back to release branch to be tested, and build standard library. Do this on each node in devnet.

`git checkout <new release> -f`

`make stdlib`

- from each node submit the upgrade transaction from each node in devnet.

`cargo r -p txs -- oracle-upgrade`

- wait for the next epoch. and check if the network is up.

## 3. A new validator (eve) can be onboarded
Devnet typically starts with three nodes, personas: alice, bob, carol. A fourth, eve, will be added from a separate node.

- Using the web-monitor alice must broadcast her account.json, which Eve will use as a template

`cargo r -p ol-cli -- serve`


- eve starting from a clean .0L folder, will start validator wizard pointing to alice template url.

`cargo r -p miner -- val-wizard -u <alice ip and port>`

- eve can start a node in fullnode mode.

`cargo r -p diem-node -- --config ~/.0L/fullnode.node.yaml`

- eve starts the web-monitor, so alice can see her onboarding configuration

`cargo r -p ol-cli -- serve`

- alice submits an onboarding transaction for eve, by pointing to eve's web-server url

`cargo r -p txs -- create-validator -u <eve ip and port>`

- if transaction is successfully completed, eve can start the node in validator mode.

`<stop diem-node from before>`

`cargo r -p diem-node -- --config ~/.0L/validator.node.yaml`

Expected result:

Eve can start in fullnode mode, and sees blocks propagated from alice

## 4. Eve can restore from database

- after a new dev network starts, alice needs to set up the devnet infrastructure with `make dev-infra`. This will publish a backup to a mock epoch-archive (like main net has), so that eve can fetch from it.

`make dev-infra`


- eve restores the saved database. The restore command automatically detects from environment variables that this is not a `prod` environment, and fetches the devnet archive.

`cargo r -p ol-cli -- restore` 
