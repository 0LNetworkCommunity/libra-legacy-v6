NODE_ENV="test"

genesis:
	cargo run -p ol-genesis-tools -- --genesis ~/.0L/genesis_from_snapshot.blob --snapshot ../fixtures/state-snapshot/194/state_ver_74694920.0889/state.manifest

build: 
	cargo build -p libra-node -p cli

swarm: build
	 cargo run -p libra-swarm -- --libra-node target/debug/libra-node -c ~/.0L/swarm_temp -n 1 -s --cli-path target/debug/cli --genesis-blob-path ~/.0L/genesis_from_snapshot.blob

