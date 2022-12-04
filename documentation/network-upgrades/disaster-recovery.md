# Manual Overrides to State

How to rescue a halted network.

When a network halts for any reason there may be two solutions:
1) change the validator set, in case validators are unresponsive.
2) update the stdlib Move code.

Both solutions require that the validators (or subset of validators) to apply manual transactions to the DB, and then restart.

These instructions assume the database is at rest, and diem-node is not running.

These instructions assumes you are building binaries from /libra source.

The CLI Tools you will use:
 - `db-restore`: The `backup-cli` tool to take archived snapshots and restore a database. We provide wrappers to those tools in: https://github.com/OLSF/epoch-archive

- `diem-transaction-replay`: To inspect state of the DB.
- `diem-writeset-generator`: Create transaction binaries, and save the files. Those file will be applied to db at a later step.
- `db-boostrapper`: a tool used to apply writesets to a database at rest (halted network). Usually this is for "genesis"


## Gotchas

1. A database must NOT be at the epoch's last block (at reconfiguration time).
There is a check in the Move code (DiemConfig::reconfigure_) which deduplicates NewEpochEvents being emitted. If the last_reconfiguration timestamp is EQUAL to current DiemTimestamp, then a new epoch event will not be emitted.
What this means: your DB (or backup) must not be at the last block of the epoch. This is an issue with the epoch archive backups, which are taken of the last epoch's block.
You will see an error by the db-bootsrapper saying `Writeset did not emit new epoch event`, and the writeset will fail to be confirmed.

Solution: Use a backup or snapshot not at the epoch boundary. Or do a coodinated halt, see #3 below.

TODO: the backup flow or Move code need to be changes so that people.

2. You are starting from the Stdlib that is in the database, not whats in source.
If there's a change to the stdlib that is needed to get the network unstuck, you'll need to apply two recovery steps. The first will update the stdlib with new source. And then the second would apply the changes by executing functions that are in that new stdlib.

To be clear, you CANNOT bundle a stdlib upgrade writset, with another transaction that depends on the new stdlib.

Note that the issue #1 above still applies. The second writeset, will likely find a database that is at last_reconfiguration timestamp is EQUAL to current DiemTimestamp. 

Solution: So you'll need to run the database for a while (at least one block) and halt the network again to apply the second step.

3. All nodes must be at exactly the same block.
Databases that are at different blockheights will yield different state, and consensus is not possible

Being in sync is easy to do if all nodes are starting from one backup file. But in a running system there may be nodes that are at different blockheights.

Solution: Run nodes with validator.node.yaml with `sync_only: true`, until all nodes in the recovery validator are at the same block. The way to see this in the logs is that the `timeout` block is at the same number.

4. There may be other nodes in the network trying to connect to the recovery nodes.
This will create side-effects, and unexpected errors. So the nodes in the recovery validator set need to have a private network. 

Solution: This can be achieved by creating a validator.node.yaml file, which has 1) no fullnode network connections. 2) in validator network `discovery_service: none`, and 3) in the validator network settings `seeds` need to contain all the networking information of all nodes.

5. The new epochs on the restored network will be discontinuous.
Nodes that were previously on the network will not be able to automatically sync to recovery nodes. They will see an `epochChangeProof certificate is not valid`. This is because the previous epoch validators did not "sign off" on the epoch transition.

Solution: fullnodes, validators, etc. that join the network after recovery will need to do so with a `db-restore` operation. Either using `ol restore` or otherwise with instructions `https://github.com/OLSF/epoch-archive`
##  Cheatsheet


```
// Starting from a reference db
tar -xv backup.tar.gz ~/.0L/db

// or use a state snapshot
ol restore -e <epoch> -v <version>

// go to transaction generator Makefile
cd libra/language/diem-tools/writeset-transaction-generator


// Export the list of validators ADDRESS that will be leading the recovery

export VALS = <alice> <bob> <carol>

// save a writset transaction binary, for example of the "rescue" transaction set.
// Compiles a new stdlib from source, updates the validator set with VALS, and enters recovery mode until RECOVERY_EPOCH.
make tx-rescue

// check those transactions can be applied to the db
make check

// commit the writset to db at rest
make commit

// reinitilize your key-store.json
make init

// start your node NOTE: you need to have a modified node.yaml file, see below
make start
```

# Get a DB
1. Take a known good state snapshot (Snapshot A)

Either from https://github.com/OLSF/epoch-archive, or from a tar.gz file of someone's database.

Note: the DB should not be at the epoch boundary block.

2. Export the 0x0 state to file for easy viewing

```
cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account 00000000000000000000000000000000 > ~/.0L/dump-a

sha256sum ~/.0L/dump-a
```


3. You are ready to create the writeset transaction that is needed.
NOTE: as above, if you need changes to the stdlib, your first writeset and recovery need to be of the stdlib. To be clear, you CANNOT bundle a stdlib upgrade writset, with another transaction that depends on the new stdlib.

# Creating a Writeset Transaction File

