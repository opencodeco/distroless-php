# Distroless PHP

🐘 PHP focused docker images, minus the operating system.

> Basically: [static-php-cli](https://github.com/crazywhalecc/static-php-cli) + [distroless](https://github.com/GoogleContainerTools/distroless).

## Usage

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3
```

### Available PHP Versions

- `8.1` - PHP 8.1.30
- `8.2` - PHP 8.2.23  
- `8.3` - PHP 8.3.9
- `8.4` - PHP 8.4.6

## Building

Images are automatically built and published via GitHub Actions for all supported PHP versions. Patch versions are managed in the GitHub Actions workflow configuration.

### Manual Build

If you need to build locally, use the build arguments:

```bash
docker build \
  --build-arg PHP_VERSION=8.3.9 \
  -t ghcr.io/opencodeco/distroless-php:8.3 .
```

Available PHP_VERSION values: `8.1.30`, `8.2.23`, `8.3.9`, `8.4.6`

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
