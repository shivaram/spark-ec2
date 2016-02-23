#!/bin/bash
NUM_FEATURES=${NUM_FEATURES:-1024}
NUM_PARTS=${NUM_PARTS:-256}
set -e

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.text.AmazonReviewsVWFeaturizer \
  --trainLocation /amazon/train \
  --testLocation /amazon/test \
  --trainOutLocation /$TIMESTAMP/train/data \
  --testOutLocation /$TIMESTAMP/test/data \
  --numParts $NUM_PARTS \
  --commonFeatures $NUM_FEATURES

time /root/mapreduce/bin/hadoop jar /root/mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.0.jar \
    -Dmapred.job.map.memory.mb=2000 \
    -input /$TIMESTAMP/train/data \
    -output /$TIMESTAMP/out \
    -mapper /root/spark-ec2/experiments/amazon/vw-streaming-task.sh \
    -reducer NONE

mkdir $TIMESTAMP
/root/ephemeral-hdfs/bin/hadoop dfs -copyToLocal /$TIMESTAMP/out/model $TIMESTAMP/
/root/spark-ec2/copy-dir /root/keystone/$TIMESTAMP/
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh pipelines.text.VWAmazonReviewsEval \
    --dataLocation /$TIMESTAMP/train/data \
    --vwLocation /root/vowpal_wabbit/vowpalwabbit/vw \
    --modelLocation /root/keystone/$TIMESTAMP/model

popd > /dev/null
echo "wrote to hdfs /$TIMESTAMP/out"

