# Start a full node

# Things you will need:

- A unix host machine, with a fixed IP address
- The fixed IP address of the machine
- Recommended minimum specs: 
  - 256G storage, 2 core CPU, 8G RAM
- Firewall rules:
  - Open the ports: 8080

## 1. Set up a host
These instructions target Ubuntu.

1.1. Set up a cloud service you have `ssh` access to. 
1.2. You'll want to use `screen` (or `tmux`) to persist the terminal session of the building. `screen -S build`, then you can rejoin the session with `screen -rd build`
1.3. Clone this repo: 

`git clone https://github.com/OLSF/libra.git`

1.4. Config dependencies: 

```
cd </path/to/libra/source/>

. ol/util/setup.sh
```

1.5. Build the source and install binaries:

```
cd </path/to/libra/source/>

make bins install
```

## 2. Catch-up to the network state, with a `fullnode`

You do not need an account for this step, you are simply syncing the database.

2.1. Restore from most recent backup in epoch-archive: `ol restore`

2.2. Run the node (remember to do it in a `screen` or `tmux` session): `diem-node --config $HOME/.0L/fullnode.node.yaml`


More details in: [syncing_your_node.md](syncing_your_node.md)

## 3. Set up web monitor

Optionally you can set up the web monitor to have easy access to server status via your web browser:

[Set up web monitor](validators/web_monitor.md) 

