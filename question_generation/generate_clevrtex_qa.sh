#!/bin/bash

# Activate conda environment

# Metadata file
# Check if names of shapes make sense (lower-case, Suzanne/Icosahedron/NewellTeapot?): done
# Check if we can use additional synonyms (e.g. doughnut for torus -> NO): done
# Add material templates back to metadata_clevrtex: done

# Add material keys back to question templates: ...
# python generate_questions.py \
#     --input_scene_file /fsx/ubuntu/clevr-dataset-gen/output/scenes/properties_000000.json \
#     --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
#     --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
#     --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
#     --output_questions_path /fsx/ubuntu/clevr-dataset-gen/output/questions_material \
#     --scene_start_idx 0 \
#     --scene_end_idx 1 \
#     --verbose

python generate_questions.py \
    --input_scene_file /fsx/ubuntu/datasets/clevrtex/properties_train_val_test_easy.json  \
    --metadata_file /fsx/ubuntu/clevr-dataset-gen/question_generation/metadata_clevrtex.json \
    --synonyms_json /fsx/ubuntu/clevr-dataset-gen/question_generation/synonyms.json \
    --template_dir /fsx/ubuntu/clevr-dataset-gen/question_generation/CLEVRTEX_material_templates \
    --output_questions_path /fsx/ubuntu/datasets/clevrtex/questions_train_val_test_easy \
    --scene_start_idx 0 \
    --scene_end_idx 0 #\
    #--verbose