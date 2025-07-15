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

### CI/CD Pipeline

The project uses a two-stage GitHub Actions pipeline:

1. **PHP Build** (`php.yml`): Builds static PHP binaries for both architectures
   - **Triggers**: Manual workflow dispatch
   - **Platforms**: `linux/amd64` and `linux/arm64`
   - **Extensions**: 60+ extensions including amqp, apcu, ast, bcmath, brotli, calendar, ctype, curl, dom, exif, gd, imagick, mongodb, mysql, redis, swoole, and many more
   - **Artifacts**: Uploads compiled PHP binaries as GitHub artifacts

2. **Image Build** (`image.yml`): Creates Docker images using the PHP binaries
   - **Triggers**: Manual workflow dispatch (requires PHP workflow run ID)
   - **Registry**: GitHub Container Registry (`ghcr.io`)
   - **Platform**: Currently `linux/arm64` (configurable)
   - **Caching**: Uses GitHub Actions cache for faster builds
   - **Authentication**: Uses `GITHUB_TOKEN` for registry access

### Architecture Support

- **AMD64** (x86_64): Built using pre-compiled PHP binaries
- **ARM64** (aarch64): Built using pre-compiled PHP binaries

### Build Process

The complete build process consists of two stages:

1. **PHP Binary Compilation** (`php.yml`):
   - Checks out the [static-php-cli](https://github.com/crazywhalecc/static-php-cli) repository
   - Sets up PHP 8.4 build environment
   - Downloads dependencies and compiles PHP with all extensions
   - Creates static PHP binaries for both AMD64 and ARM64 architectures
   - Uploads binaries as GitHub artifacts

2. **Docker Image Creation** (`image.yml`):
   - Downloads the PHP binary artifacts from the previous workflow
   - Uses multi-stage Docker build with distroless base image
   - Copies the appropriate PHP binary based on target architecture
   - Creates minimal container image with only PHP binary and distroless base
   - Pushes to GitHub Container Registry

## How it Works

This project combines static PHP binaries with Google's Distroless base images to create minimal, secure PHP runtime containers:

1. **Static PHP Binaries**: Pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli) are built with 60+ extensions including popular ones like Redis, MySQL, MongoDB, Swoole, ImageMagick, and more
2. **Multi-arch Build**: Docker build process uses architecture-specific binaries (AMD64 or ARM64) via build arguments
3. **Distroless Base**: Uses `gcr.io/distroless/cc-debian12:nonroot` for minimal attack surface and runs as non-root user
4. **No OS**: Final images contain only the PHP binary and distroless base - no package managers, shells, or unnecessary tools

### Included PHP Extensions

The PHP binaries include 60+ extensions:
- **Core**: bcmath, calendar, ctype, curl, dom, exif, fileinfo, filter, iconv, intl, mbstring, opcache, openssl, pcntl, pdo, phar, posix, session, shmop, simplexml, soap, sockets, sodium, sqlite3, tokenizer, xml, xmlreader, xmlwriter, xsl, zip, zlib
- **Caching**: apcu, memcache, memcached, redis
- **Database**: mysqli, mysqlnd, pdo_mysql, pgsql, mongodb
- **Messaging**: amqp, rdkafka
- **Performance**: swoole, swoole-hook-mysql, swoole-hook-pgsql, swoole-hook-sqlite, parallel, zstd
- **Graphics**: gd, imagick
- **Development**: ast, ffi, xdebug (if enabled)
- **Serialization**: igbinary, msgpack, yaml
- **Monitoring**: opentelemetry
- **Utilities**: brotli, ds, gettext, inotify, ldap, libxml, password-argon2, readline, xlswriter

### Project Structure

```
├── Dockerfile                                    # Multi-arch Dockerfile with build arguments
├── .github/workflows/php.yml                    # PHP binary build pipeline
└── .github/workflows/image.yml                  # Docker image build pipeline
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
