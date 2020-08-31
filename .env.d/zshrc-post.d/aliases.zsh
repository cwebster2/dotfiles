if [[ $- =~ "i" ]]; then
  echo "+ aliases"
fi

alias code='code-insiders'

if [ ! -z $(command -v batcat) ]; then
  alias cat='batcat'
fi

if [ ! -z $(command -v prettyping) ]; then
  alias ping='prettyping --nolegend'
fi

if [ ! -z $(command -v exa) ]; then
  alias ll='exa -l'
fi

alias groot='cd "$(git rev-parse --show-toplevel)"'
alias vimupdate='nvim +PlugClean +PlugUpdate +qa'

alias dockerrmrf="docker rmi $(docker images -f 'dangling=true' -q)"
alias dockercontainerrmrf="docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"

alias vpn='cli-go wireguard connect'
