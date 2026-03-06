# [[ -o interactive ]] && echo "+ aliases"

alias code='code-insiders'

(( $+commands[bat] )) && alias cat='bat'
(( $+commands[prettyping] )) && alias ping='prettyping --nolegend'
(( $+commands[eza] )) && {
  alias ls='eza --icons --git'
  alias ll='ls -l'
  alias lla='ls -la'
}

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

alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
