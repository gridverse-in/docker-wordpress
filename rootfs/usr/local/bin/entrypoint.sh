#!/bin/bash
set -e

# Function to convert bytes to megabytes
bytes_to_megabytes() {
    echo $(($1 / 1024 / 1024))M
}

# Get the container's memory limit
if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
    CONTAINER_MEMORY_LIMIT=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
    PHP_MEMORY_LIMIT=$(bytes_to_megabytes $CONTAINER_MEMORY_LIMIT)
else
    PHP_MEMORY_LIMIT=128M
fi

export PHP_MEMORY_LIMIT

# Update the PHP configuration file with environment variables
envsubst < /usr/local/etc/php/conf.d/php.ini > /usr/local/etc/php/conf.d/php.ini

# Execute the original entrypoint script
docker-entrypoint.sh "$@"
