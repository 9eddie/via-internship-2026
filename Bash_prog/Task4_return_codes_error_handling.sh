#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Edwin Abunyewa
# @index        7349723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability,
#               disk space, file existence, command availability),
#               using a shared check_status helper and documented
#               exit codes, with trap-based cleanup.
# @date         2026-09-13
# -----------------------------------------------------------------
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  a host to check for reachability (e.g. google.com)"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

# check_status: takes the exit code of the previous command, a
# description of what was checked, and the specific exit code to
# use if that check failed. Logs pass/fail and exits on failure.
check_status() {
  local result="$1"
  local description="$2"
  local fail_code="$3"

  if [ "$result" -eq 0 ]; then
    echo "[PASS] $description"
  else
    echo "[FAIL] $description" >&2
    exit "$fail_code"
  fi
}

TEMP_FILE=$(mktemp)

cleanup() {
  echo "Cleaning up temporary file '$TEMP_FILE'..."
  rm -f "$TEMP_FILE"
}

trap cleanup EXIT


HOSTNAME="$1"

echo "----- Running system checks -----"

ping -c 1 -W 2 "$HOSTNAME" > /dev/null 2>&1
check_status "$?" "Host '$HOSTNAME' is reachable" 2

AVAILABLE_KB=$(df / | tail -1 | awk '{print $4}')
[ "$AVAILABLE_KB" -ge 1048576 ]
check_status "$?" "At least 1GB free disk space on /" 3

[ -f "$TEMP_FILE" ] && [ -r "$TEMP_FILE" ]
check_status "$?" "Required file '$TEMP_FILE' exists and is readable" 4

REQUIRED_CMD="curl"
command -v "$REQUIRED_CMD" > /dev/null 2>&1
check_status "$?" "Required command '$REQUIRED_CMD' is installed" 5

echo "----- All checks passed -----"
echo "Script completed successfully."
exit 0
