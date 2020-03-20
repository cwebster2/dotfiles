## Welcome to my dotfiles

This repo contains dotfiles for my desktop environment.  If you are looking my editing environments,
I keep those in their own repos.

[vim8 / neovim](https://github.com/cwebster2/vim)


[emacs](https://github.com/cwebster2/.emacs.d)


## Try out this environment! (Work in progress)

    docker build -t caseyboxenv:v1 -f .dockerenv/Dockerfile github.com/cwebster2/dotfiles#master:bin

This will take a will take 10-15 minutes to build and may look like it is hanging in places, but it probably isnt. Just give it time.  
Explore it with:

    docker run -it --rm --name caseybox caseyboxenv:v1

This will put you into the container as user "casey".  To customize that, clone the repe and adjust the dockerfile's TARGET_USER env var.
