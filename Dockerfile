ARG WORDPRESS_VERSION=6.5.5
ARG PHP_VERSION=8.3


# Use the official WordPress image as the base
FROM wordpress:${WORDPRESS_VERSION}-php${PHP_VERSION}-apache

ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

ARG WP_CLI_VERSION=2.10.0
ARG YQ_VERSION=4.44.2

# Install necessary utilities
RUN apt-get update &&\
    apt-get install -y \
        jq \
        gettext-base \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        less \
        wget \
        unzip \
        default-mysql-client &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm &&\
    docker-php-ext-install -j$(nproc) gd

RUN \
    case "$TARGETPLATFORM" in \
      "linux/amd64") YQ_URL="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64" ;; \
      "linux/arm64") YQ_URL="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETPLATFORM}" && exit 1 ;; \
    esac &&\
    curl -o /usr/local/bin/yq -OfL "${YQ_URL}" &&\
    chmod a+x /usr/local/bin/yq


RUN curl -o /usr/local/bin/wp -OfL "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" &&\
    chmod +x /usr/local/bin/wp


COPY rootfs/ /

# Set the environment variables for PHP configuration
ENV PHP_UPLOAD_MAX_FILESIZE=20M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_MAX_EXECUTION_TIME=300


# Override the default entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start the container
CMD ["apache2-foreground"]
