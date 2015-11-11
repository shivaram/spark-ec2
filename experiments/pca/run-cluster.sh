#!/bin/bash
N=${N:-10000}
D=${D:-256}
NUM_PARTS=${NUM_PARTS:-256}
export SPARK_HOME=/root/spark
export OMP_NUM_THREADS=1

pushd /root/keystone > /dev/null
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.PCATradeoffs \
  --local False \
  --numParts $NUM_PARTS \
  --ns $N \
  --ds $D

popd > /dev/null

