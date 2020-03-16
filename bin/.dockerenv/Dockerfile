FROM debian:10.3

ENV TARGET_USER casey
ENV DOTFILESBRANCH=master

RUN adduser casey --disabled-password
COPY --chown=$TARGET_USER:$TARGET_USER install-stage0-debian.sh /home/$TARGET_USER/install-stage0.sh
WORKDIR /home/$TARGET_USER
RUN ./install-stage0.sh basemin && \
    ./install-stage0.sh base && \
    ./install-stage0.sh graphics geforce && \
    ./install-stage0.sh wm

USER $TARGET_USER
#temporary
COPY --chown=$TARGET_USER:$TARGET_USER install.sh /home/$TARGET_USER/install.sh
RUN ./install.sh dotfiles
SHELL ["/usr/bin/zsh", "-c"]
# Run an interctive shell to get zsh-nvm to install nvm
RUN ["/usr/bin/zsh", "-i"]
RUN ./install.sh tools

ENTRYPOINT ["/usr/bin/zsh"]
