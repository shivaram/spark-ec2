#!/bin/bash
set -e

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.text.AmazonReviewsPipeline \
  --trainLocation /amazon/train \
  --testLocation /amazon/test \
  --numParts 512

popd > /dev/null

