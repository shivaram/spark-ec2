#!/bin/bash

pushd /root/pipelines

# Copy training data
/root/ephemeral-hdfs/bin/stop-mapred.sh
/root/ephemeral-hdfs/bin/start-mapred.sh
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-train/ /imagenet-train
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-validation/ /imagenet-validation

# Build pipelines
git checkout -- .
git pull
sbt/sbt assembly

# Setup lib and conf correctly
cp /root/ephemeral-hdfs/conf/core-site.xml /root/pipelines/conf/
/root/spark-ec2/copy-dir /root/pipelines/conf

cp /root/pipelines/lib/openblas/libjblas.so /root/pipelines/lib/
/root/spark-ec2/copy-dir /root/pipelines/lib

popd
