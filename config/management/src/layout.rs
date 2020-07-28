// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{constants, error::Error, SingleBackend};
use libra_secure_storage::{Storage, Value};
use serde::{Deserialize, Serialize};
use std::{
    convert::TryInto,
    fs::File,
    io::Read,
    path::{Path, PathBuf},
};
use structopt::StructOpt;

/// Layout defines the set of roles to identities within genesis. In practice, these identities
/// will map to distinct namespaces where the expected data should be stored in the deterministic
/// location as defined within this tool.
#[derive(Debug, Default, Deserialize, Serialize)]
pub struct Layout {
    pub operators: Vec<String>,
    pub owners: Vec<String>,
    pub association: Vec<String>,
}

impl Layout {
    pub fn from_disk<P: AsRef<Path>>(path: P) -> Result<Self, Error> {
        println!("from disk 0");
        let mut file = File::open(&path).map_err(|e| Error::UnexpectedError(e.to_string()))?;
        println!("from disk 1");
        let mut contents = String::new();
        file.read_to_string(&mut contents)
            .map_err(|e| Error::UnexpectedError(e.to_string()))?;
        println!("from disk 2");
        let test = Self::parse(&contents);
        println!("from disk 3");

        test
    }

    pub fn parse(contents: &str) -> Result<Self, Error> {
        toml::from_str(&contents).map_err(|e| Error::UnexpectedError(e.to_string()))
    }

    pub fn to_toml(&self) -> Result<String, Error> {
        toml::to_string(&self).map_err(|e| Error::UnexpectedError(e.to_string()))
    }
}

impl std::fmt::Display for Layout {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", toml::to_string(self).unwrap())
    }
}

#[derive(Debug, StructOpt)]
pub struct SetLayout {
    #[structopt(long)]
    path: PathBuf,
    #[structopt(flatten)]
    backend: SingleBackend,
}

impl SetLayout {
    pub fn execute(self) -> Result<Layout, Error> {
        println!("execute 0");
        let layout = Layout::from_disk(&self.path)?;
        println!("execute 1");

        let data = layout.to_toml()?;
        println!("execute 2");

        let mut remote: Box<dyn Storage> = self.backend.backend.try_into()?;
        println!("execute 3");

        remote
            .available()
            .map_err(|e| Error::RemoteStorageUnavailable(e.to_string()))?;

        println!("execute 4");

        let value = Value::String(data);
        remote
            .set(constants::LAYOUT, value)
            .map_err(|e| Error::RemoteStorageWriteError(constants::LAYOUT, e.to_string()))?;

        Ok(layout)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_layout() {
        let contents = "\
            operators = [\"alice\", \"bob\"]\n\
            owners = [\"carol\"]\n\
            association = [\"dave\"]\n\
        ";

        let layout = Layout::parse(contents).unwrap();
        assert_eq!(
            layout.operators,
            vec!["alice".to_string(), "bob".to_string()]
        );
        assert_eq!(layout.owners, vec!["carol".to_string()]);
        assert_eq!(layout.association, vec!["dave".to_string()]);
    }
}
