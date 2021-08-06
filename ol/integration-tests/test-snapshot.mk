cargo run -p ol-genesis-tools -- --path ./ol/fixtures/state-snapshot/194/state_ver_74694920.0889/

cargo build -p libra-node -p cli && NODE_ENV="test" cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c ~/.0L/swarm_temp -n 1 -s --cli-path target/debug/cli --genesis-blob-path ~/.0L/genesis_from_snapshot.blob

