#!/bin/bash
HADOOP=/root/mapreduce/bin/hadoop

# Start mapreduce if necessary
/root/mapreduce/bin/start-mapred.sh
/root/ephemeral-hdfs/sbin/start-all.sh

pushd /mnt > /dev/null

#Get the data
wget https://s3-us-west-2.amazonaws.com/voc-data/VOCtrainval_06-Nov-2007.tar
wget https://s3-us-west-2.amazonaws.com/voc-data/VOCtest_06-Nov-2007.tar

#Copy to HDFS
/root/ephemeral-hdfs/bin/hadoop dfs -copyFromLocal VOCtrainval_06-Nov-2007.tar /data/
/root/ephemeral-hdfs/bin/hadoop dfs -copyFromLocal VOCtest_06-Nov-2007.tar /data/

popd > /dev/null

