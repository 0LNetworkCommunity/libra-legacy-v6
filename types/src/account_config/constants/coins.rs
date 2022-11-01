// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::account_config::constants::{from_currency_code_string, CORE_CODE_ADDRESS};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ModuleId, StructTag, TypeTag},
};
use once_cell::sync::Lazy;

//////// 0L ////////
// other coins besides GAS are only used for tests, and come from upstream
pub const GAS_NAME: &str = "GAS";
pub const GAS_IDENTIFIER: &IdentStr = ident_str!(GAS_NAME);
pub const XUS_NAME: &str = "GAS";
pub const XUS_IDENTIFIER: &IdentStr = ident_str!(XUS_NAME);
pub const XDX_NAME: &str = "GAS";
pub const XDX_IDENTIFIER: &IdentStr = ident_str!(XDX_NAME);

pub fn xus_tag() -> TypeTag {
    TypeTag::Struct(Box::new(StructTag {
        address: CORE_CODE_ADDRESS,
        module: from_currency_code_string(XUS_NAME).unwrap(),
        name: from_currency_code_string(XUS_NAME).unwrap(),
        type_params: vec![],
    }))
}

//////// 0L ////////
pub static GAS_MODULE: Lazy<ModuleId> =
    Lazy::new(|| ModuleId::new(CORE_CODE_ADDRESS, GAS_IDENTIFIER.to_owned()));

pub fn gas_struct() -> StructTag {
  StructTag {
        address: CORE_CODE_ADDRESS,
        module: from_currency_code_string(GAS_NAME).unwrap(),
        name: from_currency_code_string(GAS_NAME).unwrap(),
        type_params: vec![],
    }
}

pub fn gas_type_tag() -> TypeTag {
    TypeTag::Struct(Box::new(gas_struct()))
}

/// Return `Some(struct_name)` if `t` is a `StructTag` representing one of the current Diem coin
/// types (GAS, XUS), `None` otherwise.
pub fn coin_name(t: &TypeTag) -> Option<String> {
    match t {
        TypeTag::Struct(struct_tag) => {
            let StructTag {
                address,
                module,
                name,
                ..
            } = &**struct_tag;
            if *address == CORE_CODE_ADDRESS && module == name {
                let name_str = name.to_string();
                if name_str == GAS_NAME || name_str == XUS_NAME { /////// 0L /////////
                    Some(name_str)
                } else {
                    None
                }
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
    assert!(coin_name(&gas_type_tag()).unwrap() == GAS_NAME); //////// 0L ////////
    assert!(coin_name(&TypeTag::U64) == None);

    let bad_name = ident_str!("NotACoin").to_owned();
    let bad_coin = TypeTag::Struct(Box::new(StructTag {
        address: CORE_CODE_ADDRESS,
        module: bad_name.clone(),
        name: bad_name,
        type_params: vec![],
    }));
    assert!(coin_name(&bad_coin) == None);
}
