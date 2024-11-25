import argparse
import json
import os
from tqdm import tqdm

# After rendering all images, combine the JSON files for each scene into a
# single JSON file.
def main(input_dir, output_file_path):
    all_scene_paths = [os.path.join(input_dir, fname) for fname in os.listdir(input_dir) if fname.endswith('.json')]
    
    all_scenes = []
    for scene_path in tqdm(all_scene_paths, desc="Processing properties"):
        with open(scene_path, 'r') as f:
            all_scenes.append(json.load(f))
    
    output = {
        'info': {
            'dataset': 'clevrtex_train_val_test_easy',
        },
        'scenes': all_scenes
    }
    
    with open(output_file_path, 'w') as f:
        json.dump(output, f)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_dir', required=True, help='Directory containing input JSON files')
    parser.add_argument('--output_file_path', required=True, help='Path to the output JSON file')
    args = parser.parse_args()
    main(args.input_dir, args.output_file_path)