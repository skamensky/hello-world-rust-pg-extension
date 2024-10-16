#!/bin/bash
set -e

# Define variables
IMAGE_NAME="hello_pg_ext_image"
CONTAINER_NAME="hello_pg_ext_container"
POSTGRES_CONTAINER_NAME="postgres_with_extension"
EXTENSION_NAME="hello_pg_ext"
TARGET_DIR="/usr/src/hello_pg_ext/target/release/hello_pg_ext-pg13"
HOST_DIR="./target"

rm -rf $HOST_DIR
mkdir -p $HOST_DIR
mkdir -p $HOST_DIR/lib


echo "Building the Docker image"
docker build -t $IMAGE_NAME -f Dockerfile .

# Check if the container already exists and remove it if it does
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    docker rm -f $CONTAINER_NAME
fi

if [ "$(docker ps -a -q -f name=$POSTGRES_CONTAINER_NAME)" ]; then
    docker rm -f $POSTGRES_CONTAINER_NAME
fi

# Create a temporary container to copy the .so file
docker create --name $CONTAINER_NAME $IMAGE_NAME > /dev/null

docker cp $CONTAINER_NAME:$TARGET_DIR/usr/share/postgresql/13/extension/ $HOST_DIR/ > /dev/null
docker cp $CONTAINER_NAME:$TARGET_DIR/usr/lib/postgresql/13/lib/hello_pg_ext.so $HOST_DIR/lib/$EXTENSION_NAME.so > /dev/null

# Remove the temporary container
docker rm -f $CONTAINER_NAME > /dev/null

# Run PostgreSQL without mounting the lib directory
docker run --name $POSTGRES_CONTAINER_NAME -e POSTGRES_PASSWORD=mysecretpassword -d \
    postgres:13 > /dev/null

# Copy the .so file from the host to the PostgreSQL container
docker cp $HOST_DIR/lib/$EXTENSION_NAME.so $POSTGRES_CONTAINER_NAME:/usr/lib/postgresql/13/lib/$EXTENSION_NAME.so > /dev/null

# Copy the extension files from the host to the PostgreSQL container
docker cp $HOST_DIR/extension $POSTGRES_CONTAINER_NAME:/usr/share/postgresql/13/ > /dev/null

rm -rf $HOST_DIR

# Wait for PostgreSQL to start
echo "Waiting for PostgreSQL to start..."
until docker exec $POSTGRES_CONTAINER_NAME pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
done


# Enable the extension in PostgreSQL
docker exec -it $POSTGRES_CONTAINER_NAME psql -U postgres -c "CREATE EXTENSION $EXTENSION_NAME;"

expected_output="Hello, world! Shmuel has written a postgres extension!"
output=$(docker exec $POSTGRES_CONTAINER_NAME psql -A -t -U postgres -c "SELECT * FROM hello_hello_pg_ext();")
docker rm -f $POSTGRES_CONTAINER_NAME > /dev/null

if [ "$output" != "$expected_output" ]; then
    echo "Test failed: output was $output, expected $expected_output"
    exit 1
else
    echo "Test passed!"
fi

