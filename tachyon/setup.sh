#!/bin/bash

/root/spark-ec2/copy-dir /root/tachyon

/root/tachyon/bin/format.sh

sleep 1

bash -x /root/tachyon/bin/start.sh all Mount
