#!/bin/bash
HADOOP=/root/mapreduce/bin/hadoop

# Start mapreduce if necessary
/root/mapreduce/bin/start-mapred.sh
/root/ephemeral-hdfs/sbin/start-all.sh

# Get the data from S3
$HADOOP distcp s3n://files.sparks.west/data/amazon/ /amazon

# Some more one-time setup so vw works correctly
/root/spark/sbin/slaves.sh chmod -R ugo+rwx /root/vowpal_wabbit
/root/vowpal_wabbit/cluster/spanning_tree

