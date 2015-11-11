#!/bin/bash
EXPERIMENTS="local cluster"

# Prepare the data
echo "Preparing the experiments"
~/spark-ec2/experiments/prepare.sh

echo "Finished preparing"

set -e

# Execute
export NUM_PARTS=$(( 256 ))

for EXPERIMENT in $EXPERIMENTS
do
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  LOG_FILE=/vol7/pca-$EXPERIMENT-$TIMESTAMP.log

  echo "Writing to log file $LOG_FILE"
  ~/spark-ec2/experiments/pca/run-$EXPERIMENT.sh &> $LOG_FILE

  # grep for the important things
  less $LOG_FILE | grep -i 'PCATradeoffs' || true
done

