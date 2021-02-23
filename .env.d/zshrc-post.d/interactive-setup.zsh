[[ -o interactive ]] && echo "+ completion sources"
[[ -o interactive ]] && echo "  + kitty"
kitty + complete setup zsh | source /dev/stdin

[[ -o interactive ]] && echo "  + fzf"
export PATH="/home/casey/.fzf/bin:${PATH}"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -o interactive ]] && echo "  + navi"
if [ ! -z $(command -v navi) ]; then
  source <(navi widget zsh)
fi

[[ -o interactive ]] && echo "  + bitwarden"
if [ ! -z $(command -v bw) ]; then
  source <(bw completion --shell zsh)
fi
