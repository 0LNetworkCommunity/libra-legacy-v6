# ol-cli

This is the entrypoint for monitoring, management, and configuration tools for 0L.


## Quick start

```
# run onboarding on autopilot
> ol onboard autopilot

# run onboarding interactively, advancing each step
> ol onboard next

# serve the web dashboard
> ol serve

# watch a block explorer monitor in terminal
> ol monitor

# query your balance
> ol query balance 

# how to use entrypoint options (main command arguments)
# e.g. -a or --account
> ol -a F020472FEF994EA54A95055CF69C62F6 query balance 

```

## Help

```
# show entrypoint options (main command arguments)
> ol h // TODO: This is a hack, consult Abscissa to learn the correct usage

# show flags for a sub-command e.g. "query" 
> ol help query 
```

## Defaults

All default parameters come from the `miner.toml` file, and stored by default in `~/.0L/miner.toml`

The `ol onboard` subcommand can initialize this. Note that in this case the `ol` cli app is simply calling the `miner` app's `val-wizard` subcommand.

The default is to query the ip address of `default_node` in `miner.toml`. The validator wizard in `miner` on initialization sets this by default to `localhost:8080`.

Queries will fallback by default to one of multple `upstream_nodes` if the local node's `sync` healthcheck shows local is not caught up with chain. The validator wizard sets this to a seed fullnode.

To force the query to a given URL see entry point options below.

## Entrypoint Options

Options on the entrypoint will override configs found in `miner.toml`.

`--url`: http url string, sets the default url to perform queries

`--waypoint`: string, sets the waypoint from which the client starts to sync from

`-a or --account`: string, sets the account for queries

`--force-local`: bool,  uses the node configured as `default_node` in `miner.toml`

## Subcommands


### `ol mgmt`

Can start and stop long running processes such as `node` and `miner`. The intended use is the onboarding flow, or debugging. Note: best practice for such long running process is `systemd` daemon.

Options:
```
--start-node:  start node  
--stop-node:   stop node  
--start-miner: start miner  
--stop-miner:  stop miner  
--stop-all:    stop node and miner  
```

### `ol restore`

Can restore the database from the epoch-archive repository. Default is non-destructive, and fetches the most recent (highest epoch)  from the archive. Intended use is for onboarding.

Options:

`--wipe`: destroys local database prior to restore.

`--epoch`: fetches a specified epoch from epoch-archive. Note: not all epochs may be stored.

### `ol onboard`
Is a simple state machine of the steps involved in onboarding a `validator`. IT can return the current state, or trigger acctions to advance the onboarding process.  

Optionally there's a subcommand which can `autopilot` and loop through the state machine, attempting to advance whenever possible. Autopilot will also by default start the `serve` webserver.


Subcommands
* `onboard show`: shows the current step in the onboarding process.

* `onboard next`: Tries to advance to a next step, by triggering an action.

* `onboard autopilot`: Runs continuously, and attempts to advance every onboarding step possible, without supervision. E.g. as soon as the validator account is created on-chain, start the miner.



### `ol check` 
Runs a healthcheck on the account, node, and displays some network information. Default is to return snapshot and exit, can run in live mode continuously.

    options:

      `--live`: runs continuously

### `ol monitor`
Runs a block explorer dashboard in the terminal. Wrapping the `../explorer` app.

### `ol serve`

Starts a webserver on localhost:3030, which displays info on the node (and onboarding), chain info, and account info.

Serves the routes:
/checks/ which serves a json formatted data feed of the dashboard
/account/ which is sourced from static `account.json` which can be used in the onboarding process.


### `ol query`
Runs simple queries through subcommands, prints the value to stdout.

Note: defaults to account used in `miner.toml`, see Entrypoint Options above.

Subcommands:

* `query epoch`: fetches epoch of chain. 

* `query blockheight`: fetches height of chain. 

* `query resources`: fetches the entire state of an account. Defaults to account in `miner.toml`. 

* `query balance`: fetches GAS balance of account. Defaults to account in `miner.toml`. 

* `query sync-delay`: checks how far behind the local is to the upstream nodes, in blocks.
