#!/bin/bash
set -e
set -x

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
pushd /root/keystone > /dev/null
for CLUSTER_SIZE in 16 24 32
do
  # Change the cluster size
  ~/spark-ec2/experiments/resize-cluster.sh $CLUSTER_SIZE &> /dev/null

  # Run the trials at that cluster size
  for TRIAL in a b c
  do
    export SPARK_HOME=/root/spark
    (time KEYSTONE_MEM=100g /root/keystone/bin/run-pipeline.sh \
      pipelines.speech.TimitPipeline \
      --trainDataLocation /timit-train-features.csv \
      --trainLabelsLocation /timit-train-labels.sparse \
      --testDataLocation /timit-test-features.csv \
      --testLabelsLocation /timit-test-labels.sparse \
      --numParts $((CLUSTER_SIZE * 8)) \
      --numCosines 16 \
      --numEpochs 1 \
      ) &> /vol7/scaling/$CLUSTER_SIZE-node/trial-$TIMESTAMP-$TRIAL.log
  done
done
popd > /dev/null

