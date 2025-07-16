# Distroless PHP

🐘 PHP focused docker images, minus the operating system.

> Basically: [static-php-cli](https://github.com/crazywhalecc/static-php-cli) + [distroless](https://github.com/GoogleContainerTools/distroless).

## Usage

### Distroless Runtime Images

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3
```

### Base Images with Composer

For development and build stages, base images are available with Debian, statically built PHP, and Composer:

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3-base
```

### Available PHP Versions

**Runtime Images (Distroless):**
- `8.1` - PHP 8.1 (multi-arch: AMD64, ARM64)
- `8.2` - PHP 8.2 (multi-arch: AMD64, ARM64)
- `8.3` - PHP 8.3 (multi-arch: AMD64, ARM64)
- `8.4` - PHP 8.4 (multi-arch: AMD64, ARM64)

**Base Images (Debian + Composer):**
- `8.3-base` - PHP 8.3 with Composer on Debian (multi-arch: AMD64, ARM64)

## Building

Images are automatically built and published via GitHub Actions using pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli). The build process uses multi-architecture Docker builds to support both AMD64 and ARM64 platforms.

### CI/CD Pipeline

The project uses a multi-stage GitHub Actions pipeline:

1. **PHP Build** (`php.yml`): Builds static PHP binaries for both architectures
   - **Triggers**: Manual workflow dispatch
   - **PHP Versions**: 8.1, 8.2, 8.3, 8.4
   - **Platforms**: `linux/amd64` and `linux/arm64`
   - **Extensions**: 60+ extensions including amqp, apcu, ast, bcmath, brotli, calendar, ctype, curl, dom, ds, exif, ffi, fileinfo, filter, gd, gettext, iconv, igbinary, imagick, inotify, intl, ldap, libxml, mbregex, mbstring, memcache, memcached, mongodb, msgpack, mysqli, mysqlnd, opcache, openssl, opentelemetry, parallel, password-argon2, pcntl, pdo, pdo_mysql, pgsql, phar, posix, rdkafka, readline, redis, session, shmop, simplexml, soap, sockets, sodium, sqlite3, swoole, swoole-hook-mysql, swoole-hook-pgsql, swoole-hook-sqlite, tokenizer, xlswriter, xml, xmlreader, xmlwriter, xsl, yaml, zip, zlib, zstd
   - **Artifacts**: Uploads compiled PHP binaries as GitHub artifacts

2. **Image Build** (`image.yml`): Creates Docker images using the PHP binaries
   - **Triggers**: Manual workflow dispatch (requires PHP workflow run ID)
   - **Registry**: GitHub Container Registry (`ghcr.io`)
   - **Platforms**: Multi-architecture builds for `linux/amd64` and `linux/arm64`
   - **PHP Version**: Currently builds PHP 8.3 (configurable via matrix)
   - **Caching**: Uses GitHub Actions cache for faster builds
   - **Authentication**: Uses `GITHUB_TOKEN` for registry access

3. **Base Image Build** (`base.yml`): Creates Debian-based images with PHP and Composer
   - **Triggers**: Manual workflow dispatch
   - **Registry**: GitHub Container Registry (`ghcr.io`)
   - **Platforms**: Multi-architecture builds for `linux/amd64` and `linux/arm64`
   - **PHP Version**: Currently builds PHP 8.3 base image
   - **Features**: Includes statically built PHP binary and Composer on Debian base
   - **Use Case**: Ideal for development and build stages where you need package managers and build tools

### Architecture Support

- **AMD64** (x86_64): Built using pre-compiled PHP binaries
- **ARM64** (aarch64): Built using pre-compiled PHP binaries

### Build Process

The complete build process consists of two stages:

1. **PHP Binary Compilation** (`php.yml`):
   - Checks out the [static-php-cli](https://github.com/crazywhalecc/static-php-cli) repository
   - Sets up PHP 8.4 build environment with required tools and extensions
   - Downloads dependencies and compiles PHP with all extensions for multiple PHP versions (8.1, 8.2, 8.3, 8.4)
   - Creates static PHP binaries for both AMD64 and ARM64 architectures
   - Uses matrix builds with architecture-specific runners (ubuntu-latest for AMD64, ubuntu-latest-arm for ARM64)
   - Uploads binaries as GitHub artifacts with version and architecture naming

2. **Docker Image Creation** (`image.yml`):
   - Downloads the PHP binary artifacts from the previous workflow (requires run ID input)
   - Uses multi-stage Docker build with distroless base image
   - Copies the appropriate PHP binary based on target architecture using build arguments
   - Creates minimal container image with only PHP binary and distroless base
   - Supports multi-architecture builds (linux/amd64, linux/arm64)
   - Currently builds PHP 8.3 images (configurable via matrix strategy)
   - Pushes to GitHub Container Registry with appropriate tags

## How it Works

This project combines static PHP binaries with Google's Distroless base images to create minimal, secure PHP runtime containers:

1. **Static PHP Binaries**: Pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli) are built with 60+ extensions for multiple PHP versions (8.1, 8.2, 8.3, 8.4)
2. **Multi-arch Build**: Docker build process uses architecture-specific binaries (AMD64 or ARM64) via build arguments (PHPVERSION and TARGETARCH)
3. **Distroless Base**: Uses `gcr.io/distroless/cc-debian12:nonroot` for minimal attack surface and runs as non-root user
4. **No OS**: Final images contain only the PHP binary and distroless base - no package managers, shells, or unnecessary tools

### Included PHP Extensions

The PHP binaries include 60+ extensions:
- **Core**: bcmath, calendar, ctype, curl, dom, exif, ffi, fileinfo, filter, iconv, intl, mbregex, mbstring, opcache, openssl, pcntl, pdo, phar, posix, session, shmop, simplexml, soap, sockets, sodium, sqlite3, tokenizer, xml, xmlreader, xmlwriter, xsl, zip, zlib
- **Caching**: apcu, memcache, memcached, redis
- **Database**: mysqli, mysqlnd, pdo_mysql, pgsql, mongodb
- **Messaging**: amqp, rdkafka
- **Performance**: swoole, swoole-hook-mysql, swoole-hook-pgsql, swoole-hook-sqlite, parallel, zstd
- **Graphics**: gd, imagick
- **Development**: ast, ffi
- **Serialization**: igbinary, msgpack, yaml
- **Monitoring**: opentelemetry
- **Utilities**: brotli, ds, gettext, inotify, ldap, libxml, password-argon2, readline, xlswriter

### Project Structure

```
├── Dockerfile                                    # Multi-arch Dockerfile with build arguments (PHPVERSION, TARGETARCH)
├── Dockerfile.base                               # Debian-based image with PHP and Composer
├── .github/workflows/php.yml                    # PHP binary build pipeline (supports 8.1, 8.2, 8.3, 8.4)
├── .github/workflows/image.yml                  # Docker image build pipeline
├── .github/workflows/base.yml                   # Base image build pipeline
└── .github/copilot-instructions.md              # Copilot development guidelines
```

### Example

**Using the base image for build stage:**

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3-base AS build
WORKDIR /workspace
COPY composer.* ./
RUN composer install --prefer-dist --no-dev --no-interaction --optimize-autoloader
COPY . .

FROM ghcr.io/opencodeco/distroless-php:8.3
COPY --from=build --chown=nonroot:nonroot /workspace /app
CMD [ "/app/bin/hyperf.php", "start" ]
EXPOSE 9501
```

**Traditional approach (still supported):**

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
