#!/bin/env bash
set -e

plugin_name=$1
plugin_version=$2

wget -O /tmp/${plugin_name}.zip https://downloads.wordpress.org/plugin/${plugin_name}.${plugin_version}.zip && \
    unzip /tmp/${plugin_name}.zip -d /var/www/html/wp-content/plugins/ && \
    rm /tmp/${plugin_name}.zip
