FROM ubuntu:24.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root
ENV ZSH $HOME/.zsh
ENV ZSH_CUSTOM $ZSH/custom
ENV PYTHON_VERSION 3.12
ENV NODE_VERSION 20

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    wget \
    unzip \
    tar \
    sudo \
    htop \
    tree \
    gpg

RUN apt-get update && apt-get install -y \
    tmux \
    neovim \
    zsh \
    jq \
    bat \
    fd-find \
    ripgrep

RUN apt-get update && apt-get install -y \
    locales-all \
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
    pipx

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Change the default shell to zsh for the root user
RUN chsh -s $(which zsh)
SHELL ["/bin/zsh", "-c"]

RUN mkdir -p $HOME/.local/bin

# ------------------- Install fzf ------------------- #
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install

# create a symbolic link to bat and fd
RUN ln -s /usr/bin/batcat $HOME/.local/bin/bat
RUN ln -s /usr/bin/fdfind $HOME/.local/bin/fd

# ------------------- Install Docker ------------------- #
# Add Docker’s official GPG key and set up the stable repository
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Install Docker
RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    && rm -rf /var/lib/apt/lists/*
# -------------------------------------------------------- #

# Clone Neovim configuration from GitHub
RUN git clone https://github.com/fynnfluegge/nvim.config $HOME/.config/nvim

# ------------------- Install Oh My Zsh ------------------- #
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Download plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/conda-incubator/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
RUN git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

# Install starship prompt
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# Add dotfiles
COPY .config $HOME/.config
COPY .scripts $HOME/.scripts
COPY .zshrc $HOME/.zshrc
COPY .zprofile $HOME/.zprofile

RUN chmod +x $HOME/.scripts/*

# ------------------- Install pyenv ------------------- #
RUN curl https://pyenv.run | zsh
# Check if pyenv-virtualenv is installed and install if not
RUN zsh -c 'source $HOME/.zprofile && pyenv virtualenvs' || \
    (git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv && \
    zsh -c 'source $HOME/.zprofile && pyenv virtualenvs')
# Verify installation
RUN zsh -c 'source $HOME/.zprofile && pyenv --version && pyenv virtualenvs'

# ------------------- Install nvm ------------------- #
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# ---------------- Install tmux ---------------- #
# Download tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

# Add tmux configuration file
RUN echo 'set -g @plugin "tmux-plugins/tpm"' >> $HOME/.tmux.conf && \
    echo 'set -g @plugin "tmux-plugins/tmux-sensible"' >> $HOME/.tmux.conf && \
    echo 'run -b "$HOME/.tmux/plugins/tpm/tpm"' >> $HOME/.tmux.conf && \
    echo 'source-file $HOME/.config/tmux/tmux.conf' >> $HOME/.tmux.conf

# Script to start tmux and install plugins
RUN echo '#!/bin/bash\n' > install_plugins.sh && \
    echo 'tmux new-session -d -s install_tmux_plugins' >> install_plugins.sh && \
    echo 'sleep 1' >> install_plugins.sh && \
    echo '$HOME/.tmux/plugins/tpm/bin/install_plugins' >> install_plugins.sh && \
    echo 'tmux kill-session -t install_tmux_plugins' >> install_plugins.sh && \
    chmod +x install_plugins.sh

# Run and delete the tmux plugin install script
RUN ./install_plugins.sh
RUN rm ./install_plugins.sh
RUN rm $HOME/.tmux.conf
# ----------------------------------------------- #

# Install Python and set the global version to $PYTHON_VERSION
RUN source $HOME/.zprofile && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

# ------------------- Install Miniforge ------------------- #
# Detect architecture and download the corresponding Miniforge installer
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    wget $MINIFORGE_URL -O Miniforge3-Linux.sh && \
    bash Miniforge3-Linux.sh -b -p /opt/conda && \
    rm Miniforge3-Linux.sh

# Ensure conda is initialized in the current shell
RUN /bin/zsh -c "/opt/conda/bin/conda init zsh"
# Update Conda
RUN /bin/zsh -c "source /opt/conda/bin/activate && conda update -n base -c conda-forge conda -y"
# -------------------------------------------------------- #

# Install Node and set the global version to $NODE_VERSION
RUN source $HOME/.zprofile && nvm install $NODE_VERSION && nvm use $NODE_VERSION

# Ensure pip is installed and upgrade it
RUN source $HOME/.zprofile && pip3 install --upgrade pip --break-system-packages

# Install tldr
RUN source $HOME/.zprofile && pip3 install tldr

# Ensure pipx is installed
RUN pipx ensurepath

# Install Poetry using pipx
RUN pipx install poetry

# Install Ranger using pipx
RUN pipx install ranger-fm

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# ------------------- Install eza ------------------- #
# Create the keyrings directory and download the GPG key
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

# Add the eza repository
RUN echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list

# Set the correct permissions
RUN chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Update the package list and install eza
RUN apt-get update && apt-get install -y eza

# ------------------- Install delta ------------------- #
# Download and install delta
RUN source $HOME/.cargo/env \
    && git clone https://github.com/dandavison/delta.git /tmp/delta \
    && cd /tmp/delta \
    && cargo build --release \
    && cp target/release/delta /usr/local/bin/ \
    && rm -rf /tmp/delta

RUN touch $HOME/.gitconfig && \
    echo '[core]' >> $HOME/.gitconfig && \
    echo '    pager = delta' >> $HOME/.gitconfig && \
    echo '[interactive]' >> $HOME/.gitconfig && \
    echo '    diffFilter = delta --color-only' >> $HOME/.gitconfig && \
    echo '[delta]' >> $HOME/.gitconfig && \
    echo '    navigate = true' >> $HOME/.gitconfig && \
    echo '[merge]' >> $HOME/.gitconfig && \
    echo '    conflictStyle = diff3' >> $HOME/.gitconfig && \
    echo '[diff]' >> $HOME/.gitconfig && \
    echo '    colorMoved = default' >> $HOME/.gitconfig

# ------------------- Install LazyDocker ------------------- #
RUN LAZYDOCKER_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | \
    jq -r '.tag_name' | \
    sed 's/^v//') \
    && curl -L https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz -o lazydocker.tar.gz \
    && tar -xf lazydocker.tar.gz \
    && mv lazydocker /usr/local/bin/ \
    && rm lazydocker.tar.gz

# ------------------- Install LazyGit ------------------- #
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | \
    jq -r '.tag_name' | \
    sed 's/^v//') \
    && curl -L https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz -o lazygit.tar.gz \
    && tar -xf lazygit.tar.gz \
    && mv lazygit /usr/local/bin/ \
    && rm lazygit.tar.gz

# ------------------- Install zoxide ------------------- #
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose Docker daemon port
EXPOSE 2375

# Ensure that .zprofile and .zshrc are sourced when starting the container
CMD ["zsh", "-c", "\
if [ -e /var/run/docker.pid ]; then \
  sudo rm /var/run/docker.pid; \
fi && \
nohup dockerd > /dev/null 2>&1 & \
cd root && \
source $HOME/.zprofile && \
source $HOME/.zshrc && \
exec zsh -i"]
