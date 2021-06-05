

# Using 0L apps off-node

This guide is for running 0L apps off of the node. For example running the for `txs` app or `ol` cli from your laptop.

## Create, or refresh configs

You will need to create app configs (0L.toml and a few others)
You can refresh your configs with:

0. Make sure you have your autopay_batch.json in the folder where you would like to keep node configs (e.g. /home/alice/my_0L_configs/)

1. onboard --val --skip-mining --upstream-peer http://ip-address

This command will prompt for a few configs, including what directory you will be storing configs for that account. It will also prompt for the IP address of the node.

Fun statement is not required, but you may want to enter the original one for consistency.

Note: --upstream-peer is required to fetch up to date epoch and waypoint information.

# Use Configs
2. From now on use 0L apps with --config path/to/config/0L.toml

For example:

### ol CLI
```
# get balance
ol --config path/to/config/0L.toml query --balance

# get waypoint info
ol --config path/to/config/0L.toml query --epoch

# watch tv
ol --config path/to/config/0L.toml explorer
```

### TXS
```
# submit upgrade tx
txs --config path/to/config/0L.toml  oracle-upgrade -f path/to/libra/language/stdlib/staged/stdlib.mv
```