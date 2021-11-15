
<h1>Part 3 - A Delay Towers Implementation on BFT</h1>

[Part 0 - A high-throughput chain with a fair launch ](./delay_towers_0.md)

[Part 1 - Puzzle Towers for BFT](./delay_towers_1.md)

[Part 2 - From Puzzle Towers and VDFs to Delay Towers](./delay_towers_2.md)

[Part 3 - A Delay Towers Implementation on BFT](./delay_towers_2.md)

<h2>TL;DR</h2>
<p>
Delay towers provide many benefits to BFT networks, including diverse distribution of participants, Sybil resistance, eco-friendliness, determinism, and others. This post delves into one specific implementation of delay towers and its integration with a high-throughput BFT network for bootstrapping purposes, and offers it as a strategy to achieve the goals of a free and fair chain launch.
</p>

<h2>Context</h2>
<p>
If you followed the previous parts, you'll recall that we are using delay towers to bootstrap a new blockchain with the following properties:
</p>
<ul>
<li>High-throughput</li>
<li>Fast finality time</li>
<li>Fair launch</li>
<li>Permissionless access </li>
<li>Engender decentralization with equitable distribution</li>
</ul>
<p>
	A blockchain protocol can use delay towers to establish persistent identity for the nodes as a Sybil resistance mechanism. Delay towers serve as a proof of elapsed time (PoET) to complement BFT consensus, providing a mix of security and performance benefits that PoS ordinarily provides while preserving regulatory benefits of PoW and lowering barriers to distribution. This post delves into one specific implementation of delay towers to envision how all the pieces of delay tower and BFT fit in. 
</p>

<h2>Delay Towers Implementation</h2>
<h3>VDF Implementation</h3>
<p>The growing demand for VDFs for applications, such as randomness beacons, has led to various implementations of VDFs. The current protocol uses Chia's VDF implementation. Chia sponsored some of the early work around VDFs and has an actively deployed open-source implementation with benchmarking. Another notable implementation is Stark VDFs that use computational integrity proofs such as Starks, pioneered by Starkware with VeeDoo service on Ethereum. Other VDFs include RSA moduli and trusted setups which are yet to be deployed in the wild.
</p>
<h3>Anatomy of a Delay Tower</h3>
<p> Nodes run the delay function locally, offline, using the "tower-builder" application to produce a <i>proof_0</i> file. The proof file consists of:</p>
<ul>
  <li>A Preimage with account authorization key (public key), the chain ID with an arbitrary state of the ledger</li>
