FROM alpine AS dl
RUN wget -O- https://dl.static-php.dev/static-php-cli/bulk/php-8.1.30-cli-linux-aarch64.tar.gz | tar xz -C /usr/local/bin

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=dl /usr/local/bin/php /bin/php
ENTRYPOINT [ "php" ]