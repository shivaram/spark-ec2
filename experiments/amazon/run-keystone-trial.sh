#!/bin/bash
set -e

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR=/vol7/timit-vw-$TIMESTAMP

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.text.AmazonReviewsPipeline \
  --trainLocation /amazon/train \
  --testLocation /amazon/test \
  --numParts 512

popd > /dev/null

