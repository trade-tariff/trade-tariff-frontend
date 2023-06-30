#!/bin/bash

environment=$1
docker_tag=$(git rev-parse --short HEAD)
container="${IMAGE_NAME}-$environment"

function fetch_ecr_url {
  json=$(aws ssm get-parameter     \
  --name "/${environment}/FRONTEND_ECR_URL" \
  --with-decryption                \
  --output json                    \
  --color off)

  output=$(jq -r .Parameter.Value <<< "${json}")

  if [ -n "${output}" ]; then
    echo "${output}"
  else
    exit 1
  fi
}

ecr_url=$(fetch_ecr_url)

docker build -t "$container" .
docker tag "${container}:${docker_tag}" "${ecr_url}/${container}:${docker_tag}"

aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" |
  docker login --username AWS --password-stdin "${ecr_url}"

docker push "${ecr_url}/${container}"
