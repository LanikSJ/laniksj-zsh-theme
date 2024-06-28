# Based on the great ys theme (http://ysmood.org/wp/2013/03/my-ys-terminal-theme/)
# Honukai ZSH Theme: https://github.com/oskarkrawczyk/honukai-iterm-zsh
# and K8s Prompt: https://github.com/jonmosco/kube-ps1

# Machine name.
function hostname {
    echo $HOST
}

# K8s Prompt On
kubeon() {
    KUBE_PS1_ENABLED=on
    PROMPT="
%{$terminfo[bold]$fg[white]%}%* $reset_color% \
%{$fg[cyan]%}%n \
%{$fg[green]%}$(hostname) \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${fg[red]%} ${ctx}:${namespace}${git_info}   
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
}

# K8s Prompt Off
kubeoff() {
    KUBE_PS1_ENABLED=off
    PROMPT="
%{$terminfo[bold]$fg[white]%}%* $reset_color% \
%{$fg[cyan]%}%n \
%{$fg[green]%}$(hostname) \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${git_info}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
}

# Directory Info
local current_dir='${PWD/#$HOME/~}'

# K8s Current Context Namespace
local ctx='$(kubectl config current-context)'
local namespace='$(kubectl config view --minify -o jsonpath='{..namespace}')'

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$fg[white]%}%{$reset_color%}"
YS_VCS_PROMPT_PREFIX2="%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}✖︎"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}●"

# Git Info
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# Enable K8s Prompt Based on Variable
if [[ -z "$KUBE_PS1_ENABLED" ]] || [[ "$KUBE_PS1_ENABLED"=="off" ]]; then
    kubeoff
    autoload -Uz add-zsh-hook
elif [[ "$KUBE_PS1_ENABLED"=="on" ]]; then
    kubeon
    add-zsh-hook precmd kubeon
    autoload -Uz add-zsh-hook
fi
