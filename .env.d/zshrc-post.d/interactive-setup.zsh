kitty + complete setup zsh | source /dev/stdin

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ ! -z $(command -v navi) ]; then
  source <(navi widget zsh)
fi
