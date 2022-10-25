FROM env-install:arch-v1

USER casey
WORKDIR /home/casey

RUN mkdir -p bin
COPY bin/env-manager bin/env-manager

RUN bin/env-manager dotfiles
SHELL ["/bin/zsh", "-i", "-c"]
RUN bin/env-manager tools
RUN bin/env-manager vim
# RUN bin/env-manager emacs
