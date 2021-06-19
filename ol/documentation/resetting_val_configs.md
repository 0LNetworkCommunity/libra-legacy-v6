
## Create, or Refresh Validator Configs

Existing validators can refresh their configs by using the same `onboard` tool that new validators would use.

Ideally you will start from a fresh new user (not root) on your host.

0. Backup your config files in your current user's `~/.0L`. 

```
cd ~
rsync -av --exclude db/ ~/.0L ~/0L_backup_202106
```

1. Make sure you have your `autopay_batch.json` in the `~/.0L` before continuing

2. Create all files needed for validator

```
onboard --val --skip-mining --upstream-peer http://ip-address --source-path path/to/libra/source
```

This command will prompt for a few configs, including what directory you will be storing configs for that account. It will also prompt for the IP address of the node.

`--upstream-peer` fetches up-to-date epoch and waypoint information from an upstream.
`--from-source` indicates that you want to include paths to source in 0L.config, useful for development and oracle upgrade transaction for standard library.

`Fun statement` is not required, but you may want to enter the original one for consistency.


3. Stop your node, miner, monitor and restart

```
# in previous user
ol mgmt --stop all

# in new user
ol start
```

