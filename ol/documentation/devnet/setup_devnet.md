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