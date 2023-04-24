//! autopay view for web monitor

use std::collections::HashMap;
use move_core_types::account_address::AccountAddress;
use diem_types::access_path::AccessPath;
use move_core_types::{
  language_storage::StructTag,
  resolver::ModuleResolver,
  language_storage::ModuleId,
  resolver::ResourceResolver,
};

use diem_state_view::StateView;
use diem_vm::data_cache::RemoteStorage;
use move_binary_format::errors::*;
use anyhow::Result;

use serde::{Serialize, Deserialize};
#[derive(Debug, Default, Clone, Serialize, Deserialize)]

/// Create an empty data store for move annotation purposes
/// This used to exist in V5.
pub struct NullDataStore {
    data: HashMap<AccessPath, Vec<u8>>,
}

impl NullDataStore {
    /// Creates a new `NullDataStore` with the provided initial data.
    pub fn new() -> Self {
        let mut data = HashMap::new();
        data.insert(AccessPath::new(AccountAddress::ZERO, vec![]), vec![]);
        NullDataStore { data }
    }
}


impl StateView for NullDataStore {
    fn get(&self, access_path: &AccessPath) -> Result<Option<Vec<u8>>> {
        // Since the data is in-memory, it can't fail.
        Ok(self.data.get(access_path).cloned())
    }

    fn is_genesis(&self) -> bool {
        self.data.is_empty()
    }
}

impl ModuleResolver for NullDataStore {
    // type Error = diem_vm::data_cache::VMError;
    type Error = VMError;

    fn get_module(&self, module_id: &ModuleId) -> Result<Option<Vec<u8>>, Self::Error> {
        RemoteStorage::new(self).get_module(module_id)
    }
}

impl ResourceResolver for NullDataStore {
    type Error = VMError;

    fn get_resource(
        &self,
        address: &AccountAddress,
        tag: &StructTag,
    ) -> Result<Option<Vec<u8>>, Self::Error> {
        RemoteStorage::new(self).get_resource(address, tag)
    }
}
