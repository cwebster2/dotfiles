#!/usr/bin/env bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive
export TARGET_USER=casey

check_is_sudo() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
  fi
}

setup_sources_min() {
  apt update || true
  apt install -y \
    apt-transport-https \
    apt-listbugs \
    ca-certificates \
    curl \
    dirmngr \
    gnupg2 \
    lsb-release \
    --no-install-recommends

  # turn off translations, speed up apt update
  mkdir -p /etc/apt/apt.conf.d
  echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99translations
}

 # sets up apt sources
setup_sources() {
  setup_sources_min;

  cat <<-EOF > /etc/apt/sources.list
  deb http://httpredir.debian.org/debian sid main contrib non-free
  deb-src http://httpredir.debian.org/debian/ sid main contrib non-free

  deb http://httpredir.debian.org/debian experimental main contrib non-free
  deb-src http://httpredir.debian.org/debian experimental main contrib non-free
  EOF

  # yubico
  cat <<-EOF > /etc/apt/sources.list.d/yubico.list
  deb http://ppa.launchpad.net/yubico/stable/ubuntu xenial main
  deb-src http://ppa.launchpad.net/yubico/stable/ubuntu xenial main
  EOF

  # tlp: Advanced Linux Power Management
  cat <<-EOF > /etc/apt/sources.list.d/tlp.list
  # tlp: Advanced Linux Power Management
  # http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html
  deb http://repo.linrunner.de/debian sid main
  EOF

  # Create an environment variable for the correct distribution
  CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  export CLOUD_SDK_REPO

  # Add the Cloud SDK distribution URI as a package source
  cat <<-EOF > /etc/apt/sources.list.d/google-cloud-sdk.list
  deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main
  EOF

  # Import the Google Cloud Platform public key
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

  # Add the Google Chrome distribution URI as a package source
  cat <<-EOF > /etc/apt/sources.list.d/google-chrome.list
  deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
  EOF

  # Import the Google Chrome public key
  curl https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

  # add the yubico ppa gpg key
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 3653E21064B19D134466702E43D5C49532CBA1A9

  # add the tlp apt-repo gpg key
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 6B283E95745A6D903009F7CA641EED65CD4E8809

  #TODO: More sources!
  # google chrome, keybase, lutris, ms, slack, spotify, vscode
}

# conda / python
# last change shell to zsh, start zsh and source tools

#TODO
#bumblebee stats and anything else manually built for i3


base_min() {
	apt update || true
	apt -y upgrade

	apt install -y \
		adduser \
		automake \
    bat \
		bc \
		bzip2 \
		ca-certificates \
		coreutils \
		curl \
		dnsutils \
    fd-find \
		file \
		findutils \
		gcc \
		git \
		gnupg \
		gnupg2 \
		grep \
		gzip \
		hostname \
		indent \
		iptables \
    iw \
		jq \
		less \
		libc6-dev \
		locales \
		lsof \
		make \
		mount \
    net-tools \
		policykit-1 \
		silversearcher-ag \
		ssh \
		strace \
		sudo \
		tar \
		tree \
		tzdata \
		unzip \
		vim \
    neovim \
    emacs-gtk \
		xz-utils \
		zip \
		--no-install-recommends

	apt autoremove
	apt autoclean
	apt clean

	install_scripts
}

