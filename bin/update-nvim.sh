#!/usr/bin/env bash
NVIM_GIT_DIR=$HOME/src/neovim

if [ ! -d "${NVIM_GIT_DIR}" ]; then
  echo "Cloning neovim"
  mkdir -p $(dirname "${NVIM_GIT_DIR}")
  pushd $(dirname "${NVIM_GIT_DIR}") 2>/dev/null
  git clone git@github.com:neovim/neovim $(basename "${NVIM_GIT_DIR}")
  popd 2>/dev/null
else
  echo "Pulling latest neovim"
  pushd "${NVIM_GIT_DIR}" 2>/dev/null
  git pull
  popd 2>/dev/null
fi

pushd "${NVIM_GIT_DIR}" 2>/dev/null
make \
  CMAKE_INSTALL_PREFIX="$HOME"/.local/ \
  CMAKE_BUILD_TYPE=RelWithDebInfo \
  -j 8
make install
popd 2>/dev/null

which nvim
nvim --version | head -1
