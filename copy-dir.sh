#!/bin/bash

if [[ "$#" != "1" ]] ; then
  echo "Usage: copy-dir <dir>"
  exit 1
fi

DIR=`readlink -f "$1"`
DIR=`echo "$DIR"|sed 's@/$@@'`
DEST=`dirname "$DIR"`

SLAVES=`cat /root/spark-openstack/slaves`

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

echo "RSYNC'ing $DIR to slaves..."
for slave in $SLAVES; do
    echo $slave
    rsync -e "ssh $SSH_OPTS" -az "$DIR" "$slave:$DEST" & sleep 0.5
done
wait
