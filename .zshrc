# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# aliases
alias vz="nvim ~/.zshrc"
alias sz="source ~/.zshrc"
alias nv="nvim"
alias rr="ranger"
alias rrzsh="f(){ rr --selectfile=$HOME/.zsh/.git };f"
alias rrconfig="f(){ rr --selectfile=$HOME/.config/ranger };f"
alias fb=$HOME/.scripts/fzfbookmarks.sh

export ZSH="$HOME/.zsh"

# completion cache file path
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$USER

# ranger preview highlight style
export HIGHLIGHT_STYLE=dusk

# ranger open file with nvim
export VISUAL=nvim;
export EDITOR=nvim;

# ----- theme and styling ----- #
ZSH_THEME="powerlevel10k"

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=10,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=10,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=10,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=10
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=220
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=220
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=226
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=226

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=12
ZSH_AUTOSUGGEST_STRATEGY=(history)
# ----------------------------- #

# ---- plugins ---- #
plugins=(
 aws
 git
 docker
 docker-compose
 kubectl
 python
 zsh-syntax-highlighting
 zsh-autosuggestions
)
# ----------------- #

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm plugin
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# add pip bin to PATH
export PATH="$PATH:$HOME/Library/Python/3.9/bin"

# Added by Docker Desktop
source /Users/fynn/.docker/init-zsh.sh || true

source "$HOME/.cargo/env"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
