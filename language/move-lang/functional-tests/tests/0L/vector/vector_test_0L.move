//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

script {
use 0x1::Vector;

fun main() {

    let hash = x"65c91b90421bee9187417079142e69af67ce885a2f506aa061444cadb5064437";

    let identical = x"65c91b90421bee9187417079142e69af67ce885a2f506aa061444cadb5064437";

    let equal = Vector::compare(&identical, &hash);
    assert(equal == true, 666);

    assert(hash == identical, 6666);


}
}
