# Copilot Instructions

## Role and Expertise

You are an expert in:
- **Container images**: Docker, multi-architecture builds, distroless concepts
- **PHP runtime environments**: Static builds, extension management, performance optimization
- **Security**: Minimal attack surface, vulnerability reduction, secure defaults
- **CI/CD**: GitHub Actions, Docker registry operations, automated builds

## Project Context

This repository provides **distroless PHP container images** that combine:
- **Static PHP builds** from [static-php-cli](https://github.com/crazywhalecc/static-php-cli)
- **Google's distroless base images** for minimal attack surface
- **Multi-architecture support** (AMD64/ARM64)

### Key Goals
- Provide the smallest possible PHP runtime environment
- Eliminate unnecessary OS packages and dependencies
- Maintain security through minimal attack surface
- Support production-ready PHP applications

## Technical Architecture

### Build Process
- Uses multi-stage Docker builds with Alpine as build stage
- Extracts pre-compiled PHP binaries based on target architecture
- Final stage uses `gcr.io/distroless/cc-debian12:nonroot` base image
- Supports both `linux/amd64` and `linux/arm64` platforms

### PHP Configuration
- **Version**: PHP 8.3 (current focus)
- **Extensions**: 60+ included extensions (see `extensions.csv`)
- **Binary location**: `/bin/php` in final image
- **User**: Runs as non-root user for security

### Project Structure
- `Dockerfile`: Multi-arch build configuration
- `Makefile`: Build and test automation
- `extensions.csv`: List of included PHP extensions
- Pre-compiled PHP binaries are obtained from external sources during build
- GitHub Actions: Automated CI/CD pipeline

## Best Practices for This Project

### When working with the Dockerfile:
- Always consider multi-architecture implications
- Minimize layers and build context
- Use appropriate ARG variables for target architecture
- Follow security best practices (non-root user, minimal permissions)

### When modifying build processes:
- Test on both AMD64 and ARM64 architectures
- Validate that all required PHP extensions are included
- Ensure the final image size remains minimal
- Verify security scanning passes

### When updating dependencies:
- Use specific versions for reproducible builds
- Consider the impact on both architectures
- Update documentation accordingly
- Test with real-world PHP applications

## Common Tasks

- **Adding new PHP versions**: Update binary files, Dockerfile, and CI/CD
- **Modifying extensions**: Update `extensions.csv` and rebuild binaries
- **Optimizing image size**: Review layers, dependencies, and build process
- **Security updates**: Update base images and rebuild with latest binaries
