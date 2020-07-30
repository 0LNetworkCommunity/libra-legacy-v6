# Debug-net Environments:

Note: set_layout is already in the OLSF/test-genesis repo.

From libra/my_config:
Build the environment:

- make install

Clear the local data and register a validator to ceremony.
- make register NAME=<first name>

// TODO: need a command to reset the key_store.state of the waypoint and voting history.

Build genesis, waypoint, and node.config.toml
- make genesis NAME=<first name>

Start a node
- make start

# Debug-net fixtures:

## miner: 0

namespace:zaki

mnemonic: average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice

address:402e9aaf54ca8c39bab641b0c9829070

// NOTE DOES NOT MATCH
auth_key:9336f9ff1d9ea89f6872517b1919fea147693aa1c2ccb3e32c2d9fe224faf1fc

ip: 192.241.147.210

##  miner: 1

namespace: lucas

mnemonic: owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city

address:5e7891b719c305941e62867ffe730f48

auth_key:200eaeef43a4e938bc6ff34318d2559d5e7891b719c305941e62867ffe730f48

ip: 104.131.20.59

## miner: 2

namespace: sha

mnemonic: motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day

address: b2f38139f75a271fd8f8fae4a87c2679

auth_key: edb1e1423793ebdd7ef184b1a21667059739b1548df3149b2a2a5f1ea7cafd29

ip: 64.227.20.31

## miner: 3

namespace: keerthi

mnemonic: advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power

address: 027c83aeb3b9c085f5a1506b418d08cf

auth_key: fceea8f54505869796f6d7cba94d8e3e105c0b6ea8ff89b8736437409a6fee60

ip: 157.245.133.106


# Connect network With Remote client

1. Start cli

```
cli -u http://157.245.133.106:8080 --waypoint 0:8859e663dfc13a44d2b67b11bfa4bf7679c61691de5fb0c483c4874b4edae35b
```
Note: if you don't know the RIGHT waypoint, you can use above one to start first and get the RIGHT one by runing:
```
libra% q b 027c83aeb3b9c085f5a1506b418d08cf
[ERROR] Failed to get balances: Waypoint value mismatch: waypoint value = 8859e663dfc13a44d2b67b11bfa4bf7679c61691de5fb0c483c4874b4edae35b, 
given value = 59515aa3e6e416a7138dc2d3c81defb95e03aa68657bd9910a0d2e89d342637c
```
the restart cli with `--waypoint 0:59515aa3e6e416a7138dc2d3c81defb95e03aa68657bd9910a0d2e89d342637c`

2. Query Balance
```
libra% query balance 402e9aaf54ca8c39bab641b0c9829070
[ERROR] Failed to get balances: No account exists at 402e9aaf54ca8c39bab641b0c9829070
libra% query balance 5e7891b719c305941e62867ffe730f48
[ERROR] Failed to get balances: No account exists at 5e7891b719c305941e62867ffe730f48
```














