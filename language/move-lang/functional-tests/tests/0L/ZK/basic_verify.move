script {
use 0x1::ZK;
use 0x1::Vector;
fun main() {
	// Should return true if value >= x (Currently x=10), 
	//false if not or if SHARP is somehow dishonest

	/* Test Case 1: val1 < x */
	let name = Vector::empty<u8>();
	Vector::push_back(&mut name, 65);
	let val1: u128 = 11;

	let test1 = ZK::verify(name, val1);
	assert(test1 == false, 41);

	/* Test Case 2: val2 > x */
	let name = Vector::empty<u8>();
	Vector::push_back(&mut name, 65);
	let val2: u128 = 3;

	let test2 = ZK::verify(name, val2);
	assert(test2 == true, 4);

	/* Test Case 3: Empty name */
	let name = Vector::empty<u8>();
	let val3: u128 = 11;

	let test3 = ZK::verify(name, val3);
	assert(test3 == true, 43);

	/* Test Case 4: Name with non-printable characters (Returns (intentional) error, fails functional tests at runtime) */
	// let name = Vector::empty<u8>();
	// Vector::push_back(&mut name, 5);
	// let val4: u128 = 21;

	// let test4 = ZK::verify(name, val4);
	// assert(test4 == true, 44);

	/* Test Case 5: Negative val (Transaction aborts with ARITHMETIC_ERROR on Move's end, No support for negative numbers) */
	// let name = Vector::empty<u8>();
	// Vector::push_back(&mut name, 65);
	// let a: u128  = 0;
	// let b: u128  = 100;
	// let _: u128 = a-b;

	//let test5 = ZK::verify(name, val5);
	//assert(test5 == false, 45);

	/* Test Case 6: val6 = 0  */
	// let name = Vector::empty<u8>();
	// Vector::push_back(&mut name, 65);
	// let val6: u128 = 0;

	// let test6 = ZK::verify(name, val6);
	// assert(test6 == false, 46);

	/* Test Case 7: val7 large (val7 > PRIME) Irrelevant because size(u128) < PRIME (Field size in Cairo) */
	// let name = Vector::empty<u8>();
	// Vector::push_back(&mut name, 65);
	// let val7: u128 = 3618502788666131213697322783095070105623107215331596699973092056135872020485;

	// let test7 = ZK::verify(name, val7);
	// assert(test7 == true, 47);


	/* Some incorrect instruction formats */
	// let name = Vector::empty<u8>();
	// Vector::push_back(&mut name, 5);
	// let val4: u128 = 21;


	// Causes Functional Test Runtime Error (Switches arguments)
	//let _ = ZK::verify(val4, name);

	// Causes Functional Test Runtime Error (Incorrect types for one of them)
	//let _ = ZK::verify(name, name);

	// Causes Functional Test Runtime Error (Extra Argument)
	//let _ = ZK::verify(name, val4, val4);
}
}
