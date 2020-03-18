#!/usr/bin/env bash

SERVICE=${1?You must provide a starphleet sercice name}
HEALTHCHECK=${2:-diagnostic}
HQ=${3:-services}
SHA=${4:-$(git rev-parse --short HEAD)}

CURLCMD="curl --silent --head https://${HQ}-internal.glgresearch.com/${SERVICE}/${HEALTHCHECK}"

for (( ; ; )); do
  OUTPUT=$(${CURLCMD})
  if [[ "${OUTPUT}" =~ .*"${SHA}".* ]]; then
    break
  fi
  sleep 10
done

echo "Its there"
notify-send "Deployment Ready" "${SERVICE} ${SHA}"
