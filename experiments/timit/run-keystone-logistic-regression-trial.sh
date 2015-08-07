#!/bin/bash
set -e

NUM_COSINES=${NUM_COSINES:-16}
NUM_PARTS=${NUM_PARTS:-256}

# Get the timestamp for this run
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.LogisticRegressionTimitFeaturizer \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --trainOutLocation /$TIMESTAMP/train/data \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --testOutLocation /$TIMESTAMP/test/data \
  --numParts $NUM_PARTS \
  --numCosines $NUM_COSINES

time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh pipelines.speech.LogisticRegressionTimitSolverEval \
    --trainDataLocation /$TIMESTAMP/train/data \
    --testDataLocation /$TIMESTAMP/test/data

popd > /dev/null

