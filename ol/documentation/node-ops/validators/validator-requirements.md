# Requirements to enter the active validator set

To enter the active validator set on epoch _A_ one must check these requirements on epoch _A-1_:
- Being onboarded by a validator (as before) ;
- Submit at least 8 proofs (as before) ;
- [NEW] Collect at least 4 vouches from active validators from different family ancestry ;
  - The command to provide to voucher ```txs vouch --address <<<YOUR_ADDRESS>>>``` 
  - The command to see your collected vouches ```cd ~/libra && cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account <<<YOUR_ADDRESS>>>``` 

At the time of writing, the validator set can inflate of 15% maximum. Therefore, if more validators verify the requirements the validators with the most voting power will pass in the active set first. 

### The Vouching System
The new vouching system is a lever for active validators to express an opinion on who should or should not be in the active set based on their own criteria. 
This will hopefully be beneficial for the network where active validators will endorse contributors, people with special skills or equipments for the well-being or improvments of 0L. 
The vouches also allow some kind of weak security against sybils. 

### Family ancestry
One must collect at least 4 vouches from 4 different families.
A family is defined as accounts sharing common ancesters. 


# To stay in the active set

All active validators MUST keep satisfying the requirements of entry, otherwise it will drop off the active set. 
In addition, the active validators must vote at least on 5% of the blocks during the epoch. If one validator fails to vote enough, it will drop.

# Inactive validators

All validators (active AND inactive) are paying a fee called '_entry fee_' for the _privilege_ of being a validator.
The entry fee is 50% of the validator payment, for example, let's assume validator are being paid 20k coins every validator will pay 10k at the begining of the epoch.
Hence, inactive validators will be paying the entry fee but not receiving the payment, in other words, inactive validators will be penalized for not being active.
