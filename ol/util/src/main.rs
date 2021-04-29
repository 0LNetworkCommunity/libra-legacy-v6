/// ol-util
///
/// tool to migrate config files
/// should be run after version upgrade
///
/// currently adds db_path to 0L.toml
///
/// potential enhancements:
/// - update value for an attribute
/// - remove attribute
/// - rename attribute

use libra_global_constants::{CONFIG_FILE, NODE_HOME};

use regex::Regex;
use std::path::{PathBuf};
use std::fs::File;
use std::io::{Read, Write};
use chrono::{DateTime, Utc};
use fs_extra::file::{copy,CopyOptions};

fn main() {
    let node_home = dirs::home_dir().unwrap().join(NODE_HOME);
    let config_file = node_home.join(CONFIG_FILE);

    migrate_0l_toml(config_file, node_home);   
}

fn migrate_0l_toml(config_file: PathBuf, node_home: PathBuf) {
    if !config_file.exists() {
        println!(
            "config file: {:?} does not exist - no patch necessary",
            config_file
        );
        return;
    }

    // step 1 : make a backup
    make_backup_file(&config_file);

    // step 2: update attributes
    // for now: only db_path is added in case it does not exist already
    add_to_section(
        &config_file,
        "workspace",
        "db_path",
        node_home.join("db").as_path().display().to_string(),
    );
}

/// add an attribute to a section in case it does not exist already
/// 
/// searches in the `filename` if `attribute`
/// eists in `section`. If so, the file is not updated.
/// Otherwise the `attribute` in inserted with `value`
/// 
/// example call:
///  add_to_section("/root/.0L/0L.toml", "workspace", "db_path", "/root/.0L/db");
/// 
pub fn add_to_section(filename: &PathBuf, section: &str, attribute: &str, value: String) {
    let mut in_my_section = false;
    let mut attribute_exists = false;

    let any_section_start_re = Regex::new(r"^\[.*\]$").unwrap();
    let my_section_re = Regex::new(&format!(r"^\[{}\]$", section).as_str()).unwrap();
    let my_attribute_re = Regex::new(&format!(r"^{}[ \t]*=.*$", attribute).as_str()).unwrap();

    // round 1: check if attribute already exists
    let file_content = read_file(&filename);
    for line in file_content.lines() {
        if any_section_start_re.is_match(&line) {
            in_my_section = my_section_re.is_match(&line);
        } else {
            attribute_exists |= in_my_section && my_attribute_re.is_match(&line);
        }
    }

    // round 2: update if necessary
    if attribute_exists {
        println!(
            "{:?}: no patch needed for [{}]/{} (all fine)", &filename, &section, &attribute
        );
    } else {
        let mut file = match File::create(&filename) {
            Err(why) => panic!("couldn't create {:?}: {}", filename, why),
            Ok(file) => file,
        };

        for line in file_content.lines() {
            match file.write_fmt(format_args!("{}\n", &line)) {
                Err(why) => println!("writing to file failed {:?}", why),
                _ => ()
            }
            if my_section_re.is_match(&line) {
                // add the new attribute here
                match file.write_fmt(format_args!("{} = \"{}\"\n", attribute, value)) {
                    Err(why) => println!("writing to file failed {:?}", why),
                    _ => ()
                }
            }
        }
        println!("{:?}: added property [{}]/{}", &filename, &section, &attribute
        );
    }
}

/// creates a backup of the file
/// 
/// the filename of the backup file be like the original
/// filename, with an appended ".bak" and timestamp
/// 
/// example call
///  make_backup_file("/root/.0L/0L.toml");
/// would create a file
///  "/root/.0L/0L.toml.bak.20210428-200235"
///
fn make_backup_file(filename: &PathBuf) {
    let now: DateTime<Utc> = Utc::now();
    let backup_filename = &format!("{}.bak.{}", filename.as_path().display().to_string(), now.format("%Y%m%d-%H%M%S"));
    match copy(&filename, PathBuf::from(backup_filename), &CopyOptions::new())  {
        Err(why) => panic!("writing backup file failed {:?} - stopping", why),
        _ => println!("created backup file: {:?}", backup_filename)
    }
}

/// read a file into a String
/// borrowed from:
/// https://www.tutorialspoint.com/file-operations-in-rust-programming
fn read_file(filename: &PathBuf) -> String {
    let mut file = match File::open(&filename) {
        Err(why) => panic!("unable to open {:?} - {}", filename, why),
        Ok(file) => file,
    };
    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(why) => panic!("unable to read {:?} - {}", filename, why),
        Ok(_) => return s,
    }
}
