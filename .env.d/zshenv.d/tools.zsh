[[ -o interactive ]] && echo "+ tools"

if [[ -o interactive ]]; then
  echo "  + fnm"
  eval "$(fnm env --use-on-cd)"
fi

[[ -o interactive ]] && echo "  + fonts"
source ~/.fonts/fontawesome/*.sh