# installs base packages
# the utter bare minimal shit
base() {
	base_min;

	apt update || true
	apt -y upgrade

	apt install -y \
		apparmor \
    bluez \
    bolt \
		bridge-utils \
    build-essential \
		cgroupfs-mount \
    cpufrequtls \
		fwupd \
		fwupdate \
		gnupg-agent \
		google-cloud-sdk \
		iwd \
    lastpass-cli \
		libapparmor-dev \
		libimobiledevice6 \
		libltdl-dev \
		libpam-systemd \
		libseccomp-dev \
    pcscd \
		pinentry-curses \
		scdaemon \
		systemd \
    fzf \
    gdm3 \
    htop \
    iproute2 \
    lshw \
    mpd \
    locate \
    netbase \
    netcat \
    nftables \
    pkg-config \
    rsync \
    software-properties-common \
    texlive \
    traceroute \
    unrar \
    tcptraceroute \
    zsh \
    lm-sensors \
    exuberant-ctags \
    docker-compose \
    docker.io \
    printer-driver-brlaser \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libdrm-dev \
    libexpat1-dev \
    libffi-dev \
    libfl-dev \
    libfontconfig1-dev \
    libfreetype-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libice-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libjsoncpp-dev \
    libmount-dev \
    libmpdclient-dev \
    libncurses-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libnl-route-3-dev \
    libpcre2-dev \
    libpcre3-dev \
    libpixman-1-dev \
    libpng-dev \
    libpthread-stubs0-dev \
    libpulse-dev \
    librados-dev \
    librbd-dev \
    librdmacm-dev \
    libselinux1-dev \
    libsepol1-dev \
    libsm-dev \
    libssl-dev \
    libuv1-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxau-dev \
    libxcb-composite0-dev \
    libxcb-cursor-dev \
    libxcb-damage0-dev \
    libxcb-dpms0-dev \
    libxcb-dri2-0-dev \
    libxcb-dri3-dev \
    libxcb-ewmh-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-present-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-render0-dev \
    libxcb-screensaver0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util0-dev \
    libxcb-xfixes0-dev \
    libxcb-xinput-dev \
    libxcb-xkb-dev \
    libxcb-xrm-dev \
    libxcb1-dev \
    libxdamage-dev \
    libxdmcp-dev \
    libxext-dev \
    libxfixes-dev \
    libxkbfile-dev \
    libxml2-dev \
    libxrender-dev \
    libxshmfence-dev \
    libxslt1-dev \
    libxt-dev \
    libxxf86vm-dev \
    uuid-dev \
    x11proto-core-dev \
    x11proto-damage-dev \
    x11proto-dev \
    x11proto-fixes-dev \
    x11proto-xext-dev \
    x11proto-xf86vidmode-dev \
    xtrans-dev \
    zlib1g-dev \
		--no-install-recommends

	setup_sudo

	apt autoremove
	apt autoclean
	apt clean
}

# setup sudo for a user
# because fuck typing that shit all the time
# just have a decent password
# and lock your computer when you aren't using it
# if they have your password they can sudo anyways
# so its pointless
# i know what the fuck im doing ;)
setup_sudo() {
	# add user to sudoers
	adduser "$TARGET_USER" sudo

	# add user to systemd groups
	# then you wont need sudo to view logs and shit
	gpasswd -a "$TARGET_USER" systemd-journal
	gpasswd -a "$TARGET_USER" systemd-network

	# create docker group
	sudo groupadd docker
	sudo gpasswd -a "$TARGET_USER" docker

	# add go path to secure path
	{ \
		echo -e "Defaults	secure_path=\"/usr/local/go/bin:/home/${TARGET_USER}/.go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/share/bcc/tools:/home/${TARGET_USER}/.cargo/bin\""; \
		echo -e 'Defaults	env_keep += "ftp_proxy http_proxy https_proxy no_proxy GOPATH EDITOR"'; \
		echo -e "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL"; \
		echo -e "${TARGET_USER} ALL=NOPASSWD: /sbin/ifconfig, /sbin/ifup, /sbin/ifdown, /sbin/ifquery"; \
	} >> /etc/sudoers

	# setup downloads folder as tmpfs
	# that way things are removed on reboot
	# i like things clean but you may not want this
	mkdir -p "/home/$TARGET_USER/Downloads"
	echo -e "\\n# tmpfs for downloads\\ntmpfs\\t/home/${TARGET_USER}/Downloads\\ttmpfs\\tnodev,nosuid,size=2G\\t0\\t0" >> /etc/fstab
}

# install rust
install_rust() {
	curl https://sh.rustup.rs -sSf | sh
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
	local user="$USER"
	# rebuild stdlib for faster builds
	sudo chown -R "${user}" /usr/local/go/pkg
	CGO_ENABLED=0 go install -a -installsuffix cgo std
	)

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
}

# install graphics drivers
install_graphics() {
	local system=$1

	if [[ -z "$system" ]]; then
		echo "You need to specify whether it's intel, geforce or optimus"
		exit 1
	fi

	local pkgs=( xorg xserver-xorg xserver-xorg-input-libinput xserver-xorg-input-synaptics )

	case $system in
		"intel")
			pkgs+=( xserver-xorg-video-intel )
			;;
		"geforce")
			pkgs+=( nvidia-driver )
			;;
		"optimus")
			pkgs+=( nvidia-kernel-dkms bumblebee-nvidia primus )
			;;
		*)
			echo "You need to specify whether it's intel, geforce or optimus"
			exit 1
			;;
	esac

	apt update || true
	apt -y upgrade

	apt install -y "${pkgs[@]}" --no-install-recommends
}

