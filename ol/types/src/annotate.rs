//! annotate; parsing of account blobs and search for move structs.

use std::collections::BTreeMap;
use std::convert::TryFrom;
use anyhow::Error;
use libra_types::{account_address::AccountAddress, account_state_blob::AccountStateBlob};
use libra_types::account_state::AccountState;
use move_core_types::identifier::Identifier;
use move_core_types::language_storage::{StructTag, TypeTag};
use resource_viewer::{AnnotatedAccountStateBlob, AnnotatedMoveStruct, AnnotatedMoveValue, MoveValueAnnotator, NullStateView};
    
/// Parse an account blob into an annotated Move view
pub fn get_annotated_account_blob(account_blob: AccountStateBlob) -> Result<AnnotatedAccountStateBlob, Error> {
        let state_view = NullStateView::default();
        let annotator = MoveValueAnnotator::new(&state_view);
        annotator.view_account_state(&AccountState::try_from(&account_blob)?)
    }



// Ability to query Move types by walking an account blob. This is for structs which we may not have an equivalent type created in rust. For structs the core platform uses we have mappings available e.g. ol/types/src/miner_state.rs. This solves querying for resource structs that may be created by third parties.

/// check if the vec of value, is actually of other structs
pub fn unwrap_val_to_struct(
  move_val: &AnnotatedMoveValue,
) -> Option<&AnnotatedMoveStruct> {
  match move_val {
    AnnotatedMoveValue::Struct(s) => Some(s),
    _ => None
  }
}

/// find the value in a struct
pub fn find_value_in_struct(s: &AnnotatedMoveStruct, key_name: String) -> Option<&AnnotatedMoveValue> {
    match s
        .value
        .iter()
        .find(|v| v.0.clone().into_string() == key_name)
    {
        Some((_, v)) => Some(v),
        None => None,
    }
}

/// finds a value
pub fn find_value_from_state(
    blob: &AnnotatedAccountStateBlob,
    module_name: String,
    struct_name: String,
    key_name: String,
) -> Option<&AnnotatedMoveValue> {
    match blob.0.values().find(|&s| {
        s.type_.module.as_ref().to_string() == module_name
        && s.type_.name.as_ref().to_string() == struct_name
    }) {
        Some(s) => find_value_in_struct(s, key_name),
        None => None,
    }
}


/// test fixtures
pub fn test_fixture_blob() -> AnnotatedAccountStateBlob {
    let mut s = BTreeMap::new();
    let move_struct = test_fixture_struct();
    s.insert(move_struct.type_.clone(), move_struct);
    AnnotatedAccountStateBlob(s)
}

/// stuct fixture
pub fn test_fixture_struct() -> AnnotatedMoveStruct {
    let module_tag = StructTag {
        address: AccountAddress::random(),
        module: Identifier::new("TestModule").unwrap(),
        name: Identifier::new("TestStructName").unwrap(),
        type_params: vec![TypeTag::Bool],
    };

    let key = Identifier::new("test_key").unwrap();
    let value = AnnotatedMoveValue::Bool(true);

    AnnotatedMoveStruct {
        is_resource: true,
        type_: module_tag.clone(),
        value: vec![(key, value)],
    }
}

#[test]
fn test_find_annotated_move_value() {
    let s = test_fixture_blob();
    match find_value_from_state(
        &s,
        "TestModule".to_owned(),
        "TestStructName".to_owned(),
        "test_key".to_owned(),
    ) {
        // NOTE: This is gross, but I don't see a way to use assert_eq! on AnnotatedMoveValue
        Some(v) => {
            match v {
                // TODO: For some reason can't use assert
                AnnotatedMoveValue::Bool(b) => assert!(*b == true),
                _ => panic!("not the right value"),
            }
        }
        None => panic!("not the right value"),
    }
}
