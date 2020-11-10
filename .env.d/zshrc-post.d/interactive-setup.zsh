kitty + complete setup zsh | source /dev/stdin

export PATH="/home/casey/.fzf/bin:${PATH}"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ ! -z $(command -v navi) ]; then
  source <(navi widget zsh)
fi
