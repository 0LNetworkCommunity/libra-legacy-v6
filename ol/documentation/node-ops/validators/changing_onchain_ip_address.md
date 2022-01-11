# Update On-chain Node Discovery

Changing the IP address of your node so that validators and fullnodes can discover your node.

YOUR NODE WILL NOT BE REACHABLE FOR CONSENSUS IF:

- The IDs in your yaml file diverge from what your mnemonic produces.
- The IDs in your yaml file diverge from the on-chain configs.

## Check your current on-chain configs

Use the query cli to print out your current on-chain configs.

```
ol query --val-config

```

## Check what your curreny ID is

This tool uses your mnemonic to see what are the EXPECTED identities and public keys for this account.

```
ol whoami

```

## Check what your node.yaml file uses as ID

Your node.yaml could be malformed. You'll want to check that the IDs used in the file correspond to what your mnemonic produces (with `ol whoami`).

```
ol whoami --check-yaml <path/to/node.yaml>
```

## Update the on-chain configs

You will need to have two IP addresses 1) The validator IP, and 2) the VFN validator fullnode.
After displaying the new configs, you will be asked to confirm the changes.

```
txs val-config --val_ip <IP> --vfn-ip <OTHER/IP>
```