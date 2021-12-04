import subprocess, shutil, io, os, sys
curr_dir = os.path.dirname(os.path.realpath(__file__))


#                          #
# ------  Functions ------ # 
#                          #

"""
Parses ```lsblk -f```
to get LUKS name
"""
def get_name(string):
    name = "luks-" + string.split("luks-")[-1].split(" ")[0]
    # Check
    if len(name.split("-")) == 6:
        return(name)


"""
Given LUKS name, gets partition that it is in
"""
def get_partition(name):
    uuid = name.replace("luks-", "")
    result = subprocess.run(["lsblk", "--fs"], stdout=subprocess.PIPE)
    for line in result.stdout.decode("utf-8").split("\n"):
        if "crypto_LUKS" in line and uuid in line:
            find_part = line.split(" ")
            for _ in range(10):
                try:
                    find_part.remove("")
                except Exception:
                    pass
            find_part = find_part[0]
            return(f"sd{find_part[-2:]}")


"""
Counts the number of active key slots
"""
def count_keys(partition):
    line_count = 0
    result = subprocess.run(["sudo", "cryptsetup", "luksDump", f"/dev/{partition}", "|", "grep", "Slot"], stdout=subprocess.PIPE)
    for line in result.stdout.decode("utf-8").split("\n"):
        if "Slot" in line and "ENABLED" in line:
            line_count += 1
    return(int(line_count))


#                     #
# ------  Code ------ # 
#                     #

"""
Makes sure that the script is being run as root
"""
if os.geteuid() == 0:
    print("This script is currently being run as root. This script is required to be run as root")
    print("Make sure that you understand what this script is doing. IT IS UNSAFE TO RUN RANDOM SCRIPTS AS ROOT\n")
    if input("I have read and understand what this scipt is doing. I understand that I am running this script as root. [Y/n] ").lower() != "y":
        sys.exit("Terminated by user")
else:
    print("This script needs to be run as root!")
    subprocess.call(["sudo", "python3", *sys.argv])
    sys.exit()
os.system("cls" if os.name == "nt" else "clear")


"""
gets all LUKS names
"""
result = subprocess.run(["lsblk", "--fs"], stdout=subprocess.PIPE)
print("  - Getting LUKS names...")
for line in result.stdout.decode("utf-8").split("\n"):
    # LUKS uuid?
    if "luks-" in line:
        # Root partition?
        LUKS_names = []
        if "Root" not in line:          # Not Root
            LUKS_names.append(get_name(line))
        else:
            root_uuid = get_name(line)

LUKS_partitions = []
print("  - Getting LUKS partitions...")
for name in LUKS_names:
    LUKS_partitions.append(get_partition(name))



"""
Backs up crypttab
"""
print("  - Backing up crypttab...")
crypttab_dir = "/etc/crypttab"
wd_crypttab_dir = os.path.join(curr_dir, "crypttab")
subprocess.run(["sudo", "cp", crypttab_dir, curr_dir])
subprocess.run(["sudo", "mv", crypttab_dir, f"{crypttab_dir}.old"])


"""
Makes keyfile
"""
print("  - Making keyfile...")
keyfile_dir = "/keyfile"
subprocess.run(["sudo", "dd", "if=/dev/urandom", f"of={keyfile_dir}", "bs=1024", "count=4"])        # Creates random keyfile
subprocess.run(["sudo", "chmod", "0400", keyfile_dir])                                              # Makes the keyfile read-only to root
active_keys_pre = []
active_keys_post = []
for LUKS_partition in LUKS_partitions:
    active_keys_pre.append(count_keys(LUKS_partition))
    os.system("cls" if os.name == "nt" else "clear")
    subprocess.run("lsblk")
    print(f"\nPlease enter password for the {LUKS_partition} partition:")
    subprocess.run(["sudo", "cryptsetup", "luksAddKey", f"/dev/{LUKS_partition}", keyfile_dir])
    active_keys_post.append(count_keys(LUKS_partition))
print("\n")


"""
Creates a mapper
"""
print("  - Creating mapper...")
# Gets lines from crypttab
with io.open(wd_crypttab_dir, "r", encoding="utf-8") as f:
    crypttab_lines = f.readlines()

# Writes to crypttab
print("  - Writting to crypttab...")
with io.open(wd_crypttab_dir, "w", encoding="utf-8") as fw:
    # Writes lines that do not need to be changed
    for line in crypttab_lines:
            if not "luks-" in line:         # Not a line that needs to be altered
                fw.write(line)
                # print(line)
            elif root_uuid in line:         # This line is root. No change needed
                fw.write(line)
                # print(line)

    # Writes changed lines to crpypttab
    for name in LUKS_names:
        uuid = name.replace("luks-", "")
        fw.write(f"{name} UUID={uuid}    {keyfile_dir} luks")
        # print(f"{name} UUID={uuid}    {keyfile_dir} luks")

# Move crypttab back
print("  - Moving crypttab back...")
subprocess.run(["sudo", "mv", curr_dir + "/crypttab", crypttab_dir])


"""
Verifying
"""
print("\n\n---- Verifying ----")
errors = 0
for pre, post in zip(active_keys_pre, active_keys_post):
    if pre + 1 != post:
        print("ERROR: Key not successfuly added to one of the disks")
        errors += 1
if os.path.isfile(keyfile_dir) == False:
    print("ERROR: Keyfile not successfully created")
    errors += 1
if errors == 0:
    print("Script finished successfully with no errors")
else:
    print("Error(s) have been detected!")

    if input("Would you like to revert changes? [Y/n] ").lower() == "y":        # Revert if there are errors
        # Remove keyfile
        print("  - Removing keyfile...")
        subprocess.run(["sudo", "rm", keyfile_dir])
        # Restored crypttab
        if os.path.isfile(f"{crypttab_dir}.old") == True:                           # If there is no .old file, it will leave the current one
            print("  - Restoring crypttab")
            subprocess.run(["sudo", "rm", crypttab_dir])
            subprocess.run(["sudo", "mv", f"{crypttab_dir}.old", crypttab_dir])
        # Removes keys:
        for partition, key_number in zip(LUKS_partitions, active_keys_pre):
            if not keyfile_dir == 1:                                                # There is default 1 key. If there is only 1 key, it was not added
                print("  - Removing keys")
                subprocess.run("lsblk")
                print(f"\nPlease enter password for the {partition} partition:")
                subprocess.run(["sudo", "cryptsetup", "luksKillSlot", f"/dev/{partition}", str(key_number)])


"""
Done!
"""
print("\nDone!\n")
print("""BEFORE REBOOTING, PLEASE CHECK THAT: 
    Crypttab file has been properly edited (/etc/crypttab)
    Keyfile exists (/keyfile)""")
