#!/bin/bash
NUM_FEATURES=${NUM_FEATURES:-1024}
NUM_PARTS=${NUM_PARTS:-256}

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.text.AmazonReviewsPipelineSystemML \
  --trainLocation /amazon/train \
  --testLocation /amazon/test \
  --scriptLocation /root/keystone/bin/LinearRegCG.dml \
  --bOutLocation /dev/null \
  --numParts $NUM_PARTS \
  --commonFeatures $NUM_FEATURES

popd > /dev/null

