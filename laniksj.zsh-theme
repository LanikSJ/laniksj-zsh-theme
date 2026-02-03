# Based on the great ys theme (http://ysmood.org/wp/2013/03/my-ys-terminal-theme/)
# Honukai ZSH Theme: https://github.com/oskarkrawczyk/honukai-iterm-zsh
# K8s Prompt: https://github.com/jonmosco/kube-ps1

# Performance optimization: Git status caching
_git_status_cache=""
_git_status_last_dir=""
_git_status_last_time=0
_git_status_cache_timeout=5  # seconds

# Cached git prompt function for better performance
git_prompt() {
    local current_dir=$(pwd)
    local current_time=$(date +%s)

    # Check if we need to refresh cache
    if [[ "$current_dir" != "$_git_status_last_dir" ]] || \
       (( current_time - _git_status_last_time > _git_status_cache_timeout )); then

        if git rev-parse --git-dir >/dev/null 2>&1; then
            local git_status
            git_status=$(git_prompt_info 2>/dev/null)
            _git_status_cache="$git_status"
        else
            _git_status_cache=""
        fi

        _git_status_last_dir="$current_dir"
        _git_status_last_time="$current_time"
    fi

    echo "$_git_status_cache"
}

# Kubernetes prompt function with error handling
kube_ps1_prompt() {
    [[ -n "${prompt_kube_context}" ]] && echo "${prompt_kube_context}:${prompt_kube_namespace}"
}

# Kubernetes prompt functions
kubeon() {
    KUBE_PS1_ENABLED=on
    PROMPT=$'\n'"%{$terminfo[bold]$fg[white]%}%* %{$reset_color%} \
%{$fg[cyan]%}%n \
%{$fg[green]%}%m \
%{$terminfo[bold]$fg[yellow]%}%~
%{$reset_color%} \
%{$fg[red]%}\$(kube_ps1_prompt)%{$reset_color%}%{$fg[cyan]%}\$(git_prompt)%{$reset_color%}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
}

kubeoff() {
    KUBE_PS1_ENABLED=off
    PROMPT=$'\n'"%{$terminfo[bold]$fg[white]%}%* %{$reset_color%} \
%{$fg[cyan]%}%n \
%{$fg[green]%}%m \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%} \
%{$fg[cyan]%}\$(git_prompt)%{$reset_color%}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
}

# VCS configuration
YS_VCS_PROMPT_PREFIX1="%{${fg[white]}%}%{${reset_color}%}"
YS_VCS_PROMPT_PREFIX2="%{${fg[cyan]}%}"
YS_VCS_PROMPT_SUFFIX="%{${reset_color}%}"
YS_VCS_PROMPT_DIRTY=" %{${fg[red]}%}✖︎"
YS_VCS_PROMPT_CLEAN=" %{${fg[green]}%}●"

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${YS_VCS_PROMPT_SUFFIX}"
ZSH_THEME_GIT_PROMPT_DIRTY="${YS_VCS_PROMPT_DIRTY}"
ZSH_THEME_GIT_PROMPT_CLEAN="${YS_VCS_PROMPT_CLEAN}"

# Git prompt functions
git_prompt_info() {
    local ref
    ref=$(git symbolic-ref HEAD 2>/dev/null) || \
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

parse_git_dirty() {
    local STATUS=''
    local -a FLAGS
    FLAGS=('--porcelain')
    if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
        if [[ $POST_1_7_2_GIT -gt 0 ]]; then
            FLAGS+='--ignore-submodules=dirty'
        fi
        if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
            FLAGS+='--untracked-files=no'
        fi
        STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
    fi
    if [[ -n $STATUS ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}
# Initialize Kubernetes prompt variables
prompt_kube_context=""
prompt_kube_namespace=""

# Function to update Kubernetes context and namespace dynamically with enhanced error handling
kube_ps1_update() {
    prompt_kube_context=""
    prompt_kube_namespace=""

    # Check if kubectl is available and K8s is enabled
    if [[ "${KUBE_PS1_ENABLED}" != "on" ]] || ! command -v kubectl &> /dev/null; then
        return 0
    fi

    # Try to get current context with timeout and error handling
    local kubectl_timeout=2
    local context_cmd="kubectl config current-context"
    local namespace_cmd="kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}'"

    # Get context with fallback
    if prompt_kube_context=$(timeout $kubectl_timeout bash -c "$context_cmd" 2>/dev/null); then
        # Only try to get namespace if we have a valid context
        if [[ -n "${prompt_kube_context}" ]]; then
            if ! prompt_kube_namespace=$(timeout $kubectl_timeout bash -c "$namespace_cmd" 2>/dev/null); then
                prompt_kube_namespace="default"  # fallback if namespace query fails
            fi
            prompt_kube_namespace=${prompt_kube_namespace:-default}
        fi
    else
        # kubectl command failed entirely - disable k8s prompt temporarily
        prompt_kube_context=""
        prompt_kube_namespace=""
    fi
}

# Initialize prompt based on KUBE_PS1_ENABLED
if [[ -z "${KUBE_PS1_ENABLED}" ]] || [[ "${KUBE_PS1_ENABLED}" == "off" ]]; then
    kubeoff
else
    kube_ps1_update  # Initial update
    kubeon
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd kube_ps1_update
fi
