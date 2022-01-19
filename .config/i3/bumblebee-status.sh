#!/bin/bash

source ~/.local/share/fonts/fontawesome/*.sh
source ~/miniconda3/bin/activate

/home/casey/src/bumblebee-status/bumblebee-status \
  -m playerctl cpu2 memory nic docker_ps shell pasink pasource datetime battery dunst \
  -p datetime.format="%H:%M %a, %d %b" \
  nic.exclude="lo,docker*,veth,br-*,wg5" \
  nic.states="^down" \
  nic.format="{ssid}" \
  battery.device="BAT0" \
  battery.decorate="False" \
  cpu2.colored="1" \
  cpu2.layout="cpu2.cpuload cpu2.coresload cpu2.temp" \
  cpu2.temp_pattern="temp1_input" \
  shell.command='echo ⌨ $(upower -i /org/freedesktop/UPower/devices/keyboard_dev_CA_D5_E5_3F_FA_06 | grep percentage | cut -f2 -d: | tr -d " %")%' \
  shell.interval="900" \
  playerctl.layout='playerctl.song,playerctl.pause' \
  playerctl.format='{{trunc(artist,25)}} - {{trunc(title,25)}}' \
  playerctl.args='-p spotify' \
  -t iceberg-dark-powerline
  # --markup=pango
#  -t wal-powerline
# docker_ps
  #-t solarized-dark-awesome \
