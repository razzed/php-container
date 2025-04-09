#
# web Container running Apache and PHP
#
# Copyright &copy; 2025 Market Acumen, Inc.
#
FROM php:8.1-apache

ENV BUILD_CODE=web
ENV USER_HOME=/var/www

ENV APPLICATION_HOME=/var/www/app
ENV WEB_ROOT=$APPLICATION_HOME/public

# IDENTICAL phpContainerDockerPrefix 13
ENV APPLICATION_CONF=/etc/application.conf

RUN printf -- "%s\n" "$BUILD_CODE" > /etc/docker-role
COPY etc/docker/install.sh /usr/local/sbin/install.sh
COPY etc/docker/application.sh /usr/local/bin/application.sh

COPY bin/build/ /usr/local/bin/build/

RUN /usr/local/sbin/install.sh
RUN /usr/local/sbin/install.sh __installBase
RUN /usr/local/sbin/install.sh __installDevelopment
COPY .env /tmp/application.conf
# -- phpContainerDockerPrefix

ADD . "$APPLICATION_HOME"

RUN /usr/local/sbin/install.sh __installEnvironment /tmp/application.conf "$APPLICATION_CONF" "$APPLICATION_HOME" XDEBUG_IDE_KEY XDEBUG_CLIENT_HOST
# RUN rm -f /tmp/application.conf

# ===========================================================================
# -- Middle part --

RUN chmod 640 "$APPLICATION_CONF"
RUN chown root:www-data "$APPLICATION_CONF"

# PHP
COPY etc/docker/php.ini /usr/local/etc/php/MAP.php.ini

RUN /usr/local/sbin/install.sh __mapFiles /usr/local/etc/php

COPY composer.json /tmp/composer.json

RUN /usr/local/sbin/install.sh __installPHP /tmp/composer.json
RUN /usr/local/sbin/install.sh __installPHPXdebug
RUN date > /etc/xdebug-enabled

# -- Middle part end --
# ===========================================================================

# IDENTICAL phpContainerDockerSuffix 1
RUN /usr/local/sbin/install.sh __installClean

# Apache
COPY etc/docker/web.conf /etc/apache2/sites-available/MAP.web.conf
COPY etc/docker/bashrc.sh "$USER_HOME/MAP..bashrc"
COPY etc/docker/bashrc.sh "/root/MAP..bashrc"

# XDebug
COPY etc/docker/xdebug.ini /usr/local/etc/php/conf.d/MAP.xdebug.ini

RUN /usr/local/sbin/install.sh __mapFiles / --keep "$APPLICATION_HOME"

RUN /usr/sbin/a2enmod rewrite alias
# RUN printf "%s\n" "*" | a2disconf >/dev/null || :
RUN printf "%s\n" "*" | a2dissite >/dev/null || :
RUN /usr/sbin/a2ensite web
RUN rm -rf "/var/www/html"

RUN chown www-data "$USER_HOME/.bashrc" "$USER_HOME"

USER www-data
WORKDIR "$APPLICATION_HOME"
