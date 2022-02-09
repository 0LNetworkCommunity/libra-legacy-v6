# Running Tower: ie. Mining VDF proofs

These instructions are to run the 0L `tower` app. This creates VDF proof of work, and submits to the chain sequentially.

This documentation uses tmux as terminal multiplexer, sure you can also use screen or run it in a normal terminal session. 

## Start a `screen` or `tmux` instance

Make `tmux` work for backgrounding and resuming sessions:
```
tmux new -t tower
```
note: you may want to use separated `tmux` instances for different purposes

## Check if an account needs to be created

If you e.g. already had setup a validator, you should have these files:
you should have 
- ~/.0L/vdf_proofs/proof_0.json
- ~/.0L/key_store.json
- ~/.0L/0L.toml

If yes, continue with "Start the tower app".
If not, probably you do not have an account yet. Let's create one now:

Generate new keys and account by using the following command: `onboard keygen`. Run as many times as you like, and choose a mnemonic. 
**Mnemonic and keys are not saved anywhere, write them down now**. 

Send the generated `authkey` to someone that has GAS (the one who wants to onboard you). This person has to send e.g. 1 GAS to you by the following command:

```
txs create-account --authkey ..........   --coins 1 
```

Only after this, continue with the following steps:

```
# create 0L.toml file:
cd $HOME/.0L
ol init -u http://<ip-of-a-fullnode>:8080
# the following will take about 30-40 minutes to create the first proof and account.json:
onboard user
```

To submit the first proof (proof_0.json), you need to start the tower app using a special parameter:

```
tower -o -b start
```

After the successful first transfer, continue with starting the tower app (see below).

## Start the tower app
The tower app will produce VDF proofs or submit proofs, which are created and not yet submitted. The first block to be created is proof_1.json (which takes as the preimage input the sha256 hash of proof_0.json)

From your `tmux` instance you can run:

### for normal user accounts

```
# from any directory
export NODE_ENV=prod
tower start
```

This will ask for the mnemonics at startup. (Currently this is still needed, maybe to be fixed in future that it works without having to enter the menmonics)

### for validator accounts

```
# from any directory
export NODE_ENV=prod
tower -o start
```

WARNING: If you don't set node env as above, you will generate a "test" proof, which takes 1 second. If that happened, delete ~/.0L/vdf_proofs/proof_1.json (and any other blocks made, but NOT proof_0.json) and resume with `NODE_ENV=prod`.

## Check mining state

After a block gets submitted (or after a crash in case of block_1), you can from another terminal or screen instance connect to the network and query for state. Use these directions to connect a libra client (connect_client_to_network.md) and execute: `node ms <account>`. 

## Using `tmux`
IMPORTANT: if you would like to exit the `tmux` but keep the tower app working, (tower to run in the background) you must "unhook" your terminal from the screen instance.
unhook the terminal with key strokes:
`ctrl+b, d`.

This will take you back to the terminal from before your entered `tmux`.

To return to tmux and the background tower tasks, you can reattach to the screen with 
```
tmux a -t tower
```
