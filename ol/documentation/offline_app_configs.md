# Using 0L apps off-node

This guide is for running 0L apps off of a node. For example running the for `txs` app or `ol` cli from your laptop.

## Create 0L.toml required for apps

You will need to create app configs before using apps.

Using a mnemonic you can refresh the configs with:

```
ol init --skip-val --path /home/alice/my_0L_configs/ --upstream-peer 'http://<ip-address>'
```

Note: --upstream-peer is required to fetch up-to-date epoch and waypoint information.

`Fun statement` is not required, but you may want to enter the original one for consistency.

# Use Configs

From now on use 0L apps with the entry point arg: `--config path/to/config/0L.toml`

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