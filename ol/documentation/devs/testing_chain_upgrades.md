# Testing Chain Upgrades

How to test Chain upgrades locally with swarm.

In depth on starting swarm: (swarm_qa_tools.md)

# Prepare Env
## Pull the previous version
Choose a version that is currently in production. Preferably from a tag.

```
git checkout v4.3.0 -f

```

## Build stdlib
To ensure swarm will actually use the stdlib, from tag rather than your working branch.

```
cargo r -p stdlib
```

## Start Swarm
```

cargo build -p diem-node -p cli && NODE_ENV="test" cargo run -p libra-swarm -- --diem-node target/debug/diem-node -c ~/swarm_temp  -n 1 -s --cli-path target/debug/cli
```



## Checkout new version, with proposed stdlib
This is likely a branch

```
git checkout release-v4.3.1 -f

```

## Compile stdlib

```
make stdlib

```

## Send upgrade transaction

The instructions above start a swarm with 1 node. The 0th node is persona `alice`.

NOTE: If you are starting swarm with N validators, you'll need to send N transactions. There are currenly fixtures/mnemonics for 4 personas, so it should be less than that.

## first initialize the 0L tools for a persona, e.g. `alice`:

```
cargo run -p ol-cli -- --swarm-path=~/swarm_temp --swarm-persona=alice init
```

Send the transaction

```
cargo r -p txs -- --swarm-path ./swarm_temp --swarm-persona alice oracle-upgrade
```