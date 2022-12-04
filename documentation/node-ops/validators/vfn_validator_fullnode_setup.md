## Validator Fullnode



In your validator.node.yaml:

```
full_node_networks:
  - listen_address: "/ip4/0.0.0.0/tcp/6181"
    identity:
      type: from_storage
      backend:
        type: on_disk_storage
        path: /home/ubuntu/.0L/key_store.json
        namespace: 4152478106c9080141da1a7176292b8c-oper
      key_name: fullnode_network
      peer_id_name: owner_account
    max_outbound_connections: 0
    network_id:
      private: "vfn"
    mutual_authentication: false
```

in your vfn.node.yaml

```
base:
  data_dir: "/home/ubuntu/.0L/"
  role: "full_node"
  waypoint: 
    from_config: "12432327:528c9774b172c07c7908c0bedc8259b3d620213b780eb15c5e680362ad2d4a88"
execution:
  genesis_file_location: ""
full_node_networks:
  - discovery_method: "onchain"
    listen_address: "/ip4/0.0.0.0/tcp/6179"
    network_id: "public"
    max_inbound_connections: 100
    seed_addrs:
      0790D40397E7CAE291D235D73406593C:
        - /ip4/23.251.145.225/tcp/6179/ln-noise-ik/3dc2f343e3aae691f1a26c613c1cad3f04105741cf594d77fc7c439b63049805/ln-handshake/0
      BD69BD2D1946419A878723869789BB0D:
        - /ip4/202.182.125.18/tcp/6179/ln-noise-ik/6c8ab0b3a433f9ba2f4a11a4f831cc100d6641ac39b0181947027ca28eb4051a/ln-handshake/0
      D275B9DA59F17F8C0D3231322E6E5014:
        - /ip4/35.230.7.230/tcp/6179/ln-noise-ik/d578327226cc025724e9e5f96a6d33f55c2cfad8713836fa39a8cf7efeaf6a4e/ln-handshake/0
      29A38825D33A6E3A0CB7DC58BD240921:
        - /ip4/167.172.248.37/tcp/6179/ln-noise-ik/f2ce22752b28a14477d377a01cd92411defdb303fa17a08a640128864343ed45/ln-handshake/0
      49B3B35653680B0C1EEEE7C04FC1846A:
        - /ip4/98.158.184.17/tcp/6179/ln-noise-ik/3dbcb29d8083e28681285e92e2a1ecd37ebd6c559f2056cd9634899a0c789168/ln-handshake/0
      E14CBB40F7A5E4EDA20D6D416AAC2F26:
        - /ip4/157.245.122.242/tcp/6179/ln-noise-ik/8e85a295d9217427eaf30dd552b972e28cc1bf1db9c6e7a6fb12e046677d0424/ln-handshake/0
      4108BCE184D13CBA495D42B85C24A643:
        - /ip4/35.230.40.123/tcp/6179/ln-noise-ik/0f2e8a15abedd16f64d4651e79b572084943bf01a6a49f30928dd9d604790226/ln-handshake/0
      CA81CAADC4251AE817DDE81ED9977035:
        - /ip4/188.166.23.18/tcp/6179/ln-noise-ik/158e00c70b175ad96af7e4bb946a184d54460af39eda9973e6fe8080a1dfed4d/ln-handshake/0
      9FD07DCEE0550061968E4C2213DE730F:
        - /ip4/35.233.185.59/tcp/6179/ln-noise-ik/eac699875537ba2020e1041ec185f3e3dd165623fa31a53bb9ad666a7caefd5f/ln-handshake/0
      4C98C0AFAE08CD1FE26581C3F091083B:
        - /ip4/68.183.61.250/tcp/6179/ln-noise-ik/7cc64629542062aa960a04255e235aaf5fd85991bf49712bcd5a702e07fd8f13/ln-handshake/0
storage:
  address: "127.0.0.1:6666"
  backup_service_address: "127.0.0.1:6186"
  dir: db
  grpc_max_receive_len: 100000000
  prune_window: 20000
  timeout_ms: 30000
state_sync:
  chunk_limit: 250  
json_rpc:
  address: 0.0.0.0:8080
upstream:
  networks:
    - public

```