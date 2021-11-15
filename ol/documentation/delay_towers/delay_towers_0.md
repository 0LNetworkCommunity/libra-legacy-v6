<h1>Delay Towers - Part 0 </h1>
<h2> A high-throughput chain with a fair launch </h2>

[Part 0 - A high-throughput chain with a fair launch ](./delay_towers_0.md)

[Part 1 - Puzzle Towers for BFT](./delay_towers_1.md)

[Part 2 - From Puzzle Towers and VDFs to Delay Towers](./delay_towers_2.md)

[Part 3 - A Delay Towers Implementation on BFT](./delay_towers_2.md)

<h2>TL;DR </h2> 

A fair launch of a high-throughput layer-1 blockchain is happening. 
<p>
You won't need to buy anything or otherwise pay a centralized organization for access. The goal is to create a new standard in blockchain bootstrapping through Delay Towers.
</p>

<p>
There's a new layer-1 chain that wants to exist. It wants to have these characteristics:
<li> - High-throughput </li>
<li> - Faster finality time </li>
<li> - Fair launch </li>
<li> - Establishing a persistent identity </li>
<li> - Permissionless access </li>
<li> - Engender decentralization </li>
<li> - Regulatory certainty </li>
</p>


<p>
Centralized launches of Proof of Stake networks are an unsatisfactory strategy for bootstrapping a community-led public good. No disrespect meant to projects that have launched in such a way, there was just no credible technical alternative, possibly until now.
</p>

<h2>
The Tradeoff
</h2>

<p>
If you are looking for a blockchain with fast finality, you are likely evaluating a derivative of the Byzantine Fault Tolerance (BFT) consensus system. Research on BFT consensus has progressed from designs requiring multiple rounds of communication to finalize a block, up to the latest breakthroughs of "consensus linearity" and "pipelining", which produce systems where the throughput is limited only by the network connection latency.
</p>

<p>
To achieve the benefits of BFT, the networks require establishing identities for validators to participate in the
consensus protocol. Currently, most blockchains rely on either of these: Proof of Authority (PoA) for private consortia and Proof of Stake (PoS) for permissionless environments. PoA lacks credible neutrality due to centralized validator membership control, and PoS suffers from a lack of diversity of participants and high inequality while raising numerous significant regulatory concerns. The novel Delay Towers are an alternative mechanism to establish persistent identity in permissionless environments.
</p>


<h2>
Delay Towers
</h2>

<p>
Delay Towers are a Proof of Elapsed Time to build persistent identities. Drawing inspiration from the paper
<a href="https://docs.google.com/document/d/1eRTAe3szuIoZEloHvRMtZlrU7t2un4UVQ8LarpU3LNk/edit?usp=sharing"> "Sybil-resistant network identities from dedicated hardware" </a> by Dominic Williams, the proposed design extends the idea of "puzzle towers"
with  <a href="https://eprint.iacr.org/2018/601.pdf"> Verifiable Delay Functions (VDFs) </a> VDFs are cryptographic primitives for providing a guarantee that a lower bound of time has elapsed.
</p>

<p>
In this protocol every node in a network has a Delay Tower, which is composed of linearly chained proofs. A chain of Delay Tower blocks produces a guarantee of cumulative work done by a node in the network. Each proof extends from the previous one (using one proof as the preimage to the next block), building the tower "higher"; creating a series of sequential proofs of work. Unlike traditional Proof of Work puzzle algorithms that are parallelizable and probabilistic, "mining" a Delay Tower is sequential and deterministic. Since VDFs cannot be parallelized, they do not benefit significantly from alternative hardware such as GPUs. The delay towers enable persistent identities by providing a permissionless and non-forgeable identity for miners.
</p>


<p>
Delay Towers establish an identity for miners, and can be used as a metric to quantify a node's commitment to a network, and subsequently rank it for the purpose of choosing inclusion in the validator quorum at every epoch. This is achievable, in part due to a significant cost to participate in the network. One has to dedicate resources to build their towers and a high exit penalty to recreate their identity due to lost work. And the cost goes up over time as all nodes continue to extend their towers.
</p>

<p>
It is not feasible to apply infinite money or resources to forge a tower, the time taken cannot meaningfully be reduced. A forgery will take approximately the same amount of time as the original. As such, a Delay Tower becomes a permissionless and non-forgeable identity that is fast to verify; valuable in its own right.
</p>


<h2>The Experiment</h2> 
<p>
An experimental network ran successfully for nearly 1 year without interruption. It used a Delay Tower protocol for assigning consensus power for a modern BFT blockchain architecture.

This is the first publication in a series of articles which will summarize the protocol, and discuss the attractive features that were observed in the experiment, such as:
</p>


<li> - Providing persistent identity which aids in Sybil resistance in BFT consensus. </li>
<li> - Offer a more diverse distribution than usual, to anyone with minimal computational resources. </li>
<li> - Levelling the playing field, with a linear function the advantage of the miners at genesis goes down over time.</li>
<li> - With minimal computations and no wasted cycles, delay towers offer an eco-friendly alternative to PoW approaches.</li>
<li> - Offering a mechanism to bootstrap a BFT network without selling tokens (ICOs), venture-backed foundations, or airdrops. </li>

<h2>To be continued</h2>

<p>
Instructions for mining the new chain will materialize in the coming weeks.
</p>
