#!/bin/bash
set -e

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR=/vol7/timit-vw-$TIMESTAMP

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.TimitPipeline \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --numParts 512 \
  --numCosines 16

popd > /dev/null

