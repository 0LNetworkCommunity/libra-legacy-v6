These instructions target Ubuntu 20.4, and VS Code

# Hardware
Building on Rust is slow, and on first build you may experience cc errors related to running out of memory. Target 16bg+ of memory and quad core CPUs.

Optionally connect to a cloud remote machine, instead of using local. VS Code has mature tools for this. https://code.visualstudio.com/docs/remote/remote-overview

# Get OS dependencies
Full guide here: https://github.com/OLSF/libra/wiki/OS-Dependencies

# Set up sccache for faster build times
Full guide here: https://github.com/OLSF/libra/wiki/Improve-Rust-compile-times-with-sccache

# Install VS Code extensions
- Install rust-wrapper extension from [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer)

# Set Environment Variables
in your .bashrc you should add:
```bash
NODE_ENV=test
TEST=y
```

# Build all packages
The project is a mono-repo, and all code is in Rust, targeting stable version 1.46.0

`cargo build --all --bins --exclude cluster-test`

# Note on Move compiler
Note that when Move stdlib code changes, it is necessary to rerun the stdlib compiler. The compiler also created generated code bindings in Rust for transaction scripts.

`cargo r -p stdlib --release`

The one exception for this, is when running functional tests, which will run stdlib for you. If your e2e tests or swarm are failing inexplicably, it's likely that the stdlib has not been compiled.