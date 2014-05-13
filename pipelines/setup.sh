#!/bin/bash

pushd /root/pipelines

# Build pipelines
git checkout -- .
git pull
sbt/sbt assembly

# Copy training data
/root/ephemeral-hdfs/bin/stop-mapred.sh
/root/ephemeral-hdfs/bin/start-mapred.sh
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-train/ /imagenet-train
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-validation/ /imagenet-validation

# Setup lib and conf correctly
cp /root/ephemeral-hdfs/conf/core-site.xml /root/pipelines/conf/
/root/spark-ec2/copy-dir /root/pipelines/conf

cp /root/pipelines/lib/cc2.8xlarge/multi-core/libjblas.so /root/pipelines/lib/
/root/spark-ec2/copy-dir /root/pipelines/lib

popd
