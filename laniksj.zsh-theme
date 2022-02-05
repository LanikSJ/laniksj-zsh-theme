# Based on the great ys theme (http://ysmood.org/wp/2013/03/my-ys-terminal-theme/)
# and Honukai ZSH Theme: https://github.com/oskarkrawczyk/honukai-iterm-zsh

# Machine name.
function hostname {
    echo $HOST
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$fg[white]%}%{$reset_color%}"
YS_VCS_PROMPT_PREFIX2="%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}✖︎"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}●"

# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# Prompt format: \n # USER MACHINE DIRECTORY git:BRANCH STATE [TIME] \n $
PROMPT="
%{$terminfo[bold]$fg[white]%}%* $reset_color% \
%{$fg[cyan]%}%n \
%{$fg[green]%}$(hostname) \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${git_info}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"

if [[ "$USER" == "root" ]]; then
PROMPT="
%{$terminfo[bold]$fg[white]%}%* $reset_color% \
%{$bg[yellow]%}%{$fg[cyan]%}%n%{$reset_color%} \
%{$fg[green]%}$(hostname) \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${git_info}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
fi
