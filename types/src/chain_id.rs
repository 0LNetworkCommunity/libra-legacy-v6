// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0
use anyhow::{ensure, format_err, Error, Result};
use serde::{de::Visitor, Deserialize, Deserializer, Serialize};
use std::{convert::TryFrom, fmt, str::FromStr, env};
use once_cell::sync::Lazy;

///////// 0L ////////
/// 
/// for getting chain config from environment variables
/// in 0L abscissa apss this will override the 0L.toml file
/// in vm-genesis this will set the chain configs
pub const ENV_VAR_MODE_0L: &str = "MODE_0L";

pub static MODE_0L: Lazy<NamedChain> = Lazy::new(|| {
  let st = env::var(ENV_VAR_MODE_0L)
    .unwrap_or("MAINNET".to_string());
  NamedChain::str_to_named(st.to_uppercase().as_str())
    .unwrap_or(NamedChain::MAINNET)
});


/// A registry of named chain IDs
/// Its main purpose is to improve human readability of reserved chain IDs in config files and CLI
/// When signing transactions for such chains, the numerical chain ID should still be used
/// (e.g. MAINNET has numeric chain ID 1, TESTNET has chain ID 2, etc)

//////// 0L ////////
/// Node environment modes for compiling, starting, and mining: Mainnet/prod, Testnet, Stage, and Ci
/// See detailed chain defaults in: Globals.Move.
/// MAINNET/prod: is the default. Oracle "tower" mining is difficult. Epochs last one day.
/// Testnet: means a test chain will be started with a Testnet flag: epochs are shorter, difficulty is lower.
/// Stage Has all settings of Prod, but a short 20min epoch.
/// Ci: means that "test" env configs apply, and that any 0L CLIs 
/// can be run without user input: e.g. `onboard --val`

#[repr(u8)]
#[derive(Copy, Clone, Debug, Serialize, PartialEq)] ///////// 0L ////////
pub enum NamedChain {
    /// Users might accidentally initialize the ChainId field to 0, hence reserving ChainId 0 for accidental
    /// initialization.
    /// MAINNET is the Diem mainnet production chain and is reserved for 1
    MAINNET = 1,
    // Even though these CHAIN IDs do not correspond to MAINNET, changing them should be avoided since they
    // can break test environments for various organisations.
    TESTNET = 2,
    STAGE = 3,
    //////// 0L //////// 
    // deprecating unused chain names to simplify environment setting
    // TESTNET = 4,
    // PREMAINNET = 5,
    // STAGE = 6,
    // EXPERIMENTAL = 7, deprecated  
    CI = 4,
}


impl NamedChain {
    pub fn str_to_named(s: &str) -> Result<Self> { //////// 0L ////////
      let s = s.to_string().to_uppercase();
      let n = match s.as_str() {
          "MAINNET" => NamedChain::MAINNET,
          "TESTNET" => NamedChain::TESTNET,
          "STAGE" => NamedChain::STAGE,
          "CI" => NamedChain::CI,
          "1" => NamedChain::MAINNET,
          "2" => NamedChain::TESTNET,
          "3" => NamedChain::STAGE,
          "4" => NamedChain::CI,  
          "PROD" => NamedChain::MAINNET, // graceful transition
          "TEST" => NamedChain::TESTNET, // graceful transition
          _ => {
              return Err(format_err!("Not a reserved chain: {:?}", s));
          }
      };
      Ok(n)
    }


    pub fn str_to_chain_id(s: &str) -> Result<ChainId> { //////// 0L ////////
        Ok(ChainId::new(Self::str_to_named(s)?.id()))
    }

    pub fn id(&self) -> u8 {
        *self as u8
    }

    pub fn from_chain_id(chain_id: &ChainId) -> Result<NamedChain, String> {
        match chain_id.id() {
            1 => Ok(NamedChain::MAINNET),
            2 => Ok(NamedChain::TESTNET),
            3 => Ok(NamedChain::STAGE),
            4 => Ok(NamedChain::CI),         
            _ => Err(String::from("Not a named chain")),
        }
    }

