[[ -o interactive ]] && echo "+ tools"

[[ -o interactive ]] && echo "  + fnm"
eval "$(fnm env --use-on-cd)"

[[ -o interactive ]] && echo "  + fonts"
source ~/.fonts/fontawesome/*.sh

