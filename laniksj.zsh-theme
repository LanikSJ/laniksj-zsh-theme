# Based on the great ys theme (http://ysmood.org/wp/2013/03/my-ys-terminal-theme/)
# Honukai ZSH Theme: https://github.com/oskarkrawczyk/honukai-iterm-zsh
# and K8s Prompt: https://github.com/jonmosco/kube-ps1

# Kubernetes prompt function
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
%{$fg[red]%}\$(kube_ps1_prompt)%{$reset_color%}%{$fg[cyan]%}\$(git_prompt_info)%{$reset_color%}
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%}"
}

kubeoff() {
    KUBE_PS1_ENABLED=off
    PROMPT=$'\n'"%{$terminfo[bold]$fg[white]%}%* %{$reset_color%} \
%{$fg[cyan]%}%n \
%{$fg[green]%}%m \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%} \
%{$fg[cyan]%}\$(git_prompt_info)%{$reset_color%}
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

# Initialize Kubernetes prompt variables
prompt_kube_context=""
prompt_kube_namespace=""

# Function to update Kubernetes context and namespace dynamically
kube_ps1_update() {
    prompt_kube_context=""
    prompt_kube_namespace=""
    if [[ "${KUBE_PS1_ENABLED}" == "on" ]] && command -v kubectl &> /dev/null; then
        prompt_kube_context=$(kubectl config current-context 2>/dev/null)
        if [[ -n "${prompt_kube_context}" ]]; then
            prompt_kube_namespace=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null)
            prompt_kube_namespace=${prompt_kube_namespace:-default}
        fi
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
