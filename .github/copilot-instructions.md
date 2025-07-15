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
- Uses a two-stage GitHub Actions pipeline:
  1. **PHP Build** (`php.yml`): Compiles static PHP binaries for multiple versions (8.1-8.4) and architectures
  2. **Image Build** (`image.yml`): Creates Docker images using the compiled binaries
- Final stage uses `gcr.io/distroless/cc-debian12:nonroot` base image
- Supports both `linux/amd64` and `linux/arm64` platforms
- Uses GitHub Container Registry for image distribution

### PHP Configuration
- **Versions**: PHP 8.1, 8.2, 8.3, 8.4 (all supported)
- **Extensions**: 60+ included extensions (defined in `php.yml` workflow)
- **Binary location**: `/bin/php` in final image
- **User**: Runs as non-root user for security

### Project Structure
- `Dockerfile`: Minimal multi-arch configuration with build arguments
- `.github/workflows/php.yml`: PHP binary compilation pipeline
- `.github/workflows/image.yml`: Docker image build and push pipeline
- `.github/copilot-instructions.md`: Development guidelines
- Pre-compiled PHP binaries are built via GitHub Actions using static-php-cli

## Best Practices for This Project

### When working with the Dockerfile:
- Always consider multi-architecture implications
- Minimize layers and build context
- Use appropriate ARG variables (PHPVERSION, TARGETARCH) for target architecture
- Follow security best practices (non-root user, minimal permissions)

### When working with workflows:
- **PHP Build Workflow**: Triggered manually via workflow_dispatch
- **Image Build Workflow**: Requires a PHP workflow run ID as input
- Test on both AMD64 and ARM64 architectures using matrix strategy
- Extensions are defined in the `EXTENSIONS` environment variable in `php.yml`
- Current image builds focus on PHP 8.3 but can be expanded via matrix strategy

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
