## Documentation on Past Issues and Possible solutions

## Issues
1. [Validator logs show "Too many open files" or "File descriptor limit exceeded" error and tower app is stopped](#issue-1)
2. [Tower start: Epochs not consecutive](#issue-2)
3. [DB should open](#issue-3)
4. [Tower start: EOF error](#issue-4)
5. [When trying to start the tower app, a response was received from an upstream_node but not a remote tower state](#issue-5)
6. [When a fullnode (diem-node) has started, in the logs it states that a response was received from an upstream_node but not a remote tower state.](#issue-6)
7. [When trying to start the web monitor, Connection Failed: Connection refused (os error 111)](#issue-7)

## <a id="issue-1"></a> Issue "Too many open files"
### Validator logs show "Too many open files" or "File descriptor limit exceeded" error and tower app is stopped

The validator is not voting or syncing and the file descriptor limit exceeded error is shown in the node logs. Tower app is stuck at a proof unable to submit the transaction with ".....".

**Temporary Solution:** 

This is an issue with the file descriptor limit being exceeded. 

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

**Solution:** 

It is possible that waypoint that tower app is using might be wrong. You can check the waypoint by looking at the logs on tower start. 
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

**Problem:** 

Validator node ran out of space and tower app created empty block_.json file. When starting tower app below error is observed: 

```
Message: Error EOF while parsing a value
Location: tower/src/block.rs:....
```
**Solution:** 

Check if the last block proof created is empty. If so, remove the file and start the tower app again. This is after the node is caught up on the network. 

## <a id="issue-5"></a> Issue: Received response but no remote state found

**Problem:** 

When trying to start the tower app, a response was received from an upstream_node but not a remote tower state. 

```
Message:  called `Result::unwrap()` on an `Err` value: Info: Received response but no remote state found. Exiting.
Location: ol/tower/src/backlog.rs:27
```
**Solution:** 

There could be an issue with the address used for the validator, or an issue with mining the genesis block.
If you have another address that has already been onboarded and being used for mining normally, you can try the following:

- change your `acount` and `auth_key` set in `~/.0L/0L.toml` under `[profile]` with details of your existing address. 
- start tower again with `tower start`, `tower -u <upstream-ip-address> start` or with whatever flags you were trying to start tower with. 
- you should now see `Mining VDF Proof # 1` or similar in the logs.
- If this works, you should use this address as the validator. To do this, you will need to follow step 2.2 onwards again from [the hard onboarding guide](../../node-ops/validators/validator_onboarding_hard_mode.md#2-generate-account-keys), making sure to use the mnemonic of the working address when using `onboard val`

Alternatively, you can try a brand new address:
- make sure it is onboarded to the network already (not validator yet). If you are able to mine using Carpe on another device, it's highly likely this address will work.
- change your `acount` and `auth_key` set in `~/.0L/0L.toml` under `[profile]` with details of your new address.
- start tower again with `tower start`, `tower -u <upstream-ip-address> start` or with whatever flags you were trying to start tower with.
- you should now see `Mining VDF Proof # 1` or similar in the logs.
- If this works, you should use this address as the validator. To do this, you will need to follow step 2.2 onwards again from [the hard onboarding guide](../../node-ops/validators/validator_onboarding_hard_mode.md#2-generate-account-keys), making sure to use the mnemonic of the working address when using `onboard val`

If this doesn't work, it can also be caused by [When trying to start the web monitor, Connection Failed: Connection refused (os error 111)](#issue-7)

## <a id="issue-6"></a> Issue: NoAvailablePeers after the fullnode (diem-node) has been started. 

**Problem:**

When a fullnode (diem-node) has started, in the logs it states that a response was received from an upstream_node but not a remote tower state.
```
2022-02-05T11:55:46.052036Z [state-sync] ERROR state-sync/src/coordinator.rs:219 {"error":"NoAvailablePeers(\"No peers to send chunk request to!\")","event":"fail","name":"progress_check"}
2022-02-05T11:55:46.551657Z [state-sync] WARN state-sync/src/coordinator.rs:1514 {"name":"timeout","version":23877219}
2022-02-05T11:55:46.551690Z [state-sync] WARN state-sync/src/coordinator.rs:1567 {"event":"missing_peers","name":"send_chunk_request"}
2022-02-05T11:55:46.551818Z [state-sync] ERROR state-sync/src/coordinator.rs:1547 {"error":"NoAvailablePeers(\"No peers to send chunk request to!\")","event":"send_chunk_request_fail","local_epoch":102,"name":"timeout","version":23877219}
2022-02-05T11:55:46.551895Z [state-sync] ERROR state-sync/src/coordinator.rs:219 {"error":"NoAvailablePeers(\"No peers to send chunk request to!\")","event":"fail","name":"progress_check"}
```
**Solution:**

All you need to do is: `ol restore`

The issue occured perhaps due to configs not fully updated after changing the address or mnemonic associated with the fullnode. `ol restore` will set the waypoint and update the `key_Store.json`


## <a id="issue-7"></a> Issue: When trying to start the web monitor, Connection Failed: Connection refused (os error 111)

**Problem:**

When starting the web_monitor, you may get `Connection Failed: Connection refused (os error 111)`.

You may also either have issue 5. [When trying to start the tower app, a response was received from an upstream_node but not a remote tower state](#issue-5), the solution here could fix that too.


```
can make client but could not get metadata Error { inner: Inner { kind: Request, source: Some(ConnectionFailed("Connection refused (os error 111)")), json_rpc_error: None } }

Caused by:
    Connection Failed: Connection refused (os error 111)
ERROR: could not create client connection, message: Cannot connect to any JSON RPC peers in the list of upstream_nodes in 0L.toml
```
**Solution:**

There may be a bad IP address, `upstream_nodes`, being used in `~/.0L/0L.toml`. Try changing the ip address there to one from [here](https://github.com/0LNetworkCommunity/carpe/blob/main/seed_peers/fullnode_seed_playlist.json). 
::