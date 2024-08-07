#!/bin/env bash
set -e

name=$1
version=$2

wget -O /tmp/${name}.zip https://downloads.wordpress.org/theme/${name}.${version}.zip && \
    unzip /tmp/${name}.zip -d /var/www/html/wp-content/themes/ && \
    rm /tmp/${name}.zip
