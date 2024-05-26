### Tools

- [tmux](https://github.com/tmux/tmux)
- [neovim](https://github.com/neovim/neovim)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [ranger](https://github.com/ranger/ranger)
- [pyenv](https://github.com/pyenv/pyenv)
- [nvm](https://github.com/nvm-sh/nvm)

### Run dev environment with docker

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
