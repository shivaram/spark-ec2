#!/bin/bash
set -e

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR=/vol7/timit-vw-$TIMESTAMP

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=4g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.VWTimitFeaturizer \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --vwFeaturesWriteLocation /$TIMESTAMP/data \
  --numCores 8 \
  --numCosines 1

popd > /dev/null

time /root/mapreduce/bin/hadoop jar /root/mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.0.jar \
    -Dmapred.job.map.memory.mb=2000 \
    -input /$TIMESTAMP/data \
    -output /$TIMESTAMP/out \
    -mapper /root/spark-ec2/experiments/timit/vw-streaming-task.sh \
    -reducer NONE

/root/ephemeral-hdfs/bin/hadoop dfs -copyToLocal /$TIMESTAMP/out/mapperout $OUTPUT_DIR/vw-mapper.out
echo "wrote to hdfs /$TIMESTAMP/out"
