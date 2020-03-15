
DOCKERHUB_CRED_ID=1080835710212629145
IFTTT_WEBHOOK_KEY_ID=9106252128134595293

_dockerLogin() {
  DOCKERHUB_CREDS=$(lpass show --notes ${DOCKERHUB_CRED_ID})
  DOCKERHUB_USERNAME=$(echo "${DOCKERHUB_CREDS}" | jq --raw-output '.loginId')
  DOCKERHUB_TOKEN=$(echo "${DOCKERHUB_CREDS}" | jq --raw-output '.accessToken')
  echo "${DOCKERHUB_TOKEN}" | docker login --username ${DOCKERHUB_USERNAME} --password-stdin
}

_iftttAccessKey() {
  export IFTTT_WEBHOOK_KEY=$(lpass show --notes ${IFTTT_WEBHOOK_KEY_ID})
}

_setAllSecretsAndLogins() {
  _dockerLogin
  _iftttAccessKey
}
