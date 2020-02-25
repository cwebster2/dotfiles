#!/bin/bash

source ~/.fonts/fontawesome/*.sh

/home/casey/src/bumblebee-status/bumblebee-status \
  -m spotify cpu memory nic docker_ps pasink pasource time dunst \
  -p time.format="%-I:%M %P" nic.exclude="lo,docker0" \
  -t solarized-powerline
#  -t wal-powerline


