import argparse
import json
import os
from tqdm import tqdm

# Example usage:
# python concat_json_files.py --input_dir ~/svib/data_creation/clevrtex/output_train_val_test_easy --output_file_path ~/datasets/clevrtex/properties_train_val_test_easy.json

# Or for questions:
# python concat_json_files.py --input_dir ~/datasets/clevrtex/ --output_file_path ~/datasets/clevrtex/questions_train_val_test_easy.json --questions
# You might need to change the question_prefix variable in the main_questions function

# After rendering all images, combine the JSON files for each scene into a
# single JSON file.
def main_scenes(input_dir, output_file_path):
    all_scene_paths = []
    for root, _, files in os.walk(input_dir):
        for fname in files:
            if fname.endswith('.json'):
                all_scene_paths.append(os.path.join(root, fname))
    
    all_scenes = []
    scene_ids = []
    for scene_path in tqdm(all_scene_paths, desc="Processing properties"):
        with open(scene_path, 'r') as f:
            file = json.load(f)
            all_scenes.append(file)
            scene_ids.append(int(file['image_filename'][:6]))
    
    # Sort all_scenes based on scene_ids
    all_scenes = [scene for _, scene in sorted(zip(scene_ids, all_scenes), key=lambda x: x[0])]
    output = {
        'info': {
            'dataset': os.path.basename(input_dir),
        },
        'scenes': all_scenes
    }
    
    with open(output_file_path, 'w') as f:
        json.dump(output, f)

def main_questions(input_dir, output_file_path, question_prefix):
    if 'questions' not in question_prefix:
        question_prefix = 'questions_' + question_prefix

    all_q_paths = [
        os.path.join(input_dir, fname) for fname in os.listdir(input_dir) 
        if fname.endswith('.json') and fname.startswith(question_prefix)
    ]  
    
    all_questions = []
    for q_path in tqdm(all_q_paths, desc="Processing questions"):
        with open(q_path, 'r') as f:
            file = json.load(f)
            all_questions.append(file['questions'])
    
    output = {
        'questions': {k: v for d in all_questions for k, v in d.items()}
    }

    # Sort questions by key
    sorted_questions = dict(sorted(output['questions'].items(), key=lambda item: int(item[0][:6])))
    output['questions'] = sorted_questions

    # print(output.keys())
    # print(output['questions'].keys())
    print(f"The number of images with questions is: {len(output['questions'].keys())}")

    with open(output_file_path, 'w') as f:
        json.dump(output, f)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_dir', required=True, help='Directory containing input JSON files')
    parser.add_argument('--output_file_path', required=True, help='Path to the output JSON file')
    parser.add_argument('--questions', action='store_true', help='Whether to concatenate questions; default are scene files/properties')
    parser.add_argument('--question_prefix', default='questions_train_val_test_easy', help='Prefix of the question files')
    args = parser.parse_args()

    if args.questions:
        main_questions(args.input_dir, args.output_file_path, args.question_prefix)
    else:
        main_scenes(args.input_dir, args.output_file_path)