
### Setup Debugger:

#### Step-1 
Install VS Code extension `CodeLLDB (OS X/Linux)`

#### Step-2

Create this folder and file in project root:  
`.vscode/launch.json` 

E.g. two debug configs for `tower` package with and without using `cargo`:  
```
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": 
  [
    {
      "name": "debug tower",
       
       "type": "lldb",
       "request": "launch",
       "cargo": { "args": ["b", "-p", "tower"] },
       "args": [ "--swarm-path", "./swarm_temp", "--swarm-persona", "alice", "start" ], // e.g. ["arg1", "arg2"]
       "env": {
         "MNEM": "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse",
         "NODE_ENV": "test"
       }, // e.g. {"ENV1": "aa", "ENV2: "bb"}
       "cwd": "${workspaceFolder}"
    }, 
    {  
       "name": "debug tower without cargo",
       "type": "lldb",
       "request": "launch",
       "program": "${workspaceFolder}/target/debug/tower",
       "args": ["--swarm-path", "/opt/swarm_temp", "--swarm-persona", "alice", "start"],
       "env":{"NODE_ENV": "test"}, // {"ENV1": "aa", "ENV2: "bb"}
       "cwd": "${workspaceFolder}"
    },
  ]
}
```

#### Step-3
`File -> Preferences -> Settings` type `Allow setting breakpoints...`

Tick this checkbox:  
`<> Allow setting breakpoints in any file`

Done!

### Start Debugging:  
Set your breakpoint and press `F5` or `menu -> Run -> Start Debugging`.   
If all goes well, debug sessions should start and you should see `debug tower` on upper-left hand of VS Code in debug window.  

Note: You can see/select other debug targets if you added more than one package into `"configurations":` array in step 2.  

### Known Issues
https://github.com/0LNetworkCommunity/libra/issues/589

### Sources:   
https://www.forrestthewoods.com/blog/how-to-debug-rust-with-visual-studio-code/  
https://code.visualstudio.com/docs/editor/debugging#_launch-configurations
