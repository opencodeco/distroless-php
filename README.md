# Distroless PHP

🐘 PHP focused docker images, minus the operating system.

> Basically: [static-php-cli](https://github.com/crazywhalecc/static-php-cli) + [distroless](https://github.com/GoogleContainerTools/distroless).

## Usage

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3
```

### Example

```dockerfile
FROM composer:2.2 AS composer
FROM php:8.3 AS build
RUN apt-get update && apt-get install -y libzip-dev && docker-php-ext-install zip
WORKDIR /workspace
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY composer.* ./
RUN composer install --prefer-dist --no-dev --no-interaction --optimize-autoloader
COPY . .

FROM ghcr.io/opencodeco/distroless-php:8.3
COPY --from=build --chown=nonroot:nonroot /workspace /app
CMD [ "/app/bin/hyperf.php", "start" ]
EXPOSE 9501
```
