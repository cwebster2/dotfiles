# [[ -o interactive ]] && echo "+ completion sources"
# [[ -o interactive ]] && echo "  + kitty"
# kitty + complete setup zsh | source /dev/stdin

# [[ -o interactive ]] && echo "  + fzf"
export PATH="/home/casey/.fzf/bin:${PATH}"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=sharp --margin=2%"

# [[ -o interactive ]] && echo "  + navi"
if [ ! -z $(command -v navi) ]; then
  source <(navi widget zsh)
fi

# set -x
# [[ -o interactive ]] && echo "  + bitwarden"
# if [ ! -z $(command -v bw) ]; then
#   source <(bw completion --shell zsh)
# fi
# set +x

export DOCKER_BUILDKIT=1

export AWS_DEFAULT_REGION=us-east-1
export AWS_PAGER=
export TERMINFO=/usr/share/terminfo

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  export MOZ_ENABLE_WAYLAND=1
fi
