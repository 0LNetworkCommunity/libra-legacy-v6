# Requirements to enter the active validator set

To enter the active validator set on epoch _A_ one must check these requirements on epoch _A-1_:

1. Onboarding - Being onboarded by a validator (as before) ;
2. Proofs - Submit at least 8 proofs (as before) ;
3. Vouches [NEW] - Collect at least 4 vouches from active validators from different family ancestry ;

    - The Vouching System:
The new vouching system is a lever for active validators to express an opinion on who should or should not be in the active set based on their own criteria. 
This will hopefully be beneficial for the network where active validators will endorse contributors, people with special skills or equipments for the well-being or improvments of 0L. 
The vouches also allow some kind of weak security against sybils. For an example of what exising validators might look for when deciding to vouch for a new validator, see [these requirements](https://hackmd.io/-Zi5b2HTT46FxHGWW5nSlw).

    - Family ancestry:
One must collect at least 4 vouches from 4 different families.
A family is defined as accounts sharing common ancesters. 

    - The command to provide to voucher ```txs vouch --address <<<YOUR_ADDRESS>>>``` 
    
    - The command to see your collected vouches ```cd ~/libra && cargo r -p diem-transaction-replay -- --db ~/.0L/db annotate-account <<<YOUR_ADDRESS>>>```

4. Tower Height - Be one of the validators with the highest tower height among validators who have met the other five criteria in this list;
5. Voting Power - At the time of writing, the validator set can inflate of 15% maximum. Therefore, if more validators verify the requirements, the validators with the most voting power will pass in the active set first.

For example, if only three validators will be admitted at the epoch change, the 3 validators who have been onboarded, submitted 8 proofs, collected 4 vouches and have the highest tower height and greatest voting power will be admitted into the set.

Additional resources to bring - 

- An existing validator back into the active set, see [here](https://hackmd.io/F1gSIRn8TLubg8i3TG_gpA).
- A new validator online, see [here](https://docs.google.com/document/d/1sAyX04cfWeUtEnWsm9ezsjQgkjE5SVstc2Z4nRtZFJM/edit).

# To stay in the active set

All active validators MUST keep satisfying the requirements of entry, otherwise it will drop off the active set. 
In addition, the active validators must vote at least on 5% of the blocks during the epoch. If one validator fails to vote enough, it will drop.

# Inactive validators

All validators (active AND inactive) are paying a fee called '_cost to exist_' for the _privilege_ of being a validator.
The cost is 50% of the validator payment, for example, let's assume validator are being paid 20k coins every validator will pay 10k at the begining of the epoch.
Therefore, inactive validators will be paying the 'cost to exist' fee but not receiving the payment for not being active.

# Cost To Exist

Validators, whether active or inactive, burn a set amount of coins at the start of the epoch. For 0L system burns, a user can set their burn preferences, whether to be a pure burn, or recycle the coins to community wallets.

If the choice is to send to community wallets, an algorithm is used based on the time-weighted donations to those wallets. In practice, community wallets that receive the most donations (autopay or direct) will also receive a greater share of the recycled burns.

The details are here: https://github.com/OLSF/libra/blob/main/ol/documentation/accounts/match_burn.md
