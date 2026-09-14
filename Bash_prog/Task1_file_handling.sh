#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------
# @title       Task1_file_handling.sh
# @author      Edwin Abunyewa
# @index       7349723
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Demonstrates basic file handling: create directory,
#              create/write/append/read a file, back it up, delete it.
# @date        2026-09-13
#----------------------------------------------------------------------------------------------------

usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory> path to the directory to create/use for this script"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

TARGET_DIR="$1"

if [ -d "$TARGET_DIR" ]; then
  echo "Directory '$TARGET_DIR' already exists."
else
  mkdir -p "$TARGET_DIR"
  if [ $? -eq 0 ]; then
    echo "Directory '$TARGET_DIR' created successfully."
  else 
    echo "Error: failed to create directory '$TARGET_DIR'." >&2
    exit 1
  fi
fi


TARGET_FILE="$TARGET_DIR/sample.txt"

echo "This is the first line of content." > "$TARGET_FILE"
if [ $? -eq 0 ]; then 
  echo "File '$TARGET_FILE' created and initial content written."
else
  echo "Error: failed to write to '$TARGET_FILE'." >&2
  exit 1
fi
echo "This is an appended second line." >> "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "Content appended to '$TARGET_FILE'."
else
  echo "Error: failed to append to '$TARGET_FILE'." >&2
  exit 1
fi
echo "---- Content of $TARGET_FILE -----"
cat "$TARGET_FILE"
if [ $? -ne 0 ]; then
  echo "Error: could not read '$TARGET_FILE'." >&2
  exit 1
fi
echo "-----------------------------------------------"

BACKUP_FILE="$TARGET_FILE.bak"

cp "$TARGET_FILE" "$BACKUP_FILE"
if [ $? -eq 0 ]; then
  echo "Backup created: '$BACKUP_FILE'."
else
  echo "Error: failed to create backup '$BACKUP_FILE'." >&2
  exit 1
fi
if [ -f "$TARGET_FILE" ]; then
  echo "Deleting original file '$TARGET_FILE'..."
  rm "$TARGET_FILE"
  if [ $? -eq 0 ]; then
    echo "Original file '$TARGET_FILE' deleted successfully."
  else
    echo "Error: failed to delete '$TARGET_FILE'." >&2
    exit 1
  fi
else
  echo " Error: '$TARGET_FILE' does not exist, nothing to delete." >&2
  exit 1
fi

echo "Script completed successfully."
exit 0



