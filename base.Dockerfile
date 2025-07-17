FROM docker.io/composer/composer:2.8-bin AS composer
FROM docker.io/library/debian:12.11

ARG PHPVERSION
ARG TARGETARCH

COPY php${PHPVERSION}-${TARGETARCH}/bin/php /bin/php

COPY --from=composer /composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY php${PHPVERSION}-${TARGETARCH}/modules/xdebug.so /lib/php/xdebug.so
RUN echo "zend_extension=/lib/php/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini

ENTRYPOINT [ "php" ]
