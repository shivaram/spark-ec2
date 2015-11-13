#!/bin/bash
NUM_PARTS=${NUM_PARTS:-256}

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.text.AllOptAmazonPipeline \
  --trainLocation /amazon/train \
  --testLocation /amazon/test \
  --numParts $NUM_PARTS

popd > /dev/null

