FROM ubuntu:24.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root
ENV ZSH $HOME/.zsh
ENV ZSH_CUSTOM $ZSH/custom
ENV PYTHON_VERSION 3.11.5
ENV NODE_VERSION 20

RUN apt-get update && apt-get install -y \
    curl \
    git \
    neovim \
    zsh \
    build-essential \
    wget \
    unzip \
    tar \
    jq \
    sudo

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

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone your Neovim configuration from GitHub
RUN git clone https://github.com/fynnfluegge/nvim.config $HOME/.config/nvim

# Change the default shell to zsh for the root user
RUN chsh -s $(which zsh)
SHELL ["/bin/zsh", "-c"]


# Install Oh My Zsh with plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/conda-incubator/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
RUN git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

# Install tpm
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

# Install pyenv
RUN curl https://pyenv.run | zsh

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Add dotfiles
COPY .config $HOME/.config
COPY .scripts $HOME/.scripts
COPY .zshrc $HOME/.zshrc
COPY .zprofile $HOME/.zprofile

# Install Python and set the global version to $PYTHON_VERSION
RUN source $HOME/.zprofile && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

# Install Node and set the global version to $NODE_VERSION
RUN source $HOME/.zprofile && nvm install $NODE_VERSION && nvm use $NODE_VERSION

# Ensure pip is installed and upgrade it
RUN pip3 install --upgrade pip --break-system-packages

# Ensure pipx is installed
RUN pipx ensurepath

# Install Ranger using pipx
RUN pipx install ranger-fm

# Fetch and install the latest version of LazyDocker
RUN LAZYDOCKER_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | \
    jq -r '.tag_name' | \
    sed 's/^v//') \
    && curl -L https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz -o lazydocker.tar.gz \
    && tar -xf lazydocker.tar.gz \
    && mv lazydocker /usr/local/bin/ \
    && rm lazydocker.tar.gz

# Fetch and install the latest version of LazyGit
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | \
    jq -r '.tag_name' | \
    sed 's/^v//') \
    && curl -L https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz -o lazygit.tar.gz \
    && tar -xf lazygit.tar.gz \
    && mv lazygit /usr/local/bin/ \
    && rm lazygit.tar.gz

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

# Add tmux configuration file
RUN echo 'set -g @plugin "tmux-plugins/tpm"' >> ~/.tmux.conf && \
    echo 'set -g @plugin "tmux-plugins/tmux-sensible"' >> ~/.tmux.conf && \
    echo 'run -b "~/.tmux/plugins/tpm/tpm"' >> ~/.tmux.conf && \
    echo 'source-file ~/.config/tmux/tmux.conf' >> ~/.tmux.conf

# Script to start tmux and install plugins
RUN echo '#!/bin/bash\n' > install_plugins.sh && \
    echo 'tmux new-session -d -s install_tmux_plugins' >> install_plugins.sh && \
    echo 'sleep 1' >> install_plugins.sh && \
    echo '~/.tmux/plugins/tpm/bin/install_plugins' >> install_plugins.sh && \
    echo 'tmux kill-session -t install_tmux_plugins' >> install_plugins.sh && \
    chmod +x install_plugins.sh

# Run and delete the tmux plugin install script
RUN ./install_plugins.sh
RUN rm ./install_plugins.sh

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
