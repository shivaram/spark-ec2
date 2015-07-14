#!/usr/bin/env bash

pushd /root > /dev/null

# download vowpal wabbit
wget https://github.com/JohnLangford/vowpal_wabbit/archive/8.0.zip
unzip 8.0.zip
rm 8.0.zip
mv vowpal_wabbit-8.0 vowpal_wabbit

# install the requirements
sudo yum -q -y install boost-devel libtool
sudo yum -q -y install zlib-devel

# install vowpal wabbit
cd vowpal_wabbit
./autogen.sh
make
sudo make install

popd > /dev/null

