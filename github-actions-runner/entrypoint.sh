#!/bin/sh -l

# Environment variable that need to be set up:
# * APP_ID, the GitHub's app ID
# * APP_KEY, the content of GitHub app's private key in PEM format.
# * APP_ORG, the Github org name, where GitHub's app installed
# * REGISTRATION_TOKEN_API_URL, the registration API URL from Github


_GITHUB_HOST=${GITHUB_HOST:="github.com"}

# if [[ -z "${APP_ID}" ]] || [[ -z "${APP_KEY}" ]] || [[ -z "${APP_ORG}" ]] || [[ -z "${REGISTRATION_TOKEN_API_URL}" ]]; then
#   echo "ERROR: APP_ID, APP_KEY, APP_ORG, and REGISTRATION_TOKEN_API_URL are required."
#   exit 1
# fi


TOKEN=$(APP_ID="${APP_ID}" APP_KEY="${APP_KEY}" APP_ORG="${APP_ORG}" bash ./app_token.sh)
ORG_URL="https://${_GITHUB_HOST}/${APP_ORG}"


# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -XPOST -fsSL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"


./config.sh --url $ORG_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh