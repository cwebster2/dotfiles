[[ -o interactive ]] && echo "+ aliases"

alias code='code-insiders'

if [ ! -z $(command -v bat) ]; then
  alias cat='bat'
fi

if [ ! -z $(command -v prettyping) ]; then
  alias ping='prettyping --nolegend'
fi

if [ ! -z $(command -v exa) ]; then
  alias ls='exa --icons --git'
  alias ll='ls -l'
  alias lla='ls -la'
fi

alias bw_login="_bw_get_session; export BW_SESSION"

alias groot='cd "$(git rev-parse --show-toplevel)"'
alias vimupdate='nvim +PlugClean +PlugUpdate +qa'

alias dockerrmrf="docker rmi $(docker images -f 'dangling=true' -q)"
alias dockercontainerrmrf="docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"

alias gcm='git checkout $(gh repo view --json "defaultBranchRef" --jq ".[] | .name")'

alias icat="kitty +kitten icat"

alias pacman="sudo pacman"
alias apt="sudo apt"
