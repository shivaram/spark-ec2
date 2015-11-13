#!/bin/bash
NUM_PARTS=${NUM_PARTS:-256}

pushd /root/keystone > /dev/null
export SPARK_HOME=/root/spark
time KEYSTONE_MEM=97g /root/keystone/bin/run-pipeline.sh \
  pipelines.images.voc.NoOptVOCPipeline \
  --trainLocation /data/VOCtrainval_06-Nov-2007.tar \
  --testLocation /data/VOCtest_06-Nov-2007.tar \
  --labelPath /root/keystone/src/test/resources/images/voclabels.csv \
  --numParts $NUM_PARTS

popd > /dev/null

