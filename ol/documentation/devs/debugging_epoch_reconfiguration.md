There is a simple three step way to check libra logs in a staged environment. Note, compile times remove all the fun of this.

1. Build Move scripts in /stdlib/ as usual `cargo run -- --no-doc`

2. Use libra-swarm to start a new network (of 0 nodes, to easily inspect logs).

Follow instructions here: (swarm_qa_tools.md)

3. Go to logs folder, note the path you passed in step 2 above, usually $HOME/swarm_temp

Look under $HOME/swarm_temp/0/logs/0.log
