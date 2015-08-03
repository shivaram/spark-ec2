#!/bin/bash
git clone --single-branch --branch imagenet-research https://github.com/shivaram/keystone.git /mnt/imagenet-keystone

pushd /mnt/imagenet-keystone > /dev/null
cp ~/keystone/sbt/sbt sbt/.
sbt/sbt assembly
~/spark-ec2/copy-dir /mnt/imagenet-keystone

HADOOP=/root/mapreduce/bin/hadoop

# Start mapreduce if necessary
/root/mapreduce/bin/start-mapred.sh
/root/ephemeral-hdfs/sbin/start-all.sh

# Get the data from S3
$HADOOP distcp s3n://imagenet-train-all-scaled-tar/imagenet-train-all-scaled-tar /
$HADOOP distcp s3n://imagenet-validation-all-scaled-tar/imagenet-validation-all-scaled-tar /

popd > /dev/null
