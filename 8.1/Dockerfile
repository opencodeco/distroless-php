FROM alpine AS dl
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      wget -O- https://dl.static-php.dev/static-php-cli/bulk/php-8.1.30-cli-linux-x86_64.tar.gz | tar xz -C /usr/local/bin; \
    else \
      wget -O- https://dl.static-php.dev/static-php-cli/bulk/php-8.1.30-cli-linux-aarch64.tar.gz | tar xz -C /usr/local/bin; \
    fi

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=dl /usr/local/bin/php /bin/php
ENTRYPOINT [ "php" ]