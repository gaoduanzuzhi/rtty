#!/usr/bin/env bash

[ $# -ge 1 ] || {
    echo argc = $#
    echo "SYNTAX: $0  <envfile> [action] "
    exit
}

TOP_DIR=`pwd`

TOOLS_DIR=`dirname $1`
ENV_FILE=`basename $1`
TOOLCHAIN_DIR=$TOOLS_DIR/toolchain

echo $TOOLS_DIR  $ENV_FILE
cd $TOOLS_DIR
. $ENV_FILE
echo $ARCH $OUI


LIB_DIR=$TOP_DIR/libs

BIN_DIR=$TOP_DIR/bin

LIBEV_DIR=$TOP_DIR/mod/libev/
 
LIBMBEDTLS_DIR=$TOP_DIR/mod/mbedtls/

# clean dir



CC=${CROSS_COMPILE}gcc
echo $CC

export CC

# build libev
build_libev(){
    cd $LIBEV_DIR
    CC=${CROSS_COMPILE}gcc ./configure -q  --prefix=$BIN_DIR  --host=${ARCH}-linux
    make clean
    make
    make install
}


# build mbedtls
build_mbedtls(){
    cd $LIBMBEDTLS_DIR
    rm -rf build
    mkdir build
    cd build
    CC=${CROSS_COMPILE}gcc cmake .. 
    make 
}


# build rtty

build_rtty(){

    cd $TOP_DIR
    mkdir -p bin
    rm -rf build
    mkdir build
    cd build
    cmake .. -DRTTY_USE_MBEDTLS=1 -DLIBEV_LIBRARY=../bin/lib/libev.a -DLIBEV_INCLUDE_DIR=../bin/include/  -DMBEDTLS_LIBRARY=../mod/mbedtls/build/library/libmbedtls.a -DMBEDTLS_INCLUDE_DIR=../mod/mbedtls/build/include/ -DMBEDX509_LIBRARY=../mod/mbedtls/build/library/libmbedx509.a -DMBEDCRYPTO_LIBRARY=../mod/mbedtls/build/library/libmbedcrypto.a

    make
    readelf -d src/rtty
    cp src/rtty $TOP_DIR/bin/rtty.$OUI
    freedpi up_ct $TOP_DIR/bin/rtty.$OUI
}

# main
build_libev
build_mbedtls
build_rtty
