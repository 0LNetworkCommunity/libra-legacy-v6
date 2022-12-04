
# App Configs - 0L.toml

All 0L tools use a configuration file called `0L.toml` located in your 0L home directory. usually this is `$HOME/.0L/0L.toml`.

The Diem services, namely `diem-node`, use their own configuration format (e.g. `$HOME/.0L/validator.node.yaml`).

0L apps including Carpe, and cli tools like `ol`, `tower`, `txs`, `web-monitor`, `onboard` use the 0L.toml for configurations.

# Where is this file
By default all 0L tools search for this file in `$HOME/.0L/` directory.

If you have placed this file elsewhere, you'll need to explicitly call the config path when starting an app:
```
ol --config <path/to/config> ...
ol -c <path/to/config> ...

```

# workspace

Workspace covers default file and directory paths that the tools may refer to. The most relevant one is the `home` path which is where this file and all other state and config files will be stored.

# profile
Profile tells the apps the preferences of this node.
It describes the owner with 
```
account = "3dc18d1cf61faac6ac70e3a63f062e4b"
auth_key = "2bffcbd0e9016013cb8ca78459f69d2b3dc18d1cf61faac6ac70e3a63f062e4b"
```

A fun personal statement which was used in the first miner proof you submitted.
```
statement = "test"
```
The IP address of this node (e.g. a validator node), and the optional `vfn_ip` addresss of the validator.
```
ip = "127.0.0.1"
vfn_ip = "0.0.0.0"
```

## Client connection info.

When using 0L tools you have the option of having one or more upstream nodes for your tools to get data and submit transactions.

`upstream_nodes` contains the endpoint addresses of fullnodes which have the JSON RPC enabled (port `8080` by default).

`upstream_nodes` is a list. The default behavior of the 0L tools is to RANDOMLY pick a URL from the list, and check if it is alive. The list feature exists for Carpe primarily, where random selection is important for balancing load across fullnodes. Testing all URLs at the time of submitting txs increases reliability for end-users.

For Validators and Fullnode operators which want more control, there are other options for configuration.

1. only include a single node in this array
1. set the URL at runtime
1. force the first URL from the list

### Use a single RPC node
Or you'll set a single RPC node in your upstream_nodes.

```
upstream_nodes = ["http://x.y.z.a:8080/"]
```

### Set URL at runtime
1. You have one remote server you would like to use.

You can explicitly set the URL when running the CLI command.
`txs --url ...`

### Force using the first URL
1. You usually have a list of URLs you want to submit to. But there is one you use more often, or have more control over (e.g. localhost).

You can explicitly set the URL when running the CLI command.
`txs --use-first-url ...`

Your configs may look like:
```
upstream_nodes = ["http://localhost:8080/", "http://x.y.z.a:8080/"]
```

# chain_info

This section describes the chain you are connecting to. Importantly the the `base_waypoint` tells the client software what is the trusted state of the chain you are expected. Normally this will be initialized with the genesis waypoint.

Without a valid waypoint client connections will fail. Waypoint can be found on blockexplorers like `http://0lscan.io`.

Note that currently Diem code, you'll need to use a waypoint within the last 100 epochs.

# tx_configs

Here you can set the properties for categories of transaction types. For example the timeout and price you would bid for mining transactions.

The categories are:
`baseline_cost`, `critical_txs_cost`, `management_txs_cost`, `miner_txs_cost`, `cheap_txs_cost`.