# Running 0L validator as a system service
This guide will create a daemon service which runs `libra-node` and restarts on failure and on reboot. 

Note that this guide:
- targets Ubuntu 20.4.
- assumes you have set up your environment correctly (see util/setup.sh).
- does not provision the `miner` service which is a separate concern from `libra-node`.

# Background
`systemd`, is a linux utility for managing long-running services on linux. The validation service (`libra-node`) is one such long running service. The `miner` is another, but that is out of scope for this doc.

There are a few file paths you will be working from:

- `~/.0L/` will contain the node configurations
- `~/<project root>/libra-node`: contains the source code
- `~/<project root>/target/release`: will contain binaries produced by cargo

# Quick Start

This will use a `make` recipe to start the node daemon and install the daemon configs.

First. Copy a template for systemd from `<project root>/util/libra-node.system.template` into your 0L home path, usually `~/.0L`. There are two templates for running as `root` or with a `user`. Note that the non-root template file needs to be edited: replace occurrences of `[USER]` with the username under which the service will run.

Then the makefile can do a number of things including coping that file to the usual place, and then (re)starting the service.

From the project root:

`make daemon`

# Slow Start

## Build binaries and copy to appropriate path
Use `make bins` or alternatively:


`cargo build -p libra-node --release && sudo cp -f ~/libra/target/release/libra-node /usr/local/bin/libra-node`

## Validator Wizard

If your config files have not been created or misplaced run:
`cargo run -p miner -- val-wizard`

## Create the service configurations for Systemd
cd /lib/systemd/system/
vim miner.service

```
[Unit]
Description=Libra Node Service

[Service]
#File descriptors frequently run out
LimitNOFILE=65536
WorkingDirectory=/root/.0L
ExecStart=/usr/local/bin/libra-node --config /root/.0L/node.yaml

Restart=always
RestartSec=10s

# Make sure you CREATE the directory and file for your node.log
StandardOutput=file:/root/logs/node.log
StandardError=file:/root/logs/node.log

[Install]
WantedBy=multi-user.target
Alias=libra-node.service
```
### NOTE: When you update any `*service` file, you must reload `ststemctl`
`systemctl daemon-reload`


# Shortcuts 

### Watch libra-node logs

You can follow the logs by simply tailing the logs file.

`tail -f ~/logs/node.log`

### Start the new service
`make daemon` or manually:

`systemctl start libra-node.service`

### Stop the new service
`make stop` or manually:

`systemctl stop libra-node.service`

### Enable the new service to start on boot
`systemctl enable libra-node.service`

### Check status of the new service
`systemctl status libra-node.service`

if you have been successful when you run you will see:
```
● libra-node.service - OL Node Service
   Loaded: loaded (/lib/systemd/system/libra-node.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2020-06-23 16:06:38 UTC; 10min ago
 Main PID: 15499 (libra-node)
    Tasks: 1 (limit: 4915)
   CGroup: /system.slice/libra-node.service
           └─15499 /usr/local/bin/libra-node --config /root/.0L/node.yaml
```


### Set up proper logging

Logs are being written to a flat file. This is not ideal. You may want to configure `journalctl`.

https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs

