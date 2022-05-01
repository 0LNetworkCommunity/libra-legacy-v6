import yaml

# read the config from disk
with open("validator.node.yaml", "r") as f:
    yin = yaml.safe_load(f)

# remove fule node network config
# del yin["full_node_networks"]

# disable on chain discovery
yin["validator_network"]["discovery_method"]="none"

seeds='''
D1281DE242839FC939745996882C5FC2:
  addresses:
    - "/ip4/172.31.11.23/tcp/6180/ln-noise-ik/0a3cab5f2ecb29bdb4a9efe1dd4576feacefe4ec74ab7ef65d472bbb4461804d/ln-handshake/0"
  role: "Validator"
012338B54BA4625ADCC313394D87819C:
  addresses:
    - "/ip4/63.229.234.74/tcp/6180/ln-noise-ik/7825869ae4c0cb91bbd8027ce16c64680f84c979320f8921fc76a17c7bec6f32/ln-handshake/0"
  role: "Validator"
012345062CE76E68F1AC6D5506527AA1:
  addresses:
    - "/ip4/63.229.234.75/tcp/6180/ln-noise-ik/877d0ac5434494fad180730aa47198ba979dbb522a93f4de11fd1556554d6330/ln-handshake/0"
  role: "Validator"
D67F3FF22BD719EB5BE2DF6577C9B42D:
  addresses:
    - "/ip4/134.209.114.98/tcp/6180/ln-noise-ik/64b70bfbc19b9f9fb3d36be2d6c7b517911cd334a8fab73ca6275788e6dec761/ln-handshake/0"
  role: "Validator"
7E56B29CB23A49368BE593E5CFC9712E:
  addresses:
    - "/ip4/64.227.6.64/tcp/6180/ln-noise-ik/d4e6a48837ea6f85588cc9d9dafd55434401d3421a51cd8883d98e62df8ae93d/ln-handshake/0"
  role: "Validator"
304A03C0B4ACDFDCE54BFAF39D4E0448:
  addresses:
    - "/ip4/188.166.23.18/tcp/6180/ln-noise-ik/cd8b02613e3cc219d21e31ec53c8aba3568ac7e4b3640fc96b38614636a74e74/ln-handshake/0"
  role: "Validator"
C0A1F4D49658CF2FE5402E10F496BB80:
  addresses:
    - "/ip4/154.53.35.183/tcp/6180/ln-noise-ik/c52844976389ad6262eb09bbcd2681f248f1bdb95337862355b647b84536ad1d/ln-handshake/0"
  role: "Validator"
987BE6E871FAEEDFE255B4305B4C6D02:
  addresses:
    - "/ip4/3.12.14.24/tcp/6180/ln-noise-ik/cb7e573123b67b0bb957d23f0d11c65b0b5438815b3750461c3815d507fb5649/ln-handshake/0"
  role: "Validator"
987D7486A6DB70993EEAB79124BC6606:
  addresses:
    - "/ip4/3.18.120.115/tcp/6180/ln-noise-ik/24221a0b1df03be6ed1269976c88734bf6e027b31be53dc9011063867a516505/ln-handshake/0"
  role: "Validator"
'''

seeds_y = yaml.safe_load(seeds)

# update seeds to new values
yin["validator_network"]["seeds"] = seeds_y

with open("validator.node.yaml.new", "wt") as out_f:
    yaml.dump(yin, stream=out_f)
