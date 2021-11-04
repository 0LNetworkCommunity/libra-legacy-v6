# Running Tower: ie. Mining VDF proofs

These instructions are to run the 0L `tower` app. This creates VDF proof of work, and submits to the chain sequentially.

This documentation uses screen as terminal multiplexer, sure you can also use tmux or run it in a normal terminal session. 

## Start a `screen` or `tmux` instance

Make `screen` work for backgrounding and resuming sessions:
```
screen -S tower
```
note: you may want to use separated `screen` instances for different purposes like `screen -S node` for doing node configuration.

## Confirm the files

you should have 
- ~/.0L/vdf_proofs/proof_0.json
- ~/.0L/key_store.json
- ~/.0L/0L.toml

## Resume the tower app
The tower app will resume mining. The first block to be created is proof_1.json (which takes as the preimage input the sha256 hash of proof_0.json)

From your `screen` instance you can run:
```
# from any directory
export NODE_ENV=prod
tower -o start
```
WARNING: If you don't set node env as above, you will generate a "test" proof, which takes 1 second. If that happened, delete ~/.0L/vdf_proofs/proof_1.json (and any other blocks made, but NOT proof_0.json) and resume with `NODE_ENV=prod`.

## Check mining state

After a block gets submitted (or after a crash in case of block_1), you can from another terminal or screen instance connect to the network and query for state. Use these directions to connect a libra client (connect_client_to_network.md) and execute: `node miner_state <account>`. 

## Using `screen`
IMPORTANT: if you would like to exit the `screen` but keep the tower app working, (tower to run in the background) you must "unhook" your terminal from the screen instance.
unhook the terminal with key strokes:
`ctrl+a, ctrl+d`.

This will take you back to the terminal from before your entered `screen`.

To return to screen and the background tower tasks, you can reattach to the screen with 
```
screen -r tower
```


### Common issues with screen:

If you ran screen multiple times with the same socket name `ol` you might find there are multiple `screen` instances running, and you may not know which has the `tower` instance you are expecting. You may prefer to stop all instances, and then create a new one, and start mining again.
```
# see the screen processes running
screen ls
# kill all the processes
killall screen

# you can resume instructions above.

```