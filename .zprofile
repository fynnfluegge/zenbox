# This only gets loaded on Login-Shell
# .zshenv -> .zprofile -> .zshrc

# MacPorts Installer addition on 2023-06-15_at_11:59:04: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# Suggested by error message:
# Found pyenv, but it is badly configured (missing pyenv shims in $PATH). pyenv might not
# work correctly for non-interactive shells (for example, when run from a script).
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Add conda to PATH
export PATH="/opt/miniforge/bin:$PATH"

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export PATH="/usr/local/opt/llvm/bin:$PATH"

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Created by `pipx` on 2023-12-10 18:10:42
export PATH="$PATH:$HOME/.local/bin"

# Added by Docker Desktop
[ -f $HOME/.docker/init-zsh.sh ] && source $HOME/.docker/init-zsh.sh || true

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$HOME/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "$HOME/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

