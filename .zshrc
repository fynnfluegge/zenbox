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
 pyenv
 poetry
 zsh-syntax-highlighting
 zsh-autosuggestions
 conda-zsh-completion
)
# ----------------- #

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm plugin
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Added by Docker Desktop
source /Users/fynn/.docker/init-zsh.sh || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# only show last dir in prompt
# function zsh_directory_name() {
#   emulate -L zsh
#   [[ $1 == d ]] || return
#   while [[ $2 != / ]]; do
#     if [[ -e $2/.git ]]; then
#       typeset -ga reply=(${2:t} $#2)
#       return
#     fi
#     2=${2:h}
#   done
#   return 1
# }


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/fynn/.pyenv/versions/miniconda3-3.11-23.5.2-0/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/fynn/.pyenv/versions/miniconda3-3.11-23.5.2-0/etc/profile.d/conda.sh" ]; then
        . "/Users/fynn/.pyenv/versions/miniconda3-3.11-23.5.2-0/etc/profile.d/conda.sh"
    else
        export PATH="/Users/fynn/.pyenv/versions/miniconda3-3.11-23.5.2-0/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
