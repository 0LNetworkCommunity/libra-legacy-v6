# Devnet Setup

Assuming a devnet has been set up, restarting devnet is a one line command: `make devnet`.

This assumes all the set up has previously been done. Meaning, there is a genesis.blob with certain personas assigned to ip addressses.

The steps below do 1) setup hosts 2) create the data for genesis.

# Setup devnet hosts

Every host has a static IP, and a persistent "persona": alice, bob, carol.

Mapping the personas to a ip address is done with 0L.toml config files found in: `ol/fixtures/configs/*.0L.toml`

## From an empty box

1. pull source, and build. Use sccache for faster builds.
2. create a github token which has permissions for `dev-genesis` repo
place the token in a file `~/.0L/github_token.txt`

3. export env variables in bashrc for automation.

Note: each devnet node, has a persona. For each one choose a different `NS` (namespace)
```
# for devnet
export TEST=y NODE_ENV=test NS=alice
```

3. create local state
``` 
make clear fix

```

4. check every setting has a value
```
make check

```

# Create all the data and genesis file.

## register all nodes/personas

All nodes/personas need to register
```
make dev-register
```

Files should be updated on: https://github.com/OLSF/dev-genesis


## set the validator set layout

Only one node needs to do this.
```
make layout

```

## make genesis

Every node does this.

```
make dev-genesis
```

A waypoint will be displayed. This means the genesis file is readable.

## save the genesis

Only one node needs to do this.
NOTE: this saves the genesis to a folder ol/devnet/genesis/previous. It is named previous, because the devnet may be tesing upgrades, and a new "current" blob may be created.


```
make dev-save-genesis
```

## Commit changes to repo

Commit the genesis.blob to repo.

This makes it easy to start a devnet, without needing to do all the steps above.

# Start a devnet

A readymade genesis.blob from ol/devnet/genesis, can be used to start up a network. 

Assuming, IP addresses and personas are the same (usually alice, bob, carol), there is no need to do a devnet setup.

```
make devnet
```

