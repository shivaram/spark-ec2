#!/bin/bash
set -e

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR=/vol7/timit-vw-$TIMESTAMP

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.VWTimitFeaturizer \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --trainOutLocation /$TIMESTAMP/train/data \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --testOutLocation /$TIMESTAMP/test/data \
  --numParts 512 \
  --numCosines 16

time /root/mapreduce/bin/hadoop jar /root/mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.0.jar \
    -Dmapred.job.map.memory.mb=2000 \
    -input /$TIMESTAMP/train/data \
    -output /$TIMESTAMP/out \
    -mapper /root/spark-ec2/experiments/timit/vw-streaming-task.sh \
    -reducer NONE

mkdir $TIMESTAMP
/root/ephemeral-hdfs/bin/hadoop dfs -copyToLocal /$TIMESTAMP/out/model $TIMESTAMP/
/root/spark-ec2/copy-dir /root/keystone/$TIMESTAMP/
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh pipelines.speech.VWTimitEval \
    --dataLocation /$TIMESTAMP/test/data \
    --vwLocation /root/vowpal_wabbit/vowpalwabbit/vw \
    --modelLocation /root/keystone/$TIMESTAMP/model

popd > /dev/null
echo "wrote to hdfs /$TIMESTAMP/out"

