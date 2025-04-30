# [[ -o interactive ]] && echo "+ Setting paths"
mkdir -p /tmp/$(whoami)
export TMPDIR=/tmp/$(whoami)

# [[ -o interactive ]] && echo "  + miniconda"
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
    # [[ -o interactive ]] && echo "  + ${1}"
    export PATH="${1}:${PATH}"
  fi
}

test_and_set_path "${HOME}/bin"
test_and_set_path "/usr/local/go/bin"
test_and_set_path "${HOME}/.cargo/bin"
test_and_set_path "${HOME}/.local/bin"
test_and_set_path "${HOME}/.tfenv/bin"
test_and_set_path "${HOME}/.local/share/nvim/mason/bin"

export DENO_INSTALL="${HOME}/.deno"
export DVM_DIR="${HOME}/.dvm"
test_and_set_path "${DENO_INSTALL}/bin"
test_and_set_path "${DVM_DIR}/bin"

if [ ! -z $(command -v go) ]; then
  export GOPATH=$(go env GOPATH)
  test_and_set_path "${GOPATH}/bin"
fi