    pub fn is_prod(&self) -> bool {
        *self == NamedChain::MAINNET
    }

    pub fn is_test(&self) -> bool {
        *self == NamedChain::TESTNET
    }

    pub fn is_ci(&self) -> bool {
        *self == NamedChain::CI
    }
}

impl<'de> Deserialize<'de> for NamedChain { //////// 0L ////////
    fn deserialize<D>(deserializer: D) -> Result<NamedChain, D::Error>
    where
        D: Deserializer<'de>,
    {
      let s = String::deserialize(deserializer)?;
      NamedChain::from_str(&s).map_err(serde::de::Error::custom)
    }
}

impl FromStr for NamedChain { //////// 0L ////////
    type Err = Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Self::str_to_named(s)
    }
}
/// Note: u7 in a u8 is uleb-compatible, and any usage of this should be aware
/// that this field maybe updated to be uleb64 in the future
#[derive(Clone, Copy, Deserialize, Eq, Hash, PartialEq, Serialize)]
pub struct ChainId(u8);

pub fn deserialize_config_chain_id<'de, D>(
    deserializer: D,
) -> std::result::Result<ChainId, D::Error>
where
    D: Deserializer<'de>,
{
    struct ChainIdVisitor;

    impl<'de> Visitor<'de> for ChainIdVisitor {
        type Value = ChainId;

        fn expecting(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            f.write_str("ChainId as string or u8")
        }

        fn visit_str<E>(self, value: &str) -> std::result::Result<Self::Value, E>
        where
            E: serde::de::Error,
        {
            ChainId::from_str(value).map_err(serde::de::Error::custom)
        }

        fn visit_u64<E>(self, value: u64) -> std::result::Result<Self::Value, E>
        where
            E: serde::de::Error,
        {
            Ok(ChainId::new(
                u8::try_from(value).map_err(serde::de::Error::custom)?,
            ))
        }
    }

    deserializer.deserialize_any(ChainIdVisitor)
}

impl fmt::Debug for ChainId {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self)
    }
}

impl fmt::Display for ChainId {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{}",
            NamedChain::from_chain_id(self)
                .map_or_else(|_| self.0.to_string(), |chain| chain.to_string())
        )
    }
}

impl fmt::Display for NamedChain {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                NamedChain::MAINNET => "MAINNET",
                NamedChain::TESTNET => "TESTNET",
                NamedChain::STAGE => "STAGE",
                NamedChain::CI => "CI",
            }
        )
    }
}

impl Default for ChainId {
    fn default() -> Self {
        Self::test()
    }
}

impl FromStr for ChainId {
    type Err = Error;
    
    fn from_str(s: &str) -> Result<Self> {
        ensure!(!s.is_empty(), "Cannot create chain ID from empty string");
        NamedChain::str_to_chain_id(s).or_else(|_err| {
            let value = s.parse::<u8>()?;
            ensure!(value > 0, "cannot have chain ID with 0");
            Ok(ChainId::new(value))
        })
    }
}

impl ChainId {
    pub fn new(id: u8) -> Self {
        assert!(id > 0, "cannot have chain ID with 0");
        Self(id)
    }

    pub fn id(&self) -> u8 {
        self.0
    }

    pub fn test() -> Self {
        ChainId::new(NamedChain::TESTNET.id())
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_chain_id_from_str() {
        assert!(ChainId::from_str("").is_err());
        assert!(ChainId::from_str("0").is_err());
        assert!(ChainId::from_str("256").is_err());
        assert!(ChainId::from_str("255255").is_err());
        assert_eq!(ChainId::from_str("TESTNET").unwrap(), ChainId::test());
        assert_eq!(ChainId::from_str("255").unwrap(), ChainId::new(255));
    }
}

#[test] fn read_env() {
    env::set_var(ENV_VAR_MODE_0L, "test");
    assert!(MODE_0L.clone() == NamedChain::TESTNET);
}


#[test] fn read_env_sad() { // somehow can't set twice in test, even when removing env var
    env::set_var(ENV_VAR_MODE_0L, "woot");
    assert!(MODE_0L.clone() == NamedChain::MAINNET);
}