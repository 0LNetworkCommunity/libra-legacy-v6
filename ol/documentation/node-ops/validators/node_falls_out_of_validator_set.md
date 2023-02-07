
# How to Recover a Validator If It Stops Mining and Falls Out of the Set

If a validator stops mining for some reason and does not mine at all during an epoch, then it will be jailed and removed from the validator set. This page contains instructions for how to get the node back into the validator set.

There are two parts to getting a node back into the validator set. First you must start mining again for one epoch, second, you must run the node as a full node until it's back in the validator set to keep your DB caught-up with blockchain state. Finally you must restart the node as a validator once proofs have been mined for an epoch and it is un-jailed.

# First Step -- The tower app

NOTE: you may wish to save a copy of 0L.toml at this point for later use.

While your node is recovering, the easiest thing to do is to set your tower app up to connect to a different validator. To do so, open `0L.toml` in the .0L folder and edit the "upstream_nodes" entry to include another validator, including the port number. For instance:

`upstream_nodes = ["http://167.172.248.37:8080/"]`

Now restart the tower app with the --use-upstream-url flag, like this:

`tower --use-upstream-url start`

# Second Step -- The Node

NOTE: you may wish to save a copy of diem-node.service at this point for later use.

OL does not support a node easily changing between being a validator and a full node. You must manually make some configuration changes and restart the node. To do this, create a config file for the full node from this template: https://github.com/0LNetworkCommunity/epoch-archive/blob/main/fullnode_template.node.yaml ... and then modify the --config path in the ExecService to point to that file.

Finally, you can restart your node:

`make daemon`

You will know that your full node is syncing and catching up if you periodically see entries like this in the log file: 

"======================================  round is 219784"

This command will tell you the sync state of a RUNNING local node: `db-backup one-shot query node-state`

# Restart Node as a Validator

Once an epoch has passed where your tower app has mined proofs, your node will be eligible to rejoin the validator set. To do this, stop the node:

`make stop`

... and then revert the diem-node.service file to its previous state (i.e. so that the config parameter points to node.yaml, which is the configuration for a validator). Then finally restart the node with `make daemon`.

# Restart Your Tower App to Connect to Your Own Node

First, kill the tower app using ctrl-C in the tower screen. Then restart without the --backup-url flag:

`tower -o start`

Your node should now be back in the validator set and creating delay towers correctly!

This command that will tell you the sync state of a RUNNING local node: `db-backup one-shot query node-state`


