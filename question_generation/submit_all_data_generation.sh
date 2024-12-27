#!/bin/bash -x

datasets_train=("train_val_test_hard" "train_val_test_medium") #"train_val_test_easy")
#lengths=(4800) #48000 48000 48000)
datasets_test=("test_cood" "test_cood_obj_cood" "test_easy_obj_cood" "test_hard_obj_cood" "test_medium_obj_cood")

for dataset in "${datasets_train[@]}"; do
    sbatch data_generation_pipeline.sh \
        ~/svib/data_creation/clevrtex_original/output \
        ~/datasets/clevrtex_original \
        "$dataset" \
        48000
done

for dataset in "${datasets_test[@]}"; do
    sbatch data_generation_pipeline.sh \
        ~/svib/data_creation/clevrtex_original/output \
        ~/datasets/clevrtex_original \
        "$dataset" \
        4800
done