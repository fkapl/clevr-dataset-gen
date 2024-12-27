#!/usr/bin/env bash
#PYTHONPATH="/fsx/ubuntu/svib/containers/miniconda3/envs/image_gen/bin/python" \
#PYTHONHOME="/fsx/ubuntu/svib/containers/miniconda3/envs/image_gen" \
#/fsx/ubuntu/svib/containers/blender/blender --background \
#    --python-use-system-env --python create_data.py -- \
#    --num_samples 8 \
#    --no_target \
#    --use_gpu 1 \
#    --test_scan \
#    --save_path output_sweep

# something about mask colors does not work!!!
PYTHONPATH="/fsx/ubuntu/svib/containers/miniconda3/envs/image_gen/bin/python" \
PYTHONHOME="/fsx/ubuntu/svib/containers/miniconda3/envs/image_gen" \
/fsx/ubuntu/svib/containers/blender/blender --background \
    --python-use-system-env --python render_images.py -- \
    --num_images 1 \
    --width 128 \
    --height 128