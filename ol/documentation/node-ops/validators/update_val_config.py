import yaml

# read the config from disk
with open("validator.node.yaml", "r") as f:
    yin = yaml.safe_load(f)

# remove fule node network config
# del yin["full_node_networks"]

# disable on chain discovery
yin["validator_network"]["discovery_method"]="none"

seeds='''
BA28F081DE02FC6CC3BF9879D6033911:
  addresses:
    - "/ip4/143.198.246.18/tcp/6180/ln-noise-ik/0b9a4aa50102f1d5ec92e6387606dbb0113f733c467e94379fbda14e24abc622/ln-handshake/0"
  role: "Validator"
6A9F0FA0B6BD687F4343D8880B40F697:
  addresses:
    - "/ip4/104.154.197.161/tcp/6180/ln-noise-ik/5383842944072588806676e9433d45ea934eb4f45c734ac0ed1b272d42ab967e/ln-handshake/0"
  role: "Validator"
4C95E7B998B4E66EF666FE12930A4D5C:
  addresses:
    - "/ip4/34.70.87.157/tcp/6180/ln-noise-ik/836219f8733d0c2663c0164568e079dcc0a1e6b24ab5c8bc09e157f17101a202/ln-handshake/0"
  role: "Validator"
7EC16859C24200D8E074809D252AC740:
  addresses:
    - "/ip4/35.231.138.89/tcp/6180/ln-noise-ik/987f636ef651abc3bc0ad1a33ef2e5841768fde064971333059d84442bb3d576/ln-handshake/0"
  role: "Validator"
46A7A744B5D33C47F6B20766F8088B10:
  addresses:
    - "/ip4/35.192.123.205/tcp/6180/ln-noise-ik/da9ea456e1d9f45810669ecfcdb9f75a4d828a7e7a97f68014f47d789972a710/ln-handshake/0"
  role: "Validator"
ECAF65ADD1B785B0495E3099F4045EC0:
  addresses:
    - "/ip4/34.145.88.77/tcp/6180/ln-noise-ik/14680097d0ae4d37158ade5c90da4ce43b13c5dbeb918016f0cc8e9830f54f33/ln-handshake/0"
  role: "Validator"
8186F4D8FDD09DFE02963B0B4C385105:
  addresses:
    - "/ip4/20.39.34.205/tcp/6180/ln-noise-ik/2e7b8c6cf5abff63f88b26bd960e2c586f3723d08c895cc04c5eef3449a3905e/ln-handshake/0"
  role: "Validator"
4B08C148F5E80962BE1E5755F0D2ED29:
  addresses:
    - "/ip4/65.108.73.53/tcp/6180/ln-noise-ik/33ed842980f68a0a78d2d5d240b062c8cae59ebf58b25fa07022fd93133c457a/ln-handshake/0"
  role: "Validator"
E264023342B41ACCDBB61A190B6CB2A7:
  addresses:
    - "/ip4/137.184.118.15/tcp/6180/ln-noise-ik/e41c5b51f18d9826ca23136f0edc442d701c82c246ed1f306ece495e763df823/ln-handshake/0"
  role: "Validator"
1C03E956DD7AFC612E4EFE240C23365D:
  addresses:
    - "/ip4/161.35.228.136/tcp/6180/ln-noise-ik/a08e233ebead3c9467175df8d86a1d9ab46ce0f1c7998bdac59fc58208236837/ln-handshake/0"
  role: "Validator"
56641E58ABA97FA6B7EA833F83444392:
  addresses:
    - "/ip4/82.165.250.66/tcp/6180/ln-noise-ik/6c3f93028522845daaecf17d2c2a1359473435d9491b593e39a8c839371de03e/ln-handshake/0"
  role: "Validator"
D1281DE242839FC939745996882C5FC2:
  addresses:
    - "/ip4/172.31.11.23/tcp/6180/ln-noise-ik/e0f25c377b55581bc2c11fd03cb9ae5eba7ef276e32865d98b3e1b7436fc4020/ln-handshake/0"
  role: "Validator"
012338B54BA4625ADCC313394D87819C:
  addresses:
    - "/ip4/63.229.234.74/tcp/6180/ln-noise-ik/7825869ae4c0cb91bbd8027ce16c64680f84c979320f8921fc76a17c7bec6f32/ln-handshake/0"
  role: "Validator"
987BE6E871FAEEDFE255B4305B4C6D02:
  addresses:
    - "/ip4/3.12.14.24/tcp/6180/ln-noise-ik/cb7e573123b67b0bb957d23f0d11c65b0b5438815b3750461c3815d507fb5649/ln-handshake/0"
  role: "Validator"
D96E89E270A5273D94BC8AB7953754F9:
  addresses:
    - "/ip4/65.108.108.82/tcp/6180/ln-noise-ik/b998763ff5e33ec52baad9d3a3f395451202fee3690c8f98a372fa2c67bcca70/ln-handshake/0"
  role: "Validator"
D1C9CE9308B0BDC6DC2BA6A7B5DA8C2B:
  addresses:
    - "/ip4/34.130.72.87/tcp/6180/ln-noise-ik/6669e2741fe958f94a0a2e4965e7657b904592bb724c3e662d45d091ad473530/ln-handshake/0"
  role: "Validator"
34B5D5E56EC27D954AC5D40B24D11422:
  addresses:
    - "/ip4/104.197.186.76/tcp/6180/ln-noise-ik/c61044a4544c832bd998e0eded2fa7798a8f59b8219e0c9eef718c8b6f804b2a/ln-handshake/0"
  role: "Validator"
A2FAB2DF081CD8FEED7F4D6AD2FFF459:
  addresses:
    - "/ip4/176.9.114.29/tcp/6180/ln-noise-ik/863f660ff03a2fdc8ef3e1bf7eaf2f7f127d5bdb709a8c6af3218a09e27a790d/ln-handshake/0"
  role: "Validator"
9A710919B1A1E67EDA335269C0085C91:
  addresses:
    - "/ip4/24.229.105.9/tcp/6180/ln-noise-ik/3c37c7d6a5122a6b9ef07a11cc40e445874eb0841ae028d6326bf67768cce235/ln-handshake/0"
  role: "Validator"
B5B5BA58B8E9916FE449D1F989383834:
  addresses:
    - "/ip4/159.223.49.139/tcp/6180/ln-noise-ik/c1954be575981591f2eabd67913c839657ac45a866b15bff40b5d80eb4d82778/ln-handshake/0"
  role: "Validator"
'''

seeds_y = yaml.safe_load(seeds)

# update seeds to new values
yin["validator_network"]["seeds"] = seeds_y

with open("validator.node.yaml.new", "wt") as out_f:
    yaml.dump(yin, stream=out_f)