<li>The hex encoded bytes of the proof of the delay.</li>
<li>The metadata, such as the delay time.</li>
</ul>
<p>
The preimage serves as the base identity for which the remainder of the delay tower will be referencing. Ultimately the preimage is committed to a chain, and the state machine will verify that the preimage belongs to an account on the chain.
</p>
<p>
All the subsequent proofs will use the preceding proof's SHA256 hash as an input for evaluating their delay functions; the "tower-builder" application builds new proofs on top of existing proof to grow the delay tower. Each new block is then submitted to the chain ("committed"), and thus verified as (A) being a valid proof of elapsed time and (B) being contiguous with the previous proof committed to the chain - thus giving a linear path back to the original preimage. The proofs do not need to be stored on chain after they have passed those two approvals. Only the current proof's hash needs to be persisted on the chain, in anticipation of the next proof which will be verified. 
</p>
<p>
As for the state of the tower, the delay tower is stored locally on the node as a repository of JSON proof files. Each proof takes approximately 4kB. The tower state lives off-chain, which the user stores on their node and is responsible for backing up. This would allow for the user to replay the entire tower history if there was a need to do so (e.g. using as identity proof on another chain, or in the event of the principal chain's catastrophic failure).
</p>
<p>
That said, additional governance is necessary to prevent outliers from exploiting validator set admission and consensus voting power (as discussed further below). As we've seen, above, the state machine encodes certain rules for the submission of the tower. Upper and lower-bound threshold of proof counts can be employed.
</p>
<p>
For upper bounds, for all accounts on chain (whether a validator or not) the state-machine will outright reject proofs after an excess amount of proofs have been submitted in a given epoch (one day in our case). This is an important check to remove outliers which can happen due to either: Exploits in the cryptography (which as yet undiscovered) or advances in hardware that would allow for order-of magnitude improvement. The upper-bound disincentivizes such investments.
</p>
<p>
Similarly, additional rules exist for a lower-bound. The chain may disconsider "sufficient" proofs as having been submitted for certain cases. For example a minimum number of proofs per epoch would be necessary to join a validator set for the first time, be removed from "jail" for non-compliance, or simply in order to remain in the validator set, etc. This is discussed further, below. While in the experimental network these thresholds are hard-coded and can be changed by protocol upgrades, future implementations can make such VDF thresholds dynamic, varying according to current system state.
</p>
<p>
The description above sketches out the lifecycle of an individual delay tower. Let us examine how it integrates with a BFT blockchain chain.
</p>

<h2>Network Genesis</h2>
<p>
At the genesis of a network, the BFT chain needs a defined set of validators in the system state. Different genesis "ceremonies" are possible in creating BFT networks. In Proof of Authority, a centralized entity simply provides a genesis "layout" with the nodes that are to participate.
</p>
<p>
Coordinating a network genesis such that it is permissionless requires some infrastructure in order for nodes to make themselves candidates for genesis (registration). Usually a Github repo is used for this purpose. Once all the registrations are present, individual node operators will use a layout file with the registrations that they would like to see included in the first block of the network. In the case of using a delay tower, their proof_0 can be included in the registration information.
</p>
<p>
During the registration period, the validators candidates will generate offline and submit proof_0 along with their node configurations (such as network and public keys) to the ceremony repository. After the registration period closes, each node participating in genesis will use a genesis building tool to produce the first block of the network. Note that the genesis block does not need to be produced by one entity, each node in the new network can create the genesis.blob independently for a fully decentralized ceremony. One of the steps of the tool in our case, is to run a VDF "verifier" that confirms that proofs of each registrant  indeed correspond to an expected delay and that the preimage of proof_0 belongs in fact to the registrant. At the end of the process the genesis block for the network is produced. In this proposed implementation, a successful bootstrapping requires neither pre-mining, a coin drop, nor any other means of distributing the necessary starting stake(s).
</p>
<h2>Steady State</h2>
<h3>Onboarding Nodes</h3>
<p>
As in the genesis ceremony, each new prospective validator node (a node that wishes to enter a validator set) needs to submit configuration information to the network. After genesis, the only way of doing this (in any account-based blockchain) is to have an existing account create the new prospective account and optionally, send the configuration information on behalf of the prospective validator. For this to take place, the prospective validator must generate <i>proof_0</i> locally and transmit it (out of band) to an existing account to initialize its configurations. As discussed below, further governance can be added to the account creation, such as requiring these accounts to be created by existing compliant validators, and rate-limiting the account creation by the onboarder account.  
</p>
<p>
	In a single step, one transaction, the onboarder can submit the validator's configuration information and the <i>proof_0</i> (whose delay can be verified on chain via the transaction). Assuming all configuration information is valid (such as network settings) and the <i>proof_0</i> is verified the prospective validator can become a candidate to enter the validator set. 
</p>
<h3>Mining</h3>
<p>The governance can decide at what point the validator can join the validator set. In this proposal, the validator candidate needs to continue to produce proofs for a full day (one epoch) before they are admitted to the validator set.
</p>
<p>
	To grow their delay tower, nodes run a "tower-builder" app. Running the "tower-builder" application is called mining. The tower-builder operates in parallel to other node operations, e.g. the consensus node executable runs in a completely separate process. The tower-builder could in fact be run in a separate environment as the consensus process. 
</p>
<p>
From this point on, the miner is building the delay tower. The miner submits the VDF proofs and the chain state machine verifies the correctness of submitted VDF proofs. However, for the node operator the quantity of proofs must be created within certain thresholds. These thresholds may adapt over time. But on bootstrapping the network, a generous threshold will make allowance for operator's adapting to this system. In this implementation, a minimum of 7 proofs need to be produced per epoch (approx 4 hours of proofs per day as measured on typical cloud hardware), but an upper bound of 72 proofs per epoch (e.g. 20mins per proof continuously running). This range will narrow as more system information is collected from real-world usage. Furthermore these thresholds can be dynamically adjusted, but further research is needed. 
</p>
<p>
As noted in the previous post,  mining delay towers is not the same as PoW puzzles; it is sequential, cannot be parallelized, and has no advantage with heavy computational power. As a result, mining delay towers are indeed very eco-friendly. 
</p>

<h3>Consensus Voting Power</h3>
<p>
The BFT protocol needs a supermajority to reach consensus on block production, and every validator has some "votes" in the consensus, called voting power. In this implementation, the tower height equals the voting power in the consensus. This is a deterministic and straightforward rule that is easy to verify.
</p>
<p>
Over time, the relative linear advantage of an early node decreases, and the marginal difference between a tower starting later, will decrease and voting power becomes more evenly distributed. This could be a benefit over PoS networks where reputation and rewards are directly dependent on the stake.  
</p>
<p>
While a longer discussion is necessary on economics, it should be noted that tower height need not confer any economic advantages besides admission to the validator set. In this design, all the validators in BFT contribute relatively equally, and any major differences are often due to operator error. Hence, there's no need for consensus power to affect rewards for participating in the validator set (as is often the case for PoS).The rewards are shared equally among all the compliant validators. 
</p>

<h3>Cardinality</h3>
<p>
BFT network performance worsens if the cardinality of the validator set is too high; accordingly an upper limit on the validator set is needed. There are upper bounds to BFT network performance; there is a steep dropoff in network latency observed after 128 network nodes in most BFT consensus implementations. Thus the participation in the quorum set needs to be restricted.
</p>
<p>
Different BFT networks use different strategies to select the validator set, these are typically Proof of Stake (as pioneered by Cosmos). Variations incorporating some measure of randomness exist. The simple algorithm is picking the top N validators by Proof of Stake from the list of validator candidates. 
</p>
<p>
Delay towers could provide an alternative. The consensus power, as defined by the delay tower height, can determine the validator set in a direct, observable, and deterministic manner Similar to the rule described above. The Top N validators by tower height gain admission to the validator set. 
</p>
<p>
Again while this is a separate discussion on economics, the design above is not entirely sufficient for game theoretical equilibrium since it would penalize new entrants who may be doing more delay proofs, instead of incumbents who may abandon running the tower-builder. 
</p>
<p>
As mentioned above thresholds can be enforced by the chain. A miner that intends to be part of the validator set needs to mine at least K proofs to state to gain admission in the following epoch. This is true for new prospective validators, as well as the existing validators.
</p>

<h3>Jailing</h3>
<p>
Based on whether the validators are validating blocks (proposing and signing blocks) and/or mining, the validators could fall in one of these categories.
</p>
<table><tr>
<th>Case</th>
<th>Validating blocks</th>
<th>Mining delay tower</th>
<th>Gets reward</th>
<th>Jailed</th>
</tr>
<tr>
<td>1</td>
<td>Yes</td>
<td>Yes</td>
<td>Yes</td>
<td>No</td>
</tr>
<tr>
<td>2</td>
<td>Yes</td>
<td>No</td>
<td>No</td>
<td>No</td>
</tr>
<tr>
<td>3</td>
<td>No</td>
<td>Yes </td>
<td>No</td>
<td>Yes</td>
</tr>
<tr>
<td>4</td>
<td>No</td>
<td>No</td>
<td>No</td>
<td>Yes</td>
</tr>
</table>
<p>
The validators who are not validating blocks are not contributing to the consensus. This will increase latency. For instance, if a failed validator is chosen to propose the next block, the network has a timeout in that round instead of a new block. Even worse, if more than one-third of voting power is not reached, finality is affected.  Therefore, this behavior must be disincentivized, and the validators who do not meet a threshold within an epoch are jailed. Note that the nodes that are not mining are not punished because they are not affecting the network.
</p>

<h3>Rate Limiting Validator Entry</h3>
<p>
The validator’s entry into the network is an attack surface, including possible Sybil attacks. One potential approach, without PoS and an active centralized membership service provider, is to ask all existing validators to vote on the new validator. However, this approach could lead to encouraging validator-wide agreement (politics) for expanding the validator set. As an alternative, every validator could be rate-limited, and only those who are actively contributing (i.e., mining, and voting for 14 epochs) obtain an invite. This invite can be used to onboard a potential validator by initializing their validator configurations and these invites cannot be transferred or accumulated. At any point, there can be no more than one referral for a validator.
</p>
<p>
Assuming no more than one-third of validators are malicious, as the network grows from a seed root of trust (as all blockchains do), the damage a Sybil can conduct to consensus is limited; the sybil cannot amplify their consensus votes faster than the good actors amplify theirs. Rate limiting also prevents one actor (e.g., a "foundation") from assigning seats in the consensus since they are rate-limited as other actors. 
</p>
<h2>Benefits</h2>
<p>
The implementations above are an experiment; a proposal on how to integrate Delay Towers into networks which typically are PoS or PoA Sybil resistant.
</p>
<p>
To recap: bootstrapping a BFT network with delay towers has multi-fold benefits: 
</p>
<ul>
<li>Delay towers provide an equal playing field by making it hard to repurpose existing hardware, e.g., PoW ASICs.</li>
<li>Bootstrapping a network without external capital or ICOs.</li>
<li>Delay towers offer better distribution by lowering the barriers to entry. Can run on any commodity hardware.</li>
<li>Similar security as PoS network during bootstrapping. With withdrawal limits in place, delay tower height correlates to the stake in native tokens in PoS systems.</li>
<li>Delay towers provide a persistent identity that is hard to forge. </li>
<li>Eco-friendly consensus with minimal energy usage.</li>
<ul>
<li>Determinism and hence, no wasted cycles</li>
<li>Delay towers are sequential and are not parallelizable by nature.</li>
<li>Upper limits on number of accepted proofs per epoch caps the arms race.</li>
</ul>
<li>Economics that are familiar to users of PoS networks. The rewards are distributed similarly to PoS networks, wherein everyone contributing to BFT consensus is rewarded.</li>
</ul>

<h2>Conclusion</h2>
<p>
	Delay towers envision a permissionless, durable, and non-forgeable identity which is fast to verify. This post delves into specifics of productionizing delay towers by integrating them into a BFT network. Delay towers serve as a persistent identity that can be used for consensus power while bootstrapping the network. 
</p>