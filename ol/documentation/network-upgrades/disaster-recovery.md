# Plan B  - Manual Overrides to State

This is the (WIP) documentation on how to rescue a stuck network. 
This entails a subset of validators to apply manual transactions to the DB
to: 1) change the validator set, in case validators are unresponsive. 2) update the stdlib Move code.
These instructions assume the database is at rest, and diem-node is not running.

These insructions assumes you are building binaries from /libra source.

The CLI Tools you will use:
`db-restore`: The `backup-cli` tool to take archived snapshots and restore a database.
`diem-transaction-replay`: To inspect state of the DB.
`diem-writeset-generator`: Create transaction binaries, and save the files. Those file will be applied to db at a later step.
`db-boostrapper`: a tool typically to create genesis files, can be used to apply writesets to a database at rest (halted network).

## Creating a Forked DB
1. Take a known good state snapshot (Snapshot A)

```
https://home.gouin.io:5443/0L.167.tar.xz - Provided by Gnudrew)
```

2. Export the 0x0 state to file for easy viewing

```
cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account 00000000000000000000000000000000 > ~/.0L/dump-a

sha256sum ~/.0L/dump-a
```

4. Start a node as fullnode

You'll need to get 100+ new blocks before a new timestamp is committed.

Epoch snapshots have a timestamp time equal to the time of "the last reconfiguration". New reconfigurations will not run in those cases. We need to advance the timestamp to make that work.


3. Turn off node once it has advanced and export snapshot.

```
cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account 00000000000000000000000000000000 > ~/.0L/dump-b

sha256sum ~/.0L/dump-b
```

4. Create the writeset transaction which bulk updates validators.
This only creates the binary representation of a transaction to apply

###  Update validators

```
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob update-validators ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740
```

###  Remove validators

```
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob remove-validators 304A03C0B4ACDFDCE54BFAF39D4E0448
```

### stdlib update:
After making changes and compiling your Move code, the following writset can be created to update all the system contracts, and issue a reconfiguration event.
```
cargo r -p diem-writeset-generator -- --db ~/.0L/db --output ~/.0L/restore/rescue.blob update-stdlib 
```

### rescue mission:
A combined Stdlib update and change of validator set. This dispenses with an intermediary reconfiguration and epoch change. That is, the change of the validator set will issue a reconfiguration event.

Node the `--db` field

```
cargo r -p diem-writeset-generator -- --db ~/.0L/db --output ~/.0L/restore/rescue.blob rescue ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740 
```


## Devs: Emit a Reconfiguration Event New Epoch Event

All writesets that `db-bootstrapper` will apply must have a reconfiguraion event. 
This is a no-op to test that the writeset generator can create a writeset that simply issues a reconfiguration event.
```
cargo r -p diem-writeset-generator -- --output ~/.0L/restore/rescue.blob reconfig ~/.0L/db

```



5. A. boostrapper: Use `db-bootstrapper` to check that the writeset can be applied.

Apply the writeset to the database. You should see a new genesis waypoint printed if successful. Note this wa

```
cargo r -p db-bootstrapper -- ~/.0L/db/ --genesis-txn-file ~/.0L/restore/rescue.blob
```
NOTE THE `<WAYPOINT>` displayed

5. B. boostrapper: Commit the writeset using `db-bootstrapper`.

Apply the writeset to the database. You should see a new genesis waypoint printed if successful. Note this waypoint

```
cargo r -p db-bootstrapper -- ~/.0L/db/ --genesis-txn-file ~/.0L/restore/rescue.blob --commit --waypoint-to-verify <WAYPOINT>
```



6. Check the writeset was applied by inspecting the DB with transaction replay

```
cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account 00000000000000000000000000000000 > ~/.0L/dump-c
shas256sum ~/.0L/dump-c
git diff ~/.0L/dump-b ~/.0L/dump-c
```

## From here either all validators apply steps 1-5, or a second snapshot is created and circulated.

6. Create a new snapshot (Snapshot B)
Using DB backup snapshot the new "lab grown" database.

7. Share the new snapshot.


## Starting Up again
7. clear the safety rules in key-store.json
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
8. set new waypoint in key-store.json 

Otherwise there will be an "Epochs are not consecutive error".


