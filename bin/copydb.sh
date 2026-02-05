#!/bin/bash

# Variables
REMOTE_HOST="db-server"                # Remote host name
REMOTE_USER="root"                     # Remote user
REMOTE_SQL_DUMP="/tmp/recloud.sql.gz"  # Path on the remote host where the SQL dump will be copied
DOCKER_CONTAINER="myrecloud-db"        # Docker container name
CONTAINER_SQL_DUMP="/tmp/recloud.sql"  # Path inside the Docker container for the unpacked SQL file
DB_NAME="recloud_production"           # Database name inside the Docker container

# Step 1: Copy the local SQL dump to the remote host
LOCAL_SQL_DUMP="./tmp/latest-recloud.sql.gz"
if [ ! -f "${LOCAL_SQL_DUMP}" ]; then
    echo "Local SQL dump file (${LOCAL_SQL_DUMP}) not found. Exiting..."
    exit 1
fi

echo "Copying local SQL dump to the remote host (${REMOTE_HOST})..."
scp ${LOCAL_SQL_DUMP} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SQL_DUMP}
if [ $? -ne 0 ]; then
    echo "Failed to copy SQL dump to the remote host. Exiting..."
    exit 1
fi



# Step 2: Run Docker commands on the remote host
echo "Executing commands on the remote host (${REMOTE_HOST})..."
ssh ${REMOTE_USER}@${REMOTE_HOST} <<EOF
    echo "Copying SQL dump into the Docker container (${DOCKER_CONTAINER})..."
    docker cp ${REMOTE_SQL_DUMP} ${DOCKER_CONTAINER}:${CONTAINER_SQL_DUMP}.gz

    echo "Unpacking SQL dump inside the Docker container..."
    docker exec ${DOCKER_CONTAINER} bash -c "gunzip -f ${CONTAINER_SQL_DUMP}.gz"

    echo "Removing existing database (${DB_NAME})..."
    docker exec ${DOCKER_CONTAINER} mysql -u root -pPFogoMIj4hYHz8p -e "DROP DATABASE IF EXISTS ${DB_NAME};"

    echo "Creating new database (${DB_NAME})..."
    docker exec ${DOCKER_CONTAINER} mysql -u root -pPFogoMIj4hYHz8p -e "CREATE DATABASE ${DB_NAME};"

    echo "Importing SQL dump into the new database (${DB_NAME})..."
    docker exec ${DOCKER_CONTAINER} bash -c "mysql -u root -pPFogoMIj4hYHz8p ${DB_NAME} < ${CONTAINER_SQL_DUMP}"

EOF


# Check the status of the operation
if [ $? -eq 0 ]; then
    echo "Database successfully updated on the remote host."
else
    echo "An error occurred during the database update process."
    exit 1
fi