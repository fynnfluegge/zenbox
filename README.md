## A zenful dev environment with tools for 10x productivity

<div align="center">
  <img width="640" src="https://github.com/fynnfluegge/zendevenv/assets/16321871/4ea2ecb5-d186-4b54-bef3-879b40fc7587">
</div>

## Tools

- [tmux](https://github.com/tmux/tmux)
  - [tpm](https://github.com/tmux-plugins/tpm)
  - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
  - [tmux-vim-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [neovim](https://github.com/neovim/neovim)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [pyenv](https://github.com/pyenv/pyenv) with Python 3.12
- [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
- [conda-miniforge](https://github.com/conda-forge/miniforge)
- [poetry](https://github.com/python-poetry/poetry)
- [nvm](https://github.com/nvm-sh/nvm) with npm and Node 20
- [cargo](https://github.com/rust-lang/cargo) with latest Rust
- [fzf](https://github.com/junegunn/fzf)
- [ranger](https://github.com/ranger/ranger)
- [delta](https://github.com/dandavison/delta)
- [eza](https://github.com/eza-community/eza)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

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
