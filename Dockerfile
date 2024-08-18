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
    apt-get install -y --no-install-recommends \
        jq \
        ghostscript \
        gettext-base \
        less \
        wget \
        unzip \
        default-mysql-client &&\        
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmagickwand-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
    && \
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm &&\
    docker-php-ext-install -j$(nproc) \
        bcmath \
		exif \
		gd \
		mysqli \
		zip \
    ; \
    pecl install imagick-3.7.0; \
	docker-php-ext-enable imagick; \
    rm -r /tmp/pear; \
	\
# some misbehaving extensions end up outputting to stdout 🙈 (https://github.com/docker-library/wordpress/issues/669#issuecomment-993945967)
	out="$(php -r 'exit(0);')"; \
	[ -z "$out" ]; \
	err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]; \
	\
	extDir="$(php -r 'echo ini_get("extension_dir");')"; \
	[ -d "$extDir" ]; \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    savedAptMark="$(apt-mark showmanual)"; \
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$extDir"/*.so \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	! { ldd "$extDir"/*.so | grep 'not found'; }; \
# check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
	err="$(php --version 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]

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

RUN cp -a /usr/src/wordpress/. /var/www/html && \
    rm -rf /var/www/html/wp-content/plugins/* && \
    rm -rf /var/www/html/wp-content/themes/* && \
    mkdir /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content

COPY rootfs/ /

# Set the environment variables for PHP configuration
ENV PHP_UPLOAD_MAX_FILESIZE=20M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_MAX_EXECUTION_TIME=300


# Override the default entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start the container
CMD ["apache2-foreground"]
