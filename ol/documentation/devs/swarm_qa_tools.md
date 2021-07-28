# 0L tools using swarm

## Purpose
The swarm simulates a libra network by running some libra-nodes on localhost. The nodes are pre configured to be in a validator set. The configs for up to five libra nodes are well defined and can be accessed by specifying swarm-persona Alice, Bob, Carol, Dave and Eve.


## Bringing up a swarm
### Assumptions

Throughout this documentation the following paths are used, but they can be changed, if the setup is different on your system:

* libra source is cloned into $HOME/libra
* the temp directory for swarm files is created in $HOME/swarm_temp

### Initial compile steps

The following compile steps are mandatory for the swarm to run correctly using the latest source code. All other rust dependencies will get compiled by cargo when needed:

```
cargo build -p libra-node -p cli
cd language/stdlib
cargo run --release
```

### Starting the swarm

The general syntax to start the swarm is:

`cargo run -p libra-swarm -- [libra-node binary path] -c [path for temporary files] -n [number of nodes to simulate]`

To start swarm with a client in same terminal, pass the `-s` and `--cli-path` to cli binary

Also `NODE_ENV="test"` is important to use. In this documentation we will set it at each command, but you might also add in `.bashrc` a line `export NODE_ENV="test"`

### Swarm with 2 nodes without cli:

```
cd $HOME/libra
NODE_ENV="test" cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c $HOME/swarm_temp -n 2
```

### Swarm with 2 nodes and with cli:

```
cd $HOME/libra
NODE_ENV="test" cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c $HOME/swarm_temp -n 2 -s --cli-path target/debug/cli
```

At the cli prompt when asked to "Enter your 0L mnemonic:" you can use the mnemonics of alice (see below in the section about the cli)


### Initialize swarm configs 

After starting the swarm, the 0L.toml and other configs have to be created by:

```
export NODE_ENV="test"
cargo run -p ol -- --swarm-path=$HOME/swarm_temp --swarm-persona=alice init --source-path $HOME/libra
cargo run -p ol -- --swarm-path=$HOME/swarm_temp --swarm-persona=bob init --source-path $HOME/libra
```

If more than 2 swarm nodes are running, the same commands have to be run also for swarm-persona carol, dave and eve.

## 0L tools

After the above steps, the 0L tools can be used

## cli

If swarm has been started without cli, you can attach the cli like this (with the data that is shown at the end of swarm startup in the console). E.g.:
 
```
cargo r -p cli -- -u http://<local-host-and-port> -m <path to mint.key' --waypoint <random waypoint> --chain-id 4
```

The mnemonics to enter are those in the fixtures dorectory, e.g. for alice in `ol/fixtures/mnemonic/alice.mnem`

```
talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse
```

if succeed, you can enter `help` at the cli prompt `libra%` or for example request the account balance:

```
libra% query balance 0
Balance is: 4.995072GAS
```


## Miner

In swarm you can run the miner for alice by the following command:

```
NODE_ENV="test" cargo r -p miner -- --swarm-path $HOME/swarm_temp --swarm-persona alice start
```


## Explorer

The explorer to show network activity can be run by the following command. Usually it only makes sense to do this after the miner is running:

```
NODE_ENV="test" cargo r -p ol -- --swarm-path=$HOME/swarm_temp --swarm-persona=alice explorer
```


## Pilot

Pilot is also running for swarm and correctly detects, which components are not ok. But is not able to start the missing components, e.g. web monitor or miner:

```
NODE_ENV="test" cargo r -p ol -- --swarm-path=$HOME/libra/swarm_temp --swarm-persona=alice pilot
```


## Health

The health check for swarm nodes works basically but does not interpret each status completely correct:

```
NODE_ENV="test" cargo r -p ol -- --swarm-path=$HOME/swarm_temp --swarm-persona=alice health
```

Known inaccuracy:
`Configs exist` is always shown as `false`


## Web Monitor (warp server)

Before the web monitor will work properly for swarm, if you did not do it up to now, run the health command once (see section above).


After this, in one terminal window start the svelte dev server. This updates the HTML and JS bundles as files are changed. You need this for realtime feedback.

```
cd $HOME/libra/ol/cli/web-monitor
npm run dev
```


Then in a second terminal window, you can start the "warp" server, which will serve the web monitor on port 3030:

```
cd $HOME/libra
cargo r -p ol -- --swarm-path $HOME/swarm_temp/ --swarm-persona alice serve
```

Now you can visit the web monitor with a browser on http://localhost:3030


## Transactions

### Demo txs
With the following command you can send a demo transaction as `alice`

```
cargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=alice demo
```


### Validator account creation tx from `alice`, for `eve`

The following command would send an onboarding transaction from alice to eve:

```
cargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=alice create-validator -f ./ol/fixtures/onboarding/eve_init_test.json
```

(the create-validator step for swarm still throws an arror "could not find autopay instructions" in release-v4.3.0, even with https://github.com/OLSF/libra/pull/499)


### Relay

This transaction will appear with bob's signature and apply changes to `bob` account. However `alice` will be submitting it. The use case is if bob's machine which signs cannot or prefers not to connect (e.g. or bob would like to sign from an offline computer/device, or in onboarding cases).

#### Save a noop test transaction, by `bob` for `alice` to later send

```
cd $HOME/libra
cargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=bob --save-path ./noop_tx.json --no-send demo
```

#### submit as `alice`

```
cd $HOME/libra
cargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=bob relay --relay-file ./noop_tx.json
```

### swarm and autopay transactions

When you expermiment with swarm and the autopay feature, be aware that there is a "fail-save" build into the validator set election. If we don't get 4 validators who qualify to be in the validator set, then the system does not change the validator set. So often in swarm for dev purposes we will have 4 or fewer nodes, so we don't get an accurate picture of the reconfiguration.

In the "real world", a validator node which has no autopay set up will be thrown out of the validator set, but in swarm, as no node has autopay set up per default, no node will be thrown out.

We've debated putting a switch to have a different behavior in testnet mode, but even that felt like not "fail safe" behavior.

#### set autopay for `alice`
```
cd $HOME/libra
cargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=alice autopay-batch -f ol/fixtures/autopay/alice.autopay_batch.json
```

#### stop autopay for `alice`
```
cd $HOME/libracargo r -p txs -- --swarm-path=$HOME/swarm_temp/ --swarm-persona=alice autopay --disable
```

