#!/bin/bash -x
#SBATCH --job-name=generate_data
#SBATCH --output=slurm_log/generate_data_%j.out     # Standard output log
#SBATCH --error=slurm_log/generate_data_%j.err      # Standard error log
#SBATCH --partition=ml.p4d.24xlarge                  # Partition name (adjust if necessary)
#SBATCH --nodes=1                        # Number of nodes
#SBATCH --ntasks=48                       # Number of tasks (processes)
#SBATCH --cpus-per-task=1              # Number of CPU cores per task
#SBATCH --mem-per-cpu=20G  

#--mem=100G                        # Memory in GB
#--cpus-per-task=6                # Number of CPU cores per task

# sbatch data_generation_pipeline.sh \
#   ~/svib/data_creation/clevrtex_original/output \
#   ~/datasets/clevrtex_original \
#   train_val_test_medium \
#   48000

# sbatch data_generation_pipeline.sh \
#   ~/svib/data_creation/clevrtex_original/output \
#   ~/datasets/clevrtex_original \
#   train_val_test_hard \
#   48000

# E.g. ~/svib/data_creation/clevrtex/output_train_val_test_easy
OUTPUT_DIR=$2
DATASET_STRING=$3
INPUT_DIR="$1/${DATASET_STRING}"
LENGTH_DATASET=$4
# E.g. ~/datasets/clevrtex/properties_train_val_test_easy.json
PROPERTY_FILE="${OUTPUT_DIR}/properties_${DATASET_STRING}.json"
# /fsx/ubuntu/datasets/clevrtex_original/questions_train_val_test_easy
QUESTION_OUTPUT_PATH="${OUTPUT_DIR}/questions_${DATASET_STRING}"
#~/datasets/clevrtex/questions_train_val_test_easy.json
OUTPUT_FILE="${OUTPUT_DIR}/${DATASET_STRING}.hdf5"

echo "INPUT_DIR: $INPUT_DIR"
echo "OUTPUT_DIR: $OUTPUT_DIR"
echo "PROPERTY_FILE: $PROPERTY_FILE"
echo "DATASET_STRING: $DATASET_STRING"
echo "QUESTION_OUTPUT_PATH: $QUESTION_OUTPUT_PATH"
echo "OUTPUT_FILE: $OUTPUT_FILE"

# Load env
source ~/svib/containers/miniconda3/bin/activate
conda activate question_gen

# 1. Concat json property files
#srun --ntasks=$SLURM_NTASKS 
python concat_json_files.py \
    --input_dir $INPUT_DIR \
    --output_file_path $PROPERTY_FILE

# 2. Generate questions
# Make sure program waits until all are done

# Calculate via length argument?
NUMBER_OF_QUESTIONS=$(( LENGTH_DATASET / SLURM_NTASKS ))
echo "NUMBER_OF_QUESTIONS: $NUMBER_OF_QUESTIONS"
#NUMBER_OF_QUESTIONS=500 # 3000 for train

# Loop from 1 to NUMBER_OF_ITERATIONS
for (( i=0; i<SLURM_NTASKS; i++ ))
do
  # Calculate the argument as iteration number multiplied by stepsize
  START=$(( i * NUMBER_OF_QUESTIONS ))
  END=$(( (i + 1) * NUMBER_OF_QUESTIONS ))

  #Call the other script with the calculated argument
  srun --exclusive -n1 python generate_questions.py \
    --input_scene_file $PROPERTY_FILE \
    --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
    --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
    --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
    --output_questions_path $QUESTION_OUTPUT_PATH \
    --scene_start_idx "$START" \
    --scene_end_idx "$END" &
done
wait

# python generate_questions.py \
#     --input_scene_file $PROPERTY_FILE \
#     --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
#     --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
#     --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
#     --output_questions_path $QUESTION_OUTPUT_PATH \
#     --scene_start_idx 0 \
#     --scene_end_idx 10 #48000 or 4800 

# 3. Concat json question files
#srun --ntasks=$SLURM_NTASKS 
python concat_json_files.py \
    --input_dir $OUTPUT_DIR \
    --output_file_path "${QUESTION_OUTPUT_PATH}.json" \
    --questions \
    --question_prefix $DATASET_STRING

# 4. Create hdf5 file
#srun --ntasks=$SLURM_NTASKS 
python create_hdf5_data.py \
    --input_dir $INPUT_DIR \
    --output_h5 $OUTPUT_FILE