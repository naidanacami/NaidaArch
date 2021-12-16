import argparse, shutil, io
parser = argparse.ArgumentParser()
parser.add_argument("-d", "--directory", help="Directory of file")
args = parser.parse_args()
print(args.directory)