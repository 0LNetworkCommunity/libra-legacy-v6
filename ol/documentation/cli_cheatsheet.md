# Common CLI Commands

The 0L tooling look for configurations in `~/.0L/0L.toml` by default.

If your config file is in a different place, then for any app you can explicitly call the config file. Such as:

`txs --config <path to config file>`

## Transactions

The `txs` app will need to connect to a fullnode to send a tx. This may be a localhost or a remote.

The default node is set in the parameters of your `0L.toml`. There's also a list of upstream_nodes which can be used if instcructed explicitly in commandline.

```
default_node = "http://localhost:8080/"
upstream_nodes = ["http://localhost:8080/"]
```

There are two options if you want to change behavior from command line:

### Using the list of upstream node from 0L.toml upstream_nodes
```
txs --use-upstream-url <transaction subcommand>
```

### Using an arbitrary URL to send a tx
```
txs --url <http://your_url_here> <transaction subcommand>
```

### Send the oracle upgrade tx

Using default location of the upgrade payload `./language/diem-framework/staged/stdlib.mv`
```
txs oracle-upgrade
```

Optionally passing a different path.
```
txs oracle-upgrade -f <path to stdlib.mv>
```

### Sending an Autopay tx

### Batch

Autopay txs are submitted in batch format based on a JSON file.

```
txs autopay-batch -f <path to autopay batch file>
```

An autopay batch of instrucitons has this Json file format.
```
{
  "_readme": "Template for doing ongoing donations as a percentage of new daily inflow to wallet. Use two decimals for percentages e.g. 12.34 means 12.34%",
  "autopay_instructions": [
    {
      "note": "engineering fund, iqlusion, https://github.com/iqlusioninc/0L-iqlusion-engineering-fund",
      "uid": 0,
      "destination": "C906F67F626683B77145D1F20C1A753B",
      "type_of": "PercentOfChange",
      "value": 0.00,
      "duration_epochs": 1000
    },
  ]
}

```

The autopay types are `PercentOfBalance, PercentOfChange, FixedRecurring, FixedOnce`

### Get Payment Events Received
account: the address to query.
events-received: a bool, to check incoming txs.
txs-height: Starting event number/nonce. Note: Not all nodes will have the full event list in database. e.g. those nodes restoring from an epoch archive.

For example querying the iqlusion Engineering program:
```
ol --account c906f67f626683b77145d1f20c1a753b query --events-received --txs-height 10
```

## Query a Move struct in an account

For example getting the transaction fees accumulated in an epoch.
```
ol --account 00000000000000000000000000000000 query --move-state --move-module TransactionFee --move-struct TransactionFee --move-value balance
```