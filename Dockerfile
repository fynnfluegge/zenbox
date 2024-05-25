FROM ubuntu:24.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root
ENV ZSH_CUSTOM $HOME/.zsh
ENV PYTHON_VERSION 3.11.5

# Install necessary packages including curl, git, and Neovim
RUN apt-get update && apt-get install -y \
    curl \
    git \
    neovim \
    zsh \
    build-essential \
    wget \
    unzip \
    sudo

# Install additional CLI tools
RUN apt-get update && apt-get install -y \
    htop \
    tree \
    tmux \
    fzf

RUN apt-get update && apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    python3-pip \
    pipx

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone your Neovim configuration from GitHub
RUN git clone https://github.com/fynnfluegge/nvim.config $HOME/.config/nvim

# Change the default shell to zsh for the root user
RUN chsh -s $(which zsh)

# Copu dotfiles to the container
COPY .config $HOME/.config
COPY .scripts $HOME/.scripts
COPY .zshrc $HOME/.zshrc
COPY .zprofile $HOME/.zprofile

# Install Oh My Zsh with plugins
ENV ZSH $HOME/.zsh
ENV ZSH_CUSTOM $ZSH/custom

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/conda-incubator/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion

# Install pyenv
RUN curl https://pyenv.run | zsh

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install Python and set the global version to $PYTHON_VERSION
SHELL ["/bin/zsh", "-c"]
RUN source $HOME/.zprofile && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

ENV NODE_VERSION 20
SHELL ["/bin/zsh", "-c"]
RUN source $HOME/.zprofile && nvm install $NODE_VERSION && nvm use $NODE_VERSION

# Ensure pip is installed and upgrade it
RUN pip3 install --upgrade pip --break-system-packages

# Ensure pipx is installed
RUN pipx ensurepath

# Install Ranger using pipx
RUN pipx install ranger-fm

# Ensure that .zprofile and .zshrc are sourced when starting the container
SHELL ["/bin/zsh", "-c"]
CMD ["zsh", "-c", "cd root && source $HOME/.zprofile && source $HOME/.zshrc && exec zsh -i && cd root"]
