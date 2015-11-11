#!/bin/bash
NUM_PARTS=${NUM_PARTS:-256}
export OMP_NUM_THREADS=8 

pushd /root/keystone > /dev/null
unset SPARK_HOME
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.PCATradeoffs \
  --local True \
  --numParts $NUM_PARTS

popd > /dev/null

