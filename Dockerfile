FROM ubuntu:20.04

# Set environment variables to non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

RUN cp -r .config ~/.config
RUN cp -r .scripts ~/.scripts
RUN cp -r .zshrc ~/.zshrc
RUN cp -r .zprofile ~/.zprofile

# Install necessary packages including curl, git, and Neovim
RUN apt-get update && apt-get install -y \
    curl \
    git \
    neovim \
    zsh \
    build-essential \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install additional CLI tools
RUN apt-get update && apt-get install -y \
    htop \
    tree \
    tmux \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Clone your Neovim configuration from GitHub
RUN git clone  https://github.com/fynnfluegge/nvim.config ~/.config/nvim

# Change the default shell to zsh for the root user
RUN chsh -s $(which zsh)

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/conda-incubator/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

RUN cp -r .p10k.zsh ~/.p10k.zsh

# Set the default command to run Neovim
CMD ["nvim"]
