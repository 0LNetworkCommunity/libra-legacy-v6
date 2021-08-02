# Generate genesis blob from epoch
Sample command:
```cargo run -p ol-genesis-tools -- --path ${FULL_PATH_TO_PROJECT_ROOT}/ol/fixtures/state-snapshot/194/state_ver_74694920.0889/```

# Start swarm with a custom genesis blob file
Sample command:
```NODE_ENV="test" cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c /home/teja9999/.0L/swarm_temp -n 1 -s --cli-path target/debug/cli --genesis-blob-path ${FULL_PATH_TO_BLOB_FILE}```

--genesis-blob-path is the additional parameter added to libra-swarm module. 
