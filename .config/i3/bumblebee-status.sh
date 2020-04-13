#!/bin/bash

source ~/.fonts/fontawesome/*.sh
source ~/miniconda3/bin/activate

/home/casey/src/bumblebee-status/bumblebee-status \
  -m spotify cpu memory nic docker_ps pasink pasource time dunst \
  -p time.format="%-I:%M %P" nic.exclude="lo,docker0" \
  -t solarized-powerline
#  -t wal-powerline


