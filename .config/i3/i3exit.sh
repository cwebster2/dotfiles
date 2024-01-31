#!/bin/bash

lock() {
  i3lock -c 000000
}

case "$1" in
  lock)
    lock
    ;;
  logout)
    i3-msg exit
    ;;
  suspend)
    xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --primary --mode 3840x2160 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off
    lock && systemctl suspend
    sleep 5 && xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --primary --mode 3840x2160 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --mode 3840x2160 --pos 5760x0 --rotate normal
    ;;
  reboot)
    systemctl reboot
    ;;
  halt)
    systemctl poweroff
    ;;
  *)
    echo "Usage: $0 {lock|logout|suspend|reboot|halt}"
    exit 2
esac

exit 0