The tool `diem-writeset-generator` creates files (e.g. rescue.blob) which can be intepreted by the `db-boostrapper`. That file contains "writesets" which are state transitions to the database.
### stdlib update:
After making changes and compiling your Move code, the following writset can be created to update all the system contracts, and issue a reconfiguration event.
```
make tx-stdlib

// or 
cargo r -p diem-writeset-generator -- --db ~/.0L/db --output ~/.0L/restore/rescue.blob update-stdlib 
```

###  Update validators

```
// set the vals of the new set
export VALS = ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740
make tx-vals

// or 
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob update-validators $VALS
```

###  Remove validators

```
// set the vals to remove
export VALS = ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740
make tx-remove

// or
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob remove-validators 304A03C0B4ACDFDCE54BFAF39D4E0448
```

### rescue mission:
A combined Stdlib update and change of validator set. This dispenses with an intermediary reconfiguration and epoch change. That is, the change of the validator set will issue a reconfiguration event.

Node the `--db` field

```
export VALS = ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740

make tx-recue
// or
cargo r -p diem-writeset-generator -- --db ~/.0L/db --output ~/.0L/restore/rescue.blob rescue ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740 
```


## Devs: Emit a Reconfiguration Event New Epoch Event

TODO: this is WIP it's not known to produce a DB in a usable state.

All writesets that `db-bootstrapper` will apply must have a reconfiguraion event. 
This is a no-op to test that the writeset generator can create a writeset that simply issues a reconfiguration event.
```
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob reconfig ~/.0L/db

```

# Apply the Writeset to DB


## check the DB can accept the writeset
A. boostrapper: Use `db-bootstrapper` to check that the writeset can be applied.

Apply the writeset to the database. You should see a new genesis waypoint printed if successful. Note this wa

```
make check

// or
cargo r -p db-bootstrapper -- ~/.0L/db/ --genesis-txn-file ~/.0L/restore/rescue.blob
```
NOTE THE `<WAYPOINT>` displayed

### Troubleshooting:
You may see two kinds of errors
1) The `writset failed to emit epoch change event`. Meaning that the writset did not trigger DiemConfig::reconfigure_ when all writesets applied to a db at rest must create a new epoch. Check the Move code of the writeset you are applying.

2) The `writset failed to bump epoch`. Similar to above, the new writset also needs to advance to a new epoch number. In this case, an epoch event WAS detected, but it did not have the expected outcome of increasing the epoch height. Likely because the epoch event height emitted, was the same as a writeset previously applied.
# Commit the writeset

Commit the writeset using `db-bootstrapper`.

Apply the writeset to the database. You should see a new genesis waypoint printed if successful. Note this waypoint

```
make commit
// or
cargo r -p db-bootstrapper -- ~/.0L/db/ --genesis-txn-file ~/.0L/restore/rescue.blob --commit --waypoint-to-verify <WAYPOINT>
```



### Check the writeset was applied by inspecting the DB with transaction replay

```
cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account 00000000000000000000000000000000 > ~/.0L/dump-c
shas256sum ~/.0L/dump-c
git diff ~/.0L/dump-b ~/.0L/dump-c
```

# Starting Up again

## Create a temporary validator.node.yaml file
- Remove the fullnode networks fields.
- Change `validator_network.service_discovery`: to `none`
- Add `seeds` peer information for the nodes participating in rescue in `validator_network.seeds`.

## reinitialize key-store.json

Two things need to be changed in key-store: 1) clear the safety rules and 2) set new waypoint

This can be accomplished with one command:
```
ol init --key-store --waypoint <WAYPOINT> 
```

Otherwise you will see a Safety rules not initialized error, and a Voting power Quorum error
The easiest way is to rewrite the entire key-store.json file.
```
// backup your key store
mv ~/.0L/key-store.json ~/.0L/key-store.json.bak

// create a fresh keystore file
ol init --key-store
```

Example error:
```
{"committed_round":0,"error":"[RoundManager] SafetyRules \u001b[38;5;1mRejected\u001b[39m [id: 0c66fd46 (NIL), epoch: 168, round: 01, parent_id: f692f815]\n\nCaused by:\n    Invalid EpochChangeProof: The voting power (0) is less than quorum voting power (300903)","kind":"SafetyRules","pending_votes":"PendingVotes: []","round":1}

```
Regarding Waypoint you may see a ` "Epochs are not consecutive error".`




# Example node.yaml
This file is stripped of fullnode network info and service discovery. This is a sample. The actual files and addresses will be different.

