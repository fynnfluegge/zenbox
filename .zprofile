# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

# MacPorts Installer addition on 2023-06-15_at_11:59:04: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# Suggested by error message:
# Found pyenv, but it is badly configured (missing pyenv shims in $PATH). pyenv might not
# work correctly for non-interactive shells (for example, when run from a script).
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"


export PATH="/usr/local/opt/llvm/bin:$PATH"

source "$HOME/.cargo/env"

# Created by `pipx` on 2023-12-10 18:10:42
export PATH="$PATH:$HOME/.local/bin"
