#!/usr/bin/env bash

set -e

NVIM_GIT_DIR=$HOME/src/neovim

if [ ! -d "${NVIM_GIT_DIR}" ]; then
  echo "Cloning neovim"
  mkdir -p $(dirname "${NVIM_GIT_DIR}")
  pushd $(dirname "${NVIM_GIT_DIR}") 2>/dev/null
  git clone https://github.com/neovim/neovim $(basename "${NVIM_GIT_DIR}")
  popd 2>/dev/null || exit
else
  echo "Pulling latest neovim"
  pushd "${NVIM_GIT_DIR}" 2>/dev/null || exit
  CURRENT_SHA=$(git rev-parse HEAD)
  # git checkout master
  git checkout release-0.10
  # git checkout tags/nightly
  git pull
  NEW_SHA=$(git rev-parse HEAD)
  if [ "$CURRENT_SHA" != "$NEW_SHA" ]; then
    echo "New neovim version found, cleaning up"
    make distclean
  fi
  popd 2>/dev/null || exit
  if [ "$CURRENT_SHA" == "$NEW_SHA" ]; then
    echo "neovim already up to date"
    echo "SHA: $CURRENT_SHA"
    nvim --version | head -1
    exit 0
  fi
fi

pushd "${NVIM_GIT_DIR}" 2>/dev/null || exit
make \
  CMAKE_INSTALL_PREFIX="$HOME"/.local/ \
  CMAKE_BUILD_TYPE=RelWithDebInfo \
  -j 8
rm -rf "$HOME"/.local/share/nvim/runtime
make install
popd 2>/dev/null || exit

command -v nvim
nvim --version | head -1
