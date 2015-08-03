#!/bin/bash
HADOOP=/root/mapreduce/bin/hadoop

# Start mapreduce if necessary
/root/mapreduce/bin/start-mapred.sh
/root/ephemeral-hdfs/sbin/start-all.sh

# Get the data from S3
$HADOOP distcp s3n://timit-data/timit-train-features.csv /
$HADOOP distcp s3n://timit-data/timit-train-labels.sparse /
$HADOOP distcp s3n://timit-data/timit-test-features.csv /
$HADOOP distcp s3n://timit-data/timit-test-labels.sparse /
$HADOOP dfs -copyToLocal /timit-train-labels.sparse /
$HADOOP dfs -copyToLocal /timit-test-labels.sparse /

# Some more one-time setup so vw works correctly
/root/spark/sbin/slaves.sh chmod -R ugo+rwx /root/vowpal_wabbit
/root/vowpal_wabbit/cluster/spanning_tree

