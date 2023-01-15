#[test_only]
module DiemFramework::MerkleHashTests {
    use DiemFramework::MerkleHash;
    use Std::Hash;
    use Std::Vector;

    const EEXPECTED_EQUALITY: u64 = 0;

    #[test]
    fun merkle_hash_push_back() {
	let mh = MerkleHash::empty();
	MerkleHash::push_back(&mut mh, b"1234567890");
	let root = MerkleHash::finalize(&mut mh);
	let r1 = Hash::sha3_256(b"1234567890");
	assert!(root == r1, EEXPECTED_EQUALITY);
    }

    #[test]
    fun merkle_hash_two_elements_one_root() {
	let mh = MerkleHash::empty();
	MerkleHash::push_back(&mut mh, b"1234567890");
	MerkleHash::push_back(&mut mh, b"0987654321");
	let root = MerkleHash::finalize(&mut mh);
	let h1 = Hash::sha3_256(b"1234567890");
	let h2 = Hash::sha3_256(b"0987654321");
	Vector::append(&mut h1, h2);
	let r1 = Hash::sha3_256(h1);
	assert!(root == r1, EEXPECTED_EQUALITY);
    }

    #[test]
    fun merkle_hash_three_elements_two_roots() {
	let mh = MerkleHash::empty();
	MerkleHash::push_back(&mut mh, b"1234567890");
	MerkleHash::push_back(&mut mh, b"0987654321");
	MerkleHash::push_back(&mut mh, b"1231231231");
	let root = MerkleHash::finalize(&mut mh);
	// (level_0) root_1 = H(H(A) || H(B))
	let h1 = Hash::sha3_256(b"1234567890");
	let h2 = Hash::sha3_256(b"0987654321");
	Vector::append(&mut h1, h2);
	let r1 = Hash::sha3_256(h1);
	// (level_0) root_2 = H(H(C))
	let h3 = Hash::sha3_256(b"1231231231");
	let r2 = Hash::sha3_256(h3);
	Vector::append(&mut r1, r2);
	// (level_1) root_1 = H(root_1 || root_2)
	let t1 = Hash::sha3_256(r1);
	assert!(root == t1, EEXPECTED_EQUALITY);
    }

    #[test]
    fun merkle_hash_five_elements_three_roots() {
	let mh = MerkleHash::empty();
	MerkleHash::push_back(&mut mh, b"1234567890");
	MerkleHash::push_back(&mut mh, b"0987654321");
	MerkleHash::push_back(&mut mh, b"1231231231");
	MerkleHash::push_back(&mut mh, b"1234567890");
	MerkleHash::push_back(&mut mh, b"0987654321");
	let root = MerkleHash::finalize(&mut mh);
	// (level 0) root 1 = H(H(A) || H(B))
	let h1 = Hash::sha3_256(b"1234567890");
	let h2 = Hash::sha3_256(b"0987654321");
	Vector::append(&mut h1, h2);
	let l0_r1 = Hash::sha3_256(h1);
	// (level 0) root 2 = H(H(C) || H(D))
	let h3 = Hash::sha3_256(b"1231231231");
	let h4 = Hash::sha3_256(b"1234567890");
	Vector::append(&mut h3, h4);
	let l0_r2 = Hash::sha3_256(h3);
	// (level 0) root 3 = H(H(E))
	let h5 = Hash::sha3_256(b"0987654321");
	let l0_r3 = Hash::sha3_256(h5);
	// (level 1) root 1 = H(root 1 || root 2)
	Vector::append(&mut l0_r1, l0_r2);
	let l1_r1 = Hash::sha3_256(l0_r1);
	// (level 1) root 2 = H(root 3)
	let l1_r2 = Hash::sha3_256(l0_r3);
	// (level 2) root = H(level 1 root 1 || level 1 root 2)
	Vector::append(&mut l1_r1, l1_r2);
	let l2_r = Hash::sha3_256(l1_r1);
	assert!(root == l2_r, EEXPECTED_EQUALITY);
    }

    #[test]
    #[expected_failure(abort_code = 1)] // EEMPTY == 1
    fun finalize_when_empty() {
	let mh = MerkleHash::empty();
	MerkleHash::finalize(&mut mh);
    }
}
