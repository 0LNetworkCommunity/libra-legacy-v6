//# init --validators Alice

// Tests for ethereum keccak function
// use solidity contract from the gist and Remix to get more keccak hashes
// https://gist.github.com/coin1111/4bcf291a370f1a2be329089589717d3b

//# run --admin-script --signers DiemRoot Alice
script{
    use DiemFramework::XHash;
    use Std::Hash;

    fun main() {
        // test1
        let v1 = XHash::keccak_256(b"testing");
        let v2 = x"5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02";
        assert!(v1 == v2, 1);

        // test2
        v1 = XHash::keccak_256(b"hello world");
        v2 = x"47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad";
        assert!(v1 == v2, 1);

        // test3 sha3 != keccak
        let bs = b"hello world";
        v1 = XHash::keccak_256(copy bs);
        v2 = Hash::sha3_256(copy bs);
        assert!(v1 != v2, 1);
    }
}