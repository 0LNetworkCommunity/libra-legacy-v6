//! resfresh peers

use crate::node::node::Node;
use anyhow::{bail, Error};

use diem_genesis_tool::seeds::SeedAddresses;

impl Node {
    /// refresh the fullnode peers, and save to file
    pub fn refresh_fullnode_seeds(&mut self) -> Result<SeedAddresses, Error> {
        let mut seed_addr = SeedAddresses::default();

        self.refresh_onchain_state();
        if let Some(account_state) = &self.chain_state {
            match account_state.get_validator_set() {
                Ok(Some(v)) => {
                    v.payload().iter().for_each(|v| {
                        // let fn_addr =
                        let peer = v.account_address();
                        match v.config().fullnode_network_addresses() {
                            Ok(n) => {
                                seed_addr.insert(*peer, n);
                            }
                            Err(_) => {}
                        }
                    })
                }
                _ => bail!("cannot get onchain validators config"),
            }
        };

        Ok(seed_addr)
    }
}
