ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm-alpine

# Add non-root user
ARG USERNAME
ARG USER_UID
ARG USER_GID=${USER_UID}
RUN addgroup -g ${USER_GID} -S ${USERNAME} \
	&& adduser -D -u ${USER_UID} -S ${USERNAME} -s /bin/sh ${USERNAME} \
	&& adduser ${USERNAME} www-data \
    && chown -R ${USERNAME}:www-data /var/www/* \
    && sed -i "s/user = www-data/user = ${USERNAME}/g" /usr/local/etc/php-fpm.d/www.conf \
	&& sed -i "s/group = www-data/group = ${USERNAME}/g" /usr/local/etc/php-fpm.d/www.conf

# Install packages and dependencies for PHP extensions
RUN apk add --update \
    $PHPIZE_DEPS \
    libpng-dev freetype-dev libjpeg-turbo-dev \
    libzip-dev \
    libxml2-dev \
    zip \
    openssl \
    vim

# Install and config PHP extensions
RUN pecl install xdebug \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install \
        gd \
        bcmath\
        exif \
        opcache \
        mysqli \
        pdo \
        pdo_mysql \
        zip \
    && docker-php-ext-enable xdebug opcache \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Config for Xdebug
COPY ./php-fpm/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/

# Setting vim configuration for root user
COPY ./.docker/root/. /root

# Switch to non-root user
USER ${USERNAME}

# Setting vim configuration for non-root user
COPY ./.docker/home/non-root/. /home/${USERNAME}

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
