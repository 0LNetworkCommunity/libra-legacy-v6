
### Step 1. Install tools

Follow steps here (but be aware these docs were un-updated at the time of writing this, so combine them with the notes in this doc.):  
https://github.com/OLSF/libra/blob/main/language/move-prover/doc/user/install.md  
and  
https://github.com/OLSF/libra/blob/main/language/move-prover/doc/user/prover-guide.md


**Hint**: If `./scripts/dev_setup.sh` does not work, install the followings manually with the following order:

```
DOTNET_VERSION=3.1
BOOGIE_VERSION=2.8.32
Z3_VERSION=4.8.9
CVC4_VERSION=aac53f51
```

Double check the version numbers and see install functions e.g. `function install_boogie {..}` in `./scripts/dev_setup.sh`.

**Some Notes**:

Install dotnet   
- Download https://dot.net/v1/dotnet-install.sh
- `dotnet-install.sh --channel 3.1 --version latest `

Install boogie   
`$HOME/.dotnet/dotnet tool update --global Boogie --version 2.8.32`
	   
     
~/.mvprc
```
move_deps = [
    "/home/<user>/libra-fork/language/diem-framework/modules/",
    "/home/<user>/libra-fork/language/move-stdlib/modules/"
]

[backend]
boogie_exe = "/home/<user>/.dotnet/tools/boogie"
z3_exe = "/usr/bin/z3"
```

### Step 2. Run move-prover with sample code

```
cargo r --release -p move-prover -- /opt/counter.move 

[INFO] translating module M
[INFO] running solver
[INFO] 1.222s build, 0.000s trafo, 0.005s gen, 2.119s verify
```

/opt/counter.move:     
```
address 0x1 {

module M {
    struct Counter has key {
        value: u8,
    }

    public fun increment(a: address) acquires Counter {
        let r = borrow_global_mut<Counter>(a);
        r.value = r.value + 1;
    }

    spec increment {
        aborts_if !exists<Counter>(a);
        ensures global<Counter>(a).value == old(global<Counter>(a)).value + 1;
        // Uncomment this line to fix the prover error
        // aborts_if global<Counter>(a).value == 255;
    }
}

}
```

### Troubleshooting

- Use this command `cargo r --release -p move-prover -- --print-config` to see move-prover config. 
- Double check config file `MOVE_PROVER_CONFIG=~/.mvprc`