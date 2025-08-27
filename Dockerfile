FROM php:8.2-apache

RUN a2enmod rewrite
RUN apt-get update && apt-get install -y libicu-dev locales-all
RUN docker-php-ext-install mysqli pdo pdo_mysql intl

COPY web/ /var/www/html/
COPY docker-config.inc.php /var/www/html/config.inc.php

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure mysql client exists at build (optional; script will install if missing)
RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]
