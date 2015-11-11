#!/bin/bash
NS="10000 100000 1000000"
DS="256 512 1024 2048 4096"
EXPERIMENTS="cluster local"

# Prepare the data
echo "Preparing the experiments"
~/spark-ec2/experiments/prepare.sh

echo "Finished preparing"


# Execute
export NUM_PARTS=$(( 256 ))

for EXPERIMENT in $EXPERIMENTS
do
  for N in $NS
  do
  for D in $DS
  do
     export N=$N
     export D=$D
     TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
     LOG_FILE=/vol7/pca-$EXPERIMENT-$N-$D-$TIMESTAMP.log

     echo "Writing to log file $LOG_FILE"
     ~/spark-ec2/experiments/pca/run-$EXPERIMENT.sh &> $LOG_FILE

     # grep for the important things
     less $LOG_FILE | grep -i 'OutOfMemoryError' || true
     less $LOG_FILE | grep -i 'INFO PCATradeoffs' || true
  done
  done
done

