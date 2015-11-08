#!/bin/bash
EXPERIMENTS="amazon timit"
NON_EXACT_SOLVERS="block lbfgs"
NUM_FEATURES_SET="1024 2048 4096 8192 16384"

# Prepare the data
echo "Preparing all the data"
~/spark-ec2/experiments/prepare.sh
~/spark-ec2/experiments/amazon/prepare.sh
~/spark-ec2/experiments/timit/prepare.sh

echo "Finished preparing the data"

set -e

# Execute the non-exact trials
for NUM_FEATURES in $NUM_FEATURES_SET
do
  for SOLVER in $NON_EXACT_SOLVERS
  do
    export NUM_PARTS=$(( 256 ))
    export NUM_FEATURES=$NUM_FEATURES
    export NUM_COSINES=$(( NUM_FEATURES / 1024 ))

    for EXPERIMENT in $EXPERIMENTS
    do
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      LOG_FILE=/vol7/$EXPERIMENT-$SOLVER-solver-$NUM_FEATURES-$TIMESTAMP.log

      echo "Writing to log file $LOG_FILE"
      ~/spark-ec2/experiments/$EXPERIMENT/run-$SOLVER-solver.sh &> $LOG_FILE

      # grep for the important things
      less $LOG_FILE | grep -i 'Finished Solve' || true
      less $LOG_FILE | grep 'F1' || true
      less $LOG_FILE | grep -i 'accuracy' || true
      less $LOG_FILE | grep -i 'train error' || true
      less $LOG_FILE | grep 'real' || true
    done
  done
done

# Execute the exact trials
SOLVER="exact"
EXPERIMENT="timit"
for NUM_FEATURES in 1024 2048 4096 8192
do
  export NUM_PARTS=$(( 256 ))
  export NUM_FEATURES=$NUM_FEATURES
  export NUM_COSINES=$(( NUM_FEATURES / 1024 ))

  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  LOG_FILE=/vol7/$EXPERIMENT-$SOLVER-solver-$NUM_FEATURES-$TIMESTAMP.log

  echo "Writing to log file $LOG_FILE"
  ~/spark-ec2/experiments/$EXPERIMENT/run-$SOLVER-solver.sh &> $LOG_FILE

  # grep for the important things
  less $LOG_FILE | grep -i 'Finished Solve' || true
  less $LOG_FILE | grep 'F1' || true
  less $LOG_FILE | grep -i 'accuracy' || true
  less $LOG_FILE | grep -i 'train error' || true
  less $LOG_FILE | grep 'real' || true
done

EXPERIMENT="amazon"
for NUM_FEATURES in 1024 2048
do
  export NUM_PARTS=$(( 256 ))
  export NUM_FEATURES=$NUM_FEATURES
  export NUM_COSINES=$(( NUM_FEATURES / 1024 ))

  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  LOG_FILE=/vol7/$EXPERIMENT-$SOLVER-solver-$NUM_FEATURES-$TIMESTAMP.log

  echo "Writing to log file $LOG_FILE"
  ~/spark-ec2/experiments/$EXPERIMENT/run-$SOLVER-solver.sh &> $LOG_FILE

  # grep for the important things
  less $LOG_FILE | grep -i 'Finished Solve' || true
  less $LOG_FILE | grep 'F1' || true
  less $LOG_FILE | grep -i 'accuracy' || true
  less $LOG_FILE | grep -i 'train error' || true
  less $LOG_FILE | grep 'real' || true
done

