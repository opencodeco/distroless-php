FROM gcr.io/distroless/static-debian12:nonroot
ARG PHPVERSION
ARG TARGETARCH
COPY --chmod=755 php${PHPVERSION}-${TARGETARCH}/php /bin/php
ENTRYPOINT [ "/bin/php" ]
