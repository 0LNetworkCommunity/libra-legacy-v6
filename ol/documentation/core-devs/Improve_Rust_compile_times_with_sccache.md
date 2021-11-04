# Sccache

[Sccache](https://github.com/mozilla/sccache) is intended to cache build artifacts to improve build times.

## Steps

#### 1. Install sccache with:

 `cargo install sccache`

* Add an environment variable to your bash profile (e.g. ~/.bash_profile) `export RUSTC_WRAPPER=sccache`

* You must now **Restart terminal** (or `source ~/.bash_profile` without needing to restart)

#### 2. Clear your cargo builds:

`cargo clean` 

#### 3. Check sccache is empty:

`sccache -s` to show statistics

#### 4. Build cache: 

Do a clean build from source root:

`cargo build --all --bins --exclude cluster-test` . 

Note: this is what builds the cache, and will take as long as normal, no improvements yet.

#### 5. Cache is ready.

Clean again `cargo clean` and build now with improved build times, `cargo build`, 

## Checking cache hits
You should see a result like this with `sccache -s`

````
Compile requests                    409
Compile requests executed           282
Cache hits                            0
Cache misses                        282
Cache misses (C/C++)                237
Cache misses (Rust)                  45
Cache timeouts                        0
Cache read errors                     0
Forced recaches                       0
Cache write errors                    0
Compilation failures                  0
Cache errors                          0
Non-cacheable compilations            0
Non-cacheable calls                 123
Non-compilation calls                 4
Unsupported compiler calls            0
Average cache write               0.001 s
Average cache read miss           2.905 s
Average cache read hit            0.000 s
Failed distributed compilations       0

Non-cacheable reasons:
incremental                          90
crate-type                           32
-                                     1

Cache location                  Local disk: "/Users/lucas/Library/Caches/Mozilla.sccache"
Cache size                          274 MiB
Max cache size                       10 GiB
````

Resources:
https://vfoley.xyz/rust-compile-speed-tips/
https://www.reddit.com/r/rust/comments/96pmn5/how_to_alleviate_the_pain_of_rust_compile_times/