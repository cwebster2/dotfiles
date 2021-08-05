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

function is_bin_in_path {
  builtin type -P "$1" &> /dev/null
}

# install rust
install_rust() {
  (
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    PATH=${HOME}/.cargo/bin:$PATH
    sudo apt-get install -y
    rustup component add rls rust-analysis rust-src
    is_bin_in_path i3 && cargo install xidlehook --bins
    is_bin_in_path i3 && cargo install i3-auto-layout
    cargo install \
      navi \
      exa \
      fnm \
      ripgrep \
      bat
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
    go get github.com/genuinetools/weather

    go get github.com/wagoodman/dive

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
    sudo apt-get install kitty-terminfo
    #todo install ssh key from lastpass

    if [[ ! -d "${HOME}/.dotfiles" ]]; then
      echo "Installing dotfiles branch ${DOTFILESBRANCH}"
      DOTFILESBRANCH=${DOTFILESBRANCH:-master}
      # install dotfiles from repo
      export GIT_DIR="${HOME}/.dotfiles"
      export GIT_WORK_TREE="${HOME}"
      export GIT_DIR_WORK_TREE=1
      git init
      git remote add origin "https://github.com/cwebster2/dotfiles"
      git fetch --all
      git branch -f ${DOTFILESBRANCH} origin/${DOTFILESBRANCH}
      git checkout ${DOTFILESBRANCH}
      git pull origin ${DOTFILESBRANCH}
      git config status.showuntrackedfiles no
      git remote set-url origin "git@github.com:cwebster2/dotfiles"
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
    sudo rm -rf "${HOME}/.config/nvim"
    git clone "https://github.com/cwebster2/vim" "${HOME}/.config/nvim"
    ln -s "${HOME}/.config/nvim" "${HOME}/.vim"
    cd "${HOME}/.config/nvim"
    git remote set-url origin git@github.com:cwebster2/vim
    git checkout nvim-lua

    # update alternatives to vim
    curl -fLo "${HOME}"/bin/nvim.appimage "https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
    # Todo detect if docker and only do this if so
    (
      pushd "$HOME"/bin 2>/dev/null
      chmod +x ./nvim.appimage
      ./nvim.appimage --appimage-extract
      mv squashfs-root nvim
      popd 2>/dev/null
    )
    sudo update-alternatives --install /usr/bin/vi vi "${HOME}"/bin/nvim/AppRun 60
    sudo update-alternatives --set vi "${HOME}"/bin/nvim/AppRun
    sudo update-alternatives --install /usr/bin/vim vim "${HOME}"/bin/nvim/AppRun 60
    sudo update-alternatives --set vim "${HOME}"/bin/nvim/AppRun
    sudo update-alternatives --install /usr/bin/nvim nvim "${HOME}"/bin/nvim/AppRun 60
    sudo update-alternatives --set vim "${HOME}"/bin/nvim/AppRun
    sudo update-alternatives --install /usr/bin/editor editor "${HOME}"/bin/nvim/AppRun 60
    sudo update-alternatives --set editor "${HOME}"/bin/nvim/AppRun

    PACKER_DIRECTORY="${HOME}/.local/share/nvim/site/pack/packer/opt/packer.nvim"

    if ! [ -d "$PACKER_DIRECTORY" ]; then
      git clone "https://github.com/wbthomason/packer.nvim" "$PACKER_DIRECTORY"
    fi

    "${HOME}"/bin/nvim/AppRun -u NONE --headless \
      +'autocmd User PackerComplete quitall' \
      +'lua require("plugins")' \
      +'lua require("packer").sync()'

    "${HOME}"/.config/nvim/lspinstall.sh all
  )
}

install_emacs() {
  (
    cd "$HOME"
    sudo rm -rf "${HOME}/.emacs.d"
    sudo rm -rf "${HOME}/.doom.d"
    git clone "https://github.com/hlissner/doom-emacs" "${HOME}/.emacs.d"
    git clone "https://github.com/cwebster2/.doom.d" "${HOME}/.doom.d"
    "${HOME}/.emacs.d/bin/doom" --yes install --no-env --no-fonts
    cd "${HOME}/.doom.d"
    git remote set-url origin git@github.com:cwebster2/.doom.d
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
    if  [ ! -d zsh-lazyload ]; then
      git clone https://github.com/qoomon/zsh-lazyload zsh-lazyload
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
    git clone --branch main https://github.com/tobi-wan-kenobi/bumblebee-status
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
  echo "Installing ranger"
  echo
  
  (
    sudo apt-get install -y ranger
    echo "inode/directory=ranger.desktop" >> ${HOME}/.config/mimeapps.list
  )

  echo
  echo "Installing Discord"
  echo
  (
    set +e
    sudo snap install discord
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
  echo "Setting up symlinks"
  echo
  (
    ln -s ${HOME}/.config/i3/i3exit.sh ${HOME}/bin
  )

  echo
  echo "Setting sleep timeouts"
  echo
  (
    sudo gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout '0'
    sudo gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout '10'

    sudo bash -c "cat >> /etc/gdm3/greeter.dconf-defaults" << 'EOF'
sleep-inactive-ac-timeout=0
sleep-inactive-ac-type='nothing'
EOF
  )
}

install_terraform() {
  (
    mkdir -p "${HOME}/src"
    pushd "${HOME}/src" 2>/dev/null
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    popd 2>/dev/null
    pushd "${HOME}/bin" 2>/dev/null
    ln -s /home/casey/src/tfenv/bin/terraform .
    ln -s /home/casey/src/tfenv/bin/tfenv .
    "${HOME}/bin/tfenv" install 0.12.31
    "${HOME}/bin/tfenv" use 0.12.31
    popd 2>/dev/null
  )
}

install_node() {
  (
    source ${HOME}/.nvm/nvm.sh
    nvm install node
    npm install --silent -g \
      typescript \
      eslint \
      neovim \
      prettier \
      eslint_d \
      @bitwarden/cli
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
    pip install --quiet neovim azure-cli awscli docker
    conda install -y psutil netifaces dbus-python pango
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
  echo "Installing dbus socket..."
  echo

  # enable dbus for the user session
  systemctl --user enable dbus.socket

  echo
  echo "Installing golang..."
  echo
  install_golang "go1.15.7";

  echo
  echo "Installing rust..."
  echo
  install_rust;

  echo
  echo "Installing terraform"
  echo
  install_terraform;

  # re-set paths now that rust and go are installed
  source ${HOME}/.env.d/zshenv.d/paths.zsh

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
  echo "  emacs                               - install emacs specific dotfiles"
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
  elif [[ $cmd == "emacs" ]]; then
    install_emacs
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
