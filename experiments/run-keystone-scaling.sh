#!/bin/bash
EXPERIMENTS="amazon timit imagenet"
CLUSTER_SIZES="128 64 32 16 8"

# Prepare the data
echo "Preparing all the data"
~/spark-ec2/experiments/prepare.sh
for EXPERIMENT in $EXPERIMENTS
do
    ~/spark-ec2/experiments/$EXPERIMENT/prepare.sh
done
echo "Finished preparing the data"

set -e

# Execute the trials
for CLUSTER_SIZE in $CLUSTER_SIZES
do
  # Change the cluster size
  echo "Changing cluster to $CLUSTER_SIZE nodes"
  ~/spark-ec2/experiments/resize-cluster.sh $CLUSTER_SIZE &> /dev/null

  # Run the trials at that cluster size
  export NUM_PARTS=$(( CLUSTER_SIZE * 8 > 256 ? CLUSTER_SIZE * 8 : 256 ))
  for EXPERIMENT in $EXPERIMENTS
  do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE=/vol7/$EXPERIMENT-$CLUSTER_SIZE-nodes-$TIMESTAMP.log

    echo "Writing to log file $LOG_FILE"
    ~/spark-ec2/experiments/$EXPERIMENT/run-keystone-trial.sh &> $LOG_FILE

    # grep for the important things
    less $LOG_FILE | grep 'F1' || true
    less $LOG_FILE | grep -i 'accuracy' || true
    less $LOG_FILE | grep -i 'test error' || true
    less $LOG_FILE | grep 'real' || true
  done
done

