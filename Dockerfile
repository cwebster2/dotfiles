FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm zsh git openssh gcc cmake make unzip wget curl sudo gnupg
RUN useradd -m -s /bin/zsh -U -G wheel casey

USER casey
WORKDIR /home/casey

RUN mkdir bin
COPY bin/env-manager bin/env-manager

RUN bin/env-manager dotfiles
SHELL ["/bin/zsh", "-i", "-c"]
RUN bin/env-manager tools
RUN bin/env-manager vim
RUN bin/env-manager emacs
