// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use clap::{App, Arg};
use diem_framework::*;
use move_stdlib::utils::time_it;
use std::io::Write;
use std::path::{Path, PathBuf};

//////// 0L ////////
// for Upgrade oracle
/// The output path under which staged files will be put
pub const STAGED_OUTPUT_PATH: &str = "staged";
/// The file name for the staged stdlib
pub const STAGED_STDLIB_NAME: &str = "stdlib";
/// The extension for staged files
pub const STAGED_EXTENSION: &str = "mv";
//////// 0L end ////////

// Generates the compiled stdlib and transaction scripts. Until this is run changes to the source
// modules/scripts, and changes in the Move compiler will not be reflected in the stdlib used for
// genesis, and everywhere else across the code-base unless otherwise specified.
fn main() {
    let cli = App::new("stdlib")
        .name("Move standard library")
        .author("The Diem Core Contributors")
        .arg(Arg::with_name("output").long("output").help("use a custom output path").takes_value(true))
        //////// 0L ////////
        .arg(
            Arg::with_name("upgrade")
                .long("upgrade")
                .help("create a single file for network upgrade"),
        )
        //////// end 0L ////////
        .arg(
            Arg::with_name("no-doc")
                .long("no-doc")
                .help("do not generate documentation"),
        )
        .arg(
            Arg::with_name("no-script-abi")
                .long("no-script-abi")
                .requires("no-compiler")
                .help("do not generate script ABIs"),
        )
        .arg(
            Arg::with_name("no-script-builder")
                .long("no-script-builder")
                .help("do not generate script builders"),
        )
        .arg(
            Arg::with_name("no-compiler")
                .long("no-compiler")
                .help("do not compile modules and scripts"),
        )
        .arg(
            Arg::with_name("no-check-linking-layout-compatibility")
                .long("no-check-linking-layout-compatibility")
                .help("do not print information about linking and layout compatibility between the old and new standard library"),
        )
        .arg(Arg::with_name("no-errmap").long("no-errmap").help("do not generate error explanations"))
        .arg(
            Arg::with_name("with-diagram")
                .long("with-diagram")
                .help("include diagrams in the stdlib documentation"))
        //////// 0L ////////
        // for upgrade oracle
        // 1. build the first 
        //      `cargo r -p diem-framework --release`
        // 2. compile into one file:
        //      `cargo r -p diem-framework --release -- --create-upgrade-payload`
        .arg(
            Arg::with_name("create-upgrade-payload")
                .long("create-upgrade-payload")
                .help("generate test/stdlib.mv for upgrade oracle")
        );
    let matches = cli.get_matches();
    let options = release::ReleaseOptions {
        build_modules: !matches.is_present("no-compiler"),
        check_layout_compatibility: !matches.is_present("no-check-linking-layout-compatibility"),
        module_docs: !matches.is_present("no-doc"),
        script_docs: !matches.is_present("no-doc"),
        with_diagram: matches.is_present("with-diagram"),
        script_abis: !matches.is_present("no-script-abi"),
        script_builder: !matches.is_present("no-script-builder"),
        errmap: !matches.is_present("no-errmap"),
        time_it: true,
        upgrade_payload: matches.is_present("upgrade"),
    };

    // Make sure that the current directory is `language/diem-framework` from now on.
    let exec_path = std::env::args().next().expect("path of the executable");
    let base_path = std::path::Path::new(&exec_path)
        .parent()
        .unwrap()
        .join("../../language/diem-framework");
    std::env::set_current_dir(&base_path).expect("failed to change directory");

    #[cfg(debug_assertions)]
    {
        println!("NOTE: run this program in --release mode for better speed");
    }

    //////// 0L ////////
    let staged_path = PathBuf::from(STAGED_OUTPUT_PATH);
    std::fs::create_dir_all(&staged_path).unwrap();
    // for upgrade oracle
    let create_upgrade_payload =
        matches.is_present("create-upgrade-payload");

    if create_upgrade_payload {
        time_it("Creating staged/stdlib.mv for upgrade oracle", || {
            let mut module_path = PathBuf::from(STAGED_OUTPUT_PATH);
            module_path.push(STAGED_STDLIB_NAME);
            module_path.set_extension(STAGED_EXTENSION);
            let modules: Vec<Vec<u8>> = build_stdlib()
                .values().into_iter()
                .map(|compiled_module| {
                    let mut ser = Vec::new();
                    compiled_module.serialize(&mut ser).unwrap();
                    ser
                })
                .collect();
            let bytes = bcs::to_bytes(&modules).unwrap();
            let mut module_file = std::fs::File::create(module_path).unwrap();
            module_file.write_all(&bytes).unwrap();
        });
    }
    //////// 0L end ////////

    let output_path = matches
        .value_of("output")
        .unwrap_or("releases/artifacts/current");

    release::create_release(
        &Path::new(output_path), &options, create_upgrade_payload
    );

    // Sync the generated docs for the modules and docs to their old locations to maintain
    // documentation locations.
    if matches.value_of("output").is_none() {
        release::sync_doc_files(&output_path);
    }    
}
