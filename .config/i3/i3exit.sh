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
    lock && systemctl suspend
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
