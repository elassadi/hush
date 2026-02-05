#!/bin/bash

# Variables
REMOTE_IP="188.245.73.163"     # Replace with your DB server's IP
REMOTE_USER="root"             # Replace with the remote user (e.g., root)
REMOTE_SQL_USER="recloud"      # MySQL username
REMOTE_SQL_PASSWORD="MyRecl0ud2025" # MySQL password
DB_NAME="recloud_production"   # Database name
REMOTE_SQL_DUMP="/tmp/recloud.sql"
LOCAL_SQL_DUMP="./tmp/recloud.sql.gz"
LATEST_SQL_DUMP="./tmp/latest-recloud.sql.gz"
DATE_SUFFIX=$(date +"%Y%m%d_%H%M%S")  # Current date and time suffix
BACKUP_COPY="./../backup/recloud_backup_${DATE_SUFFIX}.sql.gz"  # Backup filename



LOCAL_DB_NAME="recloud_latest_production"

LOCAL_SQL_USER="root"    # MySQL user on the local machine
LOCAL_SQL_PASSWORD="root"  # MySQL password on the local machine
LOCAL_DB_NAME="recloud_latest_production"  # Local database name to be created

# 1. Remove the local SQL dump if it already exists
if [ -f "${LOCAL_SQL_DUMP}" ]; then
    echo "Existing ${LOCAL_SQL_DUMP} found locally. Removing..."
    rm ${LOCAL_SQL_DUMP}
fi

# 2. Log in to the remote server and check if the remote SQL dump exists, and remove it
ssh ${REMOTE_USER}@${REMOTE_IP} "if [ -f ${REMOTE_SQL_DUMP}.gz ]; then echo 'Existing ${REMOTE_SQL_DUMP}.gz found on remote server. Removing...'; rm ${REMOTE_SQL_DUMP}.gz; fi"

# 3. Log in to the remote server, create the MySQL dump, and compress it
ssh ${REMOTE_USER}@${REMOTE_IP} "mysqldump -u ${REMOTE_SQL_USER} -p${REMOTE_SQL_PASSWORD} ${DB_NAME} > ${REMOTE_SQL_DUMP} && gzip ${REMOTE_SQL_DUMP}"

# 4. Copy the compressed SQL dump to your local machine
scp ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_SQL_DUMP}.gz ${LOCAL_SQL_DUMP}


# 5. Create a backup copy of the local SQL dump with the current date
if [ -f "${LOCAL_SQL_DUMP}" ]; then
    echo "Creating a backup copy of the local SQL dump with the current date..."
    cp ${LOCAL_SQL_DUMP} ${BACKUP_COPY}
    cp ${LOCAL_SQL_DUMP} ${LATEST_SQL_DUMP}
    echo "Backup copy created: ${BACKUP_COPY}"
else
    echo "Local SQL dump not found. Skipping backup copy creation."
fi

# 5. Uncompress the file locally
gunzip ${LOCAL_SQL_DUMP}

# 6. Prompt the user for confirmation before removing the local database if it already exists
echo "Checking if local database ${LOCAL_DB_NAME} exists..."
if mysql -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "USE ${LOCAL_DB_NAME}"; then
    echo "Database ${LOCAL_DB_NAME} exists."

    # Prompt for confirmation
    read -p "Are you sure you want to drop the database ${LOCAL_DB_NAME}? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        echo "Dropping database ${LOCAL_DB_NAME}..."
        mysql -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "DROP DATABASE ${LOCAL_DB_NAME};"
    else
        echo "Database drop cancelled. Exiting script."
        exit 1
    fi
fi

# 7. Create a new local database
echo "Creating new local database ${LOCAL_DB_NAME}..."
mysql -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} -e "CREATE DATABASE ${LOCAL_DB_NAME};"

# 8. Import the dumped data into the new local database
echo "Importing data into ${LOCAL_DB_NAME}..."
mysql -u ${LOCAL_SQL_USER} -p${LOCAL_SQL_PASSWORD} ${LOCAL_DB_NAME} < /tmp/recloud.sql

echo "Database dump has been successfully imported into ${LOCAL_DB_NAME}."