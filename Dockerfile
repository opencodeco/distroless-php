# Build stage to extract PHP binaries
FROM alpine:3.22 AS extractor
ARG TARGETARCH

# Install unzip
RUN apk add --no-cache unzip

# Copy both ZIP files (Docker will copy both regardless of target arch)
COPY php-cli-8.3-linux-x86_64-glibc.zip php-cli-8.3-linux-aarch64-glibc.zip ./

# Extract the correct binary and clean up
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        unzip php-cli-8.3-linux-x86_64-glibc.zip; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        unzip php-cli-8.3-linux-aarch64-glibc.zip; \
    fi && \
    chmod +x php && \
    rm -f ./*.zip

# Final stage using distroless image
FROM gcr.io/distroless/cc-debian12:nonroot
ARG TARGETARCH
COPY --from=extractor /php /bin/php
ENTRYPOINT [ "/bin/php" ]
