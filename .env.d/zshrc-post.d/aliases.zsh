echo "+ aliases"

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

alias dockerrmrf="docker rmi $(docker images -f 'dangling=true' -q)"
alias dockercontainerrmrf="docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"

