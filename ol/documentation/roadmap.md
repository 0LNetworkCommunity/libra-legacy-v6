# Roadmap

### V.5.0.0 + 

###  Future

1. Cross chain prototype (ZM)
   1. Move Contracts (LG)
   1. Orchestration
   1. Solidity gravity contracts

1. Metamask wallet plugin (AS)

1. On-chain upgrade that alters state
   1. State migration for breaking changes to struct schema.
   1. Upgrade procedure for new modules and functions.
   1. Utilize “migration” pattern with rollback from traditional software development

1. Changes Validator logic to Operator logic (LG)
   1. Subsidy to adjust based on Operator count (not validator) (LG)

1. Decentralized Module Publishing
   1. Rights to upgrade to be distributed to accounts
   1. Accounts with decentralized publishing enabled, registered to 0x0
   1. Oracles execute decentralized publishing

1. Proof of weight consensus changes
   1. Delegation of tower height
   1. Should remove any scalability constraints associated with VDF


# Done

### v4.2.7

1. Fullnode configs for jailed validators to recover. (SM)
1. Complete comprehensive testing of auto-pay. (AD)
1. Onboarding new validators (LG)
   1. Miner cli polish
   1. (ZM) update validator config ip address encryption

### v4.2.8

1. Withdraw limits for transfer of gas (KN)
   1. Upgrade of stdlib LibraAccount

### v4.3.0

1. Jail refactor https://github.com/OLSF/libra/pull/350

1. Onboarding Moonshot https://github.com/OLSF/libra/projects/7

1. Autopay v2 escrowing
   1. Use account withdraw limits
   1. Separate funds into escrow
   1. Deduct from escrow at limit, evert tick

1. ZKP module (Gokhan, Shiquan)

1. Changes to Wallets
   1. Slow Wallet tag
   1. Community Wallet logic

1. Genesis from archive
   1. create a genesis blob from epoch snapshot
   1. modify snapshot to update state before saving genesis.
  
### v5.0.0
1. Merge Upstream 1.3.0
   1. Package 0L changes as a module
   1. Regex libra->diem

1. Packaging of non-stdlib smart contract (module) - Documentation (AD)

1. Audit (JM)
   1. Audit of v5 Move contracts.
   1. Formal verification of access control to functions.
