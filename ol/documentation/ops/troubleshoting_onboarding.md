## Documentation on Past Issues and Possible solutions

## Issues
1. [Validator logs show "Too many open files" or "File descriptor limit exceeded" error and miner is stopped](#issue-1)
2. [Miner start: Epochs not consecutive](#issue-2)
3. [DB should open](#issue-3)
4. [Miner start: EOF error](#issue-4)

## <a id="issue-1"></a> Issue "Too many open files"
### Validator logs show "Too many open files" or "File descriptor limit exceeded" error and miner is stopped

The validator is not voting or syncing and the file descriptor limit exceeded error is shown in the node logs. Miner is stuck at a proof unable to submit the transaction with ".....".

**Temporary Solution:** This is an issue with the file descriptor limit being exceeded. 

1. Go to the **libra-node.service** template you are using for starting the node. 
2. Update **LimitNOFILE=200000**
3. Restart node: **make daemon**
4. Restart miner: **miner start**

*Note: This is until we figure out a better way not to reach the limit.*


## <a id="issue-2"></a>  Issue: Epochs are not consecutive
### Miner starts but throws error on transaction: Failed to get state proof with error...Epochs are not consecutive

```
Backlog: resubmitting missing blocks.
The application panicked (crashed).
Message:  called `Result::unwrap()` on an `Err` value: Failed to get state proof with error: JsonRpcError { code: -32000, message: "Server error: Epochs are not consecutive.", data: None }
Location: miner/src/submit_tx.rs:57

Backtrace omitted. Run with RUST_BACKTRACE=1 environment variable to display it.
Run with RUST_BACKTRACE=full to include source snippets.

```

**Solution:** It is possible that waypoint that miner is using might be wrong. You can check the waypoint by looking at the logs on miner start. 
```
 Waypoint: No waypoint parsed from command line args. Searching for waypoint in key_store.json
[miner/src/config.rs:46] &value = "xxxxx"
```
If it is not the right one. This needs to be updated in key_store.json under the key: "oper/waypoint". Update the value for this key with the waypoint your node synced from. 

**Fetching Waypoint:** 
1. Use the waypoint value in restore_waypoint. 
2. If the file is not there, this needs to be fetched from an existing node.  


## <a id="issue-3"></a> Issue: DB should open... libradb/LOCK: Permission denied

```
2021-04-08T18:20:16.758813Z [main] ERROR common/crash-handler/src/lib.rs:38 details = '''panicked at 'DB should open.: IO error: while open a file for lock: /home/ubuntu/.0L/db/libradb/LOCK: Permission denied', libra-node/src/lib.rs:285:10'''
```

You may be running `libra-node` in a separate process. In that case there may be concurrent writes happening.

**Solution:**

- Stop all libra-node instances.  `killall libra-node` or if you used makefile to start systemd:  `make stop`
- Restart libra-node

## <a id="issue-4"></a> Issue: Miner start: EOF error

**Problem:** Validator node ran out of space and miner created empty block_.json file. When starting miner below error is observed: 

```
Message: Error EOF while parsing a value
Location: miner/src/block.rs:206
```
**Solution:** Check if the last block proof created is empty. If so, remove the file and start the miner again. This is after the node is caught up on the network. 


