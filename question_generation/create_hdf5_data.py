import os
import argparse
import json
import h5py
import numpy as np
from PIL import Image

import sys
from tqdm import tqdm

# Colors defined for masks in clevrtex
MASK_COLORS = [
    # Old colors
    (0, 0, 0, 0),
    (1, 0, 0, 1),
    (0, 1, 0, 1),
    (0, 0, 1, 1),
    # New colors
    (1, 1, 0, 1),
    (1, 0, 1, 1),
    (0, 1, 1, 1),
    (1, 1, 1, 1)
]
# Example usage:
# python create_hdf5_data.py --input_dir ~/svib/data_creation/clevrtex/output_train_val_test_easy --properties_json ~/datasets/clevrtex/properties_train_val_test_easy.json --output_h5 ~/clevr-dataset-gen/output/debug_data.h5

# or for questions
# python create_hdf5_data.py --questions_json ~/datasets/clevrtex/questions_train_val_test_easy.json --output_h5 ~/datasets/clevrtex/questions_train_val_test_easy.hdf5 --questions

def main(args):
    image_files = []
    mask_files = []

    for root, _, files in os.walk(args.input_dir):
        image_files.extend([os.path.join(root, f) for f in files if f.endswith('image.png')])
        mask_files.extend([os.path.join(root, f) for f in files if f.endswith('mask.png')])

    image_files.sort()
    mask_files.sort()

    if len(image_files) != len(mask_files):
        raise ValueError("Number of images and masks do not match.")

    #print(image_files[:10])
    #print(mask_files[:10])
    #sys.exit()

    images = []
    masks = []
    visibility = []
    num_objects = []
    ids = []

    for img_path, mask_path in tqdm(zip(image_files, mask_files), total=len(image_files)):
        #img_path = os.path.join(args.input_dir, img_file)
        #mask_path = os.path.join(args.input_dir, mask_file)

        img = np.array(Image.open(img_path).convert('RGB'))
        assert img.shape == (128, 128, 3), f"Image shape is {img.shape}, expected (128, 128, 3)"

        mask = np.array(Image.open(mask_path).convert('RGB'))
        assert mask.shape == (128, 128, 3), f"Mask shape is {mask.shape}, expected (128, 128, 3)"

        # Convert the mask to ids that go from 0 to num_classes with the same shape
        mask_int = mask.astype(np.uint32)

        # Combine the color channels to create a unique ID for each color
        mask_id = (
            mask_int[:, :, 0] * 256 * 256 +
            mask_int[:, :, 1] * 256 +
            mask_int[:, :, 2]
        )

        # Map mask_id to ids from 0 to num_classes - 1
        unique_ids, mask_labels = np.unique(mask_id, return_inverse=True)
        mask_labels = mask_labels.reshape(mask_id.shape).astype(np.uint8)

        images.append(img)
        masks.append(mask_labels)
        # True for background, True for each object, False for padding?
        visibility.append([True] * len(unique_ids) + [False] * (args.max_objects + 1 - len(unique_ids)))
        # Number of objects in the scene = number of unique ids - 1 (background)
        num_objects.append(len(unique_ids) - 1)

        id = os.path.splitext(os.path.basename(img_path))[0].split('_')[0]

        if id != os.path.splitext(os.path.basename(mask_path))[0].split('_')[0]:
            raise ValueError("Image and mask id do not match.")
        
        #print(id)
        ids.append(id)

        #sys.exit()
        #if id == '000010':
        #    break

    #with open(args.properties_json, 'r') as f:
    #    properties = json.load(f)

    with h5py.File(args.output_h5, 'w') as h5f:
        h5f.create_dataset('image', data=np.array(images))
        h5f.create_dataset('mask', data=np.array(masks))
        h5f.create_dataset('visibility', data=np.array(visibility))
        h5f.create_dataset('num_actual_objects', data=np.array(num_objects))
        h5f.attrs['ids'] = json.dumps(ids)
        #h5f.create_dataset('id', data=np.array(ids, dtype='S'))
        #h5f.attrs['properties'] = json.dumps(properties)

    # Test loading the file
    with h5py.File(args.output_h5, 'r') as h5f:
        images = h5f['image'][:]
        masks = h5f['mask'][:]
        ids = json.loads(h5f.attrs['ids'])
        #properties = json.loads(h5f.attrs['properties'])
    print(f'Loaded {len(images)} images and {len(masks)} masks.')
    print(f'Image shape: {images[0].shape}')
    print(f'Mask shape: {masks[0].shape}')
    print(f'First id: {ids[0]}')
    #print(f'Properties keys: {list(properties.keys())}')
    #print(f'First image properties: {properties["scenes"][0]}')

def main_questions(args):
    with open(args.questions_json, 'r') as f:
        questions = json.load(f)

    with h5py.File(args.output_h5, 'w') as h5f:
        #h5f.create_dataset('questions', data=json.dumps(questions))
        h5f.attrs['questions'] = json.dumps(questions)

    # Test loading the file
    with h5py.File(args.output_h5, 'r') as h5f:
        h5f_questions = json.loads(h5f.attrs['questions'])

    print(f"Loaded {len(h5f_questions['questions'])} questions.")
    print(f"First question: {h5f_questions['questions']['000000']}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create HDF5 data from images and masks.')
    parser.add_argument('--input_dir', required=False, help='Input directory containing images and masks')
    parser.add_argument('--properties_json', required=False, help='Path to properties.json file')
    parser.add_argument('--questions_json', required=False, help='Path to questions.json file')
    parser.add_argument('--output_h5', required=False, help='Output HDF5 file path')
    parser.add_argument('--questions', action='store_true', help='Create HDF5 data for questions')
    parser.add_argument('--max_objects', type=int, default=6, help='Maximum number of objects in the scene')
    args = parser.parse_args()

    if args.questions:
        main_questions(args)
    else:
        main(args)