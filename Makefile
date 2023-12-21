.PHONY: all build run clean

IMAGE_NAME := trade-tariff-frontend

all: build

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --env-file ".env.development" --network=host --rm $(IMAGE_NAME)

clean:
	docker rmi $(IMAGE_NAME)
