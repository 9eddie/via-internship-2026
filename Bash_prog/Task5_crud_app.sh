#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Edwin Abunyewa
# @index        7349723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven CRUD console app for managing a todo list,
#               storing data in a CSV file with backups before any
#               destructive change.
# @date         2026-09-13
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  Runs an interactive menu-driven todo list manager."
  echo "  No arguments needed — run it and follow the on-screen menu."
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

DATA_FILE="todo_data.csv"
BACKUP_FILE="$DATA_FILE.bak"

if [ ! -f "$DATA_FILE" ]; then
  touch "$DATA_FILE"
  echo "Created new data file: '$DATA_FILE'"
fi

get_next_id() {
  local last_id
  last_id=$(cut -d',' -f1 "$DATA_FILE" | sort -n | tail -1)
  if [ -z "$last_id" ]; then
    echo 1
  else
    echo $((last_id + 1))
  fi
}

add_task() {
  echo "----- Add New Task -----"
  read -p "Task description: " description

  if [ -z "$description" ]; then
    echo "Error: description cannot be empty." >&2
    return 1
  fi

  read -p "Due date (optional, press Enter to skip): " due_date

  local new_id
  new_id=$(get_next_id)

  echo "$new_id,$description,pending,$due_date" >> "$DATA_FILE"

  if [ $? -eq 0 ]; then
    echo "Task added successfully (ID: $new_id)."
  else
    echo "Error: failed to add task." >&2
    return 1
  fi
}

view_tasks() {
  echo "----- Task List -----"
  if [ ! -s "$DATA_FILE" ]; then
    echo "No tasks found."
    return 0
  fi

  printf "%-5s %-30s %-10s %-12s\n" "ID" "Description" "Status" "Due Date"
  echo "--------------------------------------------------------------"
  while IFS=',' read -r id description status due_date; do
    printf "%-5s %-30s %-10s %-12s\n" "$id" "$description" "$status" "$due_date"
  done < "$DATA_FILE"
}

search_tasks() {
  echo "----- Search Tasks -----"
  read -p "Enter keyword to search (matches description): " keyword

  if [ -z "$keyword" ]; then
    echo "Error: search keyword cannot be empty." >&2
    return 1
  fi

  local matches
  matches=$(grep -i "$keyword" "$DATA_FILE")

  if [ -z "$matches" ]; then
    echo "No matching tasks found for '$keyword'."
  else
    printf "%-5s %-30s %-10s %-12s\n" "ID" "Description" "Status" "Due Date"
    echo "--------------------------------------------------------------"
    echo "$matches" | while IFS=',' read -r id description status due_date; do
      printf "%-5s %-30s %-10s %-12s\n" "$id" "$description" "$status" "$due_date"
    done
  fi
}

update_task() {
  echo "----- Update Task -----"
  read -p "Enter ID of task to update: " id

  if [ -z "$id" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$id," "$DATA_FILE"; then
    echo "Error: no task found with ID $id." >&2
    return 1
  fi

  cp "$DATA_FILE" "$BACKUP_FILE"
  echo "Backup created before update: '$BACKUP_FILE'"

  local old_line new_description new_status new_due_date
  old_line=$(grep "^$id," "$DATA_FILE")

  read -p "New description (leave blank to keep unchanged): " new_description
  read -p "New status (pending/done, leave blank to keep unchanged): " new_status
  read -p "New due date (leave blank to keep unchanged): " new_due_date

  IFS=',' read -r _ old_description old_status old_due_date <<< "$old_line"

  [ -z "$new_description" ] && new_description="$old_description"
  [ -z "$new_status" ] && new_status="$old_status"
  [ -z "$new_due_date" ] && new_due_date="$old_due_date"

  local updated_line="$id,$new_description,$new_status,$new_due_date"

  grep -v "^$id," "$DATA_FILE" > "${DATA_FILE}.tmp"
  echo "$updated_line" >> "${DATA_FILE}.tmp"
  mv "${DATA_FILE}.tmp" "$DATA_FILE"

  if [ $? -eq 0 ]; then
    echo "Task $id updated successfully."
  else
    echo "Error: failed to update task $id." >&2
    return 1
  fi
}

delete_task() {
  echo "----- Delete Task -----"
  read -p "Enter ID of task to delete: " id

  if [ -z "$id" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$id," "$DATA_FILE"; then
    echo "Error: no task found with ID $id." >&2
    return 1
  fi

  read -p "Are you sure you want to delete task $id? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Delete cancelled."
    return 0
  fi

  cp "$DATA_FILE" "$BACKUP_FILE"
  echo "Backup created before delete: '$BACKUP_FILE'"

  grep -v "^$id," "$DATA_FILE" > "${DATA_FILE}.tmp"
  mv "${DATA_FILE}.tmp" "$DATA_FILE"

  if [ $? -eq 0 ]; then
    echo "Task $id deleted successfully."
  else
    echo "Error: failed to delete task $id." >&2
    return 1
  fi
}

show_menu() {
  echo ""
  echo "===== Todo List Manager ====="
  echo "1) Add task"
  echo "2) View/List tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Exit"
  echo "=============================="
}

while true; do
  show_menu
  read -p "Choose an option (1-6): " choice

  case "$choice" in
    1) add_task ;;
    2) view_tasks ;;
    3) search_tasks ;;
    4) update_task ;;
    5) delete_task ;;
    6)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose a number between 1 and 6." >&2
      ;;
  esac
done
