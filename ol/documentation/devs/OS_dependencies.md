# Quick start
If you are on Ubuntu 20.4 all your dependencies can be installed with `ol/util/setup.sh`

`make deps`

# Dependencies

### Installing Rust:

Rust codebase targets 1.46.0, which is now in the `stable` releases.

`curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y`

### Rust compile helpers

- sccache
Full guide here: (Improve-Rust-compile-times-with-sccache.md)


### Build dependencies:
- clang
- llvm
- libgmp-dev
- pkg-config
- libssl-dev
- lld

### Node management dependencies (Makefile):
- cmake
- jq 
- secure-delete 
- toml-cli (cargo install toml-cli)