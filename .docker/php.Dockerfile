FROM dunglas/frankenphp:php8.4-bookworm

RUN groupadd -g 1000 maho && useradd -u 1000 -g 1000 -m maho

RUN install-php-extensions pdo_mysql gd intl zip opcache ctype curl dom ffi fileinfo filter ftp hash iconv json libxml mbstring openssl session simplexml soap spl vips zlib
RUN apt update && apt install -y git patch unzip default-mysql-client

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY .docker/php.ini $PHP_INI_DIR/php.ini
