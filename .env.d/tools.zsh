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

kitty + complete setup zsh | source /dev/stdin

source ~/.fonts/fontawesome/*.sh

alias dockerrmrf="docker rmi $(docker images -f 'dangling=true' -q)"
alias dockercontainerrmrf="docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"

tabme() {
  if [ -n "$1" ]; then
    kitty @ new-window --new-tab --tab-title "${(@pj" ")@}"
  else
    kitty @ new-window --new-tab
  fi
}

if [ -d "${HOME}/miniconda3" ]; then
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
fi

test_and_set_path() {
  if [[ -d "$1" && ! "${PATH}" =~ "$1" ]]; then
    export PATH="${1}:${PATH}"
  fi
}

test_and_set_path "${HOME}/bin"
test_and_set_path "/usr/local/go/bin"
test_and_set_path "${HOME}/.cargo/bin"
