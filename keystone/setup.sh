#!/bin/bash

pushd /root

# Checkout keystone
if [ ! -d "/root/keystone" ]; then
  git clone https://github.com/shivaram/keystone.git -b imagenet-research
fi

pushd /root/keystone

# Build keystone
git stash
git pull
sbt/sbt assembly
make

/root/spark-ec2/copy-dir /root/keystone

popd

# Build openblas and link it correctly

if [ ! -d "/root/matrix-bench" ]; then
  git clone https://github.com/shivaram/matrix-bench.git
fi

/root/matrix-bench/build-openblas-ec2.sh
/root/spark-ec2/copy-dir /root/openblas-install

~/spark/sbin/slaves.sh rm /etc/ld.so.conf.d/atlas-x86_64.conf
~/spark/sbin/slaves.sh ldconfig
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

rm /etc/ld.so.conf.d/atlas-x86_64.conf
ldconfig
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

/root/spark/sbin/stop-all.sh

~/spark/sbin/slaves.sh rm -rf /root/spark/work
~/spark/sbin/slaves.sh mkdir -p /mnt/spark-work 
~/spark/sbin/slaves.sh ln -s /mnt/spark-work /root/spark/work

/root/spark/sbin/start-all.sh

mkdir -p /mnt/spark-events
