# Writing and using native functions in move

Move is very limited in what functionality it provides us. Sometimes, it's convenient to write code in the rust language due to the increased functionality. This is done using _native functions_ in move. A very brief description on native functions can be found [here](https://move-book.com/syntax-basics/function.html#native-functions) in the move book. Note: this wiki page assumes the proper imports for code snippets.

## Implementing native functions in 0L

### Step 1
Start by declaring the native function in the corresponding move module. For example, in `language/diem-framework/modules/0L/VDF.move`:
```
native public fun verify(challenge: &vector<u8>, difficulty: &u64, alleged_solution: &vector<u8>): bool;
```
This can be used in move code just like any other function defined in move.

### Step 2
The rust implementation of the native function should be written in `language/move-vm/natives/src/<filename>.rs` where your function will be written in the file `<filename>.rs`. For example, see `language/move-vm/natives/src/vdf.rs` and the verify function. The function's inputs and output must be wrapped in a certain format to allow them to be sent between rust and move. Otherwise, the body of the function can be written in rust as normal.

#### Accepting Inputs
As seen in the example files, the inputs of the function will be `context: &impl NativeContext, ty_args: Vec<Type>, mut arguments: VecDeque<Value>`. Where `ty_args` will be a vector of currency type tags from move. For example, a native function corresponding to the move function `fun pay<LBR, GAS>()` would require `ty_args` to be a size two vector containing the currency tags for `LBR` and `GAS`. Similarly, `arguments` will be a vector of arguments of a type which allows interfacing between move and rust. These inputs can be popped from the vector and parsed as shown below. Once parsed, they can be used as desired normally in rust.
```
pub fn function_name(context: &impl NativeContext, ty_args: Vec<Type>, mut arguments: VecDeque<Value>) -> VMResult<NativeResult> {
    // Below parses the last input to the move function as a vector of type u8
    // Reference is used (as opposed to Value) below because the move argument being passed in
    // is a reference instead of the actual object.
    let example_vec = pop_arg!(arguments, Reference).read_ref()?.value_as::<Vec<u8>>()?;
    ... code here ...
}
```

#### Returning Outputs
Once the desired functionality has been written, it must be parsed and packaged so that move can understand the outputs. To do this, the actual outputs will be packaged into a `VMResult<NativeResult>` object. This object will be composed of a status (`Ok` or `Err`), any return values, as well as a gas cost since rust doesn't offer functionality for computing gas as it performs computations. The final result will be returned with either `Ok(NativeResult)` or `Err`. In the case for success, the `NativeResult` object can be built with `NativeResult::ok(gas_cost, vec_of_ret_vals)`. Note that the gas costs must be supplied manually when working in rust. This is discussed later.


Any return values must be supported by move to be passed from rust to move. All return values should be put into a vector of type `Value`, whose components can be initialized using the corresponding init functions (e.g. `Value::address(addr)` will initialize an `address` `Value` and `Value::bool(var)` will initialize a `bool` `Value`). The return values should all be compiled into a vector of `Value` objects. The vector will be passed into the constructor of the `NativeResult` object.


To manage gas for native functions, the `CostTable` object (defined in `language/move-core/type/src/gas_schedule.rs` if interested) will keep track of a table which keeps track of the gas costs associated with any operation. When writing a new native function, the size of the `CostTable::native_table` will need to be increased for future implementations so the network will be able to assign a cost to your native function (by passing in a cost schedule into a config) and your function will be able to compute its own gas cost (by querying the `CostTable` object passed in with the proper index).


As of writing this guide, all tests are performed using the `zero_cost_schedule` in `move-vm`. The steps described are for this environment.
1. Increment the total number of native functions by increasing the constant `NUMBER_OF_NATIVE_FUNCTIONS` in `language/move-binary-format/src/file_format.rs`. 
> What does this do? `zero_cost_schedule` is initialized for native functions by making a table of length `NUMBER_OF_NATIVE_FUNCTIONS` with entries of zero. By increasing the size of this table (and the global constant for anywhere else it's used), you will avoid index_out_of_bounds errors since the `CostTable` is actually big enough.
2. At the bottom of `language/move-vm/types/src/gas_schedule.rs`, add another entry to the enum which holds the indices for native functions. This will make it easier to access the proper table entry without having to remember the index.
3. In `language/move-vm/types/src/gas_schedule.rs`, add another elemen to the vector e.g. `(N::VDF_VERIFY, GasCost::new(1000000, 1))`.
4. Calculate cost within your native function by calling `cost = native_gas(context.cost_table(), NativeCostIndex::YOUR_ENUM_ENTRY, 1);` where `native_gas` is imported with `use move_vm_types::natives::function::native_gas`.

The final return value  the computed gas values can be combined with the vector of return values and output from the native function with `NativeResult::ok(gas_cost, vec_of_ret_vals)`.

### Step 3
Finally, once the native function is written in rust, you must tell move how and where to find the actual code. This section deals with the declarations that must be made in various `lib` files so that move will know where to look for the native functions you've written.

In `language/move-stdlib/src/natives/mod.rs`:
1. Add a line to add `pub mod filename` where `filename` is the name of your rust file which contains the native function.
2. Add your fns e.g. `("VDF", "verify", ol_vdf::native_verify),` into the `const NATIVES: &[(&str, &str, NativeFunction)] = &[` array
        



Now your function should work!


Final Notes:
- In case of problems, check how the move std lib. native modules/fns are written e.g. `vector::empty()` or the 0L native modules/fns e.g. `ol_vdf, ol_decimal`.
- Be careful when using `assert` statements in rust. While `Transaction::assert(false, 0)` in move just causes the transaction to abort, an `assert!(false)` in rust will cause panick and will fail functional tests. When possible, asserts, checks, and confirmations should be done in move-space.
- Be careful when passing variables to/from rust/move regarding ownership. It's best practice to borrow move variables without taking ownership when possible.
