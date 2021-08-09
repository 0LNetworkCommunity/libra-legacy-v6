# Devnet Setup

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

# Register

All nodes/personas need to register
```
make dev-register

```

Files should be updated on: https://github.com/OLSF/dev-genesis


# Set the layout

Only one node needs to do this.
```
make layout

```

# Make genesis

Every node does this.

```
make dev-genesis
```

A waypoint will be displayed. This means the genesis file is readable.

# save the genesis

Only one node needs to do this.
NOTE: this saves the genesis to a folder ol/devnet/genesis/previous. It is named previous, because the devnet may be tesing upgrades, and a new "current" blob may be created.


```
make dev-save-genesis
```
