FROM alpine:3.22 AS dl
ARG TARGETARCH
ARG PHP_VERSION

# Determine the architecture suffix and download PHP
RUN echo "Using PHP version: ${PHP_VERSION}" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
      ARCH_SUFFIX="x86_64"; \
    else \
      ARCH_SUFFIX="aarch64"; \
    fi && \
    wget -O- "https://dl.static-php.dev/static-php-cli/bulk/php-${PHP_VERSION}-cli-linux-${ARCH_SUFFIX}.tar.gz" | tar xz -C /usr/local/bin

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=dl /usr/local/bin/php /bin/php
ENTRYPOINT [ "php" ]
