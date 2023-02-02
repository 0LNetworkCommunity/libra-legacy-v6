# Restoring database: Syncing from an advanced waypoint

# TL;DR

Restore latest epoch from github archives with: 
```
ol restore
```

# Summary

The backup and restore cycle consists of:

- saving a backup with backup-cli `db-backup`
- restore with backup-cli `db-restore`
- Change node.yaml and key_store.json (validators only) with waypoint.

0L maintains an archive of epochs of `experimental-network` here: https://github.com/0LNetworkCommunity/epoch-archive

# New backups

The examples above use files from epoch-archive

New snapshots can be made with:

```
	cargo run --release -p backup-cli --bin db-backup -- one-shot backup --backup-service-address http://167.172.248.37:6186 state-snapshot --state-version 41315058 local-fs --dir ~/.0L/db
```

Where the IP address above has a node.yaml config which allows connecting to port 6168 for the backup-service. The state version is the absolute blockchain height at the waypoint in question.

# Restore

To successfully bootstrap a database you must restore:

- the Waypoint
- at least a single Transaction
- a State Snapshot.

## Easy Mode: Using 0L tools

Restore from the latest package in epoch archive:
```
ol restore
```

Restore a specific epoch
```
ol restore --epoch <integer>
```

## Hard Mode: If you are not using the `ol` tools

### Restore Epoch Waypoint

`make restore-epoch`

### Restore Transaction

`make restore-transaction`

### Restore Snapshot

Using branch `backup-cli` there is a make command, which will use the manifest (and paths within) to restore state:

`make restore-snapshot`

# Node configs must be changed with new Waypoint
## Fullnodes and Validators: change the node.yaml waypoint

```
base:
    # Update this value to the location you want Diem to store its database
    data_dir: "/home/val/.0L/"
    role: "full_node"
    waypoint: 
        from_config: "45934438:732ea2e1c3c5ee892da11abcd1211f22c06b5cf75fd6d47a9492c21dbfc32a46"
```

## Validators: change the key_store.json
You must change two fields to the waypoint above: `-oper/genesis-waypoint` and `-oper/waypoint`

```
  "ed32290d9c9812cedc75af8a31ccc92e0e202106c759b18a31422628f374c827-oper/waypoint": {
    "data": "GetResponse",
    "last_update": 1613607659,
    "value": "41315058:71581c9bce01487c2c6d3a81383109f714860675bd835b66eebc02bca513e8e4"
  },
```

