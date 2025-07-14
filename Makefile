.PHONY: 8.3
8.3:
	@docker build --load -f 8.3/Dockerfile -t distroless-php:8.3 .
