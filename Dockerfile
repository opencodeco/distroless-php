FROM gcr.io/distroless/static-debian12:nonroot
COPY php-binary/php /bin/php
ENTRYPOINT [ "php" ]
