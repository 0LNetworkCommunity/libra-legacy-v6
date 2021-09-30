# New Validators

## With URL (most common):

The node should have a web-monitor running at `http://<their-ip>:3030`.

a. Submit tx with `txs` app:

NOTE: don't forget `http://`

```
txs create-validator -u http://<their-ip>
```


### Troubleshooting:

#### Unreachable
If <their-ip> is unreachable it is likely that the server is not running, or that the 3030 port is not open to the public.

If it is not reachable, the `file` option below is possible.

#### Tx Sequence number
If there is an issue with sequence_number being out of sync. It's like that an automated transaction (like `miner`), got a transaction sent concurrently. Retry the transaction.



## With file:

a. Copy the `account.json` to your local node.

b. Sumbit tx with `txs` app:

```
txs create-validator -f <path/to/json>
```


# New End User Accounts

## With file:

a. Copy the `account.json` to your local node.

b. Sumbit tx with `txs` app:

```
txs create-user -f <path/to/json>
```