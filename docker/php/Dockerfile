FROM php:8.3-fpm-alpine

# System packages and a compiler for pecl
RUN apk add --no-cache \
    icu-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    linux-headers \
    $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install \
    intl \
    pdo_mysql \
    mysqli \
    mbstring \
    gd \
    opcache \
    && apk del $PHPIZE_DEPS

# Composer
COPY --from=composer:2.10.1 /usr/bin/composer /usr/bin/composer

COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/php/install-app.sh /usr/local/bin/install-app.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/install-app.sh

WORKDIR /var/www/html

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]