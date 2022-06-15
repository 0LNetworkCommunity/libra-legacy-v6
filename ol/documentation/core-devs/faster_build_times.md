
[1. Faster incremental builds (6s instead of 40s)](#1)  
[2. Faster clean builds with 'sccache' (3min instead of 7min)](#2)

------------------------------

<a name="1"/>

## 1. Faster incremental builds (6s instead of 40s)

Here are some configs and experiment results for Ubuntu and macOS faster build times.  
Hint: Search for "FASTEST"

### Ubuntu 20.04 - ~5x faster incremental builds:

```
cargo b tower

    // default 
    Full build: 7m
    Incr build: 30-54s
    Bin Size  : 558 MB    

    // w/ [build] rustflags = ["-C", "link-arg=-fuse-ld=lld"]    
    Full build: 6:11
    Incr build: 6-7s
    Bin Size  : 567 MB          
    
    [FASTEST]
    // w/ 1) # disable debug symbols for all packages except this one 
          2) [build] rustflags = ["-C", "link-arg=-fuse-ld=lld"]    
    Full build: 4:31
    Incr build: 5-6s
    Bin Size  : 372 MB   

    // w/ 1) [build] rustflags = ["-C", "link-arg=-Wl,--compress-debug-sections=zlib-gabi"]
          2) # Optimize all dependencies for small size
    Full build: 
    Incr build: 43s - 1:20
    Bin Size  : 182 MB
```

#### Related Configs: 

```
.cargo/config (Note: sudo apt-get install lld)
# Dramatically increases the link performance for the eventbus
[build]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]   

root cargo.toml 
[profile.dev.package."*"]
# disable debug symbols for all packages except this one
debug = false
   
root cargo.toml 
# Optimize all dependencies for small size
[profile.dev.package."*"]
opt-level = "z"

.cargo/config
[build]
# Compress debug sections for small size
rustflags = ["-C", "link-arg=-Wl,--compress-debug-sections=zlib-gabi"]
```

### macOS (MacBook Pro Mid 2015) - 5x faster incremental builds:

```
cargo b tower

    // default 
    Full build: 5:58
    Incr build: 38sec

    // w/ # disable debug symbols for all packages except this one 
    Full build: 4:57
    Incr build: 23sec

    [FASTEST w/ rust 1.46 - current 0L default version]
    // w/ 1) [build] rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/zld"]
          2) # disable debug symbols for all packages except this one
    Full build: 4:32
    Incr build: 19s    

    // rust 1.51 default
    Full build: 7:55
    Incr build: 40s
    
    // rust 1.51 + split-debuginfo = "unpacked"
    Full build: 7:00
    Incr build: 12s

    [FASTEST w/ rust 1.51]
    // rust 1.51 + 
          1) split-debuginfo = "unpacked"
          2) [build] rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/zld"]
          3) # disable debug symbols for all packages except this one    
    Full build: 6:15
    Incr build: 7s

    How to install zld?
    brew install michaeleisel/zld/zld
    Ref:
    https://steipete.com/posts/zld-a-faster-linker/
    https://github.com/michaeleisel/zld
```

#### Related Configs: 
```
.cargo/config
[build] 
rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/zld"]

root cargo.toml 
[profile.dev]
split-debuginfo = "unpacked" # Requires rustc 1.51

root cargo.toml 
[profile.dev.package."*"]
# disable debug symbols for all packages except this one
debug = false
```

<a name="2"/>   

## 2. Faster clean builds with 'sccache' (3min instead of 7min)

see also: (Improve-Rust-compile-times-with-sccache.md)

Measure your build time first without 'sccache':  

```
// Clean build of `tower` takes around 7min
cargo clean 
cargo b -p tower 
```

Setup  
```
cargo install sccache
echo "export RUSTC_WRAPPER=sccache" >> ~/.bashrc
source ~/.bashrc

// macos 
echo -e "\nexport RUSTC_WRAPPER=sccache--" >> ~/.bash_profile
source ~/.bash_profile  
```

Use `sccache`  
```
// Ignore this build - caching here
cargo clean 
cargo b -p tower 

// Now, this takes `3min` instead of `7min` - Incredible!
cargo clean 
cargo b -p tower 

```


