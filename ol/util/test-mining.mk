
init:
	cd ~/libra && cargo r -p ol -- --swarm-path ~/swarm_temp --swarm-persona alice init

mine:
	cd ~/libra && cargo r -p miner -- --swarm-path ~/swarm_temp --swarm-persona alice start

create-stage:
	cd ~/libra && cargo r -p txs -- --swarm-path ~/swarm_temp --swarm-persona alice create-validator -f ol/fixtures/account/stage.eve.account.json 

create:
	cd ~/libra && cargo r -p txs -- --swarm-path ~/swarm_temp --swarm-persona alice create-validator -f ol/fixtures/account/eve.account.json 

