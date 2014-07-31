#!/bin/bash

# Checkout prober-bench branch

pushd /root/pipelines

git checkout -- .
git checkout prober-bench

git pull
sbt/sbt clean assembly

popd

# Build BLAS for this machine
# TODO: Copy this from s3 ?
pushd /root/OpenBLAS
make clean
make
rm -rf /root/openblas-install
make install PREFIX=/root/openblas-install

# Build JBLAS for this machine
# TODO: Copy this from s3 ?
pushd /root/jblas
make clean
./configure --static-libs --libpath="/root/openblas-install/lib/" --lapack-build
make
cp src/main/resources/lib/static/Linux/amd64/sse3/libjblas.so /root/pipelines/lib/
popd
