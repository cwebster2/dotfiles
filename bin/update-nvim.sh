#!/usr/bin/env bash
NVIM_GIT_DIR=$HOME/src/neovim

if [ ! -d "${NVIM_GIT_DIR}" ]; then
  echo "Cloning neovim"
  mkdir -p $(dirname "${NVIM_GIT_DIR}")
  pushd $(dirname "${NVIM_GIT_DIR}") 2>/dev/null
  git clone git@github.com:neovim/neovim $(basename "${NVIM_GIT_DIR}")
  popd 2>/dev/null || exit
else
  echo "Pulling latest neovim"
  pushd "${NVIM_GIT_DIR}" 2>/dev/null || exit
  git checkout master
  # git checkout tags/nightly
  git pull
  popd 2>/dev/null || exit
fi

pushd "${NVIM_GIT_DIR}" 2>/dev/null || exit
make \
  CMAKE_INSTALL_PREFIX="$HOME"/.local/ \
  CMAKE_BUILD_TYPE=RelWithDebInfo \
  -j 8
make install
popd 2>/dev/null || exit

command -v nvim
nvim --version | head -1
