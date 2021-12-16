import argparse, shutil, io
parser = argparse.ArgumentParser()
parser.add_argument("-d", "--directory", help="Directory of file")
parser.add_argument("-r", "--replace", help="String to match")
parser.add_argument("-i", "--insert", help="String to insert")
args = parser.parse_args()


# Backs up file
shutil.copy(args.directory, args.directory + ".old")

# Reads file
with io.open(args.directory, "r", encoding="UTF-8") as f:
    f_lines = f.readlines()

# Writes
with io.open(args.directory, "w", encoding="UTF-8") as f:
    for line in f_lines:
            if args.replace in line:
                f.write(args.insert + "\n")
            else:
                f.write(line)
