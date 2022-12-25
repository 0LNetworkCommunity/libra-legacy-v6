# Quick start

### If you are operating a node:

From project root: `make client`

### If you are connecting remotely:

- For `experimental` net:

Fill in the ip address of a known validator:

`cargo run -p cli -- -u http://<ip>:8080 --chain-id 1 --waypoint 0:683185844ef67e5c8eeaa158e635de2a4c574ce7bbb7f41f787d38db2d623ae2`

### If you are developing:

Follow in instructions in swarm, since the ports will be random on each run. The command will look like:

`cargo run -p cli -- -u http://localhost:<random> --chain-id 4 --waypoint <swarm waypoint>`


# Background

Libra ships with an interactive client app called `cli`. The cli connects to a server on a fullnode (or validator node). This server may be remote, or local.

Additionally the client needs a trusted waypoint to start. Use the genesis waypoint, or retrieve a new one.

If you are running a fullnode or validator, you can use the Makefile recipe `make client`. Otherwise you will need to connect to a remote node.

Note, when connecting by localhost, you will be querying your current database state (not the network state), and if your node is in process of syncing, you will not yet have the up-to-date network data.

# Connect a client

The command for starting a client, and typical arguments:

`cargo run -p cli -- -u http://<ip>:8080 --chain-id <id> --waypoint <waypoint>`

1. You need a fullnode or validator's ip address to which you will connect. This can  be `localhost` if running from node.

`http://localhost:8080`

2. Waypoint: you can start with the genesis waypoint if you are within 100 epochs of genesis, otherwise provide a more recent waypoint.

The genesis waypoint is archived on github.com/0LNetworkCommunity/genesis-archive/genesis/genesis_waypoint.

If you are running a fullnode, more recent waypoints can be provided from a libra node by querying `key_store.json`, a make shorcut exists for this.

`make get-waypoint`

3. Chain Id: this identifies the network you are connecting to. The defaults are:

`1` for  experimental network

`4` for swarm, if using for local dev testing.


## Example commands

### Check your account state
Tip: Use `0` as a shortcut for the 0th address of your wallet, your main account with balance.

libra% `query account_state 0`

### Check a different account state
libra% `query account_state <account>` or `q as <account>`

### Check account balance
libra% `query balance <account>` or `q b <account>`

### Check tower state
libra% `ol miner_state <account>`




