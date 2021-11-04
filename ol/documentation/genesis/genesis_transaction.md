# Quick Start

```
# make sure you have a set_layout.toml in ~/.0L/
# from project root:

NODE_ENV=prod make stdlib genesis
```
# Genesis Transaction

Once the registration period has closed, all participants must create a genesis block themselves before starting validators nodes. *No genesis transaction will be provided by a central party.*

Additionally, no validator set will be selected by any one party. All participants will choose the registrants they wish to include in the genesis validator set. *No validator layout file will be provided*

## Outputs

The output of the genesis process is a `genesis.blob` which is the initial network block. Additionally a `validator.node.yaml` file is created which contains all the configurations necessary to start a validator node (using the genesis.blob above).


## Decentralized start

In effect each participant chooses the list of validators that they wish to start a network with. 

There is no canonical network defined in the tooling or infrastructure. Multiple networks are possible given a genesis registration repository.

All the validators which start their nodes from identical genesis blocks will form a network together.


## The layout file

The validator set is defined by a "layout file".

Different layout files *will generate different genesis blocks*, and resulting networks would be separate.

To create a genesis block, a list of validators needs to be processed by the diem-genesis-tool. This creates the initial transactions to create a validator set, and the first block.

The file that is needed is `set_layout.toml` and is has a format:
```
owners = [
  "4C613C2F4B1E67CA8D98A542EE3F59F5",
  "88E74DFED34420F2AD8032148280A84B",
  "E660402D586AD220ED9BEFF47D662D54",
]
operators = [
  "4C613C2F4B1E67CA8D98A542EE3F59F5-oper",
  "88E74DFED34420F2AD8032148280A84B-oper",
  "E660402D586AD220ED9BEFF47D662D54-oper",
]
```

For every `owner` there is an `operator` and the owners and operators need to match folders in the GENESIS_REPO after the completion of registration.

If an element of the owner or operator list cannot be found in the genesis registration repo, then the program will exit without producing a genesis transaction.


# Create genesis files

From the project root you can use the `make` helper file:

The Move framework and standard library should be compiled before this step.

```
NODE_ENV=prod make stdlib genesis
```