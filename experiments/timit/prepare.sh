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

# Have to call this part of keystone setup.sh because of bug in setup scripts...
/root/matrix-bench/build-openblas-ec2.sh
/root/spark-ec2/copy-dir /root/openblas-install

~/spark/sbin/slaves.sh rm /etc/ld.so.conf.d/atlas-x86_64.conf
~/spark/sbin/slaves.sh ldconfig
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

rm /etc/ld.so.conf.d/atlas-x86_64.conf
ldconfig
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

