#!/usr/bin/env bash

mv ~/bin/nvim.appimage ~/bin/nvim.appimage.old
curl -sfLo ~/bin/nvim.appimage https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod 755 ~/bin/nvim.appimage
nvim --version | head -1
~/bin/install.sh update-npm-things
