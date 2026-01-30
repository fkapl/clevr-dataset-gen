#!/bin/bash -x

datasets_train=("train_val_test_easy" "train_val_test_hard" "train_val_test_medium" "train_val_test_super_easy" "train_val_test_super_hard")
#lengths=(4800) #48000 48000 48000)
datasets_test=("test_cood") #"test_super_easy_obj_cood" "test_super_hard_obj_cood") #("test_cood" "test_cood_obj_cood" "test_easy_obj_cood" "test_hard_obj_cood" "test_medium_obj_cood")

# Make sure to source the project variable
jutil env activate -p compprotein
BASE_DIR=${PROJECT}/kapl

echo "BASE_DIR: $BASE_DIR"

for dataset in "${datasets_train[@]}"; do
    sbatch data_generation_pipeline.sh \
        $BASE_DIR/svib/data_creation/clevrtex_original/output \
        $BASE_DIR/datasets/clevrtex_original \
        "$dataset" \
        48000
done

for dataset in "${datasets_test[@]}"; do
    sbatch data_generation_pipeline.sh \
        $BASE_DIR/svib/data_creation/clevrtex_original/output \
        $BASE_DIR/datasets/clevrtex_original \
        "$dataset" \
        4800
done