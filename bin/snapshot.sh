#!/bin/bash

# Variables
LOCAL_DB_NAME="recloud_latest_production"  # Local database name to be backed up and restored
LOCAL_SQL_USER="root"                     # MySQL user on the local machine
LOCAL_SQL_PASSWORD="root"                 # MySQL password on the local machine
DATABASE_HOST="127.0.0.1"                 # MySQL database host
DATABASE_PORT=4306                        # MySQL database port
BACKUP_DIR="./tmp"                        # Directory where backups will be saved
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
SNAPSHOT_FILE="${BACKUP_DIR}/recloud_${TIMESTAMP}.sql.gz"

# Function to take a snapshot of the local database
take_snapshot() {
    SNAPSHOT_NAME=$1

    if [ -z "$SNAPSHOT_NAME" ]; then
        SNAPSHOT_NAME="${TIMESTAMP}"
    fi

    CUSTOM_SNAPSHOT_FILE="${BACKUP_DIR}/recloud_${SNAPSHOT_NAME}.sql.gz"

    echo "Taking snapshot of the local database ${LOCAL_DB_NAME} on ${DATABASE_HOST}:${DATABASE_PORT}..."

    # Dump the database and compress the dump file
    mysqldump -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} ${LOCAL_DB_NAME} | gzip > ${CUSTOM_SNAPSHOT_FILE}

    if [ $? -eq 0 ]; then
        echo "Snapshot successfully saved to ${CUSTOM_SNAPSHOT_FILE}"
    else
        echo "Error taking snapshot."
        exit 1
    fi
}

# Function to restore a snapshot
restore_snapshot() {
    SNAPSHOT_NAME=$1

    if [ -z "$SNAPSHOT_NAME" ]; then
        # Find the latest snapshot file
        SNAPSHOT_FILE=$(ls -t ${BACKUP_DIR}/recloud_*.sql.gz 2>/dev/null | head -n 1)
    else
        # Find the specified snapshot file
        SNAPSHOT_FILE="${BACKUP_DIR}/recloud_${SNAPSHOT_NAME}.sql.gz"
    fi

    if [ ! -f "${SNAPSHOT_FILE}" ]; then
        echo "Snapshot file ${SNAPSHOT_FILE} does not exist."
        exit 1
    fi

    echo "Restoring snapshot: ${SNAPSHOT_FILE} on ${DATABASE_HOST}:${DATABASE_PORT}..."

    # Check if the database exists, then drop it
    if mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "USE ${LOCAL_DB_NAME}"; then
        echo "Database ${LOCAL_DB_NAME} exists. Dropping the database..."
        mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "DROP DATABASE ${LOCAL_DB_NAME};"
    fi

    # Create a new database
    echo "Creating new database ${LOCAL_DB_NAME}..."
    mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "CREATE DATABASE ${LOCAL_DB_NAME};"

    # Uncompress and restore the snapshot
    gunzip < ${SNAPSHOT_FILE} | mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} ${LOCAL_DB_NAME}

    if [ $? -eq 0 ]; then
        echo "Database successfully restored from ${SNAPSHOT_FILE}"
    else
        echo "Error restoring database."
        exit 1
    fi
}

# Main script
if [ "$1" == "restore" ]; then
    restore_snapshot "$2"
else
    take_snapshot "$1"
fi