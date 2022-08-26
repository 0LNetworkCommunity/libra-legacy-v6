//# init --validators Alice

//# publish
module Alice::M {
    use DiemFramework::Debug::print;
    use Std::ASCII;

    public fun do_it() {
        print(&ASCII::string(b"hello"));
    }
}

//# run --admin-script --signers DiemRoot Alice --show-events
script {
    use Alice::M;

    fun main(_dr: signer, _sender: signer) {
        M::do_it();
    }
}
