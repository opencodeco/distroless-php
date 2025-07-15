FROM gcr.io/distroless/cc-debian12:nonroot
ARG TARGETARCH
COPY php-binaries/${TARGETARCH}/php /bin/php
ENTRYPOINT [ "/bin/php" ]
