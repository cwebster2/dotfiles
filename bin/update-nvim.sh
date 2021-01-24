#!/usr/bin/env bash

mv nvim.appimage nvim.appimage.old
curl -fLo nvim.appimage https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod 755 nvim.appimage
