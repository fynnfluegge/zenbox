# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages including curl, git, and Neovim
RUN apt-get update && apt-get install -y \
    curl \
    git \
    neovim \
    build-essential \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone  https://github.com/fynnfluegge/myDotfiles ./myDotfiles
RUN cp -r ./myDotfiles/.config ~/.config
RUN cp -r ./myDotfiles/.scripts ~/.scripts
RUN cp -r ./myDotfiles/.zshrc ~/.zshrc
RUN cp -r ./myDotfiles/.zprofile ~/.zprofile
RUN cp -r ./myDotfiles/.p10k.zsh ~/.p10k.zsh

# Install additional CLI tools
RUN apt-get update && apt-get install -y \
    htop \
    tree \
    tmux \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Clone your Neovim configuration from GitHub
RUN git clone  https://github.com/fynnfluegge/nvim.config ~/.config/nvim

# Set the default command to run Neovim
CMD ["nvim"]
