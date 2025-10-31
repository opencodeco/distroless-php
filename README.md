# Distroless PHP

🐘 PHP focused docker images, minus the operating system.

> Basically: [static-php-cli](https://github.com/crazywhalecc/static-php-cli) + [distroless](https://github.com/GoogleContainerTools/distroless).

[![Build PHP](https://github.com/opencodeco/distroless-php/actions/workflows/php.yml/badge.svg)](https://github.com/opencodeco/distroless-php/actions/workflows/php.yml)
[![Build image](https://github.com/opencodeco/distroless-php/actions/workflows/image.yml/badge.svg)](https://github.com/opencodeco/distroless-php/actions/workflows/image.yml)

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
- `8.1-base` - PHP 8.1 with Composer and Xdebug on Debian (multi-arch: AMD64, ARM64)
- `8.2-base` - PHP 8.2 with Composer and Xdebug on Debian (multi-arch: AMD64, ARM64)
- `8.3-base` - PHP 8.3 with Composer and Xdebug on Debian (multi-arch: AMD64, ARM64)
- `8.4-base` - PHP 8.4 with Composer and Xdebug on Debian (multi-arch: AMD64, ARM64)

### Example

**Using the base image for build stage:**

```dockerfile
FROM ghcr.io/opencodeco/distroless-php:8.3-base AS base
WORKDIR /workspace
COPY composer.* ./
RUN composer install --prefer-dist --no-dev --no-interaction --optimize-autoloader
COPY . .

FROM ghcr.io/opencodeco/distroless-php:8.3
COPY --from=base --chown=nonroot:nonroot /workspace /opt
CMD [ "/opt/bin/hyperf.php", "start" ]
EXPOSE 9501
```

*Note: Base images are available for all PHP versions (8.1-base, 8.2-base, 8.3-base, 8.4-base) and include Composer and Xdebug for development workflows.*

## Building

Images are automatically built and published via GitHub Actions using pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli). The build process uses multi-architecture Docker builds to support both AMD64 and ARM64 platforms.

### CI/CD Pipeline

The project uses a two-stage GitHub Actions pipeline:

1. **PHP Build** (`php.yml`): Builds static PHP binaries for both architectures
   - **Triggers**: Manual workflow dispatch
   - **PHP Versions**: 8.1, 8.2, 8.3, 8.4
   - **Platforms**: `linux/amd64` and `linux/arm64`
   - **Extensions**: 60+ extensions including amqp, apcu, ast, bcmath, brotli, calendar, ctype, curl, dom, ds, exif, ffi, fileinfo, filter, gd, gettext, iconv, igbinary, imagick, inotify, intl, ldap, libxml, mbregex, mbstring, memcache, memcached, mongodb, msgpack, mysqli, mysqlnd, opcache, openssl, opentelemetry, password-argon2, pcntl, pdo, pdo_mysql, pgsql, phar, posix, rdkafka, readline, redis, session, shmop, simplexml, soap, sockets, sodium, sqlite3, swoole, swoole-hook-mysql, swoole-hook-pgsql, swoole-hook-sqlite, tokenizer, xlswriter, xml, xmlreader, xmlwriter, xsl, yaml, zip, zlib, zstd
   - **Additional**: Includes Xdebug extension for base images
   - **Artifacts**: Uploads compiled PHP binaries as GitHub artifacts

2. **Image Build** (`image.yml`): Creates Docker images using the PHP binaries
   - **Triggers**: Manual workflow dispatch (requires PHP workflow run ID)
   - **Registry**: GitHub Container Registry (`ghcr.io`)
   - **Platforms**: Multi-architecture builds for `linux/amd64` and `linux/arm64`
   - **PHP Versions**: Builds all supported PHP versions (8.1, 8.2, 8.3, 8.4)
   - **Image Types**: Both distroless runtime images and Debian-based images with Composer
   - **Caching**: Uses GitHub Actions cache for faster builds
   - **Authentication**: Uses `GITHUB_TOKEN` for registry access

### Architecture Support

- **AMD64** (x86_64): Built using pre-compiled PHP binaries
- **ARM64** (aarch64): Built using pre-compiled PHP binaries

### Build Process

The complete build process consists of two stages:

1. **PHP Binary Compilation** (`php.yml`):
   - Checks out the [static-php-cli](https://github.com/crazywhalecc/static-php-cli) repository (version 2.7.6)
   - Sets up PHP build environment with required tools and extensions
   - Downloads dependencies and compiles PHP with all extensions for multiple PHP versions (8.1, 8.2, 8.3, 8.4)
   - Creates static PHP binaries for both AMD64 and ARM64 architectures
   - Uses matrix builds with architecture-specific runners (ubuntu-24.04 for AMD64, ubuntu-24.04-arm for ARM64)
   - Includes Xdebug extension as a shared module for base images
   - Updates Swoole to specific versions per PHP version (v5.1.8 for PHP 8.1-8.3, v6.0.2 for PHP 8.4)
   - Uploads binaries as GitHub artifacts with version and architecture naming

2. **Docker Image Creation** (`image.yml`):
   - Downloads the PHP binary artifacts from the previous workflow (requires run ID input)
   - Uses multi-stage Docker build with both distroless and Debian base images
   - Copies the appropriate PHP binary based on target architecture using build arguments
   - Creates minimal distroless container images with only PHP binary and distroless base
   - Creates Debian-based images with PHP, Composer, and Xdebug for development use
   - Supports multi-architecture builds (linux/amd64, linux/arm64)
   - Builds all PHP versions (8.1, 8.2, 8.3, 8.4) for both image types
   - Pushes to GitHub Container Registry with appropriate tags

## How it Works

This project combines static PHP binaries with Google's Distroless base images to create minimal, secure PHP runtime containers:

1. **Static PHP Binaries**: Pre-compiled PHP binaries from [static-php-cli](https://github.com/crazywhalecc/static-php-cli) v2.7.6 are built with 60+ extensions for multiple PHP versions (8.1, 8.2, 8.3, 8.4)
2. **Multi-arch Build**: Docker build process uses architecture-specific binaries (AMD64 or ARM64) via build arguments (PHPVERSION and TARGETARCH)
3. **Distroless Base**: Uses `gcr.io/distroless/cc-debian12:nonroot` for minimal attack surface and runs as non-root user
4. **Base Images**: Debian 12.11-based images with Composer 2.8 and Xdebug for development workflows
5. **No OS**: Final distroless images contain only the PHP binary and distroless base - no package managers, shells, or unnecessary tools

### Included PHP Extensions

The PHP binaries include 60+ extensions:
- **Core**: bcmath, calendar, ctype, curl, dom, exif, ffi, fileinfo, filter, iconv, intl, mbregex, mbstring, opcache, openssl, pcntl, pdo, phar, posix, session, shmop, simplexml, soap, sockets, sodium, sqlite3, tokenizer, xml, xmlreader, xmlwriter, xsl, zip, zlib
- **Caching**: apcu, memcache, memcached, redis
- **Database**: mysqli, mysqlnd, pdo_mysql, pgsql, mongodb
- **Messaging**: amqp, rdkafka
- **Performance**: swoole, swoole-hook-mysql, swoole-hook-pgsql, swoole-hook-sqlite, zstd
- **Graphics**: gd, imagick
- **Development**: ast, ffi, xdebug (base images only)
- **Serialization**: igbinary, msgpack, yaml
- **Monitoring**: opentelemetry
- **Utilities**: brotli, ds, gettext, inotify, ldap, libxml, password-argon2, readline, xlswriter

### Project Structure

```
├── distroless.Dockerfile                        # Multi-arch distroless Dockerfile with build arguments (PHPVERSION, TARGETARCH)
├── base.Dockerfile                               # Debian-based image with PHP, Composer, and Xdebug
├── .github/workflows/php.yml                    # PHP binary build pipeline (supports 8.1, 8.2, 8.3, 8.4)
├── .github/workflows/image.yml                  # Docker image build pipeline (both distroless and base)
└── .github/copilot-instructions.md              # Copilot development guidelines
```
