echo "+ aliasing tools"

alias code='code-insiders'
if which batcat > /dev/null; then
  alias cat='batcat'
fi

if [ -f /home/casey/bin/prettyping ]; then
  alias ping='prettyping --nolegend'
fi

if [ -f /usr/bin/exa ]; then
  alias ll='exa -l'
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.fonts/fontawesome/*.sh

