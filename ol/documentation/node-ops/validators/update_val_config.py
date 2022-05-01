import yaml

# read the config from disk
with open("validator.node.yaml", "r") as f:
    yin = yaml.safe_load(f)

# remove fule node network config
# del yin["full_node_networks"]

# disable on chain discovery
yin["validator_network"]["discovery_method"]="none"

seeds='''
4B08C148F5E80962BE1E5755F0D2ED29:
  addresses:
    - "/ip4/65.108.73.53/tcp/6180/ln-noise-ik/33ed842980f68a0a78d2d5d240b062c8cae59ebf58b25fa07022fd93133c457a/ln-handshake/0"
  role: "Validator"
46A7A744B5D33C47F6B20766F8088B10:
  addresses:
    - ""
  role: "Validator"
46A7A744B5D33C47F6B20766F8088B10 --- OD2:
  addresses:
    - ""
  role: "Validator"
46A7A744B5D33C47F6B20766F8088B10 --- OD3:
  addresses:
    - ""
  role: "Validator"
E264023342B41ACCDBB61A190B6CB2A7:
  addresses:
    - "/ip4/137.184.118.15/tcp/6180/ln-noise-ik/e41c5b51f18d9826ca23136f0edc442d701c82c246ed1f306ece495e763df823/ln-handshake/0"
  role: "Validator"
8186F4D8FDD09DFE02963B0B4C385105:
  addresses:
    - "/ip4/20.39.34.205/tcp/6180/ln-noise-ik/2e7b8c6cf5abff63f88b26bd960e2c586f3723d08c895cc04c5eef3449a3905e/ln-handshake/0"
  role: "Validator"
D96E89E270A5273D94BC8AB7953754F9:
  addresses:
    - "/ip4/65.108.108.82/tcp/6180/ln-noise-ik/b998763ff5e33ec52baad9d3a3f395451202fee3690c8f98a372fa2c67bcca70/ln-handshake/0"
  role: "Validator"
63BB637E57BF088B129BCF1BFD93EBF4:
  addresses:
    - "/ip4/65.108.122.162/tcp/6180/ln-noise-ik/7e34a17c9e09fe733d471b86e3db6150f1d9d71a04d30a4dbb2344de2bb9b154/ln-handshake/0"
  role: "Validator"
351F3C360630F790DE10570C0A224B06:
  addresses:
    - "/ip4/65.108.195.43/tcp/6180/ln-noise-ik/d0f0d094564779a31a8ce36d572e68485a9f57263420234695579e16b5d9d031/ln-handshake/0"
  role: "Validator"
79D2A77B01E5CDE1A5FB123119424ACB:
  addresses:
    - "/ip4/65.108.143.43/tcp/6180/ln-noise-ik/ab89d9487f1b7d431409d46aca57e2d884760a3730c75f34cdb441ea62c86e6c/ln-handshake/0"
  role: "Validator"
E77DDB76C9AFCB3D5511E46CBC89023D:
  addresses:
    - "/ip4/144.126.245.86/tcp/6180/ln-noise-ik/ce7168ac62fde698c34d2e7b968f8b7b4be7cce221829dbcc3761fdf1aefaf70/ln-handshake/0"
  role: "Validator"
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
