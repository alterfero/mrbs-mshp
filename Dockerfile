FROM php:8.2-apache

RUN a2enmod rewrite

# mod_php needs prefork; ensure only one MPM is enabled
RUN a2dismod mpm_event mpm_worker || true \
 && a2enmod mpm_prefork \
 && apache2ctl -M | grep mpm

RUN apt-get update && apt-get install -y libicu-dev locales-all
RUN docker-php-ext-install mysqli pdo pdo_mysql intl

COPY web/ /var/www/html/
# COPY docker-config.inc.php /var/www/html/config.inc.php

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8 \
    LC_TIME=fr_FR.UTF-8

ENTRYPOINT ["docker-entrypoint.sh"]
