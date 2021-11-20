# How to Configure Web Monitor

## Why
When you operate a full node or validator node you might be interested in a monitoring tool which shows the current node status accessible by your web browser.

## How to set up

After your node is set up and you already have a $HOME/.0L directory, you have to install the static web files there:

```
cd $HOME/libra  # the directory where you checked out the source
make web-files
```

You might verify that a new directory has been created $HOME/.0L/web-monitor

## How to start it

It is strongly recommended to let the web-monitor run in a tmux session, as also done for the diem-node and tower app:

```
tmux new -t monitor
```

Start the web monitor in this tmux session by the following command:

```
ol serve -c
```

## How to access it

Once the web monitor is running, you can access it in your browser at the following URL:

```
http://<your-ip-address>:3030
```

