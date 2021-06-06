# QA 0L tools using swarm

## First configure swarm environment
###  Start a swarm
Remember to export `NODE_ENV="test"`, preferably have your `.bashrc` do this.
Note: the path to swarm files, in this example: ~/swarm_temp
```
cargo build -p libra-node -p cli && NODE_ENV="test" cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c ~/swarm_temp  -n 2 -s --cli-path target/debug/cli
```

### Initialize the 0L.toml, for the 0th address (alice)
```
cargo run -p ol -- --swarm-path=~/swarm_temp --swarm-persona=alice init --source-path ./
```


## Miner

In another terminal:

Preparing block_0.json, so miner can directly be started for "Alice":

`mkdir ~/swarm_temp/0/blocks  && cp ol/fixtures/blocks/test/alice/block_0.json ~/swarm_temp/0/blocks`

Start miner:

`NODE_ENV="test" cargo run -p miner -- --swarm-path=~/swarm_temp --swarm-persona=alice start`

## Explorer

In another terminal:

`cargo run -p ol-cli -- --swarm-path=~/swarm_temp --swarm-persona=alice explorer`

## TXS


### Send a noop demo transaction as `alice`

Note: that you are using the same swarm temp path as above

```
cd ~/libra/

cargo r -p txs -- --swarm-path=~/swarm_temp/ --swarm-persona=alice demo
```


### Send an account creation tx from `alice`, for `eve`

```
cd ~/libra/

cargo r -p txs -- --swarm-path=~/swarm_temp/ --swarm-persona=alice create-validator -f ./ol/fixtures/onboarding/eve_init_test.json
```

(the create-validator step for swarm still throws an arror "could not find autopay instructions" in release-v4.3.0, even with https://github.com/OLSF/libra/pull/499)

### Relay

This transaction will appear with bob's signature and apply changes to `bob` account. However `alice` will be submitting it. The use case is if bob's machine which signs cannot or prefers not to connect (e.g. or bob would like to sign from an offline computer/device, or in onboarding cases).

#### Save a noop test transaction, by `bob` for `alice` to later send

```
cd ~/libra/

cargo r -p txs -- --swarm-path=./swarm_temp/ --swarm-persona=bob --save-path ./noop_tx.json --no-send demo
```

#### submit as `alice`
```
cd ~/libra/

cargo r -p txs -- --swarm-path=./swarm_temp/ --swarm-persona=bob relay --relay-file ./noop_tx.json
```