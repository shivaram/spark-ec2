#!/bin/bash

chmod u+x /root/cs194-16_lab/machine_setup.sh
/root/spark-ec2/copy-dir /root/cs194-16

for slave in $SLAVES; do
    # Kill all existing screens (to kill any existing ipython notebooks) and then setup the machine.
    ssh $slave StrictHostKeyChecking=no -o ConnectTimeout=5 "/root/cs194-16/machine_setup.sh"
done
