FROM php:8.2-apache

ARG CACHEBUST=1

RUN a2enmod rewrite

# mod_php needs prefork; ensure only one MPM is enabled
RUN a2dismod mpm_event mpm_worker || true \
 && a2enmod mpm_prefork \
 && apache2ctl -M | grep mpm

 # Diagnose duplicate MPM loads
RUN set -eux; \
  echo "=== Enabled mpm modules (mods-enabled) ==="; \
  ls -l /etc/apache2/mods-enabled | grep mpm || true; \
  echo "=== Any LoadModule mpm_ lines ==="; \
  grep -R --line-number "LoadModule mpm_" /etc/apache2 || true; \
  echo "=== apache2ctl -M (mpm) ==="; \
  apache2ctl -M | grep mpm

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
