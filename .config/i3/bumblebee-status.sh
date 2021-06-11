#!/bin/bash

source ~/.fonts/fontawesome/*.sh
source ~/miniconda3/bin/activate

/home/casey/src/bumblebee-status/bumblebee-status \
  -m spotify cpu cpu2 memory nic docker_ps shell pasink pasource datetime dunst \
  -p datetime.format="%H:%M %a, %d %b" \
  nic.exclude="lo,docker*,veth,br-*,wg5" \
  nic.states="^down" \
  cpu2.colored="1" \
  cpu2.layout="cpu2.coresload cpu2.temp" \
  cpu2.temp_pattern="temp1_input" \
  shell.command='echo ⌨ $(upower -i /org/freedesktop/UPower/devices/keyboard_dev_CA_D5_E5_3F_FA_06 | grep percentage | cut -f2 -d: | tr -d " %")%' \
  shell.interval="60" \
  -t iceberg-dark-powerline 
  # --markup=pango
#  -t wal-powerline
  #-t solarized-dark-awesome \
