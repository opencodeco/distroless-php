FROM gcr.io/distroless/static-debian12:nonroot
ARG TARGETARCH
COPY php-binaries/${TARGETARCH}/php /bin/php
ENTRYPOINT [ "/bin/php" ]
