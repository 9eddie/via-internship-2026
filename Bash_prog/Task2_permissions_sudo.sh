#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------
# @title          Task2_permissions_sudo.sh
# @author         Edwin Abunyewa
# @index          7349723
# @school          Kwame Nkrumah University of Science and Technology (KNUST)
# @description    Demonstrates file permission inspection and changes
#                 using chmod (numeric and symbolic), plus a graceful
#                 root-only chown check.
# @date           2026-09-13
#-------------------------------------------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  echo " <file-path> path to an existing file to inspect and modify"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi
FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: '$FILE_PATH' does not exist or is not a regular file." >&2
  exit 1
fi

echo "----- Current permissions for $FILE_PATH -----"
ls -l "$FILE_PATH"
NUMERIC_PERMS=$(stat -c "%a" "$FILE_PATH")
echo "Numeric permissions: $NUMERIC_PERMS"
echo "-----Applying chmod (numeric: 644) -----"
chmod 644 "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "chmod 644 applied successfully."
else
  echo "Error: chmod 644 failed on '$FILE_PATH'." >&2
  exit 1
fi

echo "----- Applying chmod (symbolic: u+x) -----"
chmod u+x "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "chmod u+x applied successfully."
else
  echo "Error: chmod u+x failed on '$FILE_PATH'." >&2
  exit 1
fi

echo "----- Checking privilege level -----"
CURRENT_UID=$(id -u)

if [ "$CURRENT_UID" -eq 0 ]; then
  echo "Running as root — attempting chown to root:root..."
  chown root:root "$FILE_PATH"
  if [ $? -eq 0 ]; then
    echo "chown succeeded: '$FILE_PATH' is now owned by root:root."
  else
    echo "Error: chown failed on '$FILE_PATH'." >&2
    exit 1
  fi
else
  echo "Skipped chown: root privileges are required for this step, and the script is not running as root."
fi

echo "----- Permissions after changes for $FILE_PATH -----"
ls -l "$FILE_PATH"
NUMERIC_PERMS_AFTER=$(stat -c "%a" "$FILE_PATH")
echo "Numeric permissions: $NUMERIC_PERMS_AFTER"

echo "Script completed successfully."
exit 0
