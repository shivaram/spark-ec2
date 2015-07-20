#!/bin/bash
set -e

HADOOP=/root/mapreduce/bin/hadoop

/root/mapreduce/bin/start-mapred.sh

# Get the data from S3
$HADOOP distcp s3n://timit-data/timit-train-features.csv /
$HADOOP distcp s3n://timit-data/timit-train-labels.sparse /
$HADOOP distcp s3n://timit-data/timit-test-features.csv /
$HADOOP distcp s3n://timit-data/timit-test-labels.sparse /
$HADOOP dfs -copyToLocal /timit-train-labels.sparse /
$HADOOP dfs -copyToLocal /timit-test-labels.sparse /

# Some more one-time setup so vw works correctly
/root/spark/sbin/slaves.sh chmod -R ugo+rwx /root/vowpal_wabbit
/root/vowpal_wabbit/cluster/spanning_tree

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
KEYSTONE_MEM=4g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.VWTimitFeaturizer \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --vwFeaturesWriteLocation /$TIMESTAMP/data \
  --numCores 8 \
  --numCosines 1

popd > /dev/null

$HADOOP jar /root/mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.0.jar \
    -Dmapred.job.map.memory.mb=2000 \
    -input /$TIMESTAMP/data \
    -output /$TIMESTAMP/out \
    -mapper /root/spark-ec2/vw-timit-streaming-task.sh \
    -reducer NONE

echo "wrote to hdfs /$TIMESTAMP/out"
