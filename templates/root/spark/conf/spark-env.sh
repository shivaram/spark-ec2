#!/usr/bin/env bash

export JAVA_HOME="{{java_home}}"
export SPARK_LOCAL_DIRS="{{spark_local_dirs}}"

# Standalone cluster options
export SPARK_MASTER_OPTS=""
export SPARK_WORKER_INSTANCES=1
export SPARK_WORKER_CORES=8

export OMP_NUM_THREADS=1

export HADOOP_HOME="/root/ephemeral-hdfs"
export SPARK_MASTER_IP={{active_master}}
export MASTER=`cat /root/spark-ec2/cluster-url`

export SPARK_SUBMIT_LIBRARY_PATH="$SPARK_SUBMIT_LIBRARY_PATH:/root/pipelines/lib"
export SPARK_SUBMIT_CLASSPATH="$SPARK_CLASSPATH:$SPARK_SUBMIT_CLASSPATH:/root/ephemeral-hdfs/conf"

# Bind Spark's web UIs to this machine's public EC2 hostname:
export SPARK_PUBLIC_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname`

#export SPARK_JAVA_OPTS=" -Xss4m $SPARK_JAVA_OPTS"

# Set a high ulimit for large shuffles
ulimit -n 1000000
