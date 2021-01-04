script {
    use 0x1::TrustedAccounts;
    fun update_trusted (vec_my: vector<address>, vec_follow: vector<address>) {
        TrustedAccounts::update(
            account,
            vec_my, //update_my
            vec_follow, //update_follow
        );
    }
}
