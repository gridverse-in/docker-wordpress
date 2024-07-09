ARG WORDPRESS_VERSION=6.5.5
ARG PHP_VERSION=8.3
ARG WP_CLI_VERSION=2.5.0


# Use the official WordPress image as the base
FROM wordpress:${WORDPRESS_VERSION}-php${PHP_VERSION}-apache

# Install wp-cli
RUN curl -o /usr/local/bin/wp -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-${WP_CLI_VERSION}.phar \
    && chmod +x /usr/local/bin/wp
