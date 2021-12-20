import argparse, shutil, io
parser = argparse.ArgumentParser()
parser.add_argument("-d", "--directory", help="Directory of file")
parser.add_argument("-r", "--replace", help="String to match")
parser.add_argument("-i", "--insert", help="String to insert")
parser.add_argument("-c", "--ignorecomments", help="If the line is commented, it is ignored. (Ex: '-c #' ignores every line that starts with '#')")
parser.add_argument("-b", "--backup", help="Pass 'True' if you want the file to be backed up")
args = parser.parse_args()


# Backs up file
if str(args.backup).lower() == "true":
    shutil.copy(args.directory, args.directory + ".old")

# Reads file
with io.open(args.directory, "r", encoding="UTF-8") as f:
    f_lines = f.readlines()

# Writes
with io.open(args.directory, "w", encoding="UTF-8") as f:
    if args.ignorecomments == None:
        for line in f_lines:
                if args.replace in line:
                    f.write(args.insert + "\n")
                else:
                    f.write(line)
    else:
        for line in f_lines:
                if args.replace in line.split(args.ignorecomments)[0]:
                    f.write(args.insert + "\n")
                else:
                    f.write(line)