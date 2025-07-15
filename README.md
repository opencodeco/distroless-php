# Distroless PHP

🐘 PHP focused docker images, minus the operating system.

> Basically: [static-php-cli](https://github.com/crazywhalecc/static-php-cli) + [distroless](https://github.com/GoogleContainerTools/distroless).

## Usage

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3
```

### Available PHP Versions

- `8.3` - PHP 8.3 (multi-arch: AMD64, ARM64)

## Building

Images are automatically built and published via GitHub Actions using pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli). The build process uses multi-architecture Docker builds to support both AMD64 and ARM64 platforms.

### Architecture Support

- **AMD64** (x86_64): Built using `php-cli-8.3-linux-x86_64-glibc.zip`
- **ARM64** (aarch64): Built using `php-cli-8.3-linux-aarch64-glibc.zip`

### Manual Build

To build locally, you need the PHP binary zip files in the project directory:

```bash
# Multi-arch build (requires Docker Buildx)
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/opencodeco/distroless-php:8.3 .

# Single architecture build
docker build -t ghcr.io/opencodeco/distroless-php:8.3 .
```

## How it Works

This project combines static PHP binaries with Google's Distroless base images to create minimal, secure PHP runtime containers:

1. **Static PHP Binaries**: Pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli) are included as zip files in the repository
2. **Multi-arch Build**: Docker Buildx extracts the appropriate binary for each target architecture during build
3. **Distroless Base**: Uses `gcr.io/distroless/static-debian12:nonroot` for minimal attack surface
4. **No OS**: Final images contain only the PHP binary and distroless base - no package managers, shells, or unnecessary tools

### Project Structure

```
├── Dockerfile                                    # Multi-arch Dockerfile
├── php-cli-8.3-linux-x86_64-glibc.zip          # AMD64 PHP binary
├── php-cli-8.3-linux-aarch64-glibc.zip         # ARM64 PHP binary
└── .github/workflows/build.yml                  # CI/CD pipeline
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

## Testing

To test the image locally, you can run:

```bash
# Pull the latest image
docker pull ghcr.io/opencodeco/distroless-php:8.3

# Run a simple PHP script
docker run --rm -v $(pwd)/test.php:/test.php ghcr.io/opencodeco/distroless-php:8.3 /test.php

# Run PHP with command line arguments
docker run --rm ghcr.io/opencodeco/distroless-php:8.3 --version
```

### Multi-architecture Support

The image supports both AMD64 and ARM64 architectures. Docker will automatically pull the correct image for your platform.
