#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Edwin Abunyewa
# @index        7349723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data and processes it using
#               pipes and text tools (grep, sort, uniq, wc, awk, cut)
#               to produce a summary report.
# @date         2026-09-13
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  This script takes no arguments — it generates its own sample data."
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

LOG_FILE="sample_log.txt"

cat <<'EOF' > "$LOG_FILE"
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 INFO 192.168.1.11 User login successful
2026-09-11 10:00:30 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:00 INFO 192.168.1.12 User login successful
2026-09-11 10:01:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:30 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:01:45 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:02:00 INFO 192.168.1.11 User logout
2026-09-11 10:02:15 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:02:30 INFO 192.168.1.10 User login successful
2026-09-11 10:02:45 INFO 192.168.1.13 User login successful
2026-09-11 10:03:00 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:03:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:03:30 INFO 192.168.1.14 User login successful
2026-09-11 10:03:45 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:04:00 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:04:15 INFO 192.168.1.11 User logout
2026-09-11 10:04:30 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:04:45 INFO 192.168.1.10 User login successful
2026-09-11 10:05:00 INFO 192.168.1.12 User login successful
2026-09-11 10:05:15 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:05:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:05:45 INFO 192.168.1.13 User login successful
2026-09-11 10:06:00 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:06:15 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:06:30 INFO 192.168.1.11 User logout
2026-09-11 10:06:45 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:07:00 INFO 192.168.1.10 User login successful
2026-09-11 10:07:15 INFO 192.168.1.14 User login successful
2026-09-11 10:07:30 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:07:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:08:00 INFO 192.168.1.12 User login successful
2026-09-11 10:08:15 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:08:30 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:08:45 INFO 192.168.1.11 User logout
2026-09-11 10:09:00 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:09:15 INFO 192.168.1.10 User login successful
2026-09-11 10:09:30 INFO 192.168.1.13 User login successful
2026-09-11 10:09:45 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:10:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:10:15 INFO 192.168.1.14 User login successful
2026-09-11 10:10:30 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:10:45 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:11:00 INFO 192.168.1.11 User logout
2026-09-11 10:11:15 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:11:30 INFO 192.168.1.10 User login successful
2026-09-11 10:11:45 INFO 192.168.1.12 User login successful
2026-09-11 10:12:00 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:12:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:12:30 INFO 192.168.1.13 User login successful
EOF

if [ $? -eq 0 ]; then
  echo "Sample log data written to '$LOG_FILE' ($(wc -l < "$LOG_FILE") lines)."
else
  echo "Error: failed to generate sample log data." >&2
  exit 1
fi

REPORT_FILE="results.txt"
ERROR_FILE="errors.log"

# Clear/create both output files fresh each run
> "$REPORT_FILE"
> "$ERROR_FILE"

{
  echo "===== Log Analysis Report ====="
  echo ""

  echo "--- Total number of log lines ---"
  wc -l < "$LOG_FILE"
  echo ""

  echo "--- Count per log level ---"
  awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn
  echo ""

  echo "--- Top 3 most frequent IP addresses ---"
  awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 3
  echo ""

  echo "--- All ERROR lines ---"
  grep "ERROR" "$LOG_FILE"

} > "$REPORT_FILE" 2>> "$ERROR_FILE"

if [ $? -eq 0 ]; then
  echo "Report generated successfully: '$REPORT_FILE'"
else
  echo "Some errors occurred during report generation — check '$ERROR_FILE'." >&2
fi

echo "Script completed."
exit 0
