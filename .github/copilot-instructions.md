# Copilot Instructions

## Role and Expertise

You are an expert in:
- **Container images**: Docker, multi-architecture builds, distroless concepts
- **PHP runtime environments**: Static builds, extension management, performance optimization
- **Security**: Minimal attack surface, vulnerability reduction, secure defaults
- **CI/CD**: GitHub Actions, Docker registry operations, automated builds

## Project Context

This repository provides **distroless PHP container images** that combine:
- **Static PHP builds** from [static-php-cli](https://github.com/crazywhalecc/static-php-cli) v2.7.6
- **Google's distroless base images** for minimal attack surface
- **Multi-architecture support** (AMD64/ARM64)
- **Dual image types**: Distroless runtime images and Debian-based development images

### Key Goals
- Provide the smallest possible PHP runtime environment
- Eliminate unnecessary OS packages and dependencies
- Maintain security through minimal attack surface
- Support production-ready PHP applications
- Provide development-friendly base images with Composer and Xdebug

## Technical Architecture

### Build Process
- Uses a two-stage GitHub Actions pipeline:
  1. **PHP Build** (`php.yml`): Compiles static PHP binaries for multiple versions (8.1-8.4) and architectures using static-php-cli v2.7.6
  2. **Image Build** (`image.yml`): Creates Docker images using the compiled binaries for both distroless and base variants
- Distroless images use `gcr.io/distroless/cc-debian12:nonroot` base image
- Base images use `debian:12.11` with Composer 2.8 and Xdebug
- Supports both `linux/amd64` and `linux/arm64` platforms
- Uses GitHub Container Registry for image distribution
- Matrix builds for PHP versions 8.1, 8.2, 8.3, and 8.4
- Architecture-specific runners (ubuntu-24.04 for AMD64, ubuntu-24.04-arm for ARM64)

### PHP Configuration
- **Versions**: PHP 8.1, 8.2, 8.3, 8.4 (all supported)
- **Extensions**: 60+ included extensions including:
  - Core: bcmath, calendar, ctype, curl, dom, exif, ffi, fileinfo, filter, iconv, intl, mbregex, mbstring, opcache, openssl, pcntl, pdo, phar, posix, session, shmop, simplexml, soap, sockets, sodium, sqlite3, tokenizer, xml, xmlreader, xmlwriter, xsl, zip, zlib
  - Caching: apcu, memcache, memcached, redis
  - Database: mysqli, mysqlnd, pdo_mysql, pgsql, mongodb
  - Performance: swoole (v5.1.8 for PHP 8.1-8.3, v6.0.2 for PHP 8.4), zstd
  - Graphics: gd, imagick
  - Development: ast, xdebug (base images only)
  - Other: amqp, rdkafka, brotli, ds, gettext, igbinary, inotify, ldap, libxml, msgpack, opentelemetry, password-argon2, readline, xlswriter, yaml
- **Binary location**: `/bin/php` in final image
- **User**: Runs as non-root user for security
- **ZTS**: Thread-safe builds enabled
- **Special configurations**: 
  - Swoole hooks for MySQL, PostgreSQL, and SQLite
  - MongoDB driver limited to 1.x versions for compatibility

### Project Structure
- `distroless.Dockerfile`: Minimal multi-arch configuration with build arguments (PHPVERSION, TARGETARCH)
- `base.Dockerfile`: Debian-based image with PHP, Composer 2.8, and Xdebug
- `.github/workflows/php.yml`: PHP binary compilation pipeline using static-php-cli v2.7.6
- `.github/workflows/image.yml`: Docker image build and push pipeline for both image types
- `.github/copilot-instructions.md`: Development guidelines
- Pre-compiled PHP binaries are built via GitHub Actions using static-php-cli

## Best Practices for This Project

### When working with the Dockerfile:
- Always consider multi-architecture implications
- Minimize layers and build context
- Use appropriate ARG variables (PHPVERSION, TARGETARCH) for target architecture
- Follow security best practices (non-root user, minimal permissions)
- Two separate Dockerfiles: `distroless.Dockerfile` for runtime and `base.Dockerfile` for development

### When working with workflows:
- **PHP Build Workflow**: Triggered manually via workflow_dispatch
- **Image Build Workflow**: Requires a PHP workflow run ID as input
- Test on both AMD64 and ARM64 architectures using matrix strategy
- Extensions are defined in the `EXTENSIONS` environment variable in `php.yml`
- Both workflows support all PHP versions (8.1, 8.2, 8.3, 8.4) via matrix strategy
- Swoole versions are configured per PHP version (v5.1.8 for 8.1-8.3, v6.0.2 for 8.4)

### When modifying build processes:
- Test on both AMD64 and ARM64 architectures using matrix strategy
- Validate that all required PHP extensions are included
- Ensure the final image size remains minimal
- Verify security scanning passes

### When updating dependencies:
- Update the static-php-cli version in `php.yml` workflow if needed
- Consider the impact on both architectures
- Update documentation accordingly
- Test with real-world PHP applications

## Common Tasks

- **Adding new PHP versions**: Update the matrix strategy in both `php.yml` and `image.yml` workflows
- **Modifying extensions**: Update the `EXTENSIONS` environment variable in `php.yml` workflow and rebuild binaries
- **Optimizing image size**: Review layers, dependencies, and build process
- **Security updates**: Update base images and rebuild with latest binaries
