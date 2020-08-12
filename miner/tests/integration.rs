#![forbid(unsafe_code)]
use std::process::Command;
#[test]
pub fn test_command() {
    let mut echo_hello = Command::new("sh");
    echo_hello.arg("-c")
            .arg("echo hello");
    let hello_1 = echo_hello.output().expect("failed to execute process");
}