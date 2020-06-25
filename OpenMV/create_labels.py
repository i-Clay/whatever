# coding=utf-8import os, sys
import argparse
import random
import numpy as np
from tqdm import tqdm
 
import time
import shutil
 
def shuffle_in_unison(a, b):
    assert len(a) == len(b)
    shuffled_a = np.empty(a.shape, dtype=a.dtype)
    shuffled_b = np.empty(b.shape, dtype=b.dtype)
    permutation = np.random.permutation(len(a))
    for old_index, new_index in enumerate(permutation):
        shuffled_a[new_index] = a[old_index]
        shuffled_b[new_index] = b[old_index]
    return shuffled_a, shuffled_b
 
def move_files(input, output):
    '''
        Input: 数据集文件夹，不同分类的数据存储在不同子文件夹中
        Output: 输出的所有文件，文件命名格式为 class_number.jpg; 输出必须是绝对路径
    '''
    index = -1
    for root, dirs, files in os.walk(input):
        if index != -1:
            print 'Working with path', root
            print 'Path index', index
        filenum = 0
        for file in (files if index == -1 else tqdm(files)):
            fileName, fileExtension = os.path.splitext(file)
            if fileExtension == '.jpg' or fileExtension == '.JPG' or fileExtension == '.png' or fileExtension == '.PNG':
                full_path = os.path.join(root, file)
                # print full_path
                if (os.path.isfile(full_path)):
                    file = os.path.basename(os.path.normpath(root)) + str(filenum) + fileExtension
                    try:
                        test = int(file.split('_')[0])
                    except:
                        file = str(index) + '_' + file
                    # print os.path.join(output, file)
                    shutil.copy(full_path, os.path.join(output, file))
                filenum += 1
        index += 1
 
def create_text_file(input_path, percentage):
    '''
        为 Caffe 创建 train.txt 和 val.txt 文件
    '''
 
    images, labels = [], []
    os.chdir(input_path)
 
    for item in os.listdir('.'):
        if not os.path.isfile(os.path.join('.', item)):
            continue
        try:
            label = int(item.split('_')[0])
            images.append(item)
            labels.append(label)
        except:
            continue
 
    images = np.array(images)
    labels = np.array(labels)
    images, labels = shuffle_in_unison(images, labels)
 
    X_train = images[0:int(len(images) * percentage)]
    y_train = labels[0:int(len(labels) * percentage)]
 
    X_test = images[int(len(images) * percentage):]
    y_test = labels[int(len(labels) * percentage):]
 
    os.chdir('..')
 
    trainfile = open("train.txt", "w")
    for i, l in zip(X_train, y_train):
        trainfile.write(i + " " + str(l) + "\n")
 
    testfile = open("test.txt", "w")
    for i, l in zip(X_test, y_test):
        testfile.write(i + " " + str(l) + "\n")
 
    trainfile.close()
    testfile.close()
 
def main():
    # CMD 指令参数
    parser = argparse.ArgumentParser(description='Create label files for an image dataset')
    parser.add_argument("--input",      action = "store", help = "Input images dir")
    parser.add_argument("--output",     action = "store", help = "Output images dir")
    parser.add_argument("--percentage", action = "store", help = "Test/Train split", type=float, default=0.85)
    #测试数据占训练数据的比重
    # Parse CMD args
    args = parser.parse_args()
    if (args.input == None or args.output == None):
        parser.print_help()
        sys.exit(1)
 
    move_files(args.input, args.output)
    create_text_file(args.output, args.percentage)
 
    print('Finished processing all images\n')
 
if __name__ == '__main__':
    main()
