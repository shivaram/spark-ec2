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

# Hack to make sure keystone will still install properly after
ln -s /usr/lib64/libgfortran.so.3 /usr/lib64/libgfortran.so

# install vowpal wabbit
cd vowpal_wabbit
./autogen.sh
make
sudo make install

popd > /dev/null

