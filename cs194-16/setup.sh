#!/bin/bash

chmod u+x /root/cs194-16/machine_setup.sh
/root/spark-ec2/copy-dir /root/cs194-16

SLAVES=`cat /root/spark-ec2/slaves`

for slave in $SLAVES; do
    # Kill all existing screens (to kill any existing ipython notebooks) and then setup the machine.
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $slave "/root/cs194-16/machine_setup.sh"
done
