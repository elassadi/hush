#!/bin/bash

# Database connection details
DB_NAME="recloud_production"
DB_USER="root"
DB_PASSWORD="PFogoMIj4hYHz8p"
DB_HOST="localhost"
HOST_BACKUP_DIR="/root/myrecloud-db/backup"
BACKUP_DIR="/backup"
TEMP_BACKUP="/tmp/hourly_backup.sql.gz"
HOURLY_BACKUP="${BACKUP_DIR}/hourly_backup.sql.gz"
HOST_HOURLY_BACKUP="${HOST_BACKUP_DIR}/hourly_backup.sql.gz"
DAILY_BACKUP_DIR="${HOST_BACKUP_DIR}/daily"
DOCKER_CONTAINER="myrecloud-db"

# Ensure the daily backup directory exists
mkdir -p "$DAILY_BACKUP_DIR"

# Path to this script
SCRIPT_NAME=$(basename "$0")
SCRIPT_PATH=$(realpath "$0")
TARGET_PATH="/usr/bin/$SCRIPT_NAME"

# First-time setup: Copy script to /usr/bin and create a cron job
if [ ! -f "$TARGET_PATH" ]; then
  echo "First time setup: Copying script to /usr/bin..."
  sudo cp "$SCRIPT_PATH" "$TARGET_PATH"
  sudo chmod +x "$TARGET_PATH"

  echo "Setting up crontab to run this script hourly..."
  (crontab -l 2>/dev/null; echo "0 * * * * $TARGET_PATH") | crontab -
  echo "Setup complete. Script will now run hourly via cron."
  exit 0
fi

# Perform hourly backup
docker exec ${DOCKER_CONTAINER} sh -c "mysqldump -u ${DB_USER} -h ${DB_HOST} -p${DB_PASSWORD} ${DB_NAME} | gzip > '${HOURLY_BACKUP}'"



# Get the current date components
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%-d) # %-d removes leading zero from the day
TIMESTAMP=$(date +%Y%m%d%H)

# Construct the directory path
DAILY_BACKUP_PATH="${DAILY_BACKUP_DIR}/${YEAR}/${MONTH}/${DAY}"

# Ensure the directory exists
mkdir -p "$DAILY_BACKUP_PATH"

# Define the full path for the backup file
DAILY_BACKUP="${DAILY_BACKUP_PATH}/backup_${TIMESTAMP}.sql.gz"

# Copy the hourly backup to the daily backup directory
cp "$HOST_HOURLY_BACKUP" "$DAILY_BACKUP"