%builtins output pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.math import assert_nn_le

struct InputData:
    member nameHash : felt
    member value : felt
end

struct OutputData:
    member nameHash : felt
    member value : felt
    member totalHash : felt
end


# Returns a hash following the formula:
#   H(nameHash, value).
# where H is the Pedersen hash function.
func hash_data{pedersen_ptr : HashBuiltin*}(
        data : InputData*) -> (res : felt):
    let res = data.nameHash
    let (res) = hash2{hash_ptr=pedersen_ptr}(
        res, data.value)
    return (res=res)
end 



func main{
        output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
        }() -> ():
    alloc_locals

    # Setup the output pointers
    let output = cast(output_ptr, OutputData*)
    let output_ptr = output_ptr + OutputData.SIZE

    local nH
    local val

    # Populate input using prover-run hint
    %{
        import hashlib
        #from starkware.crypto.signature.signature import pedersen_hash
        from starkware.cairo.common.math_utils import as_int

        # Generate hash of name
        name = program_input["name"]
        result = hashlib.sha256(name.encode())
        # Make sure nameHash is within Cairo's Field Bounds
        PRIME = 2**251 + 17 * 2**192 + 1
        nameHash = int(result.hexdigest(), 16) % PRIME

        # Assign collected inputs to cairo program variables
        ids.nH = nameHash
        ids.val = int(program_input["value"])
    %}

    # Proof that its value is above x, x - Hardcoded #
    let x = 10
    # check val >= x (assuming x >= 0) [ or more precisiely 0 <= x <= val ]
    assert_nn_le(x, val)

    # Assign gathered inputs to input
    local input : InputData
    assert input.nameHash = nH
    assert input.value = val

    # Calculate the hash for the input structure
    let (__fp__, _) = get_fp_and_pc()
    let (data_hash) = hash_data(data=&input)

    # Write the verified data to the output.
    assert output.nameHash = input.nameHash
    assert output.value = input.value
    assert output.totalHash = data_hash

    return ()
end