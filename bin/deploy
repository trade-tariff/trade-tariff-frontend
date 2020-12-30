#!/usr/bin/env bash

[[ "$TRACE" ]] && set -o xtrace
set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

cf login -a "$CF_ENDPOINT" -u "$CF_USER" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"

export GIT_OLD_REVISION=$(cf ssh $CF_APP -c 'cat app/REVISION')
export GIT_NEW_REVISION=$(git rev-parse --short HEAD)
export CF_BUILDPACK="https://github.com/cloudfoundry/ruby-buildpack.git#v1.8.24"

echo $GIT_NEW_REVISION >REVISION

# Replace the buildpack of the current api with the build pack specified above
cat <<HERE >update_buildpack_key.rb
require 'yaml'

app_manifest = YAML.load(STDIN)

app_manifest["applications"].map do |application|
  application["buildpack"] = "$CF_BUILDPACK"
  application.delete("buildpacks")
end

puts YAML.dump(app_manifest)
HERE

function notify() {
  curl -X POST \
    --data-urlencode 'payload={"text": "'"$1"'", "channel": "'"#$SLACK_CHANNEL"'", "username": "cf-deploy", "icon_emoji": ":cloud:", "fields": [{"title": "ENV", "value": "'"$CF_SPACE"'", "short": true}, {"title": "SHA1", "value": "'"<https://github.com/TransformCore/trade-tariff-backend/compare/$GIT_OLD_REVISION...$GIT_NEW_REVISION|$GIT_NEW_REVISION>"'", "short": true}]}' \
    "$SLACK_WEBHOOK"
}

function deploy_frontend() {
  # Fetch existing manifest
  cf create-app-manifest "$CF_APP"

  # Patch downloaded manifest with specified buildpack
  ruby update_buildpack_key.rb <"$CF_APP"_manifest.yml >"$CF_APP"_patched_manifest.yml

  # Deploy patched manifest
  cf blue-green-deploy "$CF_APP" -f "$CF_APP"_patched_manifest.yml --delete-old-apps

  # Attach precreated autoscaling policy
  cf attach-autoscaling-policy "$CF_APP" config/autoscaling/"$CF_SPACE"-policy.json

  # Enable routing from this frontend to backend applications which are private
  cf add-network-policy "$CF_APP" "$CF_BACKEND_APP_XI" --protocol tcp --port 8080
  cf add-network-policy "$CF_APP" "$CF_BACKEND_APP_UK"  --protocol tcp --port 8080
}


notify "Deploying the frontend ${CF_APP}"

deploy_frontend

notify "Deployed the frontend ${CF_APP}"
