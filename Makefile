.PHONY: all build run clean

IMAGE_NAME := trade-tariff-frontend

all: build

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run \
		--env-file ".env.development" \
		--network=host \
		--rm \
		-e 'SECRET_KEY_BASE="0620b2907b1cee61dbcf5cbbf4125c04bf5db3554c66589d40a9349b5abd5463a40f4a1a8c2db9b07c13715340ee3c94bbc24b1adb3140a20f702e9dc3d4fc0c"' \
		-e 'GOVUK_APP_DOMAIN="localhost"' \
		-e 'GOVUK_WEBSITE_ROOT="http://localhost/"' \
		$(IMAGE_NAME)

clean:
	docker rmi $(IMAGE_NAME)
