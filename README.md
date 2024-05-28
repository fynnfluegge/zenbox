## A zenful dev environment with tools for 10x productivity

<div align="center">
  <img width="640" src="https://github.com/fynnfluegge/zendevenv/assets/16321871/4ea2ecb5-d186-4b54-bef3-879b40fc7587">
</div>

## Tools

- [tmux](https://github.com/tmux/tmux)
- [neovim](https://github.com/neovim/neovim)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [fzf](https://github.com/junegunn/fzf)
- [delta](https://github.com/dandavison/delta)
- [eza](https://github.com/eza-community/eza)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [ranger](https://github.com/ranger/ranger)
- [pyenv](https://github.com/pyenv/pyenv)
  - with Python 3.12
- [nvm](https://github.com/nvm-sh/nvm)
  - with Node 20
- [cargo](https://github.com/rust-lang/cargo)
  - with latest Rust

## Run dev environment with docker

#### Build docker image

```
docker build -t my-dev-environment .
```

#### Start docker container

```
docker run --privileged -it -p 2375:2375 --name dev-container my-dev-environment
```

#### Reconnect to docker container

```
docker restart dev-container && docker attach dev-container
```
