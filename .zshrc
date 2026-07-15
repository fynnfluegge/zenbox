# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

KEYTIMEOUT=100

export ZSH="$HOME/.zsh"
export ZSH_CUSTOM="$ZSH/custom"

# completion cache file path
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$USER

# ranger preview highlight style
export HIGHLIGHT_STYLE=dusk

# ranger open file with nvim
export VISUAL=nvim;
export EDITOR=nvim;

# ----- theme and styling ----- #
P10K_PATH="$HOME/.p10k.zsh"
# Check if the p10k.zsh file exists
if [[ -f $P10K_PATH ]]; then
    source $P10K_PATH
    ZSH_THEME="powerlevel10k/powerlevel10k"
else
    # Enable starship shell
    # eval "$(starship init zsh)"
    ZSH_THEME="awesomepanda"
fi

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
 # zsh-vi-mode
)
# ----------------- #

source $ZSH/oh-my-zsh.sh

# Enable fzf shell
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
[ -f $HOME/.fzf/fzf-git.sh/fzf-git.sh ] && source $HOME/.fzf/fzf-git.sh/fzf-git.sh

# Enable open vs code from terminal
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

if [ ! -L "$HOME/Library/Application Support/Code/User/settings.json" ]; then
 ln -s \
   $HOME/.config/vscode/settings.json \
   $HOME/Library/Application\ Support/Code/User/settings.json
fi
if [ ! -L "$HOME/Library/Application Support/Code/User/keybindings.json" ]; then
 ln -s \
   $HOME/.config/vscode/keybindings.json \
   $HOME/Library/Application\ Support/Code/User/keybindings.json
fi

# Enable zoxide shell
eval "$(zoxide init zsh)"

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

# aliases
alias vz="nvim ~/.zshrc"
alias sz="source ~/.zshrc"
alias nv="nvim"
# alias rr="pipx run --spec ranger-fm ranger"
alias rr="ranger"
alias rrzsh="f(){ rr --selectfile=$HOME/.zsh/.git };f"
alias rrconfig="f(){ rr --selectfile=$HOME/.config/ranger };f"
alias fb=$HOME/.scripts/fzfbookmarks.sh
alias ls="eza --icons=always"
alias ta="tmux attach -t"
alias tl='tmux list-sessions'
alias tn='tmux new-session -s $(basename "$PWD")'
alias gitmergeconflicts="git mergetool --no-prompt --tool=vimdiff"
alias c="clear"

[ -f $HOME/.zcustomaliases ] && source $HOME/.zcustomaliases
