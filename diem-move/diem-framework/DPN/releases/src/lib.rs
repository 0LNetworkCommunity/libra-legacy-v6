// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::Result;
use diem_types::{transaction::ScriptFunction, vm_status::{StatusCode, VMStatus}};
use framework_releases::{Release, ReleaseFetcher};
use move_binary_format::file_format::CompiledModule;
use move_bytecode_verifier::verifier::verify_module;
use move_command_line_common::files::{extension_equals, find_filenames, MOVE_COMPILED_EXTENSION};
use once_cell::sync::Lazy;
use std::{collections::BTreeMap, convert::TryFrom, fs::File, io::Write, path::PathBuf};

pub mod legacy;

#[cfg(test)]
mod tests;

//////// 0L ////////
// for Upgrade oracle
/// The output path under which staged files will be put
pub const STAGED_OUTPUT_PATH: &str = "staged";
/// The file name for the staged stdlib
pub const STAGED_STDLIB_NAME: &str = "stdlib";
/// The extension for staged files
pub const STAGED_EXTENSION: &str = "mv";

/// Return a list of all available releases.
pub fn list_all_releases() -> Result<Vec<String>> {
    Ok(ReleaseFetcher::list_releases(&Release::DPN))
}

/// Load the serialized modules from the specified release.
pub fn load_modules_from_release(release_name: &str) -> Result<Vec<Vec<u8>>> {
    ReleaseFetcher::new(Release::DPN, release_name).module_blobs()
}

/// Load the error descriptions from the specified release.
pub fn load_error_descriptions_from_release(release_name: &str) -> Result<Vec<u8>> {
    ReleaseFetcher::new(Release::DPN, release_name).error_descriptions()
}

/// Load the serialized modules from the specified paths.
pub fn load_modules_from_paths(paths: &[PathBuf]) -> Vec<Vec<u8>> {
    find_filenames(paths, |path| {
        extension_equals(path, MOVE_COMPILED_EXTENSION)
    })
    .expect("module loading failed")
    .iter()
    .map(|file_name| std::fs::read(file_name).unwrap())
    .collect::<Vec<_>>()
}

static CURRENT_MODULE_BLOBS: Lazy<Vec<Vec<u8>>> =
    Lazy::new(|| load_modules_from_release("current").unwrap());

static CURRENT_MODULES: Lazy<Vec<CompiledModule>> = Lazy::new(|| {
    CURRENT_MODULE_BLOBS
        .iter()
        .map(|blob| CompiledModule::deserialize(blob).unwrap())
        .collect()
});

pub fn current_modules() -> &'static [CompiledModule] {
    &CURRENT_MODULES
}

pub fn current_module_blobs() -> &'static [Vec<u8>] {
    &CURRENT_MODULE_BLOBS
}

pub fn current_modules_with_blobs(
) -> impl Iterator<Item = (&'static Vec<u8>, &'static CompiledModule)> {
    CURRENT_MODULE_BLOBS.iter().zip(CURRENT_MODULES.iter())
}

static CURRENT_ERROR_DESCRIPTIONS: Lazy<Vec<u8>> =
    Lazy::new(|| load_error_descriptions_from_release("current").unwrap());

pub fn current_error_descriptions() -> &'static [u8] {
    &CURRENT_ERROR_DESCRIPTIONS
}

pub fn name_for_script(bytes: &[u8]) -> Result<String> {
    if let Ok(script) = legacy::transaction_scripts::LegacyStdlibScript::try_from(bytes) {
        Ok(format!("{}", script))
    } else {
        bcs::from_bytes::<ScriptFunction>(bytes)
            .map(|script| {
                format!(
                    "{}::{}::{}",
                    script.module().address().short_str_lossless(),
                    script.module().name(),
                    script.function()
                )
            })
            .map_err(|err| err.into())
    }
}

//////// 0L ////////
// Update stdlib with a byte string, used as part of the upgrade oracle
pub fn import_stdlib(lib_bytes: &Vec<u8>) -> Result<Vec<CompiledModule>> {
    // set as empty array if err occurred
    let modules : Vec<CompiledModule> = bcs::from_bytes::<Vec<Vec<u8>>>(lib_bytes)?
        .into_iter()
        .filter_map(|bytes| CompiledModule::deserialize(&bytes).ok())
        .collect();

    // verify the compiled module
    let mut verified_modules = vec![];
    for module in modules {
        verify_module(&module)
        .map_err(|_| VMStatus::Error(StatusCode::CODE_DESERIALIZATION_ERROR))?;

        // TODO: Do we still need to run dependency checker?
        // DependencyChecker::verify_module(&module, &verified_modules)
        //     .expect("stdlib module dependency failed to verify");
        verified_modules.push(module)
    }
    Ok(verified_modules)
}

//////// 0L ////////
pub fn create_upgrade_payload_fn(build:  &BTreeMap<String, CompiledModule> ) {
    // let mut module_path = PathBuf::from(STAGED_OUTPUT_PATH);
    // TODO: set the .0L path the right way.
    let mut module_path = PathBuf::from(STAGED_OUTPUT_PATH);
    module_path.push(STAGED_STDLIB_NAME);
    module_path.set_extension(STAGED_EXTENSION);
    print!("{:?} ", &module_path);
    let modules: Vec<Vec<u8>> = build
        .values().into_iter()
        .map(|compiled_module| {
            let mut ser = Vec::new();
            compiled_module.serialize(&mut ser).unwrap();
            ser
        })
        .collect();
    let bytes = bcs::to_bytes(&modules).unwrap();
    let mut module_file = File::create(module_path).unwrap();
    module_file.write(&bytes).unwrap();
}