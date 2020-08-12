#![forbid(unsafe_code)]
std::process::Command;
#[test]
pub fn test_command(&self, remote_ns: &str) -> Result<Waypoint, Error> {
    let mut echo_hello = Command::new("sh");
    echo_hello.arg("-c")
            .arg("echo hello");
    let hello_1 = echo_hello.output().expect("failed to execute process");
}