# Common CLI Commands


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