#!/bin/bash

pushd /root

# Check if we can clone keystone
if [[ `curl -I https://api.github.com/repos/amplab/keystone 2>/dev/null | head -1 | awk '{print $2}'` == "200" ]]; then
  # Checkout keystone
  if [ ! -d "/root/keystone" ]; then
    git clone https://github.com/amplab/keystone.git
  fi

  pushd /root/keystone

  # Build keystone
  git stash
  git pull
  sbt/sbt assembly

  popd
else
  echo "Keystone repo cannot be accessed. Skipping clone and build."
fi

# Build openblas and link it correctly

if [ ! -d "/root/matrix-bench" ]; then
  git clone https://github.com/shivaram/matrix-bench.git
fi

/root/matrix-bench/build-openblas-ec2.sh
/root/spark-ec2/copy-dir /root/openblas-install

~/ephemeral-hdfs/bin/slaves.sh rm /etc/ld.so.conf.d/atlas-x86_64.conf
~/ephemeral-hdfs/bin/slaves.sh ldconfig
~/ephemeral-hdfs/bin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
~/ephemeral-hdfs/bin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

rm /etc/ld.so.conf.d/atlas-x86_64.conf
ldconfig
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

/root/spark/sbin/stop-all.sh

~/ephemeral-hdfs/bin/slaves.sh rm -rf /root/spark/work
~/ephemeral-hdfs/bin/slaves.sh mkdir -p /mnt/spark-work 
~/ephemeral-hdfs/bin/slaves.sh ln -s /mnt/spark-work /root/spark/work

/root/spark/sbin/start-all.sh
