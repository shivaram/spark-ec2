#!/bin/bash

pushd /root/pipelines

# Copy training data
/root/ephemeral-hdfs/bin/stop-mapred.sh
/root/ephemeral-hdfs/bin/start-mapred.sh
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-train/ /imagenet-train
#/root/ephemeral-hdfs/bin/hadoop distcp s3n://imagenet-validation/ /imagenet-validation

# Build pipelines
# git checkout -- .
git stash
git pull
sbt/sbt assembly

# Setup lib and conf correctly
cp /root/ephemeral-hdfs/conf/core-site.xml /root/pipelines/conf/
/root/spark-ec2/copy-dir /root/pipelines/conf

cp /root/pipelines/lib/openblas/libjblas.so /root/pipelines/lib/
/root/spark-ec2/copy-dir /root/pipelines/lib

popd

# Replace the spark setup with our own Spark
pushd /root
s3cmd get s3://spark1.1-pipelines/spark-1.1-pipelines.tar.gz
s3cmd get s3://spark1.1-pipelines/spark-1.1-pipelines-m2.tar.gz

# Now for m2
mkdir -p /tmp/test
pushd /tmp/test
  tar -xf /root/spark-1.1-pipelines-m2.tar.gz
  pushd root
    cp -r .m2/repository/org/apache/spark/* ~/.m2/repository/org/apache/spark/
  popd
popd
rm -rf /tmp/test

# Get the binary dist right
mv /root/spark /root/spark-old

mkdir -p /tmp/test
pushd /tmp/test
  tar -xf /root/spark-1.1-pipelines.tar.gz
  cp /root/spark-old/conf/* ./spark/conf/
  mv ./spark /root/spark
popd

rm -rf /tmp/test

/root/ephemeral-hdfs/bin/slaves.sh rm -rf /root/spark
/root/spark-ec2/copy-dir /root/spark

#spark-1.1-pipelines.tar.gz
#spark-1.1-pipelines-m2.tar.gz

popd
