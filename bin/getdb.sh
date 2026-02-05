#!/bin/bash

# Variables
REMOTE_IP="hush-db"     # Replace with your DB server's IP
DOCKER_CONTAINER="hush-db"
REMOTE_USER="root"        # Replace with the remote user (e.g., root)
REMOTE_SQL_USER="root"    # MySQL username
REMOTE_SQL_PASSWORD="PFogoMIj4hYHz8p" # MySQL password
DB_NAME="hush_production"   # Database name
REMOTE_SQL_DUMP="/tmp/hush.sql"
LOCAL_SQL_DUMP="./tmp/hush.sql.gz"
LOCAL_SQL_FILE="./tmp/hush.sql"
LATEST_SQL_DUMP="./tmp/latest-hush.sql.gz"
DATE_SUFFIX=$(date +"%Y%m%d_%H%M%S")  # Current date and time suffix
BACKUP_COPY="./../backup/hush_backup_${DATE_SUFFIX}.sql.gz"  # Backup filename

LOCAL_SQL_USER="root"    # MySQL user on the local machine
LOCAL_SQL_PASSWORD="root"  # MySQL password on the local machine
LOCAL_DB_NAME="hush_development"  # Local database name to be created
#LOCAL_DB_HOST="localhost"
#LOCAL_HOST_PORT="3306"
LOCAL_DB_HOST="127.0.0.1"
LOCAL_HOST_PORT="4306"


# 3. Create the MySQL dump inside the Docker container and compress it
ssh ${REMOTE_USER}@${REMOTE_IP} "
  set -x;  # Enable shell debugging
  docker exec ${DOCKER_CONTAINER} sh -c '
    echo \"Running mysqldump...\";
    mysqldump -u ${REMOTE_SQL_USER} -p${REMOTE_SQL_PASSWORD} ${DB_NAME} > ${REMOTE_SQL_DUMP};
    EXIT_CODE=\$?;
    if [ \$EXIT_CODE -ne 0 ]; then
      echo \"mysqldump failed with exit code \$EXIT_CODE\";
      exit \$EXIT_CODE;
    else
      echo \"mysqldump completed successfully. Compressing the dump...\";
      rm -f ${REMOTE_SQL_DUMP}.gz;
      gzip -f ${REMOTE_SQL_DUMP};
    fi
  '
"


# 4. Copy the compressed SQL dump to your local machine

ssh ${REMOTE_USER}@${REMOTE_IP} "docker cp ${DOCKER_CONTAINER}:${REMOTE_SQL_DUMP}.gz /tmp/hush.sql.gz"
scp ${REMOTE_USER}@${REMOTE_IP}:/tmp/hush.sql.gz ${LOCAL_SQL_DUMP}

# 5. Create a backup copy of the local SQL dump with the current date
if [ -f "${LOCAL_SQL_DUMP}" ]; then
    echo "Creating a backup copy of the local SQL dump with the current date..."
    cp ${LOCAL_SQL_DUMP} ${BACKUP_COPY}
    cp ${LOCAL_SQL_DUMP} ${LATEST_SQL_DUMP}
    echo "Backup copy created: ${BACKUP_COPY}"
else
    echo "Local SQL dump not found. Skipping backup copy creation."
fi

read -p "Do you want to import this dump (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        echo "importing ..."
    else
        echo "Exiting script."
        exit 1
    fi



# 6. Uncompress the file locally
gunzip -f ${LOCAL_SQL_DUMP}

#sed -i '' 's/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g' ${LOCAL_SQL_FILE}

# 7. Check if the local database exists and prompt for confirmation to drop it
echo "Checking if local database ${LOCAL_DB_NAME} exists..."
export MYSQL_PWD="${LOCAL_SQL_PASSWORD}"

if mysql -u ${LOCAL_SQL_USER} -h ${LOCAL_DB_HOST} -P ${LOCAL_HOST_PORT} -e "USE ${LOCAL_DB_NAME}"; then
    echo "Database ${LOCAL_DB_NAME} exists."

    # Prompt for confirmation
    read -p "Are you sure you want to drop the database ${LOCAL_DB_NAME}? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        echo "Dropping database ${LOCAL_DB_NAME}..."
        mysql -u ${LOCAL_SQL_USER} -h ${LOCAL_DB_HOST} -P ${LOCAL_HOST_PORT} -e "DROP DATABASE ${LOCAL_DB_NAME};"
    else
        echo "Database drop cancelled. Exiting script."
        exit 1
    fi
fi


# 8. Create a new local database
echo "Creating new local database ${LOCAL_DB_NAME}..."
mysql -u ${LOCAL_SQL_USER} -h ${LOCAL_DB_HOST} -P ${LOCAL_HOST_PORT} -e "CREATE DATABASE ${LOCAL_DB_NAME};"

# 9. Import the dumped data into the new local database
echo "Importing data into ${LOCAL_DB_NAME}..."
mysql -u ${LOCAL_SQL_USER} -h ${LOCAL_DB_HOST} -P ${LOCAL_HOST_PORT} ${LOCAL_DB_NAME} < ${LOCAL_SQL_FILE}

echo "Database dump has been successfully imported into ${LOCAL_DB_NAME}."

unset MYSQL_PWD