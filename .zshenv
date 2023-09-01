for file in ~/.env.d/zshenv.d/*; do
  source "$file"
done
. "$HOME/.cargo/env"

alias assume="source assume"
