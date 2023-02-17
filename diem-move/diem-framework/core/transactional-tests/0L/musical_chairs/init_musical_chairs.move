//# init --validators Alice Bob

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MusicalChairs;
    fun main(_dr: signer, _sender: signer) {
        // using testnet values from Globals.move
        let a = MusicalChairs::get_current_seats();
        assert!(a == 10, 10001);
    }
}
//check: EXECUTED
