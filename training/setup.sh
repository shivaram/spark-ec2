#!/bin/bash

pushd /root

# Make sure screen is installed in the master node
yum install -y screen

# Mount ampcamp-data volume
mount -t ext4 /dev/sdf /ampcamp-data

# Clone and copy training repo
ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# Add hdfs to the classpath
cp /root/ephemeral-hdfs/conf/core-site.xml /root/spark/conf/

popd
