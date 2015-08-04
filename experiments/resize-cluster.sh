#!/bin/bash

~/spark/sbin/stop-all.sh
head -n $1 /root/spark-ec2/slaves > ~/spark/conf/slaves
~/spark-ec2/copy-dir ~/spark/conf/slaves
~/spark/sbin/start-all.sh

