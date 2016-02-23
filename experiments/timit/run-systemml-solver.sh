#!/bin/bash
NUM_COSINES=${NUM_COSINES:-1}
NUM_PARTS=${NUM_PARTS:-256}

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.speech.SystemMLSolveTimitPipeline \
  --trainDataLocation /timit-train-features.csv \
  --trainLabelsLocation /timit-train-labels.sparse \
  --scriptLocation /root/keystone/bin/LinearRegCG.dml \
  --bOutLocation /dev/null \
  --testDataLocation /timit-test-features.csv \
  --testLabelsLocation /timit-test-labels.sparse \
  --numParts $NUM_PARTS \
  --numCosines $NUM_COSINES \
  --numEpochs 20

popd > /dev/null

