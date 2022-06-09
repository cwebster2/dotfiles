#!/usr/bin/env bash

IS_PAUSED=$(dunstctl is-paused)

unset STATE
if "$IS_PAUSED" == "true"; then
  STATE="Critical"
else
  STATE="Idle"
fi

jq -n --arg state "$STATE" '{"icon":"bell","state":$state, "text":""}'
