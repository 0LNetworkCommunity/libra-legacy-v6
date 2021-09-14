# Common CLI Commands


### Get Payment Events Received
account: the address to query.
events-received: a bool, to check incoming txs.
txs-height: Starting event number/nonce. Note: Not all nodes will have the full event list in database. e.g. those nodes restoring from an epoch archive.

For example querying the iqlusion Engineering program:
```
ol --account c906f67f626683b77145d1f20c1a753b query --events-received --txs-height 10
```