```
---
base:
  data_dir: /home/node/.0L/
  role: validator
  waypoint:
    from_storage:
      type: on_disk_storage
      path: /home/node/.0L/key_store.json
      namespace: 46a7a744b5d33c47f6b20766f8088b10-oper
  config_version: 5.0.9
consensus:
  contiguous_rounds: 2
  max_block_size: 1000
  max_pruned_blocks_in_mem: 100
  mempool_executed_txn_timeout_ms: 1000
  mempool_txn_pull_timeout_ms: 1000
  round_initial_timeout_ms: 1000
  proposer_type:
    type: leader_reputation
    active_weights: 99
    inactive_weights: 1
  safety_rules:
    backend:
      type: on_disk_storage
      path: /home/node/.0L/key_store.json
      namespace: 46a7a744b5d33c47f6b20766f8088b10-oper
    logger:
      chan_size: 10000
      is_async: true
      level: INFO
    service:
      type: thread
    test: ~
    verify_vote_proposal_signature: true
    export_consensus_key: false
    network_timeout_ms: 30000
    enable_cached_safety_data: true
  sync_only: false
  mempool_poll_count: 1
debug_interface:
  admission_control_node_debug_port: 6191
  address: 0.0.0.0
  metrics_server_port: 9101
  public_metrics_server_port: 9102
execution:
  sign_vote_proposal: true
  genesis_file_location: /home/node/.0L/genesis.blob
  service:
    type: thread
  backend:
    type: on_disk_storage
    path: /home/node/.0L/key_store.json
    namespace: 46a7a744b5d33c47f6b20766f8088b10-oper
  network_timeout_ms: 30000
logger:
  chan_size: 10000
  is_async: true
  level: INFO
metrics:
  collection_interval_ms: 1000
  dir: metrics
  enabled: false
mempool:
  capacity: 1000000
  capacity_per_user: 3
  default_failovers: 3
  max_broadcasts_per_peer: 1
  mempool_snapshot_interval_secs: 180
  shared_mempool_ack_timeout_ms: 2000
  shared_mempool_backoff_interval_ms: 30000
  shared_mempool_batch_size: 100
  shared_mempool_max_concurrent_inbound_syncs: 2
  shared_mempool_tick_interval_ms: 500
  system_transaction_timeout_secs: 600
  system_transaction_gc_interval_ms: 60000
json_rpc:
  address: "127.0.0.1:8080"
  batch_size_limit: 20
  page_size_limit: 1000
  content_length_limit: 4194304
  tls_cert_path: ~
  tls_key_path: ~
state_sync:
  chunk_limit: 1000
  client_commit_timeout_ms: 5000
  long_poll_timeout_ms: 10000
  max_chunk_limit: 1000
  max_timeout_ms: 120000
  mempool_commit_timeout_ms: 5000
  multicast_timeout_ms: 30000
  sync_request_timeout_ms: 60000
  tick_interval_ms: 500
storage:
  address: "127.0.0.1:6666"
  backup_service_address: "127.0.0.1:6186"
  dir: db
  grpc_max_receive_len: 100000000
  prune_window: 100000
  timeout_ms: 30000
  rocksdb_config:
    max_open_files: 10000
    max_total_wal_size: 1073741824
test: ~
# upstream:
#   networks:
#     - private: vfn
#     - public
validator_network:
  max_connection_delay_ms: 60000
  connection_backoff_base: 2
  connectivity_check_interval_ms: 5000
  network_channel_size: 1024
  max_concurrent_network_reqs: 100
  discovery_method: none
  identity:
    type: from_storage
    backend:
      type: on_disk_storage
      path: /home/node/.0L/key_store.json
      namespace: 46a7a744b5d33c47f6b20766f8088b10-oper
    key_name: validator_network
    peer_id_name: owner_account
  listen_address: /ip4/0.0.0.0/tcp/6180
  mutual_authentication: true
  network_address_key_backend:
    type: on_disk_storage
    path: /home/node/.0L/key_store.json
    namespace: 46a7a744b5d33c47f6b20766f8088b10-oper
  network_id: validator
  seed_addrs: {}
  seeds:
    7EC16859C24200D8E074809D252AC740:
      addresses:
        - "/ip4/35.231.138.89/tcp/6180/ln-noise-ik/987f636ef651abc3bc0ad1a33ef2e5841768fde064971333059d84442bb3d576/ln-handshake/0"
      role: "Validator"
    46A7A744B5D33C47F6B20766F8088B10:
      addresses:
        - "/ip4/35.192.123.205/tcp/6180/ln-noise-ik/da9ea456e1d9f45810669ecfcdb9f75a4d828a7e7a97f68014f47d789972a710/ln-handshake/0"
      role: "Validator"
    ECAF65ADD1B785B0495E3099F4045EC0:
      addresses:
        - "/ip4/34.145.88.77/tcp/6180/ln-noise-ik/14680097d0ae4d37158ade5c90da4ce43b13c5dbeb918016f0cc8e9830f54f33/ln-handshake/0"
      role: "Validator"
  max_frame_size: 8388608
  enable_proxy_protocol: false
  ping_interval_ms: 1000
  ping_timeout_ms: 10000
  ping_failures_tolerated: 10000
  max_outbound_connections: 100
  max_inbound_connections: 100
  inbound_rate_limit_config: ~
  outbound_rate_limit_config: ~
failpoints: ~

```