# install stuff for i3 window manager
install_wmapps() {
	apt update || true
	apt install -y \
		alsa-utils \
		feh \
		i3 \
		i3lock-fancy \
		i3status \
		flameshot \
		suckless-tools \
		kitty \
    rofi \
		usbmuxd \
		xclip \
		compton \
    arandr \
    adwaita-icon-theme \
    breeze-cursor-theme \
    breeze-gtk-theme \
    breeze-icon-theme \
    dunst \
    firefox \
    franz \
    gucharmap \
    hicolor-icon-theme \
    higan \
    hub \
    inkscape \
    kdeconnect \
    lxappearance \
    neofetch \
    oxygen-icon-theme \
    pavucontrol \
    pinentry-qt \
    remmina \
    vlc \
    wmctrl \
    discord \
		--no-install-recommends

}

get_dotfiles() {
	# create subshell
	(
	cd "$HOME"
  #todo install ssh key from lastpass

	if [[ ! -d "${HOME}/.dotfiles" ]]; then
		# install dotfiles from repo
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME clone git@github.com:cwebster2/dotfiles.git "${HOME}/.dotfiles"
	fi

	# enable dbus for the user session
	# systemctl --user enable dbus.socket

	cd "$HOME"
	)

	install_vim;
  install_emacs;
  install_zsh;
}

install_vim() {
	# create subshell
	(
	cd "$HOME"

	# install .vim files
	sudo rm -rf "${HOME}/.vim"
	git clone --recursive git@github.com:cwebster2/vim.git "${HOME}/.vim"
	(
	cd "${HOME}/.vim"
	)

	# update alternatives to vim
	sudo update-alternatives --install /usr/bin/vi vi "$(command -v nvim)" 60
	sudo update-alternatives --config vi
	sudo update-alternatives --install /usr/bin/vi vi "$(command -v nvim)" 60
	sudo update-alternatives --config vi
	sudo update-alternatives --install /usr/bin/editor editor "$(command -v nvim)" 60
	sudo update-alternatives --config editor
	)
}

install_emacs() {
  (
    cd "$HOME"
    sudo rm -rf "${HOME}/.emacs.d"
    git clone  --recursive git@github.com:cwebster2/.emacs.d.git "${HOME}/.emacs.d"
  )
}

install_zsh() {
  (
    chsh -s "$(command -v zsh)"
    cd "$HOME"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  )
}
install_tools() {
	echo "Installing golang..."
	echo
	install_golang;

	echo
	echo "Installing rust..."
	echo
	install_rust;

	echo
	echo "Installing scripts..."
	echo
	sudo install.sh scripts;
}

usage() {
	echo -e "install.sh\\n\\tThis script installs my basic setup for a debian laptop\\n"
	echo "Usage:"
	echo "  base                                - setup sources & install base pkgs"
	echo "  basemin                             - setup sources & install base min pkgs"
	echo "  graphics {intel, geforce, optimus}  - install graphics drivers"
	echo "  wm                                  - install window manager/desktop pkgs"
	echo "  dotfiles                            - get dotfiles"
	echo "  vim                                 - install vim specific dotfiles"
	echo "  golang                              - install golang and packages"
	echo "  rust                                - install rust"
	echo "  scripts                             - install scripts"
	echo "  tools                               - install golang, rust, and scripts"
}

main() {
	local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

	if [[ $cmd == "base" ]]; then
		check_is_sudo
		get_user

		# setup /etc/apt/sources.list
		setup_sources

		base
	elif [[ $cmd == "basemin" ]]; then
		check_is_sudo
		get_user

		# setup /etc/apt/sources.list
		setup_sources_min

		base_min
	elif [[ $cmd == "graphics" ]]; then
		check_is_sudo

		install_graphics "$2"
	elif [[ $cmd == "wm" ]]; then
		check_is_sudo

		install_wmapps
	elif [[ $cmd == "dotfiles" ]]; then
		get_user
		get_dotfiles
	elif [[ $cmd == "vim" ]]; then
		install_vim
	elif [[ $cmd == "rust" ]]; then
		install_rust
	elif [[ $cmd == "golang" ]]; then
		install_golang "$2"
	elif [[ $cmd == "scripts" ]]; then
		install_scripts
	elif [[ $cmd == "tools" ]]; then
		install_tools
	elif [[ $cmd == "dropbear" ]]; then
		check_is_sudo

		get_user

		install_dropbear
	else
		usage
	fi
}

main "$@"
