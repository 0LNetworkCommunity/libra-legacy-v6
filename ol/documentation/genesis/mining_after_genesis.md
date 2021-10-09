# Resume building tower after genesis

1. copy any existing `block_x.json` files into `~/.0L/blocks/``
2. build binaries
```
cd libra/
make bins
```
3. start tower app
NOTE: `miner` binary has been renamed `tower`

preferably start as validator (enter mnemonic)
```
tower start

```

or start without needing to enter menomic

```
tower -o start

```