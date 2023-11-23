#!/bin/sh -l

# Environment variable that need to be set up:
# * APP_ID, the GitHub's app ID
# * APP_KEY, the content of GitHub app's private key in PEM format.
# * APP_ORG, the Github org name, where GitHub's app installed
# * REGISTRATION_TOKEN_API_URL, the registration API URL from Github


export -n APP_ID
export -n APP_KEY
export -n APP_ORG

_GITHUB_HOST=${GITHUB_HOST:="github.com"}

ARGS=()
if [[ -n "${APP_ID}" ]] && [[ -n "${APP_KEY}" ]] && [[ -n "${APP_ORG}" ]] && [[ -n "${REGISTRATION_TOKEN_API_URL}" ]]; then
  echo "ERROR: APP_ID, APP_KEY, APP_ORG and REGISTRATION_TOKEN_API_URL required." >&2
  exit 1
fi

GITHUB_PAT=$(APP_ID="${APP_ID}" APP_KEY="${APP_KEY//\\n/${nl}}" APP_ORG="${APP_ORG}" bash ../app_token.sh)
ORG_URL="https://${_GITHUB_HOST}/${APP_ORG}"

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $GITHUB_PAT" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"

./config.sh --url $ORG_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh