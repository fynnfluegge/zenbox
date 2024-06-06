<div align="center">
  
# A zenful dev environment with tools for 10x productivity
  
<img width="640" src="https://github.com/fynnfluegge/zendevenv/assets/16321871/4ea2ecb5-d186-4b54-bef3-879b40fc7587">
  
[![Publish Docker image](https://github.com/fynnfluegge/zenbox/actions/workflows/publish-docker-image.yml/badge.svg)](https://github.com/fynnfluegge/zenbox/actions/workflows/publish-docker-image.yml)
  
</div>

## Preinstalled tools

- [tmux](https://github.com/tmux/tmux)
  - [tpm](https://github.com/tmux-plugins/tpm)
  - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
  - [tmux-vim-navigator](https://github.com/christoomey/vim-tmux-navigator)
  - [tmux-yank](https://github.com/tmux-plugins/tmux-yank)
- [neovim](https://github.com/neovim/neovim)
  - [nvim.config](https://github.com/fynnfluegge/nvim.config)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [nvm](https://github.com/nvm-sh/nvm) with npm and Node 20
- [cargo](https://github.com/rust-lang/cargo) with latest Rust
- [pyenv](https://github.com/pyenv/pyenv) with Python 3.12
- [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
- [conda-miniforge](https://github.com/conda-forge/miniforge)
- [poetry](https://github.com/python-poetry/poetry)
- [fzf](https://github.com/junegunn/fzf)
- [ranger](https://github.com/ranger/ranger)
- [delta](https://github.com/dandavison/delta)
- [eza](https://github.com/eza-community/eza)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

## Run dev environment with docker

#### Download docker image

```
docker image pull fynnfluegge/zenbox:latest
```

#### Build docker image from source

```
git clone https://github.com/fynnfluegge/zenbox
cd zenbox && docker build -t fynnfluegge/zenbox:latest .
```

#### Start docker container

```
docker run --privileged -it -p 2375:2375 --name zenbox fynnfluegge/zenbox:latest
```

#### Reconnect to docker container

```
docker restart zenbox && docker attach zenbox
```
