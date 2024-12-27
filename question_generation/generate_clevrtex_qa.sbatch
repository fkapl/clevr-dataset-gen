#!/bin/bash
#SBATCH --job-name=generate_questions
#SBATCH --output=slurm_log/create_qa_%j.out     # Standard output log
#SBATCH --error=slurm_log/create_qa_%j.err      # Standard error log
#SBATCH --partition=ml.p4d.24xlarge                  # Partition name (adjust if necessary)
#SBATCH --ntasks=1                       # Number of tasks (processes)
#SBATCH --cpus-per-task=1              # Number of CPU cores per task
#SBATCH --mem=20G                        # Total memory per node

# Load necessary modules
source ~/svib/containers/miniconda3/bin/activate
conda activate question_gen

echo "Start index: $1"
echo "End index: $2"

# python generate_questions.py \
#     --input_scene_file /fsx/ubuntu/datasets/clevrtex/properties_train_val_test_easy.json  \
#     --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
#     --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
#     --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
#     --output_questions_path /fsx/ubuntu/datasets/clevrtex/questions_train_val_test_easy \
#     --scene_start_idx $1 \
#     --scene_end_idx $2

python generate_questions.py \
    --input_scene_file /fsx/ubuntu/datasets/clevrtex_original/properties_train_val_test_easy.json \
    --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
    --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
    --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
    --output_questions_path /fsx/ubuntu/datasets/clevrtex_original/questions_train_val_test_easy \
    --scene_start_idx $1 \
    --scene_end_idx $2