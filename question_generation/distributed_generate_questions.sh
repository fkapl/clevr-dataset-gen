#!/bin/bash

# Example usage
# ./distributed_generate_data.sh /path/to/your/output/folder /path/to/your/binds.json
# ./distributed_generate_data.sh output precomputed_binds/train_binds_alpha_0.60.json

# Call the sbatch script to generate images with different starting idx

# Train_Val_TestID: Right now 3k images per 16 gpus = 48k images
# Test_COOD: 300 images per gpu = 4800 images
# Define the number of iterations and the stepsize
NUMBER_OF_JOBS=96
NUMBER_OF_QUESTIONS=500 # 3000 for train

# Loop from 1 to NUMBER_OF_ITERATIONS
for (( i=0; i<NUMBER_OF_JOBS; i++ ))
do
  # Calculate the argument as iteration number multiplied by stepsize
  START=$(( i * NUMBER_OF_QUESTIONS ))
  END=$(( (i + 1) * NUMBER_OF_QUESTIONS ))

  # Call the other script with the calculated argument
  sbatch generate_clevrtex_qa.sbatch "$START" "$END"

  # Optional: Print a message indicating progress
  echo "Iteration $i: Called generate_clevrtex_qa.sbatch with starting idx $START and ending idx $END"
done