#!/usr/bin/env bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive
export APT_LISTBUGS_FRONTEND=none
export TARGET_USER=${TARGET_USER:-casey}

# Choose a user account to use for this installation
get_user() {
  if [ -z "${TARGET_USER-}" ]; then
    mapfile -t options < <(find /home/* -maxdepth 0 -printf "%f\\n" -type d)
    # if there is only one option just use that user
    if [ "${#options[@]}" -eq "1" ]; then
      readonly TARGET_USER="${options[0]}"
      echo "Using user account: ${TARGET_USER}"
      return
    fi

    # iterate through the user options and print them
    PS3='command -v user account should be used? '

    select opt in "${options[@]}"; do
      readonly TARGET_USER=$opt
      break
    done
  fi
}

check_is_sudo() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
  fi
}

# install rust
install_rust() {
  (
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    PATH=${HOME}/.cargo/bin:$PATH
    rustup component add rls rust-analysis rust-src
    cargo install xidlehook --bins
    cargo install navi
    cargo install exa
  )
}

# install/update golang from source
install_golang() {
  export GO_VERSION
  GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
  export GO_SRC=/usr/local/go

  # if we are passing the version
  if [[ -n "$1" ]]; then
    GO_VERSION=$1
  fi

  # purge old src
  if [[ -d "$GO_SRC" ]]; then
    sudo rm -rf "$GO_SRC"
    sudo rm -rf "$GOPATH"
  fi

  GO_VERSION=${GO_VERSION#go}

  # subshell
  (
    kernel=$(uname -s | tr '[:upper:]' '[:lower:]')
    curl -sSL "https://storage.googleapis.com/golang/go${GO_VERSION}.${kernel}-amd64.tar.gz" | sudo tar -v -C /usr/local -xz
    local user="$TARGET_USER"
    # rebuild stdlib for faster builds
    sudo chown -R "${user}" /usr/local/go/pkg
    export PATH=/usr/local/go/bin:${PATH}
    CGO_ENABLED=0 go install -a -installsuffix cgo std
  )

  export PATH=/usr/local/go/bin:${GOPATH}/bin:${PATH}
  # get commandline tools
  (
    set -x
    set +e
    go get golang.org/x/lint/golint
    go get golang.org/x/tools/cmd/cover
    go get golang.org/x/tools/cmd/gopls
    go get golang.org/x/review/git-codereview
    go get golang.org/x/tools/cmd/goimports
    go get golang.org/x/tools/cmd/gorename
    go get golang.org/x/tools/cmd/guru

    go get github.com/axw/gocov/gocov
    go get honnef.co/go/tools/cmd/staticcheck

    # Tools for vimgo.
    go get github.com/jstemmer/gotags
    go get github.com/nsf/gocode
    go get github.com/rogpeppe/godef
    go get -u github.com/sourcegraph/go-langserver

    # symlink weather binary for motd
    sudo ln -snf "${GOPATH}/bin/weather" /usr/local/bin/weather
  )
}

get_dotfiles() {
  # create subshell
  (
    cd "$HOME"
    #todo install ssh key from lastpass

    if [[ ! -d "${HOME}/.dotfiles" ]]; then
      echo "Installing dotfiles branch ${DOTFILESBRANCH}"
      DOTFILESBRANCH=${DOTFILESBRANCH:-razer-ubuntu}
      # install dotfiles from repo
      #git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME clone git@github.com:cwebster2/dotfiles.git "${HOME}/.dotfiles"
      #git clone --bare  git@github.com:cwebster2/dotfiles.git "${HOME}/.dotfiles"
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git init
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git remote add install "https://github.com/cwebster2/dotfiles"
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git pull install ${DOTFILESBRANCH}
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git remote add origin "git@github.com:cwebster2/dotfiles"
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git remote rm install
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git config status.showuntrackedfiles no
      GIT_DIR="${HOME}/.dotfiles" GIT_WORK_TREE="${HOME}" GIT_DIR_WORK_TREE=1 git branch --set-upstream-to=origin/${DOTFILESBRANCH} ${DOTFILESBRANCH}

    fi


  )
  install_zsh
}

install_vim() {
  # create subshell
  (
    cd "$HOME"

    # install .vim files
    sudo rm -rf "${HOME}/.vim"
    git clone "https://github.com/cwebster2/vim" "${HOME}/.vim"
    cd "${HOME}/.vim"
    git remote set-url origin git@github.com:cwebster2/vim

    # update alternatives to vim
    sudo update-alternatives --install /usr/bin/vi vi "$(command -v nvim)" 60
    sudo update-alternatives --set vi "$(command -v nvim)"
    sudo update-alternatives --install /usr/bin/vim vim "$(command -v nvim)" 60
    sudo update-alternatives --set vim "$(command -v nvim)"
    sudo update-alternatives --install /usr/bin/editor editor "$(command -v nvim)" 60
    sudo update-alternatives --set editor "$(command -v nvim)"

    ln -s ${HOME}/.vim/coc-settings.json ${HOME}/.config/nvim

    nvim --headless +PlugInstall +qa &
    sleep 180
    killall nvim
  )
}

install_emacs() {
  (
    cd "$HOME"
    sudo rm -rf "${HOME}/.emacs.d"
    git clone "https://github.com/cwebster2/.emacs.d" "${HOME}/.emacs.d"
    cd "${HOME}/.emacs.d"
    git remote set-url origin git@github.com:cwebster2/.emacs.d
  )
}

install_zsh() {
  (
    cd "$HOME"
    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes
    sudo chsh -s $(command -v zsh) ${TARGET_USER}
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    cd "${HOME}/.oh-my-zsh/custom/plugins"
    if  [ ! -d zsh-autosuggestions ]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
    fi
    if  [ ! -d zsh-nvm ]; then
      git clone https://github.com/lukechilds/zsh-nvm zsh-nvm
    fi
    cd "${HOME}/.oh-my-zsh/custom/themes"
    if  [ ! -d powerlevel10k ]; then
      git clone https://github.com/romkatv/powerlevel10k.git powerlevel10k
    fi
  )
  echo "zsh installed"
  cd "$HOME"
}

install_misc() {
  mkdir -p "${HOME}/src"

  echo
  echo "Installing Openrazer and Polychromatic"
  echo
  (
    sudo add-apt-repository -y ppa:openrazer/stable
    sudo add-apt-repository -y ppa:polychromatic/stable
    sudo apt-get update
    sudo apt-get install -y \
      openrazer-meta \
      polychromatic \
      --no-install-recommends
  )

  echo
  echo "Install fzf"
  echo
  (
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --no-update-rc --key-bindings --completion
  )

  echo
  echo "Install delta"
  echo
  (
    DELTA_VERSION="0.0.17"
    TEMPDIR=$(mktemp -d)
    pushd ${TEMPDIR} 2> /dev/null
    wget -qO- "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" | tar xvz
    cp "delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu/delta" ${HOME}/bin
    popd 2> /dev/null
    rm -rf ${TEMPDIR}
    git config --global core.pager 'delta --dark --plus-color="#012800" --minus-color="#340001"'
  )

  echo
  echo "Install Bumblebee-status"
  echo
  (
    cd "${HOME}/src"
    git clone https://github.com/tobi-wan-kenobi/bumblebee-status
  )

  # qmk_firmware prusaslicer Lector wally
  echo
  echo "Installing ergodox keyboard stuff"
  echo
  (
  sudo bash -c "cat > /etc/udev/rules.d/50-wally.rules" << 'EOF'
# Teensy rules for the Ergodox EZ Original / Shine / Glow
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
EOF

  wget -q 'https://configure.ergodox-ez.com/wally/linux' -O "${HOME}/bin/wally"
  chmod 755 "${HOME}/bin/wally"
  )

  echo
  echo "Installing azuredatastudio"
  echo
  (
    wget -q https://go.microsoft.com/fwlink/?linkid=2116780 -O ${HOME}/Downloads/azuredatastudio.deb
    sudo dpkg -i ${HOME}/Downloads/azuredatastudio.deb
    sudo apt-get install -f
  )

  echo
  echo "Installing Snaps"
  echo
  (
    set +e
    sudo snap install discord
    sudo snap install slack --classic
    sudo snap install spotify
    echo "Done"
  )

  echo
  echo "Installing docker credential helper"
  echo
  (
    export GOPATH=$(go env GOPATH)
    set +e
    go get github.com/docker/docker-credential-helpers
    cd ${GOPATH}/src/github.com/docker/docker-credential-helpers
    make secretservice
    ln -s ${PWD}/bin/docker-credential-secretservice ${GOPATH}/bin

    mkdir -p  ${HOME}/.docker
    cat <<- EOF > ${HOME}/.docker/config.json
    {
      "credsStore": "secretservice"
    }
EOF
  )

  echo
  echo "Installing Comfortable Swipe"
  echo
  (
    sudo apt-get install -y \
      libinput-tools \
      libxdo-dev \
      g++ \
      --no-install-recommends

    pushd ${HOME}/src
    git clone https://github.com/Hikari9/comfortable-swipe.git --depth 1
    cd comfortable-swipe
    bash install
    sudo gpasswd -a "${TARGET_USER}" $(ls -l /dev/input/event* | awk '{print $4}' | head --line=1)

    sudo bash -c "cat > /usr/local/share/comfortable-swipe/comfortable-swipe.conf" << 'EOF'
threshold = 0.0
left3 = Super_L+Left
left4 = Super_L+shift+Left
right3 = Super_L+Right
right4 = Super_L+shift+Right
up3 = Super_L+Up
up4 = Super_L+shift+Up
down3 = Super_L+Down
down4 = Super_L+shift+Down
EOF
    popd
  )

  echo
  echo "Setting up symlinks"
  echo
  (
    ln -s ${HOME}/.config/i3/i3exit.sh ${HOME}/bin
  )
}

install_node() {
  (
    source ${HOME}/.nvm/nvm.sh
    nvm install node
    npm install --silent -g typescript eslint bash-language-server neovim
  )
}

install_python() {
  (
    cd ${HOME}
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ${HOME}/miniconda.sh -b -p ${HOME}/miniconda3
    rm ${HOME}/miniconda.sh
  )
  (
    source ${HOME}/miniconda3/bin/activate
    pip install --quiet neovim azure-cli awscli
    conda install -y psutil netifaces
  )
}

install_tools() {
  echo
  echo "Installing node..."
  echo
  install_node;
  echo
  echo "Installing python..."
  echo
  install_python;
  echo
  echo "Installing emacs dotfiles..."
  echo
  install_emacs;
  echo
  echo "Installing dbus socket..."
  echo

  # enable dbus for the user session
  systemctl --user enable dbus.socket

  echo
  echo "Installing golang..."
  echo
  install_golang "go1.13.8";

  echo
  echo "Installing rust..."
  echo
  install_rust;

  # re-set paths now that rust and go are installed
  source ${HOME}/.env.d/zshenv.d/paths.zsh

  echo
  echo "Installing vim environment and dotfiles..."
  echo
  install_vim;

  echo
  echo "Installing user programs..."
  echo
  install_misc;
}

usage() {
  echo -e "install.sh\\n\\tThis script installs my basic setup for a debian laptop\\n"
  echo "Usage:"
  echo "  dotfiles                            - get dotfiles"
  echo "  vim                                 - install vim specific dotfiles"
  echo "  golang                              - install golang and packages"
  echo "  rust                                - install rust"
  echo "  python                              - install Python 3 (miniconda)"
  echo "  node                                - install node via nvm"
  echo "  tools                               - install golang, rust, and scripts"
}

main() {
  local cmd=$1

  if [[ -z "$cmd" ]]; then
    usage
    exit 1
  fi

  if [[ $cmd == "dotfiles" ]]; then
    get_user
    get_dotfiles
  elif [[ $cmd == "vim" ]]; then
    install_vim
  elif [[ $cmd == "rust" ]]; then
    install_rust
  elif [[ $cmd == "node" ]]; then
    install_node
  elif [[ $cmd == "python" ]]; then
    install_python
  elif [[ $cmd == "golang" ]]; then
    install_golang "$2"
  elif [[ $cmd == "scripts" ]]; then
    install_scripts
  elif [[ $cmd == "tools" ]]; then
    install_tools
  else
    usage
  fi
}

main "$@"
