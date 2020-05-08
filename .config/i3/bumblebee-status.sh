#!/bin/bash

source ~/.fonts/fontawesome/*.sh
source ~/miniconda3/bin/activate

/home/casey/src/bumblebee-status/bumblebee-status \
  -m spotify cpu cpu2 memory nic docker_ps pasink pasource datetime dunst \
  -p datetime.format="%H:%M %a, %d %b" \
  nic.exclude="lo,docker0,veth" \
  cpu2.colored="1" \
  cpu2.layout="cpu2.coresload cpu2.temp" \
  cpu2.temp_pattern="temp1_input" \
  -t iceberg-dark-powerline \
  --markup=pango
#  -t wal-powerline
  #-t solarized-dark-awesome \
