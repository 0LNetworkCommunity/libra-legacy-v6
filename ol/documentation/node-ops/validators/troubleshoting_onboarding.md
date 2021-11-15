## Documentation on Past Issues and Possible solutions

## Issues
1. [Validator logs show "Too many open files" or "File descriptor limit exceeded" error and tower app is stopped](#issue-1)
2. [Tower start: Epochs not consecutive](#issue-2)
3. [DB should open](#issue-3)
4. [Tower start: EOF error](#issue-4)

## <a id="issue-1"></a> Issue "Too many open files"
### Validator logs show "Too many open files" or "File descriptor limit exceeded" error and tower app is stopped

The validator is not voting or syncing and the file descriptor limit exceeded error is shown in the node logs. Tower app is stuck at a proof unable to submit the transaction with ".....".

**Temporary Solution:** This is an issue with the file descriptor limit being exceeded. 

1. Go to the **diem-node.service** template you are using for starting the node. 
2. Update **LimitNOFILE=200000**
3. Restart node: **make daemon**
4. Restart tower app: **tower -o start**

*Note: This is until we figure out a better way not to reach the limit.*


## <a id="issue-2"></a>  Issue: Epochs are not consecutive
### Tower app starts but throws error on transaction: Failed to get state proof with error...Epochs are not consecutive

```
Backlog: resubmitting missing blocks.
The application panicked (crashed).
Message:  called `Result::unwrap()` on an `Err` value: Failed to get state proof with error: JsonRpcError { code: -32000, message: "Server error: Epochs are not consecutive.", data: None }
Location: tower/src/submit_tx.rs:...

Backtrace omitted. Run with RUST_BACKTRACE=1 environment variable to display it.
Run with RUST_BACKTRACE=full to include source snippets.

```

**Solution:** It is possible that waypoint that tower app is using might be wrong. You can check the waypoint by looking at the logs on tower start. 
```
 Waypoint: No waypoint parsed from command line args. Searching for waypoint in key_store.json
[tower/src/config.rs:...] &value = "xxxxx"
```
If it is not the right one. This needs to be updated in key_store.json under the key: "oper/waypoint". Update the value for this key with the waypoint your node synced from. 

**Fetching Waypoint:** 
1. Use the waypoint value in restore_waypoint. 
2. If the file is not there, this needs to be fetched from an existing node.  


## <a id="issue-3"></a> Issue: DB should open... libradb/LOCK: Permission denied

```
2021-04-08T18:20:16.758813Z [main] ERROR common/crash-handler/src/lib.rs:38 details = '''panicked at 'DB should open.: IO error: while open a file for lock: /home/ubuntu/.0L/db/libradb/LOCK: Permission denied', diem-node/src/lib.rs:285:10'''
```

You may be running `diem-node` in a separate process. In that case there may be concurrent writes happening.

**Solution:**

- Stop all diem-node instances.  `killall diem-node` or if you used makefile to start systemd:  `make stop`
- Restart diem-node

## <a id="issue-4"></a> Issue: Tower App start: EOF error

**Problem:** Validator node ran out of space and tower app created empty block_.json file. When starting tower app below error is observed: 

```
Message: Error EOF while parsing a value
Location: tower/src/block.rs:....
```
**Solution:** Check if the last block proof created is empty. If so, remove the file and start the tower app again. This is after the node is caught up on the network. 


