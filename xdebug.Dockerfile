ARG WORDPRESS_VERSION=6.5.5
ARG PHP_VERSION=8.3


# Use the official WordPress image as the base
FROM wordpress:${WORDPRESS_VERSION}-php${PHP_VERSION}-apache

ARG WP_CLI_VERSION=2.10.0

# Install wp-cli
RUN curl -o /usr/local/bin/wp -OfL "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" \
    && chmod +x /usr/local/bin/wp

# Install necessary utilities
RUN apt-get update &&\
	apt-get install -y \
      jq && \
 	apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_386 -O /usr/local/bin/yq && \
    chmod a+x /usr/local/bin/yq


COPY rootfs/ /

# Set the environment variables for PHP configuration
ENV PHP_UPLOAD_MAX_FILESIZE 20M
ENV PHP_POST_MAX_SIZE 10M
ENV PHP_MAX_EXECUTION_TIME 300


# Override the default entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start the container
CMD ["apache2-foreground"]

# Install XDebug from source as described here:
# https://xdebug.org/docs/install
# Available branches of XDebug could be seen here:
# https://github.com/xdebug/xdebug/branches
RUN cd /tmp && \
    git clone https://github.com/xdebug/xdebug.git && \
    cd xdebug && \
    git checkout xdebug_3_3 && \
    phpize && \
    ./configure --enable-xdebug && \
    make && \
    make install && \
    rm -rf /tmp/xdebug

# Configure Xdebug
RUN echo "zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini



