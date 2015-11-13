#!/bin/bash
EXPERIMENTS="voc amazon timit"
OPTS="all endtoend none"

# Prepare the data
echo "Preparing all the data"
~/spark-ec2/experiments/prepare.sh
~/spark-ec2/experiments/amazon/prepare.sh
~/spark-ec2/experiments/timit/prepare.sh
~/spark-ec2/experiments/voc/prepare.sh

echo "Finished preparing the data"

# Execute the non-exact trials
for EXPERIMENT in $EXPERIMENTS
do
  for OPT in $OPTS
  do
    export NUM_PARTS=$(( 256 ))

    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE=/vol7/$EXPERIMENT-opt-$OPT-$TIMESTAMP.log

    echo "Writing to log file $LOG_FILE"
    ~/spark-ec2/experiments/$EXPERIMENT/run-opt-$OPT.sh &> $LOG_FILE

    # grep for the important things
    less $LOG_FILE | grep -i 'Finished training' || true
    less $LOG_FILE | grep -i 'Finished Solve' || true
    less $LOG_FILE | grep 'F1' || true
    less $LOG_FILE | grep -i 'accuracy' || true
    less $LOG_FILE | grep -i 'train error' || true
    less $LOG_FILE | grep ' MAP is' || true
    less $LOG_FILE | grep ' APs are' || true
    less $LOG_FILE | grep 'real' || true
  done
done

