/// Implements a Merkle Tree Hash using SHA3-256.
module DiemFramework::MerkleHash {
    use Std::Vector;
    use Std::Hash;

    /// An element was added past the max supported size.
    const ELENGTH: u64 = 0;
    /// The MerkleHash elements vector was empty when calling finalize.
    const EEMPTY: u64 = 1;

    /// REVIEW: Picked a random sensible sounding number.
    const MAX_SIZE: u64 = 32;

    struct MerkleHash has copy, drop, store {
	elements: vector<vector<u8>>,
    }

    /// Creates an empty MerkleHash (cannot be finalized).
    public fun empty(): MerkleHash {
	MerkleHash {
	    elements: Vector::empty(),
	}
    }

    /// Hashes and pushes a byte vector into the MerkleHash struct.
    public fun push_back(merkle_hash: &mut MerkleHash, element: vector<u8>) {
	assert!(Vector::length(&merkle_hash.elements) < MAX_SIZE, ELENGTH);
	let h = Hash::sha3_256(element);
	Vector::push_back(&mut merkle_hash.elements, h);
    }

    /// Computes the merkle tree root and returns it.
    public fun finalize(merkle_hash: &mut MerkleHash): vector<u8> {
	assert!(Vector::length(&merkle_hash.elements) > 0, EEMPTY);

	// A new temporary vector is setup to hold the roots which will form the elements of the
	// MerkleHash (a vector of length 1 containing the merkle root) once finalize is complete.
	let roots = Vector::empty();

	while (Vector::length(&merkle_hash.elements) > 1) {
	    // The elements are reversed such that they are returned in FIFO rather than LIFO
	    // order.
	    Vector::reverse(&mut merkle_hash.elements);

	    while (Vector::length(&merkle_hash.elements) > 0) {
		let len = Vector::length(&merkle_hash.elements);
		if (len >= 2) {
		    // The current length >= 2, can pop two elements from the back and hash.
		    let lhs = Vector::pop_back(&mut merkle_hash.elements);
		    let rhs = Vector::pop_back(&mut merkle_hash.elements);
		    // H(lhs || rhs)
		    Vector::append(&mut lhs, rhs);
		    let root = Hash::sha3_256(lhs);
		    Vector::push_back(&mut roots, root);
		} else {
		    assert!(Vector::length(&merkle_hash.elements) == 1, ELENGTH);
		    // The current length == 1 so we can only pop one element and hash it.
		    let singleton = Vector::pop_back(&mut merkle_hash.elements);
		    // H(singleton)
		    let root = Hash::sha3_256(singleton);
		    Vector::push_back(&mut roots, root);
		} 
	    };

	    // The current length of elements should now be 0 since all its elements were popped,
	    // mutate the elements to be the next generation of roots and set the temporary root
	    // vector to the empty vector.
	    assert!(Vector::length(&merkle_hash.elements) == 0, ELENGTH);
	    assert!(Vector::length(&roots) > 0, ELENGTH);
	    merkle_hash.elements = roots;
	    roots = Vector::empty();
	};

	// The result is the first element in merkle_hash.elements.
	Vector::remove(&mut merkle_hash.elements, 0)
    }
}
