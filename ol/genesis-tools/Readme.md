
### JSON export from snapshot 
cargo r -p ol-genesis-tools -- --export-json ~/libra-recovery/v5_recovery.json --snapshot-path ~/epoch-archive/667/state_ver* --ancestry-file ~/libra-recovery/v5_ancestry.json

state_ver: [https://github.com/0LNetworkCommunity/epoch-archive/tree/main/359/state_ver_76353076.a0ff](https://github.com/0LNetworkCommunity/epoch-archive/tree/main/667/state_ver_136811663.1906)

### Create genesis blob from JSON export:
cargo r -p ol-genesis-tools -- --fork --recovery-json-path /opt/rec.json --output-path /opt/genesis_from_recovery.blob

### Verify the validity of genesis blob by starting a node in test mode:
cargo r -p diem-node -- --test --genesis-modules /opt/genesis_from_recovery.blob
