#!/bin/bash --

case $0 in
   (/*) dir=${0%/*}/;;
   (*/*) dir=./${0%/*};;
   (*) dir=.;;
esac
cd "$dir"

unset dir CARGO_INCREMENTAL LD_LIBRARY_PATH LD_RUN_PATH RUST_BACKTRACE
export RUSTFLAGS='-Clto -Cpanic=abort'

which apt-get >/dev/null 2>&1 &&
   sudo apt-get -y install build-essential m4 curl gnupg2 xz cargo gnupg gpg gpgv2
which dnf > /dev/null 2>&1 && sudo dnf -y install gcc gpg xz cargo
tmpdir=$(mktemp -d /var/tmp/vdf.XXXXXX)
trap 'rm -rf -- "$tmpdir"' EXIT
recv_gpg_keys () {
   gpg2 --keyserver=keys.gnupg.net \
        --homedir=. \
        --recv-keys 343c2ff0fbee5ec2edbef399f3599ff828c67298
}

until recv_gpg_keys; do :; done

fetch_file () {
  test -f "$1" ||
     until curl --location -O --proto '=https' "https://gmplib.org/download/gmp/$1"; do :; done
}

for i in '' .sig; do fetch_file "gmp-6.1.2.tar.xz$i"; done
gpgv2 --keyring=./pubring.kbx gmp-6.1.2.tar.xz.sig gmp-6.1.2.tar.xz || exit $?
mkdir build 2>/dev/null || { rm -rf build && mkdir build; }
tar xJvf gmp-6.1.2.tar.xz
cd build
libdir=/usr/lib
test -d /usr/lib64 && libdir=/usr/lib64
../gmp-6.1.2/configure --prefix=/usr "--libdir=$libdir" 'CFLAGS=-O3 -march=native'
make -j2 && make check
sudo make install
sudo ldconfig

cargo install --force --path=vdf-competition
