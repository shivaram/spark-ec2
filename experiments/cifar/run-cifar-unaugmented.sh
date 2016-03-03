#!/bin/bash
set -e
set -x

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
#NUM_FILTERS=5120
pushd /root/keystone > /dev/null
# Run the trials at that cluster size
TRIAL="l"
for NUM_FILTERS in 20480 30720 #16384 #20480 #512 1024 2048 4096 5120 8192 10240 16384 #b c
do
  for LAMBDA in 1000 3000
  do
    export SPARK_HOME=/root/spark
    (time KEYSTONE_MEM=100g /root/keystone/bin/run-pipeline.sh \
      pipelines.images.cifar.RandomPatchCifar \
      --trainLocation /mnt/cifar_train.bin \
      --testLocation /mnt/cifar_test.bin \
      --numFilters $NUM_FILTERS \
      --lambda $LAMBDA
      ) &> /mnt/cifar-logs/cifar-unaugmented-trial-$TIMESTAMP-$TRIAL-$NUM_FILTERS-$LAMBDA.log
  done
done
popd > /dev/null
