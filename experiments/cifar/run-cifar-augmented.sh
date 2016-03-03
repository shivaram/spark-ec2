#!/bin/bash
set -e
set -x

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
NUM_FILTERS=20480
TEST_AUG="false"
pushd /root/keystone > /dev/null
# Run the trials at that cluster size
for TRIAL in shuffleBoth #b c
do
  for LAMBDA in 1e3 3e3 1e2 #1e2 1e0 1e-3 #1e-1 1e2
  do
    export SPARK_HOME=/root/spark
    (time KEYSTONE_MEM=100g /root/keystone/bin/run-pipeline.sh \
      pipelines.images.cifar.RandomPatchCifarFeaturizerRawAugment \
      --trainLocation /mnt/cifar_train.bin \
      --testLocation /mnt/cifar_test.bin \
      --numFilters $NUM_FILTERS \
      --lambda $LAMBDA \
      --numRandomPatchesAugment 10 \
      ) &> /mnt/cifar-logs/cifar-augmented-trial-$TIMESTAMP-$TRIAL-$NUM_FILTERS-$LAMBDA.log
  done
done
popd > /dev/null
