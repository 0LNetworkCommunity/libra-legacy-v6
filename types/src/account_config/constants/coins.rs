// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::account_config::constants::{from_currency_code_string, CORE_CODE_ADDRESS};
use move_core_types::{
    identifier::Identifier,
    language_storage::{ModuleId, StructTag, TypeTag},
};
use once_cell::sync::Lazy;

pub const GAS_NAME: &str = "GAS";
pub const XUS_NAME: &str = "XUS";

pub fn xus_tag() -> TypeTag {
    TypeTag::Struct(StructTag {
        address: CORE_CODE_ADDRESS,
        module: from_currency_code_string(XUS_NAME).unwrap(),
        name: from_currency_code_string(XUS_NAME).unwrap(),
        type_params: vec![],
    })
}

pub static GAS_MODULE: Lazy<ModuleId> =
    Lazy::new(|| ModuleId::new(CORE_CODE_ADDRESS, Identifier::new(GAS_NAME).unwrap()));
pub static GAS_STRUCT_NAME: Lazy<Identifier> = Lazy::new(|| Identifier::new(GAS_NAME).unwrap());

pub fn gas_type_tag() -> TypeTag {
    TypeTag::Struct(StructTag {
        address: CORE_CODE_ADDRESS,
        module: from_currency_code_string(GAS_NAME).unwrap(),
        name: from_currency_code_string(GAS_NAME).unwrap(),
        type_params: vec![],
    })
}

/// Return `Some(struct_name)` if `t` is a `StructTag` representing one of the current Diem coin
/// types (GAS, XUS), `None` otherwise.
pub fn coin_name(t: &TypeTag) -> Option<String> {
    match t {
        TypeTag::Struct(StructTag {
            address,
            module,
            name,
            ..
        }) if *address == CORE_CODE_ADDRESS && module == name => {
            let name_str = name.to_string();
            if name_str == GAS_NAME || name_str == XUS_NAME {
                Some(name_str)
            } else {
                None
            }
        }
        _ => None,
    }
}

#[test]
fn coin_names() {
    assert!(coin_name(&xus_tag()).unwrap() == XUS_NAME);
    assert!(coin_name(&gas_type_tag()).unwrap() == GAS_NAME);

    assert!(coin_name(&TypeTag::U64) == None);
    let bad_name = Identifier::new("NotACoin").unwrap();
    let bad_coin = TypeTag::Struct(StructTag {
        address: CORE_CODE_ADDRESS,
        module: bad_name.clone(),
        name: bad_name,
        type_params: vec![],
    });
    assert!(coin_name(&bad_coin) == None);
}
