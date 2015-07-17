#!/bin/bash
set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
HADOOP=/root/ephemeral-hdfs/bin/hadoop

/root/ephemeral-hdfs/bin/start-all.sh

# Get the data from S3
$HADOOP distcp s3n://timit-data/timit-train-features.csv /
$HADOOP distcp s3n://timit-data/timit-train-labels.sparse /
$HADOOP distcp s3n://timit-data/timit-test-features.csv /
$HADOOP distcp s3n://timit-data/timit-test-labels.sparse /
$HADOOP dfs -copyToLocal /timit-train-labels.sparse /
$HADOOP dfs -copyToLocal /timit-test-labels.sparse /

export SPARK_HOME=/root/spark
KEYSTONE_MEM=4g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.VWTimitFeaturizer \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --vwFeaturesWriteLocation /$TIMESTAMP/data \
  --numCosines 1

/root/vowpal_wabbit/cluster/spanning_tree

$HADOOP jar /root/ephemeral-hdfs/contrib/streaming/hadoop-streaming-1.0.4.jar \
    -files runvw.sh \
    -Dmapred.job.map.memory.mb=2000 \
    -input /$TIMESTAMP/data \
    -output /$TIMESTAMP/out \
    -mapper runvw.sh \
    -reducer NONE

echo "wrote to hdfs /$TIMESTAMP/out"
