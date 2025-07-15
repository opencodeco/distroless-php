.PHONY: 8.3 8.3-test

# Build PHP 8.3 image
8.3:
	docker build -t ghcr.io/opencodeco/distroless-php:8.3 .

# Test PHP 8.3 image
8.3-test:
	docker run --rm ghcr.io/opencodeco/distroless-php:8.3 --version
