#!/bin/sh -l

export -n APP_ID
export -n APP_KEY
export -n APP_ORG

ARGS=()
if [[ -n "${APP_ID}" ]] && [[ -n "${APP_KEY}" ]] && [[ -n "${APP_ORG}" ]]; then
  echo "ERROR: APP_ID and APP_KEY and APP_ORG required." >&2
  exit 1
fi

GITHUB_PAT=$(APP_ID="${APP_ID}" APP_KEY="${APP_KEY//\\n/${nl}}" APP_ORG="${APP_ORG}" bash ../app_token.sh)

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL \
  -H 'Accept: application/vnd.github.v3+json' \
  -H "Authorization: Bearer $GITHUB_PAT" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"

./config.sh --url $REPO_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh