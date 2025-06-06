# [[ -o interactive ]] && echo "+ aliases"

alias code='code-insiders'

if [ ! -z $(command -v bat) ]; then
  alias cat='bat'
fi

if [ ! -z $(command -v prettyping) ]; then
  alias ping='prettyping --nolegend'
fi

if [ ! -z $(command -v eza) ]; then
  alias ls='eza --icons --git'
  alias ll='ls -l'
  alias lla='ls -la'
fi

alias bw_login="_bw_get_session; export BW_SESSION"

alias groot='cd "$(git rev-parse --show-toplevel)"'
alias vimupdate='nvim +PlugClean +PlugUpdate +qa'

alias dockerrmrf="docker rmi $(docker images -f 'dangling=true' -q)"
alias dockercontainerrmrf="docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"

alias gcm='git checkout $(gh repo view --json "defaultBranchRef" --jq ".[] | .name")'
alias git.branches="git for-each-ref --color=always --sort=-committerdate refs/heads refs/remotes --format='%(authordate:short) %(color:red)%(objectname:short) %(color:yellow)%(refname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset)) %(authorname)'"

alias icat="kitty +kitten icat"

alias pacman="sudo pacman"
alias apt="sudo apt"

alias norg='nvim +"Neorg journal today"'
alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
